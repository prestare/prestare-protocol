// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { PrestareCounterStorage } from "../../DataType/PrestareStorage.sol";

library AssetConfiguration {
    uint256 constant LTV_MASK =                   0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000; // prettier-ignore
    uint256 constant DECIMALS_MASK =              0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFF; // prettier-ignore
    uint256 constant ACTIVE_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF; // prettier-ignore
    uint256 constant FROZEN_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF; // prettier-ignore
    uint256 constant LIQUIDATION_THRESHOLD_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFF; // prettier-ignore
    uint256 constant LIQUIDATION_BONUS_MASK =     0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFF; // prettier-ignore
    uint256 constant RESERVE_FACTOR_MASK =        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFF; // prettier-ignore

    uint256 constant LIQUIDATION_THRESHOLD_START_BIT_POSITION = 16;
    uint256 constant RESERVE_DECIMALS_START_BIT_POSITION = 48;
    uint256 constant IS_ACTIVE_START_BIT_POSITION = 56;
    uint256 constant IS_FROZEN_START_BIT_POSITION = 57;
    uint256 constant LIQUIDATION_BONUS_START_BIT_POSITION = 32;
    uint256 constant RESERVE_FACTOR_START_BIT_POSITION = 64;
    
    uint256 constant MAX_VALID_LTV = 65535;
    uint256 constant MAX_VALID_DECIMALS = 255;
    uint256 constant MAX_VALID_LIQUIDATION_THRESHOLD = 65535;
    uint256 constant MAX_VALID_LIQUIDATION_BONUS = 65535;

    uint256 constant MAX_VALID_RESERVE_FACTOR = 65535;

    /**
   * @dev Sets the Loan to Value of the reserve
   * @param self The reserve configuration
   * @param ltv the new ltv
   **/
    function setLtv(PrestareCounterStorage.CounterConfigMapping memory self, uint256 ltv) internal pure {
        require(ltv <= MAX_VALID_LTV, "Error");

        self.data = (self.data & LTV_MASK) | ltv;
    }

    /**
    * @dev Sets the liquidation threshold of the reserve
    * @param self The reserve configuration
    * @param threshold The new liquidation threshold
    **/
    function setLiquidationThreshold(PrestareCounterStorage.CounterConfigMapping memory self, uint256 threshold)
        internal
        pure
    {
        require(threshold <= MAX_VALID_LIQUIDATION_THRESHOLD, "Error");

        self.data =
        (self.data & LIQUIDATION_THRESHOLD_MASK) |
        (threshold << LIQUIDATION_THRESHOLD_START_BIT_POSITION);
    }

    /**
    * @dev Sets the liquidation bonus of the reserve
    * @param self The reserve configuration
    * @param bonus The new liquidation bonus
    **/
    function setLiquidationBonus(PrestareCounterStorage.CounterConfigMapping memory self, uint256 bonus)
        internal
        pure
    {
        require(bonus <= MAX_VALID_LIQUIDATION_BONUS, "Error");

        self.data =
        (self.data & LIQUIDATION_BONUS_MASK) |
        (bonus << LIQUIDATION_BONUS_START_BIT_POSITION);
    }

    /**
   * @dev Sets the decimals of the underlying asset of the reserve
   * @param self The reserve configuration
   * @param decimals The decimals
   **/
    function setDecimals(PrestareCounterStorage.CounterConfigMapping memory self, uint256 decimals)
        internal
        pure
    {
        require(decimals <= MAX_VALID_DECIMALS, "Error");

        self.data = (self.data & DECIMALS_MASK) | (decimals << RESERVE_DECIMALS_START_BIT_POSITION);
    }

    /**
   * @dev Sets the active state of the reserve
   * @param self The reserve configuration
   * @param active The active state
   **/
    function setActive(PrestareCounterStorage.CounterConfigMapping memory self, bool active) internal pure {
        self.data =
        (self.data & ACTIVE_MASK) |
        (uint256(active ? 1 : 0) << IS_ACTIVE_START_BIT_POSITION);
    }

    /**
   * @dev Sets the frozen state of the reserve
   * @param self The reserve configuration
   * @param frozen The frozen state
   **/
    function setFrozen(PrestareCounterStorage.CounterConfigMapping memory self, bool frozen) internal pure {
        self.data =
        (self.data & FROZEN_MASK) |
        (uint256(frozen ? 1 : 0) << IS_FROZEN_START_BIT_POSITION);
    }

    /**
     * @dev Sets the reserve factor of the reserve
     * @param self The reserve configuration
     * @param reserveFactor The reserve factor
     */
    function setReserveFactor(PrestareCounterStorage.CounterConfigMapping memory self, uint256 reserveFactor)
        internal
        pure
    {
        require(reserveFactor <= MAX_VALID_RESERVE_FACTOR, "Errors");

        self.data =
        (self.data & RESERVE_FACTOR_MASK) |
        (reserveFactor << RESERVE_FACTOR_START_BIT_POSITION);
    }
}