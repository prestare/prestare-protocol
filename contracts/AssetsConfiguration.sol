// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

// From Aave V2

import {PrestareCounterStorage} from "./DataType/PrestareStorage.sol";

library AssetsConfiguration {
    uint256 constant LTV_MASK =                   0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000; // prettier-ignore
    uint256 constant LIQUIDATION_THRESHOLD_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFF; // prettier-ignore
    uint256 constant LIQUIDATION_BONUS_MASK =     0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFF; // prettier-ignore
    uint256 constant DECIMALS_MASK =              0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFF; // prettier-ignore
    uint256 constant ACTIVE_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF; // prettier-ignore
    uint256 constant FROZEN_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF; // prettier-ignore
    uint256 constant BORROWING_MASK =             0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF; // prettier-ignore
    uint256 constant STABLE_BORROWING_MASK =      0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FFFFFFFFFFFFFF; // prettier-ignore
    uint256 constant RESERVE_FACTOR_MASK =        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFF; // prettier-ignore

    uint256 constant RESERVE_FACTOR_START_BIT_POSITION = 64;

    /**
   * @dev Gets the reserve factor of the reserve
   * @param self The reserve configuration
   * @return The reserve factor
   **/
    function getReserveFactor(PrestareCounterStorage.CounterConfigMapping storage self) internal view returns(uint256) {
        return (self.data & ~RESERVE_FACTOR_MASK >> RESERVE_FACTOR_START_BIT_POSITION);
    }


    /**
    * @dev Gets the configuration flags of the reserve
    * @param self The reserve configuration
    * @return The state flags representing active, frozen, borrowing enabled, stableRateBorrowing enabled
    **/
    function getFlags(PrestareCounterStorage.CounterConfigMapping storage self)
    internal
    view
    returns (
        bool,
        bool,
        bool,
        bool
    )
    {
    uint256 dataLocal = self.data;

    return (
        (dataLocal & ~ACTIVE_MASK) != 0,
        (dataLocal & ~FROZEN_MASK) != 0,
        (dataLocal & ~BORROWING_MASK) != 0,
        (dataLocal & ~STABLE_BORROWING_MASK) != 0
    );
    }
}

