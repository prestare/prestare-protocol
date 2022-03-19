// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import {TestRateModelInterface} from "./Interfaces/RateModel.sol";
import {CounterAddressProviderInterface} from "./Interfaces/CounterAddressProviderInterface.sol";
import {WadRayMath} from "./utils/WadRay.sol";
import {EIP20Interface} from "./dependencies/EIP20Interface.sol";

contract TestInterestRateModel is TestRateModelInterface {
    using WadRayMath for uint256;

    CounterAddressProviderInterface public immutable ADDRESS_PROVIDER;
    uint256 public immutable OPTIMAL_UTILIZATION_RATE;
    uint256 public immutable ONE_MINUS_OPTIMAL_U;

    uint256 internal immutable BASE_BORROW_RATE;
    uint256 internal immutable SLOPE1;
    uint256 internal immutable SLOPE2;

    constructor(
        CounterAddressProviderInterface addrProvider,
        uint256 optUtilizationRate,
        uint256 baseBorrowRate,
        uint256 slope1,
        uint256 slope2
    ) public {

        OPTIMAL_UTILIZATION_RATE = optUtilizationRate;
        ADDRESS_PROVIDER = addrProvider;
        // 数学计算方法待定
        ONE_MINUS_OPTIMAL_U = WadRayMath.ray() - (optUtilizationRate);
        BASE_BORROW_RATE = baseBorrowRate;
        SLOPE1 = slope1;
        SLOPE2 = slope2;
    }

    struct InterestRateLocalVars {
        uint256 totalBorrowAmount;
        uint256 currentBorrowRate;
        uint256 currentLiquidityRate;
        uint256 utilizationRate;
    }

    function calculateInterestRate(
        address assetAddr,
        address pTokenAddr,
        uint256 liquidityAdded,
        uint256 liquidityTaken,
        uint256 totalBorrowAmount,
        uint256 reserveFactor
    ) external view returns (uint256, uint256) {

        uint256 availableLiquidity = EIP20Interface(assetAddr).balanceOf(pTokenAddr);
        //确认数学计算方法
        availableLiquidity = availableLiquidity + liquidityAdded - liquidityTaken;
        return InterestModel1(assetAddr, availableLiquidity, totalBorrowAmount, reserveFactor);
    }

    function InterestModel1(
        address assetAddr,
        uint256 availableLiquidity,
        uint256 totalBorrowAmount,
        uint256 reserveFactor
    ) public view returns (uint256, uint256) {

        InterestRateLocalVars memory vars;

        // Initialization
        vars.totalBorrowAmount = totalBorrowAmount;
        vars.currentBorrowRate = 0;
        vars.currentLiquidityRate = 0;

        if (vars.totalBorrowAmount == 0) {
            vars.utilizationRate = 0;
        } else {
            // TODO: 确认数学计算逻辑
            vars.utilizationRate = vars.totalBorrowAmount / (availableLiquidity + vars.totalBorrowAmount);
        }


        // 根据白皮书, 判断当前UR与optimal U的关系
        if (vars.utilizationRate > OPTIMAL_UTILIZATION_RATE) {
            // excessRatio = (U - U_opt) / (1 - U_opt)
            // BorrowRate = base + slope_1 + excessRatio * slope_2
            // 确认数学计算方法
            uint256 excessRatio = (vars.utilizationRate - OPTIMAL_UTILIZATION_RATE) / ONE_MINUS_OPTIMAL_U;
            // 确认数学计算方法
            vars.currentBorrowRate = BASE_BORROW_RATE + SLOPE1 + (excessRatio * SLOPE2);
        } else {
            // BorrowRate = base + slope_1 * U / U_opt 
            // 确认数学计算方法
            vars.currentBorrowRate = BASE_BORROW_RATE + SLOPE1 * vars.utilizationRate / OPTIMAL_UTILIZATION_RATE;
        }

        // 计算当前流动性收益率
        // LiquidityRate = BorrowRate * U * (100 - reserveFactor)
        // 确认数学计算方法
        vars.currentLiquidityRate = vars.currentBorrowRate * vars.utilizationRate * (WadRayMath.ray() - reserveFactor);

        return (vars.currentBorrowRate, vars.currentLiquidityRate);

    }

}