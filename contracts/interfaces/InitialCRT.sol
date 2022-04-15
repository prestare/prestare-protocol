// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {CounterInterface} from "./CounterInterface.sol";
// import {IncentivesController} from "./Incentives.sol";

/**
 * @title InitialCRT
 * @notice Interface for the initialize function on PToken
 * @author Prestare
 **/
interface InitialCRT {

    /**
     * @dev Emitted after the initialization. 
     * @param counter The address of the counter where this CRT will be used
     * @param crtDecimals The decimals of the pToken, same as the underlying asset's
     * @param crtName The name of the pToken
     * @param crtymbol The symbol of the pToken
     */
    event Initialized(        
        address counter,
        uint8 crtDecimals,
        string crtName,
        string crtymbol,
        bytes params
    );

    /**
     * @notice Initializes the crt 
     * @param counter The address of the counter where this crt will be used
     * @param crtDecimals The decimals of the crt, same as the underlying asset's
     * @param crtName The name of the crt
     * @param crtymbol The symbol of the crt
     */
    // maybe we should add a initializer modify to check the status before call this function
    function initialize(
        CounterInterface counter,
        uint8 crtDecimals,
        string calldata crtName,
        string calldata crtymbol,
        bytes calldata params
    ) external;
}