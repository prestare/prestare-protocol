// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ICounterCollateralManager} from '../../interfaces/ICounterCollateralManager.sol';
import {IPriceOracleGetter} from '../../interfaces/IPriceOracleGetter.sol';
import {IPToken} from '../../interfaces/IPToken.sol';
import {IVariableDebtToken} from '../../interfaces/IVariableDebtToken.sol';

import {CounterStorage} from './CounterStorage.sol';
import {WadRayMath} from '../libraries/math/WadRayMath.sol';
import {PercentageMath} from '../libraries/math/PercentageMath.sol';

import {ReserveConfiguration} from '../libraries/configuration/ReserveConfiguration.sol';
import {UserConfiguration} from '../libraries/configuration/UserConfiguration.sol';

import {Errors} from '../libraries/helpers/Errors.sol';
import {Helpers} from '../libraries/helpers/Helpers.sol';
import {ReserveLogic} from '../libraries/logic/ReserveLogic.sol';
import {GenericLogic} from '../libraries/logic/GenericLogic.sol';
import {ValidationLogic} from '../libraries/logic/ValidationLogic.sol';

import {DataTypes} from '../libraries/types/DataTypes.sol';


contract CounterCollateralManager is
  ICounterCollateralManager,
  CounterStorage
{
  using SafeERC20 for IERC20;
  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using ReserveLogic for DataTypes.ReserveData;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;

  uint256 internal constant LIQUIDATION_CLOSE_FACTOR_PERCENT = 5000;

  struct LiquidationCallLocalVars {
    uint256 userCollateralBalance;
    uint256 userVariableDebt;
    uint256 maxLiquidatableDebt;
    uint256 actualDebtToLiquidate;
    uint256 liquidationRatio;
    uint256 maxAmountCollateralToLiquidate;
    uint256 maxCollateralToLiquidate;
    uint256 debtAmountNeeded;
    uint256 healthFactor;
    uint256 liquidatorPreviousPTokenBalance;
    IPToken collateralPtoken;
    bool isCollateralEnabled;
    DataTypes.InterestRateMode borrowRateMode;
    uint256 errorCode;
    string errorMsg;
  }

  /**
   * @dev described in ICounterCollateralManager.sol
   */
  function liquidationCall(
    ExcuteLiqudationParams memory liqParams
  ) external override returns (uint256, string memory) {
    DataTypes.ReserveData storage collateralReserve = _reserves[liqParams.collateralAsset][liqParams.collateralRiskTier];
    DataTypes.ReserveData storage debtReserve = _reserves[liqParams.debtAsset][liqParams.debtRiskTier];
    DataTypes.UserConfigurationMap storage userConfig = _usersConfig[liqParams.user];
    DataTypes.UserCreditData storage userCredit = _usersCredit[liqParams.user];
    LiquidationCallLocalVars memory vars;

    (, , , , vars.healthFactor) = GenericLogic.calculateUserAccountData(
      DataTypes.calculateUserAccountDatamsg(
        liqParams.user,
        _reservesCount,
        _addressesProvider.getPriceOracle(),
        liqParams.collateralRiskTier
      ),
      _reserves,
      userConfig,
      userCredit,
      _reservesList
    );

    vars.userVariableDebt = Helpers.getUserCurrentDebt(liqParams.user, debtReserve);

    (vars.errorCode, vars.errorMsg) = ValidationLogic.validateLiquidationCall(
      collateralReserve,
      debtReserve,
      userConfig,
      vars.healthFactor,
      vars.userVariableDebt
    );

    if (Errors.CollateralManagerErrors(vars.errorCode) != Errors.CollateralManagerErrors.NO_ERROR) {
      return (vars.errorCode, vars.errorMsg);
    }

    vars.collateralPtoken = IPToken(collateralReserve.pTokenAddress);

    vars.userCollateralBalance = vars.collateralPtoken.balanceOf(liqParams.user);

    vars.maxLiquidatableDebt = vars.userVariableDebt.percentMul(
      LIQUIDATION_CLOSE_FACTOR_PERCENT
    );

    vars.actualDebtToLiquidate = liqParams.debtToCover > vars.maxLiquidatableDebt
      ? vars.maxLiquidatableDebt
      : liqParams.debtToCover;

    (
      vars.maxCollateralToLiquidate,
      vars.debtAmountNeeded
    ) = _calculateAvailableCollateralToLiquidate(
      collateralReserve,
      debtReserve,
      liqParams.collateralAsset,
      liqParams.debtAsset,
      vars.actualDebtToLiquidate,
      vars.userCollateralBalance
    );

    // If debtAmountNeeded < actualDebtToLiquidate, there isn't enough
    // collateral to cover the actual amount that is being liquidated, hence we liquidate
    // a smaller amount

    if (vars.debtAmountNeeded < vars.actualDebtToLiquidate) {
      vars.actualDebtToLiquidate = vars.debtAmountNeeded;
    }

    // If the liquidator reclaims the underlying asset, we make sure there is enough available liquidity in the
    // collateral reserve
    if (!liqParams.receivePToken) {
      uint256 currentAvailableCollateral =
        IERC20(liqParams.collateralAsset).balanceOf(address(vars.collateralPtoken));
      if (currentAvailableCollateral < vars.maxCollateralToLiquidate) {
        return (
          uint256(Errors.CollateralManagerErrors.NOT_ENOUGH_LIQUIDITY),
          Errors.LPCM_NOT_ENOUGH_LIQUIDITY_TO_LIQUIDATE
        );
      }
    }

    debtReserve.updateState();

    if (vars.userVariableDebt >= vars.actualDebtToLiquidate) {
      IVariableDebtToken(debtReserve.variableDebtTokenAddress).burn(
        liqParams.user,
        vars.actualDebtToLiquidate,
        debtReserve.variableBorrowIndex
      );
    }

    debtReserve.updateInterestRates(
      liqParams.debtAsset,
      debtReserve.pTokenAddress,
      vars.actualDebtToLiquidate,
      0
    );

    if (liqParams.receivePToken) {
      vars.liquidatorPreviousPTokenBalance = IERC20(vars.collateralPtoken).balanceOf(msg.sender);
      vars.collateralPtoken.transferOnLiquidation(liqParams.user, msg.sender, vars.maxCollateralToLiquidate);

      if (vars.liquidatorPreviousPTokenBalance == 0) {
        DataTypes.UserConfigurationMap storage liquidatorConfig = _usersConfig[msg.sender];
        liquidatorConfig.setUsingAsCollateral(collateralReserve.id, true);
        emit ReserveUsedAsCollateralEnabled(liqParams.collateralAsset, msg.sender);
      }
    } else {
      collateralReserve.updateState();
      collateralReserve.updateInterestRates(
        liqParams.collateralAsset,
        address(vars.collateralPtoken),
        0,
        vars.maxCollateralToLiquidate
      );

      // Burn the equivalent amount of pToken, sending the underlying to the liquidator
      vars.collateralPtoken.burn(
        liqParams.user,
        msg.sender,
        vars.maxCollateralToLiquidate,
        collateralReserve.liquidityIndex
      );
    }

    // If the collateral being liquidated is equal to the user balance,
    // we set the currency as not being used as collateral anymore
    if (vars.maxCollateralToLiquidate == vars.userCollateralBalance) {
      userConfig.setUsingAsCollateral(collateralReserve.id, false);
      emit ReserveUsedAsCollateralDisabled(liqParams.collateralAsset, liqParams.user);
    }

    // Transfers the debt asset being repaid to the pToken, where the liquidity is kept
    IERC20(liqParams.debtAsset).safeTransferFrom(
      msg.sender,
      debtReserve.pTokenAddress,
      vars.actualDebtToLiquidate
    );

    emit LiquidationCall(
      liqParams.collateralAsset,
      liqParams.debtAsset,
      liqParams.user,
      vars.actualDebtToLiquidate,
      vars.maxCollateralToLiquidate,
      msg.sender,
      liqParams.receivePToken
    );

    return (uint256(Errors.CollateralManagerErrors.NO_ERROR), Errors.LPCM_NO_ERRORS);
  }

  struct AvailableCollateralToLiquidateLocalVars {
    uint256 userCompoundedBorrowBalance;
    uint256 liquidationBonus;
    uint256 collateralPrice;
    uint256 debtAssetPrice;
    uint256 maxAmountCollateralToLiquidate;
    uint256 debtAssetDecimals;
    uint256 collateralDecimals;
  }

  /**
   * @dev Calculates how much of a specific collateral can be liquidated, given
   * a certain amount of debt asset.
   * - This function needs to be called after all the checks to validate the liquidation have been performed,
   *   otherwise it might fail.
   * @param collateralReserve The data of the collateral reserve
   * @param debtReserve The data of the debt reserve
   * @param collateralAsset The address of the underlying asset used as collateral, to receive as result of the liquidation
   * @param debtAsset The address of the underlying borrowed asset to be repaid with the liquidation
   * @param debtToCover The debt amount of borrowed `asset` the liquidator wants to cover
   * @param userCollateralBalance The collateral balance for the specific `collateralAsset` of the user being liquidated
   * @return collateralAmount: The maximum amount that is possible to liquidate given all the liquidation constraints
   *                           (user balance, close factor)
   *         debtAmountNeeded: The amount to repay with the liquidation
   **/
  function _calculateAvailableCollateralToLiquidate(
    DataTypes.ReserveData storage collateralReserve,
    DataTypes.ReserveData storage debtReserve,
    address collateralAsset,
    address debtAsset,
    uint256 debtToCover,
    uint256 userCollateralBalance
  ) internal view returns (uint256, uint256) {
    uint256 collateralAmount = 0;
    uint256 debtAmountNeeded = 0;
    IPriceOracleGetter oracle = IPriceOracleGetter(_addressesProvider.getPriceOracle());

    AvailableCollateralToLiquidateLocalVars memory vars;

    vars.collateralPrice = oracle.getAssetPrice(collateralAsset);
    vars.debtAssetPrice = oracle.getAssetPrice(debtAsset);

    (, , vars.liquidationBonus, vars.collateralDecimals, ) = collateralReserve
      .configuration
      .getParams();
    vars.debtAssetDecimals = debtReserve.configuration.getDecimals();

    // This is the maximum possible amount of the selected collateral that can be liquidated, given the
    // max amount of liquidatable debt
    vars.maxAmountCollateralToLiquidate = vars
      .debtAssetPrice
      * debtToCover
      * (10**vars.collateralDecimals)
      .percentMul(vars.liquidationBonus)
      / (vars.collateralPrice * (10**vars.debtAssetDecimals));

    if (vars.maxAmountCollateralToLiquidate > userCollateralBalance) {
      collateralAmount = userCollateralBalance;
      debtAmountNeeded = vars
        .collateralPrice
        * (collateralAmount)
        * (10**vars.debtAssetDecimals)
        / (vars.debtAssetPrice * (10**vars.collateralDecimals))
        .percentDiv(vars.liquidationBonus);
    } else {
      collateralAmount = vars.maxAmountCollateralToLiquidate;
      debtAmountNeeded = debtToCover;
    }
    return (collateralAmount, debtAmountNeeded);
  }
}