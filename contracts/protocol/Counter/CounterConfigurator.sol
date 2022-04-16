// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;

import { CounterConfiguratorInterface } from "../../Interfaces/CounterConfiguratorInterface.sol";
import { CounterAddressProviderInterface } from "../../Interfaces/CounterAddressProviderInterface.sol";
import { CounterInterface } from "../../Interfaces/CounterInterface.sol";
import { InitialPToken } from "../../Interfaces/InitialPToken.sol"; 
import { InitialCRT } from "../../Interfaces/InitialCRT.sol"; 
import { IncentiveController } from "../../Interfaces/IncentiveController.sol"; 
import { PrestareCounterStorage } from "../../DataType/PrestareStorage.sol";
import { InitializableImmutableAdminUpgradeabilityProxy } from "../utils/InitAdminUpgradeProxy.sol";
import { AssetConfiguration } from "../utils/AssetConfiguration.sol";
import { EIP20Interface } from "../../dependencies/EIP20Interface.sol";

import "hardhat/console.sol";

contract CounterConfigurator is CounterConfiguratorInterface {
    uint256 internal constant CONFIGURATOR_REVISION = 0x1;
    using AssetConfiguration for PrestareCounterStorage.CounterConfigMapping;

    CounterAddressProviderInterface internal addressProvider;
    CounterInterface internal counter;

    modifier onlyPoolAdmin {
        require(addressProvider.getCounterAdmin() == msg.sender, "Error");
        _;
    }

    function getRevision() internal pure returns (uint256) {
        return CONFIGURATOR_REVISION;
    }

    function initialize(CounterAddressProviderInterface provider) public {
        addressProvider = provider;
        counter = CounterInterface(addressProvider.getCounter());
    }

    /**
    * @dev Initializes reserves in batch
    **/
    function batchInitReserve(InitReserveInput[] calldata input) external onlyPoolAdmin {
        CounterInterface cachedPool = counter;
        for (uint256 i = 0; i < input.length; i++) {
            _initReserve(cachedPool, input[i]);
        }
    }

    function _initReserve(CounterInterface counter_, InitReserveInput calldata input) internal {
        address pTokenProxyAddress = 
            _initTokenWithProxy(
                input.pTokenImpl,
                abi.encodeWithSelector(
                    InitialPToken.initialize.selector,
                    counter_,
                    input.treasury,
                    input.underlyingAsset,
                    input.underlyingAssetDecimals,
                    input.pTokenName,
                    input.pTokenSymbol,
                    input.params
                )
            );
        
        address crtProxyAddress = 
            _initTokenWithProxy(
                input.crtTokenImpl,
                abi.encodeWithSelector(
                    InitialCRT.initialize.selector,
                    counter_,
                    input.crtDecimals,
                    input.crtName,
                    input.crtSymbol,
                    input.crtParams
                )
            );
        console.log("1244");
        console.log(crtProxyAddress);
        counter_.initReserve(
        input.underlyingAsset,
        pTokenProxyAddress,
        crtProxyAddress,
        input.interestRateStrategyAddress
        );

        PrestareCounterStorage.CounterConfigMapping memory currentConfig =
        counter_.getConfiguration(input.underlyingAsset);

        currentConfig.setDecimals(input.underlyingAssetDecimals);

        currentConfig.setActive(true);
        currentConfig.setFrozen(false);

        counter_.setConfiguration(input.underlyingAsset, currentConfig.data);

        // TODO: for tmp use.
        emit ReserveInitialized(
        input.underlyingAsset,
        pTokenProxyAddress,
        input.interestRateStrategyAddress
        );
    }

    /**
   * @dev Configures the reserve collateralization parameters
   * all the values are expressed in percentages with two decimals of precision. A valid value is 10000, which means 100.00%
   * @param asset The address of the underlying asset of the reserve
   * @param ltv The loan to value of the asset when used as collateral
   * @param liquidationThreshold The threshold at which loans using this asset as collateral will be considered undercollateralized
   * @param liquidationBonus The bonus liquidators receive to liquidate this asset. The values is always above 100%. A value of 105%
   * means the liquidator will receive a 5% bonus
   **/
    function configureReserveAsCollateral(
        address asset,
        uint256 ltv,
        uint256 liquidationThreshold,
        uint256 liquidationBonus
    ) external onlyPoolAdmin {
        PrestareCounterStorage.CounterConfigMapping memory currentConfig = counter.getConfiguration(asset);
        // console.log("0000");
        // console.log(asset);
        // console.log(ltv);
        // console.log(liquidationThreshold);
        // console.log(liquidationBonus);

        //validation of the parameters: the LTV can
        //only be lower or equal than the liquidation threshold
        //(otherwise a loan against the asset would cause instantaneous liquidation)
        require(ltv <= liquidationThreshold, "Error");

        // TODO: check the neccessary

        // if (liquidationThreshold != 0) {
        // // //liquidation bonus must be bigger than 100.00%, otherwise the liquidator would receive less
        // // //collateral than needed to cover the debt
        // // require(
        // //     liquidationBonus > PercentageMath.PERCENTAGE_FACTOR,
        // //     "Error"
        // // );

        // //if threshold * bonus is less than PERCENTAGE_FACTOR, it's guaranteed that at the moment
        // //a loan is taken there is enough collateral available to cover the liquidation bonus
        // require(
        //     liquidationThreshold.percentMul(liquidationBonus) <= PercentageMath.PERCENTAGE_FACTOR,
        //     Errors.LPC_INVALID_CONFIGURATION
        // );
        // } else {
        // require(liquidationBonus == 0, Errors.LPC_INVALID_CONFIGURATION);
        // //if the liquidation threshold is being set to 0,
        // // the reserve is being disabled as collateral. To do so,
        // //we need to ensure no liquidity is deposited
        // _checkNoLiquidity(asset);
        // }

        currentConfig.setLtv(ltv);
        currentConfig.setLiquidationThreshold(liquidationThreshold);
        currentConfig.setLiquidationBonus(liquidationBonus);
        // console.log(currentConfig.data);

        counter.setConfiguration(asset, currentConfig.data);

        emit CollateralConfigurationChanged(asset, ltv, liquidationThreshold, liquidationBonus);
    }

    function _initTokenWithProxy(address implementation, bytes memory initParams) internal returns (address)
    {   
        // console.logBytes(initParams);
        InitializableImmutableAdminUpgradeabilityProxy proxy =
            new InitializableImmutableAdminUpgradeabilityProxy(address(this));
        proxy.initialize(implementation, initParams);

        return address(proxy);
    }

    /**
     * @dev Updates the reserve factor of a reserve
     * @param asset The address of the underlying asset of the reserve
     * @param reserveFactor The new reserve factor of the reserve
     */
    // function setReserveFactor(address asset, uint256 reserveFactor) external onlyPoolAdmin {
    //     PrestareCounterStorage.CounterConfigMapping memory currentConfig = counter.getConfiguration(asset);

    //     currentConfig.setReserveFactor(reserveFactor);

    //     counter.setConfiguration(asset, currentConfig.data);

    //     emit ReserveFactorChanged(asset, reserveFactor);
    // }
    /**
     * @dev Deactivates a reserve
     * @param asset The address of the underlying asset of the reserve
     */
    function deactivateReserve(address asset) external onlyPoolAdmin {
        _checkNoLiquidity(asset);

        PrestareCounterStorage.CounterConfigMapping memory currentConfig = counter.getConfiguration(asset);

        currentConfig.setActive(false);

        counter.setConfiguration(asset, currentConfig.data);

        emit ReserveDeactivated(asset);
    }

    function _checkNoLiquidity(address asset) internal view {
        PrestareCounterStorage.CounterProfile memory reserveData = counter.getReserveData(asset);

        uint256 availableLiquidity = EIP20Interface(asset).balanceOf(reserveData.pTokenAddress);

        require(
            availableLiquidity == 0 && reserveData.currentLiquidityRate == 0,
            "Errors"
        );
    }
}