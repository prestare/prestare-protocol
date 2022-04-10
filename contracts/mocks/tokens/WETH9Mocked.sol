// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {WETH9} from "../../dependencies/WETH9.sol";

contract WETH9Mocked is WETH9 {
    // Mint not backed by Ether: only for testing purposes
    function mint(uint256 value) public returns (bool) {
        balanceOf[msg.sender] += value;
        emit Transfer(address(0), msg.sender, value);
    }
}