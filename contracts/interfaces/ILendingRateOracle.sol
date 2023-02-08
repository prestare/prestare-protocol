// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

/**
 * @title ILendingRateOracle interface
 * @notice Interface for the borrow rate oracle.
 **/

interface ILendingRateOracle {
  /**
    @dev returns the market borrow rate in ray
    **/
  function getMarketBorrowRate(address asset) external view returns (uint256);

  /**
    @dev sets the market borrow rate. Rate value must be in ray
    **/
  function setMarketBorrowRate(address asset, uint256 rate) external;
}
