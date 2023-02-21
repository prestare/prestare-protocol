// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IPriceOracleGetter} from '../../../interfaces/IPriceOracleGetter.sol';
import {ReserveLogic} from './ReserveLogic.sol';
import {ReserveConfiguration} from '../configuration/ReserveConfiguration.sol';
import {UserConfiguration} from '../configuration/UserConfiguration.sol';
import {WadRayMath} from '../math/WadRayMath.sol';
import {PercentageMath} from '../math/PercentageMath.sol';
import {DataTypes} from '../types/DataTypes.sol';
import "hardhat/console.sol";

/**
 * @title GenericLogic library
 * @author Prestare
 * @dev calculate and validate the state of a user
 */
library GenericLogic {
  using ReserveLogic for DataTypes.ReserveData;
  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;

  uint256 public constant HEALTH_FACTOR_LIQUIDATION_THRESHOLD = 1 ether;

  struct balanceDecreaseAllowedLocalVars {
    uint256 decimals;
    uint256 liquidationThreshold;
    uint256 totalCollateralInUSD;
    uint256 totalDebtInUSD;
    uint256 avgLiquidationThreshold;
    uint256 amountToDecreaseInETH;
    uint256 collateralBalanceAfterDecrease;
    uint256 liquidationThresholdAfterDecrease;
    uint256 healthFactorAfterDecrease;
    bool reserveUsageAsCollateralEnabled;
  }

  /**
   * @dev Checks if a specific balance decrease is allowed
   * (i.e. doesn't bring the user borrow position health factor under HEALTH_FACTOR_LIQUIDATION_THRESHOLD)
   * @param asset The address of the underlying asset of the reserve
   * @param user The address of the user
   * @param amount The amount to decrease
   * @param reservesData The data of all the reserves
   * @param userConfig The user configuration
   * @param userCredit The user credit Data
   * @param reserves The list of all the active reserves
   * @param oracle The address of the oracle contract
   * @return true if the decrease of the balance is allowed
   **/
  function balanceDecreaseAllowed(
    address asset,
    address user,
    uint256 amount,
    mapping(address => DataTypes.ReserveData) storage reservesData,
    DataTypes.UserConfigurationMap calldata userConfig,
    DataTypes.UserCreditData memory userCredit,
    mapping(uint256 => address) storage reserves,
    uint256 reservesCount,
    address oracle
  ) external view returns (bool) {
    if (!userConfig.isBorrowingAny() || !userConfig.isUsingAsCollateral(reservesData[asset].id)) {
      return true;
    }

    balanceDecreaseAllowedLocalVars memory vars;

    (, vars.liquidationThreshold, , vars.decimals, ) = reservesData[asset]
      .configuration
      .getParams();

    if (vars.liquidationThreshold == 0) {
      return true;
    }

    (
      vars.totalCollateralInUSD,
      vars.totalDebtInUSD,
      ,
      vars.avgLiquidationThreshold,

    ) = calculateUserAccountData(user, reservesData, userConfig, userCredit,reserves, reservesCount, oracle);

    if (vars.totalDebtInUSD == 0) {
      return true;
    }

    vars.amountToDecreaseInETH = IPriceOracleGetter(oracle).getAssetPrice(asset) * amount / (
      10**vars.decimals
    );

    vars.collateralBalanceAfterDecrease = vars.totalCollateralInUSD - vars.amountToDecreaseInETH;

    //if there is a borrow, there can't be 0 collateral
    if (vars.collateralBalanceAfterDecrease == 0) {
      return false;
    }

    vars.liquidationThresholdAfterDecrease = vars
      .totalCollateralInUSD
      * vars.avgLiquidationThreshold
      - (vars.amountToDecreaseInETH * vars.liquidationThreshold)
      / vars.collateralBalanceAfterDecrease;

    uint256 healthFactorAfterDecrease =
      calculateHealthFactorFromBalances(
        vars.collateralBalanceAfterDecrease,
        vars.totalDebtInUSD,
        vars.liquidationThresholdAfterDecrease
      );

    return healthFactorAfterDecrease >= GenericLogic.HEALTH_FACTOR_LIQUIDATION_THRESHOLD;
  }

  struct CalculateUserAccountDataVars {
    uint256 reserveUnitPrice;
    uint256 tokenUnit;
    uint256 compoundedLiquidityBalance;
    uint256 compoundedBorrowBalance;
    uint256 decimals;
    uint256 ltv;
    uint256 liquidationThreshold;
    uint256 i;
    uint256 healthFactor;
    uint256 totalCollateralInUSD;
    uint256 totalDebtInUSD;
    uint256 avgLtv;
    uint256 avgLiquidationThreshold;
    uint256 reservesLength;
    bool healthFactorBelowThreshold;
    address currentReserveAddress;
    bool usageAsCollateralEnabled;
    bool userUsesReserveAsCollateral;
  }

  /**
   * @dev Calculates the user data across the reserves.
   * this includes the total liquidity/collateral/borrow balances in ETH,
   * the average Loan To Value, the average Liquidation Ratio, and the Health factor.
   * @param user The address of the user
   * @param reservesData Data of all the reserves
   * @param userConfig The configuration of the user
   * @param userCredit The credit Data of the user
   * @param reserves The list of the available reserves
   * @param oracle The price oracle address
   * @return The total collateral and total debt of the user in ETH, the avg ltv, liquidation threshold and the HF
   **/
  function calculateUserAccountData(
    address user,
    mapping(address => DataTypes.ReserveData) storage reservesData,
    DataTypes.UserConfigurationMap memory userConfig,
    DataTypes.UserCreditData memory userCredit,
    mapping(uint256 => address) storage reserves,
    uint256 reservesCount,
    address oracle
  )
    internal
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    CalculateUserAccountDataVars memory vars;

    if (userConfig.isEmpty()) {
      return (0, 0, 0, 0, type(uint256).max);
    }
    for (vars.i = 0; vars.i < reservesCount; vars.i++) {
      if (!userConfig.isUsingAsCollateralOrBorrowing(vars.i)) {
        console.log("calculateUserAccountData - found not allow borrowed asset");
        continue;
      }

      vars.currentReserveAddress = reserves[vars.i];
      DataTypes.ReserveData storage currentReserve = reservesData[vars.currentReserveAddress];

      (vars.ltv, vars.liquidationThreshold, , vars.decimals, ) = currentReserve
        .configuration
        .getParams();

      vars.tokenUnit = 10**vars.decimals;
      vars.reserveUnitPrice = IPriceOracleGetter(oracle).getAssetPrice(vars.currentReserveAddress);
      console.log("user Config:");
      console.log(userConfig.isUsingAsCollateral(vars.i));
      console.log("liquidationThreshold");
      console.log(vars.liquidationThreshold);

      if (vars.liquidationThreshold != 0 && userConfig.isUsingAsCollateral(vars.i)) {
        console.log("calculateUserAccountData calculate asset %s value", vars.i);
        vars.compoundedLiquidityBalance = IERC20(currentReserve.pTokenAddress).balanceOf(user);

        uint256 liquidityBalanceUSD =
          vars.reserveUnitPrice * (vars.compoundedLiquidityBalance) / (vars.tokenUnit);

        vars.totalCollateralInUSD = vars.totalCollateralInUSD + liquidityBalanceUSD;
        console.log(" USD is: ", vars.totalCollateralInUSD );
        vars.avgLtv = vars.avgLtv + (liquidityBalanceUSD * vars.ltv);
        vars.avgLiquidationThreshold = vars.avgLiquidationThreshold + (
          liquidityBalanceUSD * vars.liquidationThreshold
        );
      }

      if (userConfig.isBorrowing(vars.i)) {
        vars.compoundedBorrowBalance = 
          IERC20(currentReserve.variableDebtTokenAddress).balanceOf(user);

        vars.totalDebtInUSD = vars.totalDebtInUSD + (
          vars.reserveUnitPrice * vars.compoundedBorrowBalance / vars.tokenUnit
        );
      }
    }
    // problem how to interact with credit score
    vars.avgLtv = vars.totalCollateralInUSD > 0 ? (vars.avgLtv / (vars.totalCollateralInUSD + userCredit.crtValue)) : 0;
    vars.avgLiquidationThreshold = vars.totalCollateralInUSD > 0
      ? vars.avgLiquidationThreshold / (vars.totalCollateralInUSD +  userCredit.crtValue)
      : 0;

    vars.healthFactor = calculateHealthFactorFromBalances(
      vars.totalCollateralInUSD + userCredit.crtValue, 
      vars.totalDebtInUSD,
      vars.avgLiquidationThreshold
    );
    return (
      vars.totalCollateralInUSD,
      vars.totalDebtInUSD,
      vars.avgLtv,
      vars.avgLiquidationThreshold,
      vars.healthFactor
    );
  }

  /**
   * @dev Calculates the health factor from the corresponding balances
   * @param totalCollateralCreditInUSD The total collateral in USD
   * @param totalDebtInUSD The total debt in USD
   * @param liquidationThreshold The avg liquidation threshold
   * @return The health factor calculated from the balances provided
   **/
  function calculateHealthFactorFromBalances(
    uint256 totalCollateralCreditInUSD,
    uint256 totalDebtInUSD,
    uint256 liquidationThreshold
  ) internal pure returns (uint256) {
    if (totalDebtInUSD == 0) return type(uint256).max;

    return (totalCollateralCreditInUSD.percentMul(liquidationThreshold)).wadDiv(totalDebtInUSD);
  }

  /**
   * @dev Calculates the equivalent amount in ETH that an user can borrow, depending on the available collateral and the
   * average Loan To Value
   * @param totalCollateralInUSD The total collateral in ETH
   * @param totalDebtInUSD The total borrow balance
   * @param ltv The average loan to value
   * @return the amount available to borrow in ETH for the user
   **/
  function calculateAvailableBorrowsETH(
    uint256 totalCollateralInUSD,
    uint256 totalDebtInUSD,
    uint256 ltv
  ) internal pure returns (uint256) {
    uint256 availableBorrowsETH = totalCollateralInUSD.percentMul(ltv);

    if (availableBorrowsETH < totalDebtInUSD) {
      return 0;
    }

    availableBorrowsETH = availableBorrowsETH - totalDebtInUSD;
    return availableBorrowsETH;
  }
  
}
