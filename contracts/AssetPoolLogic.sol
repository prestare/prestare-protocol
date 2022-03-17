// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AssetsLib} from "./DataType/TypeLib.sol";
import {SafeMath256} from "./dependencies/SafeMath.sol";
import {functions} from "./math/function.sol";
import {BorrowInterface} from "./Interfaces/BorrowInterface.sol";

// TODO: Math 模块检查

library AssetPoolProfile {
    using SafeMath256 for uint256;

    function updateState(AssetsLib.AssetProfile storage asset) internal {
        // 待定, 我们不需要发debt token的
    }

    struct LocalRateVars {
        uint256 liquidityRemained;
        uint256 totalBorrowAmount;
        uint256 newSupplyRate;
        uint256 newBorrowRate;
    }

    function updateRate(
    AssetsLib.AssetProfile storage asset, 
    address assetAddress,
    address pTokenAddress,
    uint256 liquidityAdded, 
    uint256 liquidityTaken ) internal {

        LocalRateVars memory vars;

        // 先手写一份利率模型

    }

    function calCumLiquidityIndex(AssetsLib.AssetProfile storage asset) internal {

    }


    function _calPoolCumNormIncome(AssetsLib.AssetProfile storage asset) internal view returns (uint256) {
        
        // TODO: 为什么要用uint40
        uint40 lastTimeStamp = asset.lastUpdateTimestamp;

        if (lastTimeStamp == block.timestamp) {
            return asset.liquidityIndex;
        }

        uint256 temp1 = functions.calculateLinearInterest(asset.currentLiquidityRate, lastTimeStamp);

        // TODO: 为什么前面用了using  tryRayMul_前面还必须要加library name
        (bool status, uint256 result) = SafeMath256.tryRayMul_(temp1, asset.liquidityIndex);
        // TODO: error to be added
        require(status == true, "");

        return result;
    }

    function calTotalBorrowIndex(AssetsLib.AssetProfile storage asset) internal view returns (uint256) {

        uint40 lastTimeStamp = asset.lastUpdateTimestamp;

        if (lastTimeStamp == block.timestamp) {
            return asset.totalBorrowIndex;
        }

        uint256 newBorrowIndex = functions.calculateCompoundedInterest(asset.currentBorrowRate, lastTimeStamp, block.timestamp);

        return newBorrowIndex;
    }
}