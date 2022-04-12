// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AssetsConfiguration} from "../AssetsConfiguration.sol";
import {PrestareCounterStorage} from "../DataType/PrestareStorage.sol";
import {CounterAddressProviderInterface} from "../Interfaces/CounterAddressProviderInterface.sol";
import {CounterInterface} from "../Interfaces/CounterInterface.sol";
import {EIP20Interface} from "../dependencies/EIP20Interface.sol";

import "hardhat/console.sol";

contract PrestareDataProvider {
    using AssetsConfiguration for PrestareCounterStorage.CounterConfigMapping;

    address constant MKR = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
    address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    CounterAddressProviderInterface public immutable ADDRESSES_PROVIDER;

    constructor(CounterAddressProviderInterface addressesProvider) public {
        ADDRESSES_PROVIDER = addressesProvider;
    }

    function getReserveConfigurationData(address asset) external view returns (
        uint256 decimals,
        uint256 ltv,
        uint256 liquidationThreshold,
        uint256 liquidationBonus,
        uint256 reserveFactor,
        bool usageAsCollateralEnabled,
        bool borrowingEnabled,
        bool stableBorrowRateEnabled,
        bool isActive,
        bool isFrozen
    )
    {
    }

    struct TokenData {
        string symbol;
        address tokenAddress;
    }

    function getAllPTokens() external view returns (TokenData[] memory) {
        CounterInterface counter = CounterInterface(ADDRESSES_PROVIDER.getCounter());
        address[] memory reserves = counter.getReservesList();        
        TokenData[] memory pTokens = new TokenData[](reserves.length);
        for (uint256 i = 0; i < reserves.length; i++) {
            PrestareCounterStorage.CounterProfile memory reserveData = counter.getReserveData(reserves[i]);
            pTokens[i] = TokenData({
                symbol: EIP20Interface(reserveData.pTokenAddress).symbol(),
                tokenAddress: reserveData.pTokenAddress
                });
            }
        return pTokens;
    }

    function getAllReservesTokens() external view returns (TokenData[] memory) {
        CounterInterface counter = CounterInterface(ADDRESSES_PROVIDER.getCounter());
        address[] memory reserves = counter.getReservesList();
        TokenData[] memory reservesTokens = new TokenData[](reserves.length);
        for (uint256 i = 0; i < reserves.length; i++) {
            if (reserves[i] == MKR) {
                reservesTokens[i] = TokenData({symbol: "MKR", tokenAddress: reserves[i]});
                continue;
            }
            if (reserves[i] == ETH) {
                reservesTokens[i] = TokenData({symbol: "ETH", tokenAddress: reserves[i]});
                continue;
            }
            reservesTokens[i] = TokenData({
                symbol: EIP20Interface(reserves[i]).symbol(),
                tokenAddress: reserves[i]
            });
        }
        return reservesTokens;
    }
}