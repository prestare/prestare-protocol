// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ReserveLogic} from './ReserveLogic.sol';
import {WadRayMath} from '../math/WadRayMath.sol';
import {PercentageMath} from '../math/PercentageMath.sol';
import {ReserveConfiguration} from '../configuration/ReserveConfiguration.sol';
import {UserConfiguration} from '../configuration/UserConfiguration.sol';
import {Errors} from '../helpers/Errors.sol';
import {IReserveInterestRateStrategy} from '../../../interfaces/IReserveInterestRateStrategy.sol';
import {DataTypes} from '../types/DataTypes.sol';

import {ICRT} from '../../../CRT/ICRT.sol';
import "hardhat/console.sol";
/**
 * @title CRT Logic Library
 */

// credit token的兑换机制，交易所的gas费影响，如何分发crt
library CRTLogic {
    using PercentageMath for uint256;
    using PercentageMath for int256;

    using WadRayMath for uint256;
    using ReserveLogic for DataTypes.ReserveData;
    using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

    uint256 public constant dec = 0;
    // the flood price is 0.574 scaled by 1e18
    uint256 public constant FLOODPRICE = 57e2;

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
        uint256 crtNeed;
        uint256 perCrtValueInUSD;
    }

    function calculateCRTBorrow(
        address userAddress,
        DataTypes.ReserveData storage reserve,
        uint256 amount,
        uint256 amountInUSD,
        DataTypes.UserAccountVars memory userStateVars,
        address oracle
    ) external returns (uint256, uint256) {
        CrtBorrowVars memory vars;
        // todo add the crt logic how to calculate the idle amount
        vars.cf = reserve.configuration.getLtv();
        console.log("calculateCRTBorrow - amountInUSD: ", amountInUSD);

        console.log("calculateCRTBorrow - collateral Factor is: ", vars.cf);
        console.log("calculateCRTBorrow - userCollateralBalanceUSD is: ", userStateVars.userCollateralBalanceUSD);
        console.log("calculateCRTBorrow - userBorrowBalanceUSD is: ", userStateVars.userBorrowBalanceUSD);
        // scaled by 18, against Eth
        // problem userBorrowBalance may be a multi-asset debt, but cf is a specific collateral factor, will be attack by other?
        vars.collateralNotBeBorrowed = userStateVars.userCollateralBalanceUSD - (userStateVars.userBorrowBalanceUSD).percentDiv(vars.cf);
        // amountInTETH is a 18 decimals number if they scaled by 18 again, it will be overflow problem? 
        // vars.crtltv = amountInUSD.wadDiv(vars.collateralNotBeBorrowed) * 10000 / WadRayMath.WAD;
        // crtltv is represented in percentage form
        vars.crtltv = amountInUSD.wadDiv(vars.collateralNotBeBorrowed) * 10000 / WadRayMath.WAD;
        
        // PROBLEM: when crtltv is represented in percentage form, but currentLtv is scaled by 18, 
        // there is a Accuracy problem
        
        console.log("calculateCRTBorrow - crtltv is: ", vars.crtltv);
        // sclaed by 18, against usd
        // uint256 canBorrowAmount = (vars.collateralNotBeBorrowed).percentMul(vars.cf);
        uint256 amountOfCollateralNeedUSD = amountInUSD.percentDiv(vars.cf);
        console.log("calculateCRTBorrow - amountOfCollateralNeedUSD: ", amountOfCollateralNeedUSD);

        // calculate the gap between use want to borrow and can Borrow Amount, which will be fill by the crt
        vars.additionalAmount = 0;
        if (vars.collateralNotBeBorrowed < amountOfCollateralNeedUSD) {
            vars.additionalAmount = amountOfCollateralNeedUSD -  vars.collateralNotBeBorrowed;
        }
        // problem: when amountInUSD < canBorrowAmount, if it can use crt to lower the ltv?
        console.log("calculateCRTBorrow - additionalAmount needed: ", vars.additionalAmount);
        // calculate when ltv is crtltv, the value of one crt
        vars.perCrtValueInUSD = calculateCRTValue(vars.crtltv, vars.cf);
        vars.crtNeed = calculateValueAfterDecay(vars.additionalAmount, vars.perCrtValueInUSD);
        console.log("calculateCRTBorrow - crtamount needed: ", vars.crtNeed);

        return (vars.crtNeed, vars.additionalAmount);
    }

    // struct CrtRepayVars {
    //     uint256 cf;
    //     uint256 collateralNotBeBorrowed;
    //     uint256 crtltv;
    //     uint256 additionalAmount;
    //     uint256 crtamount;
    // }
    function calculateCRTRepay(
        address userAddress,
        DataTypes.ReserveData storage reserve,
        uint256 amount,
        uint256 amountInUSD,
        DataTypes.UserAccountVars memory userStateVars,
        address crtaddress
    ) external returns (uint) {
        uint256 newdebt = userStateVars.userBorrowBalanceUSD - amountInUSD;
        uint256 newltv = newdebt.wadDiv(userStateVars.userCollateralBalanceUSD) * 10000 / WadRayMath.WAD;
        console.log("calculateCRTRepay - newltv is", newltv);
        uint cf = reserve.configuration.getLtv();
        console.log("calculateCRTRepay - currentLtv is", currentLtv);
        uint oldcrtvalue = calculateCRTValue(userStateVars.currentLtv, cf);
        uint newcrtvalue = calculateCRTValue(newltv, cf);
        if (newcrtvalue < oldcrtvalue) {
            return 0;
        }
        uint userlockBalance = ICRT(crtaddress).lockBalance(userAddress);
        if (userlockBalance == 0) {
            return 0;
        }
        uint idleCRT = userlockBalance * (newcrtvalue - oldcrtvalue);
        console.log("idelCRT value is: ", idleCRT);
        // todo it need more validation? like check the user health factor?
        return idleCRT;
    }

    function calculateValueAfterDecay(uint256 additional_amount, uint256 crtValue) internal returns (uint256) {

        uint256 crtAmount = additional_amount.percentDiv(crtValue);
        
        return crtAmount;
    }
    /**
     * @dev calculate value of one CRT
     * @param ltv in this borrow loan to value, in percentage
     * @param cf The collateral factor of the asset, represent in percentage
    */
    function calculateCRTValue(uint256 ltv, uint256 cf) internal returns (uint) {
        console.log("ltv is ", ltv);
        console.log("collateral factor is ", cf);
        if (ltv < cf) {
            return PercentageMath.BASIC_POINT;
        }
        // first is represent in percentage and max is 10000 = 100.00
        int256 first = int256(cf.percentMul(ltv - cf));
        console.log("first is ");
        console.logInt(first);

        // scaled by 18
        // TODO !! there may be error that caused by conversion
        // exp的溢出问题，精度损失，公式的优化, 牛顿算法
        // 求导牛顿
        // int128 second = 0 - ABDKMath64x64.fromUInt(first);
        // int128 crtvalue_128 = ABDKMath64x64.log_2(ABDKMath64x64.exp(second) + 1);
        // 原式太过复杂，因此使用泰勒展开来逼近实际结果
        // exp(-x); x == first
        // 1 - x + x^2/2 - x^3/6
        int256 second = int256(PercentageMath.BASIC_POINT) - first;
        console.log("second is...");
        console.logInt(second);
        second = second + first.percentMul(first)/ 2;
        console.logInt(second);
        second = second - first.percentMul(first).percentMul(first) / 6;
        // second = PercentageMath.BASIC_POINT * WadRayMath.GWEI - first + first.gweiMul(first).gweiDiv(2e9) - first.gweiMul(first).gweiDiv(6e9).gweiMul(first);
        console.logInt(second);

        // log(1+x); x = exp(-x);
        // x - x^2/2 + x^3/3
        // console.log(second);
        // console.log(second.percentMul(second) / 2);
        // console.log(second.percentMul(second).percentMul(second) / 3);
        uint256 crtvalue = uint256(second - second.percentMul(second ) / 2 + second.percentMul(second).percentMul(second) / 3);
        // console.log("crtvalue is ", crtvalue);

        require(crtvalue > 0, "Crt value lower than 0");
        // uint256 crtvalue = ABDKMath64x64.toUInt(crtvalue_128);
        if (crtvalue < FLOODPRICE){
            crtvalue = FLOODPRICE;
        }
        console.log("crtvalue is ", crtvalue);

        return uint256(crtvalue);
    }

}