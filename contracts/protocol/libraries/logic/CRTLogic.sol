// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.10;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ReserveLogic} from './ReserveLogic.sol';
import {GenericLogic} from './GenericLogic.sol';
import {WadRayMath} from '../math/WadRayMath.sol';
import {PercentageMath} from '../math/PercentageMath.sol';
import {ReserveConfiguration} from '../configuration/ReserveConfiguration.sol';
import {UserConfiguration} from '../configuration/UserConfiguration.sol';
import {Errors} from '../helpers/Errors.sol';
import {IReserveInterestRateStrategy} from '../../../interfaces/IReserveInterestRateStrategy.sol';
import {DataTypes} from '../types/DataTypes.sol';

import {ICRT} from '../../../CRT/ICRT.sol';
/**
 * @title CRT Logic Library
 */

// credit token的兑换机制，交易所的gas费影响，如何分发crt
library CRTLogic {

    using WadRayMath for uint256;
    using ReserveLogic for DataTypes.ReserveData;
    using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

    uint256 public constant dec = 0;
    // the flood price is 0.574 scaled by 1e18
    uint256 public constant floodPrice = 574e15;

    /**
     * @dev validate a user has enought crt in their wallet
     */
    function validateCRTBalance(address crt, address user, uint256 amount) external view {
        uint256 userCanUseBalance = IERC20(crt).balanceOf(user) - ICRT(crt).lockBalance(user);
        require(userCanUseBalance >= amount, Errors.CRT_INVALID_AMOUNT);
    }

    struct CrtBorrowVars {
        uint256 cf;
        uint256 collateralNotBeBorrowed;
        uint256 crtltv;
        uint256 additionalAmount;
        uint256 crtamount;
    }
    function calculateCRTBorrow(
        address userAddress,
        DataTypes.ReserveData storage reserve,
        uint256 amount,
        uint256 amountInETH,
        DataTypes.UserAccountVars memory userStateVars,
        address oracle
    ) external returns (uint) {
        CrtBorrowVars memory vars;
        // todo add the crt logic how to calculate the idle amount
        vars.cf = reserve.configuration.getReserveFactor();
        vars.collateralNotBeBorrowed = userStateVars.userCollateralBalanceETH - userStateVars.userBorrowBalanceETH / vars.cf;

        vars.crtltv = amountInETH / vars.collateralNotBeBorrowed;
        vars.additionalAmount = amountInETH - vars.collateralNotBeBorrowed * vars.cf;
        vars.crtamount = calculateCRTDecay(vars.crtltv, vars.cf, vars.additionalAmount);

        return vars.crtamount;
    }

    // function calculateCRTRepay(
    //     address userAddress,
    //     DataTypes.ReserveData storage reserve,
    //     uint256 amount,
    //     uint256 amountInETH,
    //     mapping(address => DataTypes.ReserveData) storage reservesData,
    //     DataTypes.UserConfigurationMap storage userConfig,
    //     mapping(uint256 => address) storage reserves,
    //     uint256 reservesCount,
    //     address oracle,
    //     address crtaddress
    // ) external returns (uint) {
    //     (
    //         uint userCollateralBalanceETH,
    //         uint userBorrowBalanceETH,
    //         uint currentLtv,
    //         ,
    //     ) = GenericLogic.calculateUserAccountData(
    //         userAddress,
    //         reservesData,
    //         userConfig,
    //         reserves,
    //         reservesCount,
    //         oracle
    //     );
        
    //     uint newdebt = userBorrowBalanceETH - amountInETH;
    //     uint newltv = newdebt / userCollateralBalanceETH;
    //     uint cf = reserve.configuration.getReserveFactor();

    //     uint oldcrtvalue = calculateCRTValue(currentLtv, cf);
    //     uint newcrtvalue = calculateCRTValue(newltv, cf);
    //     uint userlockBalance = ICRT(crtaddress).lockBalance(userAddress);
    //     uint idleCRTValue = userlockBalance * newcrtvalue - (oldcrtvalue);
    //     // todo it need more validation? like check the user health factor?
    //     return idleCRTValue;
    // }

    function calculateCRTDecay(uint256 ltv, uint256 cf, uint256 additional_amount) internal returns (uint) {

        uint crtvcalculateCRTDecayalue = calculateCRTValue(ltv, cf);
        uint crtAmount = additional_amount.rayDiv(crtvcalculateCRTDecayalue);
        
        return crtAmount;
    }

    function calculateCRTValue(uint256 ltv, uint256 cf) internal returns (uint) {
        // scale by 1e18
        uint256 first = cf * (ltv - cf);
        // TODO !! there may be error that caused by conversion
        // exp的溢出问题，精度损失，公式的优化, 牛顿算法
        // 求导牛顿
        // int128 second = 0 - ABDKMath64x64.fromUInt(first);
        // int128 crtvalue_128 = ABDKMath64x64.log_2(ABDKMath64x64.exp(second) + 1);
        // 原式太过复杂，因此使用泰勒展开来逼近实际结果
        // exp(-x) x == first
        // 1 - x + x^2/2 - x^3/6
        
        uint256 second = WadRayMath.WAD - first + (first * first / (2e18)) - (first * first / (6e18) * first);
        // log(1+x)
        // x - x^2/2 + x^3/3
        uint256 crtvalue = second - (second * second / (2e18)) + (second * second / (3e18) * second);

        // uint256 crtvalue = ABDKMath64x64.toUInt(crtvalue_128);
        if (crtvalue < floodPrice){
            crtvalue = floodPrice;
        }
        return crtvalue;
    }

}