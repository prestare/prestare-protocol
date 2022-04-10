// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AssetsLib} from "./DataType/TypeLib.sol";
import {CounterAddressProviderInterface} from "./Interfaces/CounterAddressProviderInterface.sol";
import {ReserveLogic} from "./ReserveLogic.sol";
import {AssetsConfiguration} from "./AssetsConfiguration.sol";


contract AssetsStorage {
    using ReserveLogic for AssetsLib.AssetProfile;
    using AssetsConfiguration for AssetsLib.AssetConfigMapping;

    CounterAddressProviderInterface internal _addressProvider;

    mapping(address => AssetsLib.AssetProfile) internal _assetData;
    mapping(address => AssetsLib.UserConfigurationMapping) internal _userConfig;

    uint256 internal _reservesCount;
    mapping(uint256 => address) internal _reservesList;

    uint256 internal _maxNumberOfReserves;

    bool internal _paused;
}