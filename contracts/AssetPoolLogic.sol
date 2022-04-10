// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AssetsLib} from "./DataType/TypeLib.sol";
import {SafeMath256} from "./dependencies/SafeMath.sol";
import {functions} from "./math/function.sol";
import {BorrowInterface} from "./Interfaces/BorrowInterface.sol";
import {WadRayMath} from "./utils/WadRay.sol";
import {AssetsConfiguration} from "./AssetsConfiguration.sol";
import {PTokenInterface} from "./Interfaces/PTokenInterface.sol";
import {TestRateModelInterface} from "./Interfaces/RateModel.sol";

// TODO: Math 模块检查

library AssetPoolProfile {
    // using SafeMath256 for uint256;
    // using WadRayMath for uint256;

    // using AssetsConfiguration for AssetsLib.AssetConfigMapping;

    // // TODO: 根据TypeLib的数据进行初始化
    // function init(
    //     AssetsLib.AssetProfile storage asset, 
    //     address pTokenAddr
    //     ) external {
    //         reserve.liquidityIndex = uint128(WadRayMath.ray());
    //         reserve.borrowIndex = uint128(WadRayMath.ray());
    //         reserve.pTokenAddress = pTokenAddr;
    //     }

    // function updateState(AssetsLib.AssetProfile storage asset) internal {
    //     uint256 oldBorrowIndex = asset.borrowIndex;
    //     uint256 oldLiquidityIndex = asset.liquidityIndex;
    //     uint40 lastUpdateTimestamp = asset.lastUpdateTimestamp;

    //     // 记录scaledBorrowedAmount的数量
    //     uint256 scaledBorrowedAmount = asset._assetData.scaledBorrowedAmount;

    //     (uint256 newLiquidityIndex, uint256 newBorrowIndex) = _updateIndicators(asset, oldLiquidityIndex, oldBorrowIndex, lastUpdateTimestamp);

    //     _toVault(asset, scaledBorrowedAmount, oldBorrowIndex, newLiquidityIndex, newBorrowIndex, lastUpdateTimestamp);
    // }

    // struct VaultLocalVars {
    //     uint256 previousDebt;
    //     uint256 currentDebt;
    //     uint256 amountToVault;
    //     uint256 reserveFactor;
    //     uint256 totalDebtAccured;
    // }

    // function _toVault(
    //     AssetsLib.AssetProfile storage asset, 
    //     uint256 scaledBorrowedAmount,
    //     uint256 oldBorrowIndex,
    //     uint256 newLiquidityIndex, 
    //     uint256 newBorowIndex, 
    //     uint40 timestamp
    // ) internal {
    //     VaultLocalVars memory vars;

    //     vars.reserveFactor = asset.configuration.getReserveFactor();

    //     if (vars.reserveFactor == 0) {
    //         return;
    //     }

    //     vars.previousDebt = scaledBorrowedAmount.rayMul(oldBorrowIndex);
    //     vars.currentDebt = scaledBorrowedAmount.rayMul(newBorowIndex);

    //     // 数学方法待确定
    //     vars.totalDebtAccured = vars.currentDebt - vars.previousDebt;

    //     // 这里的计算方式要确定
    //     vars.amountToVault = vars.totalDebtAccured * vars.reserveFactor;

    //     if (vars.amountToVault != 0) {
    //         PTokenInterface(asset.pTokenAddress).mintToVault(vars.amountToVault, newLiquidityIndex);
    //     }
    // }

    // struct UpdateRateLocalVars {
    //     uint256 availableLiquidity;
    //     uint256 totalBorrowAmount;
    //     uint256 newLiquidityRate;
    //     uint256 newBorrowRate;
    // }

    // function updateRate(
    //     AssetsLib.AssetProfile storage asset, 
    //     address assetAddress,
    //     address pTokenAddress,
    //     uint256 liquidityAdded, 
    //     uint256 liquidityTaken ) 
    //     internal {
    //     LocalRateVars memory vars;

    //     vars.totalBorrowAmount = asset._assetData.scaledBorrowedAmount.rayMul(asset.borrowIndex);
        
    //     (vars.newBorrowRate, vars.newLiquidityRate) = TestRateModelInterface(asset.interestRateStrategyAddress).calculateInterestRate(
    //         assetAddress,
    //         pTokenAddress,
    //         liquidityAdded,
    //         liquidityTaken,
    //         vars.totalBorrowAmount,
    //         vars.reserveFactor
    //     );

    //     // 检查是否溢出
    //     require(vars.newBorrowRate <= type(uint128).max, "ERROR");
    //     require(vars.liquidityAdded <= type(uint128).max, "ERROR");

    //     asset.currentBorrowRate = vars.newBorrowRate;
    //     asset.currentLiquidityRate = vars.newLiquidityRate;

    //     emit UpdateAssetData(assetAddress, vars.newLiquidityRate, vars.newBorrowRate, asset.liquidityIndex, asset.borrowIndex);
    // }

    // function _updateIndicators(
    //     AssetsLib.AssetProfile storage asset, 
    //     uint256 liquidityIndex,
    //     uint256 borrowIndex,
    //     uint40 timestamp
    // ) internal returns (uint256, uint256) {
    //     uint256 currentLiquidityRate = asset.currentLiquidityRate;
    //     uint256 newLiquidityIndex = liquidityIndex;
    //     uint256 newBorrowIndex = borrowIndex;

    //     if (currentLiquidityRate > 0) {
    //         uint256 cumLiquidityInterest = functions.calculateLinearInterest(asset.currentLiquidityRate, timestamp);
    //         newLiquidityIndex = cumLiquidityInterest.rayMul(liquidityIndex);
    //         require(newLiquidityIndex <= type(uint128).max, "ERROR");

    //         asset.liquidityIndex = uint128(newLiquidityIndex);

    //         uint256 cumBorrowIndex = functions.calculateCompoundedInterest(asset.currentBorrowRate, timestamp, block.timestamp);
    //         newBorrowIndex = cumBorrowIndex.rayMul(borrowIndex);
    //         require(newBorrowIndex <= type(uint128).max, "ERROR");

    //         asset.borrowIndex = uint128(newBorrowIndex);
    //     }

    //     asset.lastUpdateTimestamp = uint40(block.timestamp);
    //     return (newLiquidityIndex, newBorrowIndex);
        
    // }


    // struct LocalRateVars {
    //     uint256 liquidityRemained;
    //     uint256 totalBorrowAmount;
    //     uint256 newSupplyRate;
    //     uint256 newBorrowRate;
    // }

    // function calCumLiquidityIndex(AssetsLib.AssetProfile storage asset) internal {

    // }


    // function _calPoolCumNormIncome(AssetsLib.AssetProfile storage asset) internal view returns (uint256) {
        
    //     // TODO: 为什么要用uint40
    //     uint40 lastTimeStamp = asset.lastUpdateTimestamp;

    //     if (lastTimeStamp == block.timestamp) {
    //         return asset.liquidityIndex;
    //     }

    //     uint256 temp1 = functions.calculateLinearInterest(asset.currentLiquidityRate, lastTimeStamp);

    //     // TODO: 为什么前面用了using  tryRayMul_前面还必须要加library name
    //     (bool status, uint256 result) = SafeMath256.tryRayMul_(temp1, asset.liquidityIndex);
    //     // TODO: error to be added
    //     require(status == true, "");

    //     return result;
    // }

    // function calTotalBorrowIndex(AssetsLib.AssetProfile storage asset) internal view returns (uint256) {

    //     uint40 lastTimeStamp = asset.lastUpdateTimestamp;

    //     if (lastTimeStamp == block.timestamp) {
    //         return asset.borrowIndex;
    //     }

    //     uint256 newBorrowIndex = functions.calculateCompoundedInterest(asset.currentBorrowRate, lastTimeStamp, block.timestamp);

    //     return newBorrowIndex;
    // }

    // event UpdateAssetData(
    //     address indexed assetAddr, 
    //     uint256 liquidityRate, 
    //     uint256 BorrowRate, 
    //     uint256 liquidityIndex, 
    //     uint256 borrowIndex 
    //     );
}