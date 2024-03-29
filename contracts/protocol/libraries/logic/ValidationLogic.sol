// SPDX-License-Identifier: none
pragma solidity ^0.8.10;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ReserveConfiguration} from '../configuration/ReserveConfiguration.sol';
import {UserConfiguration} from '../configuration/UserConfiguration.sol';
import {Errors} from '../helpers/Errors.sol';
import {ReserveLogic} from './ReserveLogic.sol';
import {WadRayMath} from '../math/WadRayMath.sol';
import {PercentageMath} from '../math/PercentageMath.sol';
import {DataTypes} from '../types/DataTypes.sol';

import {CRTLogic} from './CRTLogic.sol';
import {GenericLogic} from './GenericLogic.sol';

import "hardhat/console.sol";

/**
 * @title ReserveLogic library
 * @author Prestare
 * @notice Implements functions to validate the different actions of the protocol
 */
library ValidationLogic {
  using ReserveLogic for DataTypes.ReserveData;
  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;

  uint256 public constant REBALANCE_UP_LIQUIDITY_RATE_THRESHOLD = 4000;
  uint256 public constant REBALANCE_UP_USAGE_RATIO_THRESHOLD = 0.95 * 1e27; //usage ratio of 95%

  /**
   * @dev Validates a deposit action
   * @param reserve The reserve object on which the user is depositing
   * @param amount The amount to be deposited
   */
  function validateDeposit(DataTypes.ReserveData storage reserve, uint256 amount) external view {
    (bool isActive, bool isFrozen, , ) = reserve.configuration.getFlags();

    require(amount != 0, Errors.VL_INVALID_AMOUNT);
    require(isActive, Errors.VL_NO_ACTIVE_RESERVE);
    require(!isFrozen, Errors.VL_RESERVE_FROZEN);
  }

  /**
   * @dev Validates a withdraw action
   * @param reserveAddress The address of the reserve
   * @param assetTier The tier of the asset
   * @param amount The amount to be withdrawn
   * @param userBalance The balance of the user
   * @param reservesData The reserves state
   * @param userConfig The user configuration
   * @param reserves The addresses of the reserves
   * @param reservesCount The number of reserves
   * @param oracle The price oracle
   */
  function validateWithdraw(
    address reserveAddress,
    uint8 assetTier,
    uint256 amount,
    uint256 userBalance,
    mapping(address => mapping(uint8 => DataTypes.ReserveData)) storage reservesData,
    DataTypes.UserConfigurationMap storage userConfig,
    DataTypes.UserCreditData memory userCredit,
    mapping(uint256 => DataTypes.RerserveAdTier) storage reserves,
    uint256 reservesCount,
    address oracle
  ) external view {
    require(amount != 0, Errors.VL_INVALID_AMOUNT);
    require(amount <= userBalance, Errors.VL_NOT_ENOUGH_AVAILABLE_USER_BALANCE);

    (bool isActive, , , ) = reservesData[reserveAddress][assetTier].configuration.getFlags();
    require(isActive, Errors.VL_NO_ACTIVE_RESERVE);

    require(
      GenericLogic.balanceDecreaseAllowed(
        DataTypes.balanceDecreaseAllowedBaseVar(
          reserveAddress,
          assetTier,
          msg.sender,
          amount
        ),
        reservesData,
        userConfig,
        userCredit,
        reserves,
        reservesCount,
        oracle
      ),
      Errors.VL_TRANSFER_NOT_ALLOWED
    );
  }

  struct ValidateBorrowLocalVars {
    uint256 amountOfCollateralNeededUSD;
    uint256 availableLiquidity;
    bool isActive;
    bool isFrozen;
    bool borrowingEnabled;
    bool stableRateBorrowingEnabled;
  }

  /**
   * @dev Validates a borrow action
   * @param asset The address of the asset to borrow
   * @param reserve The reserve state from which the user is borrowing
   * @param userAddress The address of the user
   * @param amount The amount to be borrowed
   * @param amountInUSD The amount to be borrowed, in USD
   * @param interestRateMode The interest rate mode at which the user is borrowing
   * @param userStateVars User State Variable
   * @param crtAddress The address of Crt
   * @param crtValue The value of the crtNeed in this borrow transaction
   * @param crtNeed The value of one crt in this borrow transaction
   */
  function validateBorrow(
    address asset,
    DataTypes.ReserveData storage reserve,
    address userAddress,
    uint256 amount,
    uint256 amountInUSD,
    uint256 interestRateMode,
    DataTypes.UserAccountVars memory userStateVars,
    address crtAddress,
    uint256 crtValue,
    uint256 crtNeed
  ) external view {

    if (crtNeed != 0) {
        CRTLogic.validateCRTBalance(crtAddress, userAddress, crtNeed);
    }

    uint256 availableLiquidity = IERC20(asset).balanceOf(reserve.pTokenAddress);
    // console.log(asset);
    // console.log(reserve.pTokenAddress);
    console.log("validateBorrow - availableLiquidity is: ", availableLiquidity);
    console.log("validateBorrow - amountInUSD is: ", amountInUSD);
    // require(availableLiquidity > amountInUSD, 
    //   Errors.VL_COLLATERAL_CANNOT_COVER_NEW_BORROW);

    ValidateBorrowLocalVars memory vars;

    (vars.isActive, vars.isFrozen, vars.borrowingEnabled, vars.stableRateBorrowingEnabled) = reserve
      .configuration
      .getFlags();

    require(vars.isActive, Errors.VL_NO_ACTIVE_RESERVE);
    require(!vars.isFrozen, Errors.VL_RESERVE_FROZEN);
    require(amount != 0, Errors.VL_INVALID_AMOUNT);

    require(vars.borrowingEnabled, Errors.VL_BORROWING_NOT_ENABLED);

    //validate interest rate mode
    require(
      uint256(DataTypes.InterestRateMode.VARIABLE) == interestRateMode,
      Errors.VL_INVALID_INTEREST_RATE_MODE_SELECTED
    );

    require(userStateVars.userCollateralBalanceUSD > 0, Errors.VL_COLLATERAL_BALANCE_IS_0);

    require(
      userStateVars.healthFactor > GenericLogic.HEALTH_FACTOR_LIQUIDATION_THRESHOLD,
      Errors.VL_HEALTH_FACTOR_LOWER_THAN_LIQUIDATION_THRESHOLD
    );

    // //add the current already borrowed amount to the amount requested to calculate the total collateral needed.
    vars.amountOfCollateralNeededUSD = (userStateVars.userBorrowBalanceUSD + amountInUSD).percentDiv(
      userStateVars.currentLtv
    ); //LTV is calculated in percentage
    console.log("validateBorrow userBorrowBalanceUSD is: ", userStateVars.userBorrowBalanceUSD);
    console.log("validateBorrow amountInUSD is: ", amountInUSD);
    console.log("validateBorrow currentLtv is: ", userStateVars.currentLtv);
    console.log("validateBorrow amountOfCollateralNeededUSD is: ", vars.amountOfCollateralNeededUSD);

    uint256 userTotalCredit = userStateVars.userCollateralBalanceUSD + userStateVars.userLockCRTValue + crtValue;
    console.log("validateBorrow userCollateralBalanceUSD is: ", userStateVars.userCollateralBalanceUSD);
    console.log("validateBorrow crt value is: ", crtValue);
    console.log("validateBorrow userTotalCredit is: ", userTotalCredit);
    
    require(
      vars.amountOfCollateralNeededUSD <= userTotalCredit,
      Errors.VL_COLLATERAL_CANNOT_COVER_NEW_BORROW
    );
  }

  /**
   * @dev Validates a repay action
   * @param reserve The reserve state from which the user is repaying
   * @param amountSent The amount sent for the repayment. Can be an actual value or uint(-1)
   * @param onBehalfOf The address of the user msg.sender is repaying for
   * @param variableDebt The borrow balance of the user
   */
  function validateRepay(
    DataTypes.ReserveData storage reserve,
    uint256 amountSent,
    DataTypes.InterestRateMode rateMode,
    address onBehalfOf,
    uint256 variableDebt
  ) external view {
    bool isActive = reserve.configuration.getActive();

    require(isActive, Errors.VL_NO_ACTIVE_RESERVE);

    require(amountSent > 0, Errors.VL_INVALID_AMOUNT);

    require(
      variableDebt > 0 &&
        DataTypes.InterestRateMode(rateMode) == DataTypes.InterestRateMode.VARIABLE,
      Errors.VL_NO_DEBT_OF_SELECTED_TYPE
    );

    require(
      amountSent != type(uint256).max || msg.sender == onBehalfOf,
      Errors.VL_NO_EXPLICIT_AMOUNT_TO_REPAY_ON_BEHALF
    );
  }

  /**
   * @dev Validates the action of setting an asset as collateral
   * @param reserve The state of the reserve that the user is enabling or disabling as collateral
   * @param reserveAddress The address of the reserve
   * @param reservesData The data of all the reserves
   * @param userConfig The state of the user for the specific reserve
   * @param reserves The addresses of all the active reserves
   * @param oracle The price oracle
   */
  function validateSetUseReserveAsCollateral(
    DataTypes.ReserveData memory reserve,
    address reserveAddress,
    uint8 riskTier,
    bool useAsCollateral,
    mapping(address => mapping(uint8 => DataTypes.ReserveData)) storage reservesData,
    DataTypes.UserConfigurationMap storage userConfig,
    DataTypes.UserCreditData memory userCredit,
    mapping(uint256 => DataTypes.RerserveAdTier) storage reserves,
    uint256 reservesCount,
    address oracle
  ) external view {
    uint256 underlyingBalance = IERC20(reserve.pTokenAddress).balanceOf(msg.sender);
    uint8 reserveTier = reserves[reserve.id].tier;
    require(underlyingBalance > 0, Errors.VL_UNDERLYING_BALANCE_NOT_GREATER_THAN_0);

    require(
      useAsCollateral ||
        GenericLogic.balanceDecreaseAllowed(
          DataTypes.balanceDecreaseAllowedBaseVar(
            reserveAddress,
            reserveTier,
            msg.sender,
            underlyingBalance
          ),
          reservesData,
          userConfig,
          userCredit,
          reserves,
          reservesCount,
          oracle
        ),
      Errors.VL_DEPOSIT_ALREADY_IN_USE
    );
  }

    /**
   * @dev Validates the liquidation action
   * @param collateralReserve The reserve data of the collateral
   * @param principalReserve The reserve data of the principal
   * @param userConfig The user configuration
   * @param userHealthFactor The user's health factor
   * @param userVariableDebt Total variable debt balance of the user
   **/
  function validateLiquidationCall(
    DataTypes.ReserveData storage collateralReserve,
    DataTypes.ReserveData storage principalReserve,
    DataTypes.UserConfigurationMap storage userConfig,
    uint256 userHealthFactor,
    uint256 userVariableDebt
  ) internal view returns (uint256, string memory) {
    if (
      !collateralReserve.configuration.getActive() || !principalReserve.configuration.getActive()
    ) {
      return (
        uint256(Errors.CollateralManagerErrors.NO_ACTIVE_RESERVE),
        Errors.VL_NO_ACTIVE_RESERVE
      );
    }

    if (userHealthFactor >= GenericLogic.HEALTH_FACTOR_LIQUIDATION_THRESHOLD) {
      return (
        uint256(Errors.CollateralManagerErrors.HEALTH_FACTOR_ABOVE_THRESHOLD),
        Errors.LPCM_HEALTH_FACTOR_NOT_BELOW_THRESHOLD
      );
    }

    bool isCollateralEnabled =
      collateralReserve.configuration.getLiquidationThreshold() > 0 &&
        userConfig.isUsingAsCollateral(collateralReserve.id);

    //if collateral isn't enabled as collateral by user, it cannot be liquidated
    if (!isCollateralEnabled) {
      return (
        uint256(Errors.CollateralManagerErrors.COLLATERAL_CANNOT_BE_LIQUIDATED),
        Errors.LPCM_COLLATERAL_CANNOT_BE_LIQUIDATED
      );
    }

    if (userVariableDebt == 0) {
      return (
        uint256(Errors.CollateralManagerErrors.CURRRENCY_NOT_BORROWED),
        Errors.LPCM_SPECIFIED_CURRENCY_NOT_BORROWED_BY_USER
      );
    }

    return (uint256(Errors.CollateralManagerErrors.NO_ERROR), Errors.LPCM_NO_ERRORS);
  }

  /**
   * @dev Validates an pToken transfer
   * @param from The user from which the pTokens are being transferred
   * @param riskTier The riskTier of asset.
   * @param reservesData The state of all the reserves
   * @param userConfig The state of the user for the specific reserve
   * @param reserves The addresses of all the active reserves
   * @param oracle The price oracle
   */
  function validateTransfer(
    address from,
    uint8 riskTier,
    mapping(address => mapping(uint8 => DataTypes.ReserveData)) storage reservesData,
    DataTypes.UserConfigurationMap storage userConfig,
    DataTypes.UserCreditData memory userCredit,
    mapping(uint256 => DataTypes.RerserveAdTier) storage reserves,
    uint256 reservesCount,
    address oracle
  ) internal view {
    (, , , , uint256 healthFactor) =
      GenericLogic.calculateUserAccountData(
        DataTypes.calculateUserAccountDatamsg(
          from,
          reservesCount,
          oracle,
          riskTier
        ),    
        reservesData,
        userConfig,
        userCredit,
        reserves
      );

    require(
      healthFactor >= GenericLogic.HEALTH_FACTOR_LIQUIDATION_THRESHOLD,
      Errors.VL_TRANSFER_NOT_ALLOWED
    );
  }
}