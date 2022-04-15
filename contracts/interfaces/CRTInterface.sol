// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import {EIP20Interface} from "../dependencies/EIP20Interface.sol";
import {InitialCRT} from "./InitialCRT.sol";

interface CRTInterface is EIP20Interface, InitialCRT {
    
    /**
     * @dev Emitted after the mint action
     * @param from The address performing the mint
     * @param value The amount being
     */
    event Mint(address indexed from, uint256 value);
    
    /**
     * @dev Emitted after the burn action
     * @param user The owner of the pTokens, getting them burned
     * @param receiverOfUnderlying The address that will receive the underlying
     * @param amount The amount being burned
     */
    event Burn(
        address indexed user, 
        address indexed receiverOfUnderlying, 
        uint256 amount
    );
}