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
  uint256 constant BASIC_POINT = 1e4; //use the idea of bps

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
}
