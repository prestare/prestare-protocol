// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {ICounter} from './ICounter.sol';

/**
 * @title IInitializablePToken
 * @notice Interface for the initialize function on PToken
 **/
interface IInitializablePToken {
  /**
   * @dev Emitted when an pToken is initialized
   * @param underlyingAsset The address of the underlying asset
   * @param counter The address of the associated lending pool
   * @param treasury The address of the treasury
   * @param pTokenDecimals the decimals of the underlying
   * @param pTokenName the name of the pToken
   * @param pTokenSymbol the symbol of the pToken
   * @param params A set of encoded parameters for additional initialization
   **/
  event Initialized(
    address indexed underlyingAsset,
    address indexed counter,
    address treasury,
    uint8 pTokenDecimals,
    string pTokenName,
    string pTokenSymbol,
    bytes params
  );

  /**
   * @dev Initializes the pToken
   * @param counter The address of the lending pool where this pToken will be used
   * @param treasury The address of the treasury, receiving the fees on this pToken
   * @param underlyingAsset The address of the underlying asset of this pToken (E.g. WETH for aWETH)
   * @param assetRiskTier The risk tier of this pToken
   * @param pTokenDecimals The decimals of the pToken, same as the underlying asset's
   * @param pTokenName The name of the pToken
   * @param pTokenSymbol The symbol of the pToken
   */
  function initialize(
    ICounter counter,
    address treasury,
    address underlyingAsset,
    uint8 assetRiskTier,
    uint8 pTokenDecimals,
    string calldata pTokenName,
    string calldata pTokenSymbol,
    bytes calldata params
  ) external;
}
