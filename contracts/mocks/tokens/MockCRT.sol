// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {CrtToken} from '../../CRT/token/CrtToken.sol';
/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract MockCRT is CrtToken {
  uint8 _decimals;

  constructor() public CrtToken() {
    
  }
  /**
   * @dev Function to mint tokens
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  // function mint(uint256 value) external override returns (bool) {
  //   _mint(_msgSender(), value);
  //   return true;
  // }
}