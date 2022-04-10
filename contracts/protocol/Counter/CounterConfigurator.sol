// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;

import { CounterConfiguratorInterface } from "../../Interfaces/CounterConfiguratorInterface.sol";
import { CounterAddressProviderInterface } from "../../Interfaces/CounterAddressProviderInterface.sol";
import { CounterInterface } from "../../Interfaces/CounterInterface.sol";
import { InitialPToken } from "../../Interfaces/InitialPToken.sol"; 
import { IncentiveController } from "../../Interfaces/IncentiveController.sol"; 
import { AssetsLib } from "../../DataType/TypeLib.sol";
import { InitializableImmutableAdminUpgradeabilityProxy } from "../utils/InitAdminUpgradeProxy.sol";
import { AssetConfiguration } from "../utils/AssetConfiguration.sol";

import "hardhat/console.sol";

contract CounterConfigurator is CounterConfiguratorInterface {
    uint256 internal constant CONFIGURATOR_REVISION = 0x1;
    using AssetConfiguration for AssetsLib.AssetConfigMapping;

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
                IncentiveController(input.incentivesController),
                input.underlyingAssetDecimals,
                input.pTokenName,
                input.pTokenSymbol,
                input.params
            )
        );

        counter_.initReserve(
        input.underlyingAsset,
        pTokenProxyAddress,
        input.interestRateStrategyAddress
        );

        AssetsLib.AssetConfigMapping memory currentConfig =
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
        AssetsLib.AssetConfigMapping memory currentConfig = counter.getConfiguration(asset);
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
}