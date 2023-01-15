// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

/**
 * @title IPriceOracleGetter interface
 * @notice Interface for the price oracle.
 **/

interface IPriceOracleGetter {
  /**
   * @dev returns the asset price in ETH
   * @param asset the address of the asset
   * @return the ETH price of the asset
   **/
  function getAssetPrice(address asset) external view returns (uint256);
}
