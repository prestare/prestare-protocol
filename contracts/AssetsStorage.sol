// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {PrestareCounterStorage} from "./DataType/PrestareStorage.sol";
import {MarketStorage} from "./DataType/PrestareStorage.sol";
import {CounterAddressProviderInterface} from "./Interfaces/CounterAddressProviderInterface.sol";
import {ReserveLogic} from "./ReserveLogic.sol";
import {AssetsConfiguration} from "./AssetsConfiguration.sol";


contract AssetsStorage {
    using ReserveLogic for PrestareCounterStorage.CounterProfile;
    using AssetsConfiguration for PrestareCounterStorage.CounterConfigMapping;

    CounterAddressProviderInterface internal _addressProvider;

    MarketStorage internal _marketStorage;

    mapping(address => PrestareCounterStorage.CounterProfile) internal _assetData;
    mapping(address => PrestareCounterStorage.UserConfigurationMapping) internal _userConfig;

    uint256 internal _reservesCount;
    mapping(uint256 => address) internal _reservesList;

    uint256 internal _maxNumberOfReserves;

    bool internal _paused;
}