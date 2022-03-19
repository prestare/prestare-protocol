// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {EIP20Interface} from "./../dependencies/EIP20Interface.sol";
import {InitialPToken} from "./InitialPToken.sol";

interface PTokenInterface is EIP20Interface, InitialPToken{
    
}