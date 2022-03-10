// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AssetsLib} from "./DataType/TypeLib.sol";


contract AssetsStorage {

    // using Logic for DataTypes.ReserveData;

    mapping(address => AssetsLib.AssetProfile) _AssetData;
    mapping(address => AssetsLib.UserConfigurationMapping) internal _userConfig;
}