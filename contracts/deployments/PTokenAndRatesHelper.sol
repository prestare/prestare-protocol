// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Ownable} from "../dependencies/Ownable.sol";
import {CounterConfigurator} from "../protocol/Counter/CounterConfigurator.sol";

import "hardhat/console.sol";

contract PTokenAndRatesHelper is Ownable {
    address payable private pool;
    address private addressesProvider;
    address private poolConfigurator;
    event deployedContracts(address pToken, address strategy);

    struct InitDeploymentInput {
        address asset;
        uint256[6] rates;
    }

    struct ConfigureReserveInput {
        address asset;
        uint256 baseLTV;
        uint256 liquidationThreshold;
        uint256 liquidationBonus;
        uint256 reserveFactor;
        bool stableBorrowingEnabled;
    }

    constructor(
        address payable _pool,
        address _addressesProvider,
        address _poolConfigurator
    ) public {
        pool = _pool;
        addressesProvider = _addressesProvider;
        poolConfigurator = _poolConfigurator;
    }

    function configureReserves(ConfigureReserveInput[] calldata inputParams) external onlyOwner {
        CounterConfigurator configurator = CounterConfigurator(poolConfigurator);
        // console.log("5555");
        // console.log(inputParams.length);
        for (uint256 i = 0; i < inputParams.length; i++) {
            configurator.configureReserveAsCollateral(
                inputParams[i].asset,
                inputParams[i].baseLTV,
                inputParams[i].liquidationThreshold,
                inputParams[i].liquidationBonus
            );
        }
    }
}
