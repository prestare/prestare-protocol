// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {EIP20Interface} from "./EIP20Interface.sol";

interface IERC20Detailed is EIP20Interface {
    function name() external view override returns (string memory);

    function symbol() external view override returns (string memory);

    function decimals() external view override returns (uint8);
}