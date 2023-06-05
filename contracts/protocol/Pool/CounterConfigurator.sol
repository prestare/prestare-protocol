// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import {ICounter} from '../../interfaces/ICounter.sol';
import {ICounterAddressesProvider} from '../../interfaces/ICounterAddressesProvider.sol';
import {ICounterConfigurator} from '../../interfaces/ICounterConfigurator.sol';

import {Errors} from '../libraries/helpers/Errors.sol';
import {ReserveConfiguration} from '../libraries/configuration/ReserveConfiguration.sol';

import {PercentageMath} from '../libraries/math/PercentageMath.sol';
import {DataTypes} from '../libraries/types/DataTypes.sol';
import {ReserveLogic} from '../libraries/logic/ReserveLogic.sol';

import {ICounterConfigurator} from '../../interfaces/ICounterConfigurator.sol';
import {IInitializablePToken} from '../../interfaces/IInitializablePToken.sol';
import {IInitializableDebtToken} from '../../interfaces/IInitializableDebtToken.sol';

import "hardhat/console.sol";

contract CounterConfigurator is ICounterConfigurator {
  using PercentageMath for uint256;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

  ICounterAddressesProvider internal addressesProvider;
  ICounter internal _counter;
  uint8 internal _initAssetTier;

  modifier onlyPoolAdmin {
    require(addressesProvider.getPoolAdmin() == msg.sender, Errors.CALLER_NOT_POOL_ADMIN);
    _;
  }

  modifier onlyEmergencyAdmin {
    console.log(addressesProvider.getEmergencyAdmin());
    console.log(msg.sender);
    require(
      addressesProvider.getEmergencyAdmin() == msg.sender,
      Errors.LPC_CALLER_NOT_EMERGENCY_ADMIN
    );
    _;
  }

  uint256 internal constant CONFIGURATOR_REVISION = 0x1;

  function getRevision() internal pure returns (uint256) {
    return CONFIGURATOR_REVISION;
  }

  function initialize(ICounterAddressesProvider provider) public {
    addressesProvider = provider;
    // C Tier
    _initAssetTier = 2;
    _counter = ICounter(addressesProvider.getCounter());
  }

  function _initToken(
    ICounter cache,
    InitReserveInput calldata input
  ) internal {
    IInitializablePToken(input.pToken).initialize(
      cache,
      input.treasury,
      input.underlyingAsset,
      input.assetRiskTier,
      input.underlyingAssetDecimals,
      input.pTokenName,
      input.pTokenSymbol,
      input.params
    );
    IInitializableDebtToken(input.variableDebtToken).initialize(
      cache, 
      input.underlyingAsset, 
      input.assetRiskTier,
      input.underlyingAssetDecimals, 
      input.variableDebtTokenName, 
      input.variableDebtTokenSymbol, 
      input.params
    );
  }

  function initReserve(InitReserveInput calldata input) external {
    ICounter cache = _counter;
    require(input.assetRiskTier == _initAssetTier, "Init Reserve in wrong risk Tier");
    // console.log("init pToken");
    _initToken(cache, input);

    _counter.initReserve(
      input.underlyingAsset,
      input.assetRiskTier,
      input.pToken,
      input.variableDebtToken,
      input.interestRateStrategyAddress
    );
    DataTypes.ReserveConfigurationMap memory currentConfig =
    _counter.getConfiguration(input.underlyingAsset, _initAssetTier);

    currentConfig.setDecimals(input.underlyingAssetDecimals);

    currentConfig.setActive(true);
    currentConfig.setFrozen(false);

    _counter.setConfiguration(input.underlyingAsset, _initAssetTier, currentConfig.data);

    emit ReserveInitialized(
      input.underlyingAsset,
      input.pToken,
      input.variableDebtToken,
      input.interestRateStrategyAddress
    );
  }

  function upgradeAssetClass(InitReserveInput calldata input) external onlyPoolAdmin{
    console.log("upgradeAssetClass...");
    ICounter cache = _counter;

    _initToken(cache, input);

    _counter.upgradeAssetClass(
      input.underlyingAsset,
      input.pToken,
      input.variableDebtToken,
      input.interestRateStrategyAddress
    );
    // after upgrade, the asset Class will minus one
    uint8 assetClass = _counter.getAssetClass(input.underlyingAsset);
    DataTypes.ReserveConfigurationMap memory currentConfig =
    _counter.getConfiguration(input.underlyingAsset, assetClass);

    currentConfig.setDecimals(input.underlyingAssetDecimals);

    currentConfig.setActive(true);
    currentConfig.setFrozen(false);

    _counter.setConfiguration(input.underlyingAsset, assetClass, currentConfig.data);

    emit ReserveClassUpdate(
      input.underlyingAsset,
      assetClass,
      1,
      input.pToken,
      input.variableDebtToken,
      input.interestRateStrategyAddress
    );
  }

  function degradeAssetClass(address asset) external onlyPoolAdmin{
    ICounter cache = _counter;

    _counter.degradeAssetClass(
      asset
    );
    // after degrade, the asset Class will plus one
    uint8 assetClass = _counter.getAssetClass(asset);
    DataTypes.ReserveData memory currentData = _counter.getReserveData(asset, assetClass);
    
    emit ReserveClassUpdate(
      asset,
      assetClass,
      0,
      currentData.pTokenAddress,
      currentData.variableDebtTokenAddress,
      currentData.interestRateStrategyAddress
    );
  }
  /**
   * @dev Enables borrowing on a reserve
   * @param asset The address of the underlying asset of the reserve
   * @param riskTier The risk tier of the asset
   * @param stableBorrowRateEnabled True if stable borrow rate needs to be enabled by default on this reserve
   **/
  function enableBorrowingOnReserve(address asset, uint8 riskTier, bool stableBorrowRateEnabled)
    external
    onlyPoolAdmin
  {
    DataTypes.ReserveConfigurationMap memory currentConfig = _counter.getConfiguration(asset , riskTier);

    currentConfig.setBorrowingEnabled(true);
    currentConfig.setStableRateBorrowingEnabled(stableBorrowRateEnabled);

    _counter.setConfiguration(asset, riskTier, currentConfig.data);

    emit BorrowingEnabledOnReserve(asset, stableBorrowRateEnabled);
  }

  /**
   * @dev Disables borrowing on a reserve
   * @param asset The address of the underlying asset of the reserve
   * @param riskTier The risk tier of the asset
   **/
  function disableBorrowingOnReserve(address asset, uint8 riskTier) external onlyPoolAdmin {
    DataTypes.ReserveConfigurationMap memory currentConfig = _counter.getConfiguration(asset, riskTier);

    currentConfig.setBorrowingEnabled(false);

    _counter.setConfiguration(asset, riskTier, currentConfig.data);
    emit BorrowingDisabledOnReserve(asset);
  }

    /**
   * @dev Configures the reserve collateralization parameters
   * all the values are expressed in percentages with two decimals of precision. A valid value is 10000, which means 100.00%
   * @param asset The address of the underlying asset of the reserve
   * @param riskTier The risk tier of the asset
   * @param ltv The loan to value of the asset when used as collateral
   * @param liquidationThreshold The threshold at which loans using this asset as collateral will be considered undercollateralized
   * @param liquidationBonus The bonus liquidators receive to liquidate this asset. The values is always above 100%. A value of 105%
   * means the liquidator will receive a 5% bonus
   **/
  function configureReserveAsCollateral(
    address asset,
    uint8 riskTier,
    uint256 ltv,
    uint256 liquidationThreshold,
    uint256 liquidationBonus
  ) external onlyPoolAdmin {
    console.log("configureReserveAsCollateral");
    DataTypes.ReserveConfigurationMap memory currentConfig = _counter.getConfiguration(asset, riskTier);
    console.log("asset is:", asset);
    // console.log("riskTier is:", riskTier);

    require(currentConfig.getActive(), Errors.VL_NO_ACTIVE_RESERVE);

    //validation of the parameters: the LTV can
    //only be lower or equal than the liquidation threshold
    //(otherwise a loan against the asset would cause instantaneous liquidation)
    require(ltv <= liquidationThreshold, Errors.LPC_INVALID_CONFIGURATION);

    if (liquidationThreshold != 0) {
      //liquidation bonus must be bigger than 100.00%, otherwise the liquidator would receive less
      //collateral than needed to cover the debt
      require(
        liquidationBonus > PercentageMath.PERCENTAGE_FACTOR,
        Errors.LPC_INVALID_CONFIGURATION
      );

      //if threshold * bonus is less than PERCENTAGE_FACTOR, it's guaranteed that at the moment
      //a loan is taken there is enough collateral available to cover the liquidation bonus
      require(
        liquidationThreshold.percentMul(liquidationBonus) <= PercentageMath.PERCENTAGE_FACTOR,
        Errors.LPC_INVALID_CONFIGURATION
      );
    } else {
      require(liquidationBonus == 0, Errors.LPC_INVALID_CONFIGURATION);
      //if the liquidation threshold is being set to 0,
      // the reserve is being disabled as collateral. To do so,
      //we need to ensure no liquidity is deposited
      _checkNoLiquidity(asset, riskTier);
    }

    currentConfig.setLtv(ltv);
    currentConfig.setLiquidationThreshold(liquidationThreshold);
    currentConfig.setLiquidationBonus(liquidationBonus);

    _counter.setConfiguration(asset, riskTier, currentConfig.data);

    emit CollateralConfigurationChanged(asset, ltv, liquidationThreshold, liquidationBonus);
  }

  /**
   * @dev Activates a reserve
   * @param asset The address of the underlying asset of the reserve
   **/
  function activateReserve(address asset, uint8 riskTier) external onlyPoolAdmin {
    DataTypes.ReserveConfigurationMap memory currentConfig = _counter.getConfiguration(asset, riskTier);

    currentConfig.setActive(true);

    _counter.setConfiguration(asset, riskTier, currentConfig.data);

    emit ReserveActivated(asset, riskTier);
  }

  /**
   * @dev Deactivates a reserve
   * @param asset The address of the underlying asset of the reserve
   **/
  function deactivateReserve(address asset, uint8 riskTier) external onlyPoolAdmin {
    _checkNoLiquidity(asset, riskTier);

    DataTypes.ReserveConfigurationMap memory currentConfig = _counter.getConfiguration(asset, riskTier);

    currentConfig.setActive(false);

    _counter.setConfiguration(asset, riskTier, currentConfig.data);

    emit ReserveDeactivated(asset, riskTier);
  }

  /**
   * @dev Freezes a reserve. A frozen reserve doesn't allow any new deposit, borrow or rate swap
   *  but allows repayments, liquidations, rate rebalances and withdrawals
   * @param asset The address of the underlying asset of the reserve
   * @param riskTier The risk tier of the asset
   **/
  function freezeReserve(address asset, uint8 riskTier) external onlyPoolAdmin {
    DataTypes.ReserveConfigurationMap memory currentConfig = _counter.getConfiguration(asset, riskTier);

    currentConfig.setFrozen(true);

    _counter.setConfiguration(asset, riskTier, currentConfig.data);

    emit ReserveFrozen(asset, riskTier);
  }

  /**
   * @dev Unfreezes a reserve
   * @param asset The address of the underlying asset of the reserve
   * @param riskTier The risk tier of the asset
   **/
  function unfreezeReserve(address asset, uint8 riskTier) external onlyPoolAdmin {
    DataTypes.ReserveConfigurationMap memory currentConfig = _counter.getConfiguration(asset, riskTier);

    currentConfig.setFrozen(false);

    _counter.setConfiguration(asset, riskTier, currentConfig.data);

    emit ReserveUnfrozen(asset, riskTier);
  }

  /**
   * @dev Updates the reserve factor of a reserve
   * @param asset The address of the underlying asset of the reserve
   * @param reserveFactor The new reserve factor of the reserve
   * @param riskTier The risk tier of the asset
   **/
  function setReserveFactor(address asset, uint8 riskTier, uint256 reserveFactor) external onlyPoolAdmin {
    DataTypes.ReserveConfigurationMap memory currentConfig = _counter.getConfiguration(asset, riskTier);

    currentConfig.setReserveFactor(reserveFactor);

    _counter.setConfiguration(asset, riskTier, currentConfig.data);

    emit ReserveFactorChanged(asset, reserveFactor);
  }

  /**
   * @dev Sets the interest rate strategy of a reserve
   * @param asset The address of the underlying asset of the reserve
   * @param riskTier The risk tier of the asset
   * @param rateStrategyAddress The new address of the interest strategy contract
   **/
  function setReserveInterestRateStrategyAddress(address asset, uint8 riskTier, address rateStrategyAddress)
    external
    onlyPoolAdmin
  {
    _counter.setReserveInterestRateStrategyAddress(asset, riskTier, rateStrategyAddress);
    emit ReserveInterestRateStrategyChanged(asset, rateStrategyAddress);
  }

  /**
   * @dev pauses or unpauses all the actions of the protocol, including pToken transfers
   * @param val true if protocol needs to be paused, false otherwise
   **/
  function setPoolPause(bool val) external onlyEmergencyAdmin {
    _counter.setPause(val);
  }

  function setCRT(address crt) external onlyEmergencyAdmin {
    _counter.setCRT(crt);
  }

  function _checkNoLiquidity(address asset, uint8 riskTier) internal view {
    DataTypes.ReserveData memory reserveData = _counter.getReserveData(asset, riskTier);

    uint256 availableLiquidity = IERC20(asset).balanceOf(reserveData.pTokenAddress);

    require(
      availableLiquidity == 0 && reserveData.currentLiquidityRate == 0,
      Errors.LPC_RESERVE_LIQUIDITY_NOT_0
    );
  }
}
