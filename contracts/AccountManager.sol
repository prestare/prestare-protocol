// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {PrestareCounterStorage} from "./DataType/PrestareStorage.sol";
import {UserConfiguration} from "./configs/UserConfiguration.sol";
import {ReserveLogic} from "./ReserveLogic.sol";
import {AssetsConfiguration} from "./AssetsConfiguration.sol";

contract AccountManager {

    using UserConfiguration for PrestareCounterStorage.UserConfigurationMapping;
    using AssetsConfiguration for PrestareCounterStorage.CounterConfigMapping;

    struct CalculateUserDataVars {
        uint256 i; // reserve index
        address reserveAddress;
        uint256 ltv;
        uint256 liquidationThreshold;
        uint256 decimals;
        uint256 tokenUnit;
        uint256 healthfactor;
    }


    /**
    @param reserveList The list of available reserve
    **/
    function calculateUserData(
        address user,
        PrestareCounterStorage.UserConfigurationMapping memory userConfig,
        uint256 tokenCount,
        mapping(uint256 => address) storage reserveList,
        mapping(address => PrestareCounterStorage.CounterProfile) storage counterProfile,
        address priceOracle
    ) 
        internal 
        view 
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        CalculateUserDataVars memory vars;

        if (userConfig.isEmpty()) {
            return (0, 0, type(uint256).max);
        }

        for (vars.i = 0; vars.i < tokenCount; vars.i++) {
            if (!userConfig.isUsingAsCollateralOrBorrowing(vars.i)) {
                continue;
            }

            vars.reserveAddress = reserveList[vars.i];
            PrestareCounterStorage.CounterProfile storage _counterProfile = counterProfile[vars.reserveAddress];

            (vars.ltv, vars.liquidationThreshold, , vars.decimals, ) = _counterProfile.configuration.getParams();

            // why?
            vars.tokenUnit = 10**vars.decimals;

        }
    }
}