// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {EIP20Implementation} from "../../dependencies/EIP20Implementation.sol";

/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract MintableERC20 is EIP20Implementation {
    constructor(
    string memory name,
    string memory symbol,
    uint8 decimals
    ) public EIP20Implementation(name, symbol) {
    _setupDecimals(decimals);
    }

    /**
   * @dev Function to mint tokens
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
    function mint(uint256 value) public returns (bool) {
    _mint(_msgSender(), value);
    return true;
    }
}