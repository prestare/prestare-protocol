// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AssetStorage} from "../../DataType/AssetStorage.sol";
import {MarketStorage} from "../../DataType/MarketStorage.sol";
// import {PrestareMarketStorage} from "../../DataType/PrestareStorage.sol";
import {CounterAddressProviderInterface} from "../../interfaces/CounterAddressProviderInterface.sol";
import {AssetPoolLogic} from "../libraries/AssetPoolLogic.sol";
import {AssetsConfiguration} from "../libraries/configuration/AssetsConfiguration.sol";
import {UserConfiguration} from '../libraries/configuration/UserConfiguration.sol';

contract CounterStorage {
    using AssetPoolLogic for AssetStorage.AssetProfile;
    using AssetsConfiguration for AssetStorage.CounterConfigMapping;
    using UserConfiguration for DataTypes.UserConfigurationMap;
    
    ICounterAddressProvider internal _addressProvider;

    // User's balance for each asset
    mapping(address => mapping(address => MarketStorage.UserBalanceByAsset)) _userDataByAsset;
    // User's total balance 
    mapping(address => MarketStorage.UserBalanceSummary) _userBalanceSummary;
    
    mapping(address => MarketStorage.CreditTokenStorage) internal _crt;
    mapping(uint8 => address) _crtList;

    mapping(address => AssetStorage.AssetProfile) internal _assetData;
    mapping(address => AssetStorage.UserConfigurationMapping) internal _userConfig;

    uint256 internal _reservesCount;
    mapping(uint256 => address) internal _reservesList;

    uint256 internal _maxNumberOfReserves;

    bool internal _paused;
        
    struct BorrowParams {
        address assetAddress;
        address user;
        address borrower;
        uint256 amount;
        address pTokenAddress;
        address crtAddress;
        uint256 interestRateMode;
        uint8 crtQuota;
    }
}