// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// dependencies file
import {IERC20} from "../../dependencies/openzeppelin/contracts/IERC20.sol";
import {SafeERC20} from "../../dependencies/openzeppelin/contracts/SafeERC20.sol";

// interfaces file
import {IPToken} from "../../interfaces/IPToken.sol";

//
import {CounterStorage} from "../Counter/CounterStorage.sol";

library CounterOp {
    using SafeERC20 for IERC20;

    using CouterOp for PrestareCounterStorage.CounterProfile;

    /**
     * @dev Updates the liquidity cumulative index and the variable borrow index.
     * @param asset the asset need to update
     */
    function AssetUpdate(PrestareCounterStorage.CounterProfile asset) internal {
        asset.updateCumulativeIndexes();
        asset.updateInterestRatesAndTimestamp();

    }

    function updateCumulativeIndexes(PrestareCounterStorage.CounterProfile storage asset) internal {
        uint256 totalBorrows = getTotalBorrows(asset);
        if (totalBorrows > 0) {
            uint256 cmulatedLiquidityInterest = calculateLinearInterest(
                asset.curr
            )
        }
    }
}