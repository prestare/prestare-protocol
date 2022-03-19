// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import {AssetsLib} from "./../DataType/TypeLib.sol";

interface CounterInterface {
    /**
    * @dev Emitted on deposit()
    * @param assetAddr The address of the underlying asset of the reserve
    * @param user The address initiating the deposit
    * @param receiver The beneficiary of the deposit, receiving the aTokens
    * @param amount The amount deposited
    **/
    event Deposit(
    address indexed assetAddr,
    address user,
    address indexed receiver,
    uint256 amount
    );

    /**
    * @dev Emitted on withdraw()
    * @param asset The address of the underlyng asset being withdrawn
    * @param user The address initiating the withdrawal, owner of aTokens
    * @param to Address that will receive the underlying
    * @param amount The amount to be withdrawn
    **/
    event Withdraw(address indexed asset, address indexed user, address indexed to, uint256 amount);
}
