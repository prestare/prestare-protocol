// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.4;

import { Ownable } from "../dependencies/Ownable.sol";
import { EIP20Interface } from "../dependencies/EIP20Interface.sol";

import { PriceOracleGetterInterface } from "../Interfaces/PriceOracleGetterInterface.sol";
import { ChainlinkAggregatorInterface } from "../Interfaces/ChainlinkAggregatorInterface.sol";
import { SafeERC20 } from "../dependencies/SafeERC20.sol";

/**
 * @title Prestare Oracle
 * @author Prestare
 * @dev Proxy smart contract to get the price of an asset from a price source, with Chainlink Aggregator
 *      smart contracts as primary option
 *      the returned price by a Chainlink aggregator is <= 0, the call is forwarded to a fallbackOracle
 *       Owned by the Prestare governance system, allowed to add sources for assets, replace them
 *       and change the fallbackOracle
 * @notice the fallback oracle haven't done.
 */
contract PrstareOracle is PriceOracleGetterInterface, Ownable {
    using SafeERC20 for EIP20Interface;

    event BaseCurrencySet(address indexed baseCurrency, uint256 baseCurrencyUnit);
    event AssetSourceUpdated(address indexed asset, address indexed source);
    //   event FallbackOracleUpdated(address indexed fallbackOracle);

    mapping(address => ChainlinkAggregatorInterface) private assetsSources;
    PriceOracleGetterInterface private _fallbackOracle;
    address public immutable BASE_CURRENCY;
    uint256 public immutable BASE_CURRENCY_UNIT;

    /**
     * @notice Constructor
     * @param assets The addresses of the assets
     * @param sources The address of the source of each asset
     * fallbackOracle The address of the fallback oracle to use if the data of an
                aggregator is not consistent
     * @param baseCurrency the base currency used for the price quotes. If USD is used, base currency is 0x0
     * @param baseCurrencyUnit the unit of the base currency
     */
    constructor(
        address[] memory assets,
        address[] memory sources,
        // address fallbackOracle,
        address baseCurrency,
        uint256 baseCurrencyUnit
    ) public {
        // _setFallbackOracle(fallbackOracle);
        _setAssetsSources(assets, sources);
        BASE_CURRENCY = baseCurrency;
        BASE_CURRENCY_UNIT = baseCurrencyUnit;
        emit BaseCurrencySet(baseCurrency, baseCurrencyUnit);
    }

    /**
     * @notice External function called by the Prestare governance to set or replace sources of assets
     * @param assets The addresses of the assets
     * @param sources The address of the source of each asset
     */ 
    function setAssetSources(address[] calldata assets, address[] calldata sources)
        external
        onlyOwner
    {
        _setAssetsSources(assets, sources);
    }
    /**
     * @notice Sets the fallbackOracle Callable only by the Prestare governance
     * @param fallbackOracle The address of the fallbackOracle
     */
    // function setFallbackOracle(address fallbackOracle) external onlyOwner {
    //     _setFallbackOracle(fallbackOracle);
    // }

    /**
     * @notice Internal function to set the sources for each asset
     * @param assets The addresses of the assets
     * @param sources The address of the source of each asset
     */
    function _setAssetsSources(address[] memory assets, address[] memory sources) internal {
        require(assets.length == sources.length, 'INCONSISTENT_PARAMS_LENGTH');
        for (uint256 i = 0; i < assets.length; i++) {
        assetsSources[assets[i]] = ChainlinkAggregatorInterface(sources[i]);
        emit AssetSourceUpdated(assets[i], sources[i]);
        }
    }

    /**
     * @notice Internal function to set the fallbackOracle
     * @param fallbackOracle The address of the fallbackOracle
     */
    // function _setFallbackOracle(address fallbackOracle) internal {
    //     _fallbackOracle = PriceOracleGetterInterface(fallbackOracle);
    //     emit FallbackOracleUpdated(fallbackOracle);
    // }

    /** 
     * @notice Gets an asset price by address
     * @param asset The asset address
     */
    function getAssetPrice(address asset) public view override returns (uint256) {
        ChainlinkAggregatorInterface source = assetsSources[asset];

        if (asset == BASE_CURRENCY) {
        return BASE_CURRENCY_UNIT;
        } 
        // else if (address(source) == address(0)) {
        //     return _fallbackOracle.getAssetPrice(asset);
        // } 
        else if (address(source) == address(0)) {
            require(address(source) != address(0), "Error: can't find the Price Oracle for this asset.");
        }
        else {
            int256 price = ChainlinkAggregatorInterface(source).latestAnswer();
            require(price > 0, "Error: Chainlink Price Oracle return negative price");
            return uint256(price);
            // if (price > 0) {
            //     return uint256(price);
            // } 
            // else {
            //     return _fallbackOracle.getAssetPrice(asset);
            // }
        }
    }
    
    /**
     * @notice Gets a list of prices from a list of assets addresses
     * @param assets The list of assets addresses
     */
    function getAssetsPrices(address[] calldata assets) external view returns (uint256[] memory) {
        uint256[] memory prices = new uint256[](assets.length);
        for (uint256 i = 0; i < assets.length; i++) {
        prices[i] = getAssetPrice(assets[i]);
        }
        return prices;
    }
    /**
     * @notice Gets the address of the source for an asset address
     * @param asset The address of the asset
     * @return address The address of the source
     */
    function getSourceOfAsset(address asset) external view returns (address) {
        return address(assetsSources[asset]);
    }

    /**
     * @notice Gets the address of the fallback oracle
     * @return address The addres of the fallback oracle
     */
    // function getFallbackOracle() external view returns (address) {
    //     return address(_fallbackOracle);
    // }
}
