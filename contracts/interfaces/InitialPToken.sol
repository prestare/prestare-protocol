// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {CounterInterface} from "./CounterInterface.sol";
// import {IncentivesController} from "./Incentives.sol";

/**
 * @title IInitialPToken
 * @notice Interface for the initialize function on PToken
 * @author Prestare
 **/
interface InitialPToken {

    /**
     * @dev Emitted after the initialization. 
     * @param counter The address of the counter where this pToken will be used
     * @param gasStation The address of the Aave treasury, receiving the fees on this pToken
     * @param underlyingAsset The address of the underlying asset of this pToken (E.g. WETH for aWETH)
     * incentivesController The smart contract managing potential incentives distribution
     * @param pTokenDecimals The decimals of the pToken, same as the underlying asset's
     * @param pTokenName The name of the pToken
     * @param pTokenSymbol The symbol of the pToken
     */
    event Initialized(        
        address counter,
        address gasStation,
        address underlyingAsset,
        uint8 pTokenDecimals,
        string pTokenName,
        string pTokenSymbol,
        bytes params
    );

    /**
     * @notice Initializes the PToken 
     * @param counter The address of the counter where this pToken will be used
     * @param gasStation The address of the Prestare treasury, receiving the fees on this pToken
     * @param underlyingAsset The address of the underlying asset of this pToken (E.g. WETH for aWETH)
     * incentivesController The smart contract managing potential incentives distribution
     * @param pTokenDecimals The decimals of the pToken, same as the underlying asset's
     * @param pTokenName The name of the pToken
     * @param pTokenSymbol The symbol of the pToken
     */
    // maybe we should add a initializer modify to check the status before call this function
    function initialize(
        CounterInterface counter,
        address gasStation,
        address underlyingAsset,
        uint8 pTokenDecimals,
        string calldata pTokenName,
        string calldata pTokenSymbol,
        bytes calldata params
    ) external;
}

