// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.4;

/**
 * @title IPriceOracleGetter interface
 * @notice Interface for the Prstare price oracle.
 * @dev lendingpool can call this contract to get the asset Price
 **/

interface PriceOracleGetterInterface {
  /**
   * @dev returns the asset price in ETH
   * @param asset the address of the asset
   * @return the ETH price of the asset
   **/
  function getAssetPrice(address asset) external view returns (uint256);
}