// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.10;

interface ICRT {
    event LockCRT(address indexed account, uint256 amount);
    event UnlockCRT(address indexed account, uint256 amount);

    function lockBalance(address account) external view returns (uint256);
    function lockCRT(address account, uint256 amount) external;
    function unlockCRT(address account, uint256 amount) external;
}