// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AssetStorage} from "../../DataType/AssetStorage.sol";
// import {SafeMath256} from "./dependencies/openzeppelin/contracts/SafeMath.sol";
// import {functions} from "./math/function.sol";
import {BorrowInterface} from "../../interfaces/BorrowInterface.sol";
import {WadRayMath} from "../../utils/WadRay.sol";
import {AssetsConfiguration} from "../../AssetsConfiguration.sol";
import {PTokenInterface} from "../../interfaces/PTokenInterface.sol";
import {TestRateModelInterface} from "../../interfaces/RateModel.sol";

// TODO: Math 模块检查

library AssetPoolLogic {
    // using SafeMath256 for uint256;
    // using WadRayMath for uint256;

    // using AssetsConfiguration for AssetStorage.Mapping;

    // // TODO: 根据PrestareStorage的数据进行初始化
    // function init(
    //     AssetStorage.AssetProfile storage asset, 
    //     address pTokenAddr
    //     ) external {
    //         reserve.ExchangeRate = uint128(WadRayMath.ray());
    //         reserve.borrowIndex = uint128(WadRayMath.ray());
    //         reserve.pTokenAddress = pTokenAddr;
    //     }

    /**
     * @dev updates the liquidity cumulative exchange rate and the borrow index.
     * @param asset the asset object
     */
    function updateState(AssetStorage.AssetProfile storage asset) internal {
        uint256 oldBorrowIndex = asset.borrowIndex;
        uint256 oldExchangeRate = asset.ExchangeRate;
        uint40 lastUpdateTimestamp = asset.lastUpdateTimestamp;

        // 记录scaledBorrowedAmount的数量
        // uint256 scaledBorrowedAmount = asset._assetData.scaledBorrowedAmount;
        uint256 scaledBorrowedAmount = IDebtToken(asset.debtTokenAddress).scaledTotalSupply();

        (uint256 newExchangeRate, uint256 newBorrowIndex) = _updateIndicators(asset, scaledBorrowedAmount, oldLiquidityIndex, oldBorrowIndex, lastUpdateTimestamp);

        _toVault(asset, scaledBorrowedAmount, oldBorrowIndex, newLiquidityIndex, newBorrowIndex, lastUpdateTimestamp);
    }

    // struct VaultLocalVars {
    //     uint256 previousDebt;
    //     uint256 currentDebt;
    //     uint256 amountToVault;
    //     uint256 reserveFactor;
    //     uint256 totalDebtAccured;
    // }

    // function _toVault(
    //     AssetStorage.AssetProfile storage asset, 
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
    //     AssetStorage.AssetProfile storage asset, 
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

    //     emit UpdateAssetData(assetAddress, vars.newLiquidityRate, vars.newBorrowRate, asset.ExchangeRate, asset.borrowIndex);
    // }
    /**
     * @dev Updates the reserve indexes and the timestamp of the update
     * @param asset The reserve reserve to be updated
     * @param scaledDebt The scaled variable debt
     * @param exchangeRate The last stored liquidity index
     * @param borrowIndex The last stored variable borrow index
     * @param timestamp The asset last update timestamp
    */
    function _updateIndicators(
        AssetStorage.AssetProfile storage asset, 
        uint256 scaledDebt,
        uint256 exchangeRate,
        uint256 borrowIndex,
        uint40 timestamp
    ) internal returns (uint256, uint256) {
        uint256 currentInterest = asset.currentInterest;
        
        uint256 newExchangeRate = exchangeRate;
        uint256 newBorrowIndex = borrowIndex;

        if (currentInterest > 0) {
            uint256 cumLiquidityInterest = functions.calculateLinearInterest(currentInterest, timestamp);
            newExchangeRate = cumLiquidityInterest.rayMul(exchangeRate);
            require(newLiquidityIndex <= type(uint128).max, "ERROR");

            asset.exchangeRate = uint128(newLiquidityIndex);

            if (scaledDebt != 0) {
                uint256 cumulatedBorrowInterest = 
                    functions.calculateCompoundedInterest(asset.currentBorrowRate, timestamp);
                newBorrowIndex = cumulatedBorrowInterest.rayMul(variableBorrowIndex);
                require(
                    newBorrowIndex <= type(uint128).max,
                    "ERROR"
                );
                reserve.variableBorrowIndex = uint128(newVariableBorrowIndex);
            }
        }
        asset.lastUpdateTimestamp = uint40(block.timestamp);
        return (newLiquidityIndex, newBorrowIndex);
    }


    // struct LocalRateVars {
    //     uint256 liquidityRemained;
    //     uint256 totalBorrowAmount;
    //     uint256 newSupplyRate;
    //     uint256 newBorrowRate;
    // }

    // function calCumLiquidityIndex(AssetStorage.AssetProfile storage asset) internal {

    // }


    // function _calPoolCumNormIncome(AssetStorage.AssetProfile storage asset) internal view returns (uint256) {
        
    //     // TODO: 为什么要用uint40
    //     uint40 lastTimeStamp = asset.lastUpdateTimestamp;

    //     if (lastTimeStamp == block.timestamp) {
    //         return asset.ExchangeRate;
    //     }

    //     uint256 temp1 = functions.calculateLinearInterest(asset.currentLiquidityRate, lastTimeStamp);

    //     // TODO: 为什么前面用了using  tryRayMul_前面还必须要加library name
    //     (bool status, uint256 result) = SafeMath256.tryRayMul_(temp1, asset.ExchangeRate);
    //     // TODO: error to be added
    //     require(status == true, "");

    //     return result;
    // }

    // function calTotalBorrowIndex(AssetStorage.AssetProfile storage asset) internal view returns (uint256) {

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
    //     uint256 ExchangeRate, 
    //     uint256 borrowIndex 
    //     );
}