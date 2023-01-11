// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import {SafeMath} from '../../../dependencies/openzeppelin/contracts/SafeMath.sol';
import {IERC20} from '../../../dependencies/openzeppelin/contracts/IERC20.sol';
import {ReserveLogic} from './ReserveLogic.sol';
import {GenericLogic} from './GenericLogic.sol';
import {WadRayMath} from '../math/WadRayMath.sol';
import {PercentageMath} from '../math/PercentageMath.sol';
import {SafeERC20} from '../../../dependencies/openzeppelin/contracts/SafeERC20.sol';
import {ReserveConfiguration} from '../configuration/ReserveConfiguration.sol';
import {UserConfiguration} from '../configuration/UserConfiguration.sol';
import {Errors} from '../helpers/Errors.sol';
import {Helpers} from '../helpers/Helpers.sol';
import {IReserveInterestRateStrategy} from '../../../interfaces/IReserveInterestRateStrategy.sol';
import {DataTypes} from '../types/DataTypes.sol';

// import {ABDKMath64x64} from '../helpers/ABDKMath64x64.sol';
import {ICRT} from '../../../CRT/ICRT.sol';
/**
 * @title CRT Logic Library
 */

// credit token的兑换机制，交易所的gas费影响，如何分发crt
library CRTLogic {
    using SafeMath for uint256;
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
        uint256 userCanUseBalance =  IERC20(crt).balanceOf(user) - ICRT(crt).lockBalance(user);
        require(userCanUseBalance >= amount, Errors.CRT_INVALID_AMOUNT);
    }

    struct CrtBorrowVars {
        uint userCollateralBalanceETH;
        uint userBorrowBalanceETH;
        uint currentLtv;
    }

    function calculateCRTBorrow(
        address userAddress,
        uint cf,
        uint256 amount,
        uint256 amountInETH,
        CrtBorrowVars memory vars
    ) external returns (uint) {
        // CrtBorrowVars memory vars;
        // (
        //     vars.userCollateralBalanceETH,
        //     vars.userBorrowBalanceETH,
        //     vars.currentLtv,
        //     ,
        // ) = GenericLogic.calculateUserAccountData(
        //     userAddress,
        //     reservesData,
        //     userConfig,
        //     reserves,
        //     reservesCount,
        //     oracle
        // );

        // todo add the crt logic how to calculate the idle amount
        // uint cf = reserve.configuration.getReserveFactor();
        uint collateralNotBeBorrowed = vars.userCollateralBalanceETH.sub(vars.userBorrowBalanceETH.div(cf));

        uint crtltv = amountInETH.div(collateralNotBeBorrowed);
        uint additionalAmount = amountInETH - collateralNotBeBorrowed * cf;
        uint crtamount = calculateCRTDecay(crtltv, cf, additionalAmount);

        return crtamount;
    }

    struct CrtUseVars {
        uint userCollateralBalanceETH;
        uint userBorrowBalanceETH;
        uint currentLtv;
        uint newdebt;
        uint newltv;
        uint oldcrtvalue;
        uint newcrtvalue;
    }

    function calculateCRTRepay(
        address userAddress,
        uint cf,
        uint256 amount,
        uint256 amountInETH,
        CrtUseVars memory vars,
        address crtaddress
    ) external returns (uint) {
        // CrtUseVars memory vars;
        // (
        //     vars.userCollateralBalanceETH,
        //     vars.userBorrowBalanceETH,
        //     vars.currentLtv,
        //     ,
        // ) = GenericLogic.calculateUserAccountData(
        //     userAddress,
        //     reservesData,
        //     userConfig,
        //     reserves,
        //     reservesCount,
        //     oracle
        // );
        
        vars.newdebt = vars.userBorrowBalanceETH - amountInETH;
        vars.newltv = vars.newdebt.div(vars.userCollateralBalanceETH);
        // uint cf = reserve.configuration.getReserveFactor();

        vars.oldcrtvalue = calculateCRTValue(vars.currentLtv, cf);
        vars.newcrtvalue = calculateCRTValue(vars.newltv, cf);
        uint userlockBalance = ICRT(crtaddress).lockBalance(userAddress);
        uint idleCRTValue = userlockBalance * (vars.newcrtvalue.sub(vars.oldcrtvalue));
        // todo it need more validation? like check the user health factor?
        return idleCRTValue;
    }

    function calculateCRTDecay(uint256 ltv, uint256 cf, uint256 additional_amount) internal returns (uint) {

        uint crtvcalculateCRTDecayalue = calculateCRTValue(ltv, cf);
        uint crtNeed = additional_amount.rayDiv(crtvcalculateCRTDecayalue);
        
        // uint256 crtAmount = ABDKMath64x64.toUInt(crtvcalculateCRTDecayalue);

        return crtNeed;
    }

    function calculateCRTValue(uint256 ltv, uint256 cf) internal returns (uint256) {
        // scale by 1e18
        uint256 first = cf.mul(ltv.sub(cf));
        // TODO !! there may be error that caused by conversion
        // exp的溢出问题，精度损失，公式的优化, 牛顿算法
        // 求导牛顿
        // int128 second = 0 - ABDKMath64x64.fromUInt(first);
        // int128 crtvalue_128 = ABDKMath64x64.log_2(ABDKMath64x64.exp(second) + 1);
        // 原式太过复杂，因此使用泰勒展开来逼近实际结果
        // exp(-x) x == first
        // 1 - x + x^2/2 - x^3/6
        
        uint256 second = WadRayMath.WAD.sub(first).add(first.mul(first).div(2e18)).sub(first.mul(first).div(6e18).mul(first));
        // log(1+x)
        // x - x^2/2 + x^3/3
        uint256 crtvalue = second.sub(second.mul(second).div(2e18)).add(second.mul(second).div(3e18).mul(second));

        // uint256 crtvalue = ABDKMath64x64.toUInt(crtvalue_128);
        if (crtvalue < floodPrice){
            crtvalue = floodPrice;
        }
        return crtvalue;
    }

}