// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.6.12;

interface ICRT {
    event LockCRT(address indexed account, uint256 amount);

    function lockBalance(address account) external view returns (uint256);
    function lockCRT(address account, uint256 amount) external returns (bool);
    function unlockCRT(address account, uint256 amount) external returns (bool);
}