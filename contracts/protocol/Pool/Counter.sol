// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Address} from '@openzeppelin/contracts/utils/Address.sol';

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
import "hardhat/console.sol";
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

  modifier whenNotPaused() {
    _whenNotPaused();
    _;
  }

  modifier onlyCounterConfigurator() {
    _onlyCounterConfigurator();
    _;
  }

  function _whenNotPaused() internal view {
    require(!_paused, Errors.LP_IS_PAUSED);
  }

  function _onlyCounterConfigurator() internal view {
    require(
      _addressesProvider.getCounterConfigurator() == msg.sender,
      Errors.LP_CALLER_NOT_Counter_CONFIGURATOR
    );
  }

  /**
   * @dev Constructor.
   * @param provider The address of the PoolAddressesProvider contract
   */
  // constructor(ICounterAddressesProvider provider) {
  //   _addressesProvider = provider;
  // }

  /**
   * @dev Function is invoked by the proxy contract when the Counter contract is added to the
   * CounterAddressesProvider of the market.
   * - Caching the address of the CounterAddressesProvider in order to reduce gas consumption
   *   on subsequent operations
   * @param provider The address of the CounterAddressesProvider
   **/
  function initialize(ICounterAddressesProvider provider) public {
    _addressesProvider = provider;
    _maxAssetClass = 3;
    _flashLoanPremiumTotal = 9;
    _maxNumberOfReserves = 128;
  }

  /**
   * @dev described in ICounter.sol
   */
  function deposit(
    address asset,
    uint8 riskTier,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external override whenNotPaused {
    console.log("");
    console.log("Counter deposit....");
    console.log("asset address is ", asset);
    DataTypes.ReserveData storage reserve = _reserves[asset][riskTier];
    // DataTypes.ReserveData storage reserve = _reserves[asset];

    ValidationLogic.validateDeposit(reserve, amount);

    address pToken = reserve.pTokenAddress;
    console.log("pToken is ", pToken);
    console.log("reserve updateState...");
    reserve.updateState();
    console.log("reserve updateInterestRates");
    reserve.updateInterestRates(asset, pToken, amount, 0);
    console.log("reserve update success");
    IERC20(asset).transferFrom(msg.sender, pToken, amount);

    bool isFirstDeposit = IPToken(pToken).mint(onBehalfOf, amount, reserve.liquidityIndex);

    if (isFirstDeposit) {
      console.log("First deposit and setUsingAsCollateral");
      _usersConfig[onBehalfOf].setUsingAsCollateral(reserve.id, true);
      emit ReserveUsedAsCollateralEnabled(asset, onBehalfOf);
    }

    emit Deposit(asset, msg.sender, onBehalfOf, amount, referralCode);
  }

  /**
   * @dev described in ICounter.sol
   */
  function withdraw(
    address asset,
    uint8 riskTier,
    uint256 amount,
    address to
  ) external override whenNotPaused returns (uint256) {
    DataTypes.ReserveData storage reserve = _reserves[asset][riskTier];

    address pToken = reserve.pTokenAddress;

    uint256 userBalance = IPToken(pToken).balanceOf(msg.sender);

    uint256 amountToWithdraw = amount;

    if (amount == type(uint256).max) {
      amountToWithdraw = userBalance;
    }

    ValidationLogic.validateWithdraw(
      asset,
      riskTier,
      amountToWithdraw,
      userBalance,
      _reserves,
      _usersConfig[msg.sender],
      _usersCredit[msg.sender],
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
   * @dev described in ICounter.sol
   */
  function borrow(
    address asset,
    uint8 riskTier,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode,
    address onBehalfOf,
    bool crtenable
  ) external override whenNotPaused {
    console.log("");
    console.log("borrow...");
    address pTokenAddress = _reserves[asset][riskTier].pTokenAddress;

    // DataTypes.ReserveData storage reserve = _reserves[asset];
    _executeBorrow(
      ExecuteBorrowParams(
        asset,
        riskTier,
        msg.sender,
        onBehalfOf,
        amount,
        interestRateMode,
        pTokenAddress,
        referralCode,
        true,
        crtenable
      )
    );
  }

  struct ExecuteBorrowParams {
    address asset;
    uint8 riskTier;
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
    console.log("_executeBorrow");
    DataTypes.ReserveData storage reserve = _reserves[vars.asset][vars.riskTier];
    DataTypes.UserConfigurationMap storage userConfig = _usersConfig[vars.onBehalfOf];

    address oracle = _addressesProvider.getPriceOracle();

    uint256 amountInUSD =
      IPriceOracleGetter(oracle).getAssetPrice(vars.asset) * vars.amount / (
        10**reserve.configuration.getDecimals()
      );
    console.log("asset address:", vars.asset);
    console.log("price is:", IPriceOracleGetter(oracle).getAssetPrice(vars.asset));
    console.log("amount in USD:", amountInUSD);
    // get User Account Stata
    DataTypes.UserAccountVars memory userStatVar;
    // include crt value
    (
      userStatVar.userCollateralBalanceUSD,
      userStatVar.userBorrowBalanceUSD,
      userStatVar.currentLtv,
      userStatVar.currentLiquidationThreshold,
      userStatVar.healthFactor
    ) = GenericLogic.calculateUserAccountData(
      vars.onBehalfOf,
      _reserves,
      userConfig,
      _usersCredit[vars.onBehalfOf],
      _reservesList,
      _reservesCount,
      oracle
    );
    console.log("borrow - userCollateralBalanceUSD is ", userStatVar.userCollateralBalanceUSD);
    userStatVar.userLockCRTValue = _usersCredit[vars.onBehalfOf].crtValue;
    uint256 crtNeed = 0;
    uint256 crtValue = 0;
    if (vars.crtenable) {
      // if the amountInUSD > canBorrowAmount, how much crt need to fill the gap
      (crtNeed, crtValue) = CRTLogic.calculateCRTBorrow(
        vars.onBehalfOf,
        reserve.configuration.getLtv(),
        amountInUSD,
        userStatVar,
        oracle
      );
    }
    // 审计问题
    // 考虑拆分更仔细
    // when undercollateral, need to check if we have enough balance
    ValidationLogic.validateBorrow(
      vars.asset,
      reserve,
      vars.onBehalfOf,
      vars.amount,
      amountInUSD,
      vars.interestRateMode,
      userStatVar,
      _crtaddress,
      crtValue,
      crtNeed
    );

    reserve.updateState();

    bool isFirstBorrowing = false;

    if (vars.crtenable && crtNeed != 0) {
        ICRT(_crtaddress).lockCRT(vars.onBehalfOf, crtNeed);
        _usersCredit[vars.onBehalfOf].crtValue += crtValue;
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
   * @dev described in ICounter.sol
   */
  function repay(
    address asset,
    uint8 riskTier,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external override whenNotPaused returns (uint256) {
    address pTokenAddress = _reserves[asset][riskTier].pTokenAddress;
    return _executeRepay(
      ExecuteRepayParams(
        asset,
        riskTier,
        msg.sender,
        onBehalfOf,
        amount,
        rateMode,
        pTokenAddress
      )
    );
  }

  struct ExecuteRepayParams {
    address asset;
    uint8 riskTier;
    address user;
    address onBehalfOf;
    uint256 amount;
    uint256 interestRateMode;
    address pTokenAddress;
    // uint16 referralCode;
  }

  function _executeRepay(ExecuteRepayParams memory vars) internal returns (uint256) {
    console.log("");
    console.log("repay...");
    DataTypes.ReserveData storage reserve = _reserves[vars.asset][vars.riskTier];

    // DataTypes.ReserveData storage reserve = _reserves[asset];
    DataTypes.UserCreditData storage userCredit = _usersCredit[vars.onBehalfOf];

    uint256 variableDebt = Helpers.getUserCurrentDebt(vars.onBehalfOf, reserve);

    DataTypes.InterestRateMode interestRateMode = DataTypes.InterestRateMode(vars.interestRateMode);

    ValidationLogic.validateRepay(
      reserve,
      vars.amount,
      interestRateMode,
      vars.onBehalfOf,
      variableDebt
    );

    uint256 paybackAmount = variableDebt;

    if (vars.amount < paybackAmount) {
      paybackAmount = vars.amount;
    }
    
    address oracle = _addressesProvider.getPriceOracle();
    uint256 paybackamountInUSD =
      IPriceOracleGetter(oracle).getAssetPrice(vars.asset) * paybackAmount / (
        10**reserve.configuration.getDecimals()
      );
    
    DataTypes.UserAccountVars memory userStatVar;
    // the userCollateralBalanceUSD is not contain crtvalue 
    (
      userStatVar.userCollateralBalanceUSD,
      userStatVar.userBorrowBalanceUSD,
      userStatVar.currentLtv,
      userStatVar.currentLiquidationThreshold,
      userStatVar.healthFactor
    ) = GenericLogic.calculateUserAccountData(
      vars.onBehalfOf,
      _reserves,
      _usersConfig[vars.onBehalfOf],
      userCredit,
      _reservesList,
      _reservesCount,
      oracle
    );
    // CRT 
    (userStatVar.idleCRT, userStatVar.newCrtValue) = CRTLogic.calculateCRTRepay(
      vars.onBehalfOf,
      reserve.configuration.getLtv(),
      // paybackAmount,
      paybackamountInUSD,
      userStatVar,
      userCredit,
      _crtaddress
    );

    if (userStatVar.idleCRT > 0) {
      ICRT(_crtaddress).unlockCRT(vars.user, userStatVar.idleCRT);
      // fix
      _usersCredit[vars.user].crtValue = userStatVar.newCrtValue;
    }

    reserve.updateState();
    console.log("update state finish");
    IVariableDebtToken(reserve.variableDebtTokenAddress).burn(
        vars.onBehalfOf,
        paybackAmount,
        reserve.variableBorrowIndex
      );

    // address pToken = reserve.pTokenAddress;
    console.log("update asset ir:", vars.asset);
    reserve.updateInterestRates(vars.asset, vars.pTokenAddress, paybackAmount, 0);

    if (variableDebt - paybackAmount == 0) {
      _usersConfig[vars.onBehalfOf].setBorrowing(reserve.id, false);
    }
    console.log("repay payback amount is: ", paybackAmount);
    IERC20(vars.asset).transferFrom(vars.user, vars.pTokenAddress, paybackAmount);

    IPToken(vars.pTokenAddress).handleRepayment(vars.user, paybackAmount);

    emit Repay(vars.asset, vars.onBehalfOf, vars.user, paybackAmount);

    return paybackAmount;
  }


  /**
   * @dev described in ICounter.sol
   */
  function setUserUseReserveAsCollateral(address asset, uint8 riskTier, bool useAsCollateral)
    external
    override
    whenNotPaused
  {
    DataTypes.ReserveData storage reserve = _reserves[asset][riskTier];

    ValidationLogic.validateSetUseReserveAsCollateral(
      reserve,
      asset,
      useAsCollateral,
      _reserves,
      _usersConfig[msg.sender],
      _usersCredit[msg.sender],
      _reservesList,
      _reservesCount,
      _addressesProvider.getPriceOracle()
    );

    _usersConfig[msg.sender].setUsingAsCollateral(reserve.id, useAsCollateral);

    if (useAsCollateral) {
      emit ReserveUsedAsCollateralEnabled(asset, msg.sender);
    } else {
      emit ReserveUsedAsCollateralDisabled(asset, msg.sender);
    }
  }

  struct ExcuteLiqudationParams {
    address collateralAsset;
    uint8 collateralRiskTier;
    address debtAsset;
    uint8 debtRiskTier;
    address user;
    uint256 debtToCover;
    bool receivePToken;
  }
  /**
   * @dev Function to liquidate a non-healthy position collateral-wise, with Health Factor below 1
   * - The caller (liquidator) covers `debtToCover` amount of debt of the user getting liquidated, and receives
   *   a proportionally amount of the `collateralAsset` plus a bonus to cover market risk
   * @param collateralAsset The address of the underlying asset used as collateral, to receive as result of the liquidation
   * @param debtAsset The address of the underlying borrowed asset to be repaid with the liquidation
   * @param user The address of the borrower getting liquidated
   * @param debtToCover The debt amount of borrowed `asset` the liquidator wants to cover
   * @param receivePToken `true` if the liquidators wants to receive the collateral pTokens, `false` if he wants
   * to receive the underlying collateral asset directly
   **/
  function liquidationCall(
    address collateralAsset,
    uint8 collateralRiskTier,
    address debtAsset,
    uint8 debtRiskTier,
    address user,
    uint256 debtToCover,
    bool receivePToken
  ) external override whenNotPaused {
    address collateralManager = _addressesProvider.getCounterCollateralManager();

    //solium-disable-next-line
    (bool success, bytes memory result) =
      collateralManager.delegatecall(
        abi.encodeWithSignature(
          'liquidationCall(ExcuteLiqudationParams memory)',
          ExcuteLiqudationParams(
            collateralAsset,
            collateralRiskTier,
            debtAsset,
            debtRiskTier,
            user,
            debtToCover,
            receivePToken
          )
        )
      );

    require(success, Errors.LP_LIQUIDATION_CALL_FAILED);

    (uint256 returnCode, string memory returnMessage) = abi.decode(result, (uint256, string));

    require(returnCode == 0, string(abi.encodePacked(returnMessage)));
  }

  /**
   * @dev described in ICounter.sol
   */
  function getReserveData(address asset, uint8 riskTier)
    external
    view
    override
    returns (DataTypes.ReserveData memory)
  {
    return _reserves[asset][riskTier];
  }

  /**
   * @dev Returns the user account data across all the reserves
   * @param user The address of the user
   * @return totalCollateralUSD the total collateral in ETH of the user
   * @return totalDebtUSD the total debt in ETH of the user
   * @return availableBorrowsUSD the borrowing power left of the user
   * @return currentLiquidationThreshold the liquidation threshold of the user
   * @return ltv the loan to value of the user
   * @return healthFactor the current health factor of the user
   **/
  function getUserAccountData(address user)
    external
    view
    override
    returns (
      uint256 totalCollateralUSD,
      uint256 totalDebtUSD,
      uint256 availableBorrowsUSD,
      uint256 currentLiquidationThreshold,
      uint256 ltv,
      uint256 healthFactor
    )
  {
    (
      totalCollateralUSD,
      totalDebtUSD,
      ltv,
      currentLiquidationThreshold,
      healthFactor
    ) = GenericLogic.calculateUserAccountData(
      user,
      _reserves,
      _usersConfig[user],
      _usersCredit[user],
      _reservesList,
      _reservesCount,
      _addressesProvider.getPriceOracle()
    );

    availableBorrowsUSD = GenericLogic.calculateAvailableBorrowsUSD(
      totalCollateralUSD,
      totalDebtUSD,
      ltv
    );
  }

  /**
   * @dev Returns the configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The configuration of the reserve
   **/
  function getConfiguration(address asset, uint8 riskTier)
    external
    view
    override
    returns (DataTypes.ReserveConfigurationMap memory)
  {
    return _reserves[asset][riskTier].configuration;
  }

  /**
   * @dev Returns the configuration of the user across all the reserves
   * @param user The user address
   * @return The configuration of the user
   **/
  function getUserConfiguration(address user)
    external
    view
    override
    returns (DataTypes.UserConfigurationMap memory)
  {
    return _usersConfig[user];
  }

  /**
   * @dev Returns the normalized income per unit of asset
   * @param asset The address of the underlying asset of the reserve
   * @param riskTier The risk tier of the reserve
   * @return The reserve's normalized income
   */
  function getReserveNormalizedIncome(address asset, uint8 riskTier)
    external
    view
    virtual
    override
    returns (uint256)
  {
    return _reserves[asset][riskTier].getNormalizedIncome();
  }

  /**
   * @dev Returns the normalized variable debt per unit of asset
   * @param asset The address of the underlying asset of the reserve
   * @param riskTier The risk tier of the reserve
   * @return The reserve normalized variable debt
   */
  function getReserveNormalizedVariableDebt(address asset, uint8 riskTier)
    external
    view
    override
    returns (uint256)
  {
    return _reserves[asset][riskTier].getNormalizedDebt();
  }

  /**
   * @dev Returns if the Counter is paused
   */
  function paused() external view override returns (bool) {
    return _paused;
  }

  /**
   * @dev Returns the list of the initialized reserves
   **/
  function getReservesList() external view override returns (address[] memory) {
    address[] memory _activeReserves = new address[](_reservesCount);

    for (uint256 i = 0; i < _reservesCount; i++) {
      _activeReserves[i] = _reservesList[i].reserveAddress;
    }
    return _activeReserves;
  }

  /**
   * @dev Returns the cached CounterAddressesProvider connected to this contract
   **/
  function getAddressesProvider() external view override returns (ICounterAddressesProvider) {
    return _addressesProvider;
  }

  function setReserveInterestRateStrategyAddress(address asset, uint8 riskTier, address rateStrategyAddress)
    external
    override
    onlyCounterConfigurator
  {
    _reserves[asset][riskTier].interestRateStrategyAddress = rateStrategyAddress;
  }

  /**
   * @dev Sets the configuration bitmap of the reserve as a whole
   * - Only callable by the CounterConfigurator contract
   * @param asset The address of the underlying asset of the reserve
   * @param riskTier The risk tier of the reserve
   * @param configuration The new configuration bitmap
   **/
  function setConfiguration(address asset, uint8 riskTier, uint256 configuration)
    external
    override
    onlyCounterConfigurator
  {
    _reserves[asset][riskTier].configuration.data = configuration;
  }

  /**
   * @dev Set the _pause state of a reserve
   * - Only callable by the CounterConfigurator contract
   * @param val `true` to pause the reserve, `false` to un-pause it
   */
  function setPause(bool val) external override onlyCounterConfigurator {
    _paused = val;
    if (_paused) {
      emit Paused();
    } else {
      emit Unpaused();
    }
  }

  function setCRT(address crt) external override onlyCounterConfigurator {
    _crtaddress = crt;
  }

  /**
   * @dev described in ICounter.sol
   */
  function finalizeTransfer(
    address asset,
    uint8 riskTier,
    address from,
    address to,
    uint256 amount,
    uint256 balanceFromBefore,
    uint256 balanceToBefore
  ) external override whenNotPaused {
    require(msg.sender == _reserves[asset][riskTier].pTokenAddress, Errors.LP_CALLER_MUST_BE_AN_pToken);

    ValidationLogic.validateTransfer(
      from,
      _reserves,
      _usersConfig[from],
      _usersCredit[from],
      _reservesList,
      _reservesCount,
      _addressesProvider.getPriceOracle()
    );

    uint256 reserveId = _reserves[asset][riskTier].id;

    if (from != to) {
      if (balanceFromBefore - amount == 0) {
        DataTypes.UserConfigurationMap storage fromConfig = _usersConfig[from];
        fromConfig.setUsingAsCollateral(reserveId, false);
        emit ReserveUsedAsCollateralDisabled(asset, from);
      }

      if (balanceToBefore == 0 && amount != 0) {
        DataTypes.UserConfigurationMap storage toConfig = _usersConfig[to];
        toConfig.setUsingAsCollateral(reserveId, true);
        emit ReserveUsedAsCollateralEnabled(asset, to);
      }
    }
  }

    /**
   * @dev Initializes a reserve, activating it, assigning an pToken and debt tokens and an
   * interest rate strategy
   * - Only callable by the CounterConfigurator contract
   * @param asset The address of the underlying asset of the reserve
   * @param pTokenAddress The address of the pToken that will be assigned to the reserve
   * @param variableDebtAddress The address of the VariableDebtToken that will be assigned to the reserve
   * @param interestRateStrategyAddress The address of the interest rate strategy contract
   **/
  function initReserve(
    address asset,
    uint8 initRiskTier,
    address pTokenAddress,
    address variableDebtAddress,
    address interestRateStrategyAddress
  ) external override onlyCounterConfigurator {
    require(Address.isContract(asset), Errors.LP_NOT_CONTRACT);
    // uint8 initAssetTier = 3;
    _reserves[asset][initRiskTier].init(
      pTokenAddress,
      variableDebtAddress,
      interestRateStrategyAddress
    );
    _addReserveToList(asset, initRiskTier);
  }

  function getAssetClass(address asset) external view override returns(uint8) {
    return _assetClass[asset];
  }

  function upgradeAssetClass(
    address asset,
    address pTokenAddress,
    address variableDebtAddress,
    address interestRateStrategyAddress
  ) external override onlyCounterConfigurator {
    require(Address.isContract(asset), Errors.LP_NOT_CONTRACT);
    require(_assetClass[asset] > 0, Errors.ASSET_HAVE_BEEN_ACLASS);
    uint8 targetAssetClass = _assetClass[asset] - 1;
    _reserves[asset][targetAssetClass].init(
      pTokenAddress,
      variableDebtAddress,
      interestRateStrategyAddress
    );
    _addReserveToList(asset, targetAssetClass);
  }

  function degradeAssetClass(
    address asset 
  ) external override onlyCounterConfigurator {
    uint8 nowAssetTier = _assetClass[asset];
    require(nowAssetTier < _maxAssetClass, Errors.ASSET_CLASS_IS_LOWERST);
    // After downgrade, asset Class become nowAssetTier + 1
    uint8 demoteAssetTier = nowAssetTier + 1;
    // get reserve assetTier config
    DataTypes.ReserveData memory reserveData = _reserves[asset][nowAssetTier];
    DataTypes.ReserveConfigurationMap memory currentConfig = reserveData.configuration;
    address pTokenAddress = reserveData.pTokenAddress;
    address variableDebtAddress = reserveData.variableDebtTokenAddress;
    address interestRateStrategyAddress = reserveData.interestRateStrategyAddress;
    // After downgrading asset Class, the assetTier which is higher than assetClass should be frozen; 
    currentConfig.setFrozen(true);
    _reserves[asset][nowAssetTier].configuration.data = currentConfig.data;
    // Downgrade asset Class by 1;
    _assetClass[asset] = demoteAssetTier;
    emit ReserveClassUpdate(
      asset,
      demoteAssetTier,
      0,
      pTokenAddress,
      variableDebtAddress,
      interestRateStrategyAddress
    );
  }

  function _addReserveToList(address asset, uint8 riskTier) internal {
    uint256 reservesCount = _reservesCount;

    require(reservesCount < _maxNumberOfReserves, Errors.LP_NO_MORE_RESERVES_ALLOWED);

    bool reserveAlreadyAdded = _reserves[asset][riskTier].id != 0 || _reservesList[0].reserveAddress == asset;

    if (!reserveAlreadyAdded) {
      _assetClass[asset] = riskTier;
      _reserves[asset][riskTier].id = uint8(reservesCount);
      _reservesList[reservesCount].reserveAddress = asset;

      _reservesCount = reservesCount + 1;
    }
  }
}
