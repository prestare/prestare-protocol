// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {ICounter} from './ICounter.sol';

/**
 * @title IInitializableAToken
 * @notice Interface for the initialize function on PToken
 **/
interface IInitializablePToken {
  /**
   * @dev Emitted when an aToken is initialized
   * @param underlyingAsset The address of the underlying asset
   * @param pool The address of the associated lending pool
   * @param treasury The address of the treasury
   * @param pTokenDecimals the decimals of the underlying
   * @param pTokenName the name of the aToken
   * @param pTokenSymbol the symbol of the aToken
   * @param params A set of encoded parameters for additional initialization
   **/
  event Initialized(
    address indexed underlyingAsset,
    address indexed pool,
    address treasury,
    uint8 pTokenDecimals,
    string pTokenName,
    string pTokenSymbol,
    bytes params
  );

  /**
   * @dev Initializes the aToken
   * @param pool The address of the lending pool where this aToken will be used
   * @param treasury The address of the Aave treasury, receiving the fees on this aToken
   * @param underlyingAsset The address of the underlying asset of this aToken (E.g. WETH for aWETH)
   * @param pTokenDecimals The decimals of the aToken, same as the underlying asset's
   * @param pTokenName The name of the aToken
   * @param pTokenSymbol The symbol of the aToken
   */
  function initialize(
    ICounter pool,
    address treasury,
    address underlyingAsset,
    uint8 pTokenDecimals,
    string calldata pTokenName,
    string calldata pTokenSymbol,
    bytes calldata params
  ) external;
}
