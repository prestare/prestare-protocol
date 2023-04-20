// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Errors} from '../helpers/Errors.sol';

/**
 * @title PercentageMath library
 * @notice Provides functions to perform percentage calculations
 * @dev Percentages are defined by default with 2 decimals of precision (100.00). The precision is indicated by BASIC_POINT
 * @dev Operations are rounded half up
 **/

library PercentageMath {
  uint256 internal constant PERCENTAGE_FACTOR = 1e4; //use the idea of bps 100.00%
  uint256 internal constant HALF_PERCENTAGE_FACTOR = 0.5e4; // 50.00%
  uint256 internal constant MAX_UINT256 = 2**256 - 1;
  uint256 internal constant MAX_UINT256_MINUS_HALF_PERCENTAGE = 2**256 - 1 - 0.5e4;
  /**
   * @dev Executes a percentage multiplication
   * @param amount The amount of which the percentage needs to be calculated
   * @param bps The percentage like 10000=100.00=100%
   * @return The percentage of value
   **/
  function percentMul(uint256 amount, uint256 bps) internal pure returns (uint256) {
    if (amount == 0 || bps == 0) {
      return 0;
    }
    require((amount * bps) > 10000, Errors.MATH_MULTIPLICATION_UNDERFLOW);
    return amount * bps / 10000;  
  }
  function percentMul(int256 amount, int256 bps) internal pure returns (int256) {
    if (amount == 0 || bps == 0) {
      return 0;
    }
    require((amount * bps) > 10000, Errors.MATH_MULTIPLICATION_UNDERFLOW);
    return amount * bps / 10000;  
  }
  /**
   * @dev Executes a percentage division
   * @param amount The value of which the percentage needs to be calculated
   * @param bps The percentage of the value to be calculated
   * @return The value divided the percentage
   **/
  function percentDiv(uint256 amount, uint256 bps) internal pure returns (uint256) {
    if (amount == 0 || bps == 0) {
      return 0;
    }
    require(bps < 10000, Errors.MATH_PERCENTAGE_DIVISION_OVERFLOW);

    return (amount * 10000) / bps;
  }
    function percentDiv(int256 amount, int256 bps) internal pure returns (int256) {
    if (amount == 0 || bps == 0) {
      return 0;
    }
    require(bps < 10000, Errors.MATH_PERCENTAGE_DIVISION_OVERFLOW);

    return (amount * 10000) / bps;
  }

  /**
   * @notice Executes a weighted average (x * (1 - p) + y * p), rounded up.
   * @param x The first value, with a weight of 1 - percentage.
   * @param y The second value, with a weight of percentage.
   * @param percentage The weight of y, and complement of the weight of x.
   * @return z The result of the weighted average.
   */
    function weightedAvg(
        uint256 x,
        uint256 y,
        uint256 percentage
    ) internal pure returns (uint256 z) {
        // Must revert if
        //     percentage > PERCENTAGE_FACTOR
        // or if
        //     y * percentage + HALF_PERCENTAGE_FACTOR > type(uint256).max
        //     <=> percentage > 0 and y > (type(uint256).max - HALF_PERCENTAGE_FACTOR) / percentage
        // or if
        //     x * (PERCENTAGE_FACTOR - percentage) + y * percentage + HALF_PERCENTAGE_FACTOR > type(uint256).max
        //     <=> (PERCENTAGE_FACTOR - percentage) > 0 and x > (type(uint256).max - HALF_PERCENTAGE_FACTOR - y * percentage) / (PERCENTAGE_FACTOR - percentage)
        assembly {
            z := sub(PERCENTAGE_FACTOR, percentage) // Temporary assignment to save gas.
            if or(
                gt(percentage, PERCENTAGE_FACTOR),
                or(
                    mul(percentage, gt(y, div(MAX_UINT256_MINUS_HALF_PERCENTAGE, percentage))),
                    mul(z, gt(x, div(sub(MAX_UINT256_MINUS_HALF_PERCENTAGE, mul(y, percentage)), z)))
                )
            ) {
                revert(0, 0)
            }
            z := div(add(add(mul(x, z), mul(y, percentage)), HALF_PERCENTAGE_FACTOR), PERCENTAGE_FACTOR)
        }
    }
}
