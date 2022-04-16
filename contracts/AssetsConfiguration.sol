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

    /// @dev For the LTV, the start bit is 0 (up to 15), hence no bitshifting is needed
    uint256 constant LIQUIDATION_THRESHOLD_START_BIT_POSITION = 16;
    uint256 constant LIQUIDATION_BONUS_START_BIT_POSITION = 32;
    uint256 constant RESERVE_DECIMALS_START_BIT_POSITION = 48;
    uint256 constant IS_ACTIVE_START_BIT_POSITION = 56;
    uint256 constant IS_FROZEN_START_BIT_POSITION = 57;
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

    /**
    * @dev Gets the configuration paramters of the reserve
    * @param self The reserve configuration
    * @return The state params representing ltv, liquidation threshold, liquidation bonus, the reserve decimals
    **/
    function getParams(PrestareCounterStorage.CounterConfigMapping storage self)
        internal
        view
        returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
        )
    {
        uint256 dataLocal = self.data;

        return (
        dataLocal & ~LTV_MASK,
        (dataLocal & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION,
        (dataLocal & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION,
        (dataLocal & ~DECIMALS_MASK) >> RESERVE_DECIMALS_START_BIT_POSITION,
        (dataLocal & ~RESERVE_FACTOR_MASK) >> RESERVE_FACTOR_START_BIT_POSITION
        );
    }

    /**
    * @dev Gets the configuration paramters of the reserve from a memory object
    * @param self The reserve configuration
    * @return The state params representing ltv, liquidation threshold, liquidation bonus, the reserve decimals
    **/
    function getParamsMemory(PrestareCounterStorage.CounterConfigMapping memory self)
        internal
        pure
        returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
        )
    {
        return (
        self.data & ~LTV_MASK,
        (self.data & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION,
        (self.data & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION,
        (self.data & ~DECIMALS_MASK) >> RESERVE_DECIMALS_START_BIT_POSITION,
        (self.data & ~RESERVE_FACTOR_MASK) >> RESERVE_FACTOR_START_BIT_POSITION
        );
    }
    /**
     * @dev Gets the configuration flags of the reserve from a memory object
     * @param self The reserve configuration
     * @return The state flags representing active, frozen, borrowing enabled, stableRateBorrowing enabled
     */
    function getFlagsMemory(PrestareCounterStorage.CounterConfigMapping memory self)
        internal
        pure
        returns (
        bool,
        bool,
        bool
        )
    {
        return (
            (self.data & ~ACTIVE_MASK) != 0,
            (self.data & ~FROZEN_MASK) != 0,
            (self.data & ~BORROWING_MASK) != 0
        );
    }
}

