// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AssetsLib} from "./DataType/TypeLib.sol";
import {SafeMath256} from "./dependencies/SafeMath.sol";
import {functions} from "./math/function.sol";

library AssetPoolProfile {
    using SafeMath256 for uint256;

    function _calPoolCumNormIncome(AssetsLib.AssetProfile storage asset) internal view returns (uint256) {
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
}