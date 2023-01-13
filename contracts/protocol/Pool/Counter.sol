// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ICounter} from '../../interfaces/ICounter.sol';
import {ICounterAddressesProvider} from '../../interfaces/ICounterAddressesProvider.sol';
import {IPriceOracleGetter} from '../../interfaces/IPriceOracleGetter.sol';
import {IPToken} from '../../interfaces/IPToken.sol';
import {IVariableDebtToken} from '../../interfaces/IVariableDebtToken.sol';
import {ICRT} from '../../CRT/ICRT.sol';
import {CounterStorage} from './CounterStorage.sol';

import {ReserveConfiguration} from '../libraries/configuration/ReserveConfiguration.sol';
import {UserConfiguration} from '../libraries/configuration/UserConfiguration.sol';

import {Errors} from '../libraries/helpers/Errors.sol';
import {Helpers} from '../libraries/helpers/Helpers.sol';
import {CRTLogic} from '../libraries/logic/CRTLogic.sol';
import {ReserveLogic} from '../libraries/logic/ReserveLogic.sol';
import {GenericLogic} from '../libraries/logic/GenericLogic.sol';
import {ValidationLogic} from '../libraries/logic/ValidationLogic.sol';

import {DataTypes} from '../libraries/types/DataTypes.sol';

/**
 * @title Prestare Counter contract
 * @dev Main point of User interaction in Prestare protocol
 * - Users can:
 *   # Deposit
 *   # Withdraw
 *   # Borrow
 *   # Repay
 *   # Liquidate positions
 *   # Execute Flash Loans
 * @author Prestare
 **/

contract Counter is ICounter, CounterStorage {
  using ReserveLogic for DataTypes.ReserveData;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;

  ICounterAddressesProvider public immutable _addressesProvider;

  modifier whenNotPaused() {
    _whenNotPaused();
    _;
  }

  modifier onlyLendingPoolConfigurator() {
    _onlyLendingPoolConfigurator();
    _;
  }

  function _whenNotPaused() internal view {
    require(!_paused, Errors.LP_IS_PAUSED);
  }

  function _onlyLendingPoolConfigurator() internal view {
    require(
      _addressesProvider.getCounterConfigurator() == msg.sender,
      Errors.LP_CALLER_NOT_LENDING_POOL_CONFIGURATOR
    );
  }

  /**
   * @dev Constructor.
   * @param provider The address of the PoolAddressesProvider contract
   */
  constructor(ICounterAddressesProvider provider) {
    _addressesProvider = provider;
  }

  /**
   * @dev Function is invoked by the proxy contract when the Counter contract is added to the
   * CounterAddressesProvider of the market.
   * - Caching the address of the CounterAddressesProvider in order to reduce gas consumption
   *   on subsequent operations
   * @param provider The address of the CounterAddressesProvider
   **/
  function initialize(ICounterAddressesProvider provider) public {
    _flashLoanPremiumTotal = 9;
    _maxNumberOfReserves = 128;
  }

  /**
   * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
   * - E.g. User deposits 100 USDC and gets in return 100 aUSDC
   * @param asset The address of the underlying asset to deposit
   * @param amount The amount to be deposited
   * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user
   *   wants to receive them on his own wallet, or a different address if the beneficiary of aTokens
   *   is a different wallet
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the action is executed directly by the user, without any middle-man
   **/
  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external override whenNotPaused {
    DataTypes.ReserveData storage reserve = _reserves[asset];

    ValidationLogic.validateDeposit(reserve, amount);

    address pToken = reserve.pTokenAddress;

    reserve.updateState();
    reserve.updateInterestRates(asset, pToken, amount, 0);

    IERC20(asset).transferFrom(msg.sender, pToken, amount);

    bool isFirstDeposit = IPToken(pToken).mint(onBehalfOf, amount, reserve.liquidityIndex);

    if (isFirstDeposit) {
      _usersConfig[onBehalfOf].setUsingAsCollateral(reserve.id, true);
      emit ReserveUsedAsCollateralEnabled(asset, onBehalfOf);
    }

    emit Deposit(asset, msg.sender, onBehalfOf, amount, referralCode);
  }

  /**
   * @dev Withdraws an `amount` of underlying asset from the reserve, burning the equivalent pTokens owned
   * @param asset The address of the underlying asset to withdraw
   * @param amount The underlying amount to be withdrawn
   *   - If the value is type(uint256).max which mean withdraw the whole pToken balance
   * @param to Address that will receive the underlying
   * @return The final amount withdrawn
   **/
  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external override whenNotPaused returns (uint256) {
    DataTypes.ReserveData storage reserve = _reserves[asset];

    address pToken = reserve.pTokenAddress;

    uint256 userBalance = IPToken(pToken).balanceOf(msg.sender);

    uint256 amountToWithdraw = amount;

    if (amount == type(uint256).max) {
      amountToWithdraw = userBalance;
    }

    ValidationLogic.validateWithdraw(
      asset,
      amountToWithdraw,
      userBalance,
      _reserves,
      _usersConfig[msg.sender],
      _reservesList,
      _reservesCount,
      _addressesProvider.getPriceOracle()
    );

    reserve.updateState();

    reserve.updateInterestRates(asset, pToken, 0, amountToWithdraw);

    if (amountToWithdraw == userBalance) {
      _usersConfig[msg.sender].setUsingAsCollateral(reserve.id, false);
      emit ReserveUsedAsCollateralDisabled(asset, msg.sender);
    }

    IPToken(pToken).burn(msg.sender, to, amountToWithdraw, reserve.liquidityIndex);

    emit Withdraw(asset, msg.sender, to, amountToWithdraw);

    return amountToWithdraw;
  }

  /**
   * @dev Allows users to borrow a specific `amount` of the reserve underlying asset, provided that the borrower
   * already deposited enough collateral, or he was given enough allowance by a credit delegator on the
   * corresponding debt token (StableDebtToken or VariableDebtToken)
   * - E.g. User borrows 100 USDC passing as `onBehalfOf` his own address, receiving the 100 USDC in his wallet
   *   and 100 stable/variable debt tokens, depending on the `interestRateMode`
   * @param asset The address of the underlying asset to borrow
   * @param amount The amount to be borrowed
   * @param interestRateMode The interest rate mode at which the user wants to borrow: 1 for Stable, 2 for Variable
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the action is executed directly by the user, without any middle-man
   * @param onBehalfOf Address of the user who will receive the debt. Should be the address of the borrower itself
   * calling the function if he wants to borrow against his own collateral, or the address of the credit delegator
   * if he has been given credit delegation allowance
   **/
  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode,
    address onBehalfOf,
    bool crtenable
  ) external override whenNotPaused {
    DataTypes.ReserveData storage reserve = _reserves[asset];

    _executeBorrow(
      ExecuteBorrowParams(
        asset,
        msg.sender,
        onBehalfOf,
        amount,
        interestRateMode,
        reserve.pTokenAddress,
        referralCode,
        true,
        crtenable
      )
    );
  }

  struct ExecuteBorrowParams {
    address asset;
    address user;
    address onBehalfOf;
    uint256 amount;
    uint256 interestRateMode;
    address pTokenAddress;
    uint16 referralCode;
    bool releaseUnderlying;
    bool crtenable;
  }

  function _executeBorrow(ExecuteBorrowParams memory vars) internal {
    DataTypes.ReserveData storage reserve = _reserves[vars.asset];
    DataTypes.UserConfigurationMap storage userConfig = _usersConfig[vars.onBehalfOf];

    address oracle = _addressesProvider.getPriceOracle();

    uint256 amountInETH =
      IPriceOracleGetter(oracle).getAssetPrice(vars.asset) * vars.amount / (
        10**reserve.configuration.getDecimals()
      );
    
    // get User Account Stata
    DataTypes.UserAccountVars memory userStatVar;
    (
      userStatVar.userCollateralBalanceETH,
      userStatVar.userBorrowBalanceETH,
      userStatVar.currentLtv,
      userStatVar.currentLiquidationThreshold,
      userStatVar.healthFactor
    ) = GenericLogic.calculateUserAccountData(
      vars.onBehalfOf,
      _reserves,
      userConfig,
      _reservesList,
      _reservesCount,
      oracle
    );

    uint256 crtamount = 0;
    if (vars.crtenable) {
      crtamount = CRTLogic.calculateCRTBorrow(
        vars.onBehalfOf,
        reserve,
        vars.amount,
        amountInETH,
        userStatVar,
        oracle
      );
    }
    // 审计问题
    // 考虑拆分更仔细
    ValidationLogic.validateBorrow(
      vars.asset,
      reserve,
      vars.onBehalfOf,
      vars.amount,
      amountInETH,
      vars.interestRateMode,
      userStatVar,
      _crtaddress,
      crtamount
    );

    reserve.updateState();

    uint256 currentStableRate = 0;

    bool isFirstBorrowing = false;

    if (vars.crtenable && crtamount != 0) {
        ICRT(_crtaddress).lockCRT(vars.onBehalfOf, crtamount);
    }

    isFirstBorrowing = IVariableDebtToken(reserve.variableDebtTokenAddress).mint(
        vars.user,
        vars.onBehalfOf,
        vars.amount,
        reserve.variableBorrowIndex
    );

    if (isFirstBorrowing) {
      userConfig.setBorrowing(reserve.id, true);
    }

    reserve.updateInterestRates(
      vars.asset,
      vars.pTokenAddress,
      0,
      vars.releaseUnderlying ? vars.amount : 0
    );

    if (vars.releaseUnderlying) {
      IPToken(vars.pTokenAddress).transferUnderlyingTo(vars.user, vars.amount);
    }

    emit Borrow(
      vars.asset,
      vars.user,
      vars.onBehalfOf,
      vars.amount,
      vars.interestRateMode,
      reserve.currentVariableBorrowRate,
      vars.referralCode
    );
  }

  /**
   * @notice Repays a borrowed `amount` on a specific reserve, burning the equivalent debt tokens owned
   * - E.g. User repays 100 USDC, burning 100 variable/stable debt tokens of the `onBehalfOf` address
   * @param asset The address of the borrowed underlying asset previously borrowed
   * @param amount The amount to repay
   * - Send the value type(uint256).max in order to repay the whole debt for `asset` on the specific `debtMode`
   * @param rateMode The interest rate mode at of the debt the user wants to repay: 1 for Stable, 2 for Variable
   * @param onBehalfOf Address of the user who will get his debt reduced/removed. Should be the address of the
   * user calling the function if he wants to reduce/remove his own debt, or the address of any other
   * other borrower whose debt should be removed
   * @return The final amount repaid
   **/
  function repay(
    address asset,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external override whenNotPaused returns (uint256) {
    DataTypes.ReserveData storage reserve = _reserves[asset];

    uint256 variableDebt = Helpers.getUserCurrentDebt(onBehalfOf, reserve);

    DataTypes.InterestRateMode interestRateMode = DataTypes.InterestRateMode(rateMode);

    ValidationLogic.validateRepay(
      reserve,
      amount,
      interestRateMode,
      onBehalfOf,
      variableDebt
    );

    uint256 paybackAmount = variableDebt;

    if (amount < paybackAmount) {
      paybackAmount = amount;
    }
    
    // CRT 
    address oracle = _addressesProvider.getPriceOracle();
    uint256 paybackamountInETH =
      IPriceOracleGetter(oracle).getAssetPrice(asset) * paybackAmount / (
        10**reserve.configuration.getDecimals()
      );
    
    DataTypes.UserAccountVars memory userStatVar;
    (
      userStatVar.userCollateralBalanceETH,
      userStatVar.userBorrowBalanceETH,
      userStatVar.currentLtv,
      userStatVar.currentLiquidationThreshold,
      userStatVar.healthFactor
    ) = GenericLogic.calculateUserAccountData(
      onBehalfOf,
      _reserves,
      _usersConfig[onBehalfOf],
      _reservesList,
      _reservesCount,
      oracle
    );

    uint unlockCRT = CRTLogic.calculateCRTRepay(
      msg.sender,
      reserve,
      paybackAmount,
      paybackamountInETH,
      userStatVar,
      _crtaddress
    );

    if (unlockCRT != 0) {
      ICRT(_crtaddress).unlockCRT(msg.sender, unlockCRT);
    }

    reserve.updateState();

    IVariableDebtToken(reserve.variableDebtTokenAddress).burn(
        onBehalfOf,
        paybackAmount,
        reserve.variableBorrowIndex
      );

    address pToken = reserve.pTokenAddress;
    reserve.updateInterestRates(asset, pToken, paybackAmount, 0);

    if (variableDebt - paybackAmount == 0) {
      _usersConfig[onBehalfOf].setBorrowing(reserve.id, false);
    }

    IERC20(asset).transferFrom(msg.sender, pToken, paybackAmount);

    IPToken(pToken).handleRepayment(msg.sender, paybackAmount);

    emit Repay(asset, onBehalfOf, msg.sender, paybackAmount);

    return paybackAmount;
  }
}
