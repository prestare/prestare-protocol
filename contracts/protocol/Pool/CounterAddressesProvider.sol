// SPDX-License-Identifier: none
pragma solidity ^0.8.10;

import {Ownable} from '../../CRT/openzeppelin/Ownable.sol';
import {ICounterAddressesProvider} from '../../interfaces/ICounterAddressesProvider.sol';

contract CounterAddressesProvider is Ownable, ICounterAddressesProvider {
    string private _marketId;
    mapping(bytes32 => address) private _addresses;

    bytes32 private constant COUNTER = 'COUNTER';
    bytes32 private constant COUNTER_CONFIGURATOR = 'COUNTER_CONFIGURATOR';
    bytes32 private constant POOL_ADMIN = 'POOL_ADMIN';
    bytes32 private constant EMERGENCY_ADMIN = 'EMERGENCY_ADMIN';
    bytes32 private constant COUNTER_COLLATERAL_MANAGER = 'COLLATERAL_MANAGER';
    bytes32 private constant PRICE_ORACLE = 'PRICE_ORACLE';
    bytes32 private constant LENDING_RATE_ORACLE = 'LENDING_RATE_ORACLE';

    constructor(string memory marketId) public {
        _setMarketId(marketId);
    }

    /**
     * @dev Returns the id of the Prestare market chain to which this contracts points to
     * @return The market id
    **/
    function getMarketId() external view override returns (string memory) {
        return _marketId;
    }

    /**
     * @dev Allows to set the market which this LendingPoolAddressesProvider represents
     * @param marketId The market id
     */
    function setMarketId(string memory marketId) external override onlyOwner {
        _setMarketId(marketId);
    }

    /**
     * @dev Sets an address for an id replacing the address saved in the addresses map
     * IMPORTANT Use this function carefully, as it will do a hard replacement
     * @param id The id
     * @param newAddress The address to set
     */
    function setAddress(bytes32 id, address newAddress) external override onlyOwner {
        _addresses[id] = newAddress;
        emit AddressSet(id, newAddress, false);
    }

    /**
    * @dev Returns an address by id
    * @return The address
    */
    function getAddress(bytes32 id) public view override returns (address) {
        return _addresses[id];
    }

    /**
    * @dev Returns the address of the LendingPool proxy
    * @return The LendingPool proxy address
    **/
    function getCounter() external view override returns (address) {
        return getAddress(COUNTER);
    }

    /**
    * @dev Returns the address of the LendingPoolConfigurator proxy
    * @return The LendingPoolConfigurator proxy address
    **/
    function getCounterConfigurator() external view override returns (address) {
        return getAddress(COUNTER_CONFIGURATOR);
    }

    /**
    * @dev Returns the address of the LendingPoolCollateralManager. Since the manager is used
    * through delegateCall within the LendingPool contract, the proxy contract pattern does not work properly hence
    * the addresses are changed directly
    * @return The address of the LendingPoolCollateralManager
    **/

    function getCounterCollateralManager() external view override returns (address) {
        return getAddress(COUNTER_COLLATERAL_MANAGER);
    }

    /**
    * @dev Updates the address of the LendingPoolCollateralManager
    * @param manager The new LendingPoolCollateralManager address
    **/
    function setCounterCollateralManager(address manager) external override onlyOwner {
        _addresses[COUNTER_COLLATERAL_MANAGER] = manager;
        emit CounterCollateralManagerUpdated(manager);
    }
    /**
    * @dev The functions below are getters/setters of addresses that are outside the context
    * of the protocol hence the upgradable proxy pattern is not used
    **/

    function getPoolAdmin() external view override returns (address) {
        return getAddress(POOL_ADMIN);
    }

    function setPoolAdmin(address admin) external override onlyOwner {
        _addresses[POOL_ADMIN] = admin;
        emit ConfigurationAdminUpdated(admin);
    }

    function getEmergencyAdmin() external view override returns (address) {
        return getAddress(EMERGENCY_ADMIN);
    }

    function setEmergencyAdmin(address emergencyAdmin) external override onlyOwner {
        _addresses[EMERGENCY_ADMIN] = emergencyAdmin;
        emit EmergencyAdminUpdated(emergencyAdmin);
    }

    function getPriceOracle() external view override returns (address) {
        return getAddress(PRICE_ORACLE);
    }

    function setPriceOracle(address priceOracle) external override onlyOwner {
        _addresses[PRICE_ORACLE] = priceOracle;
        emit PriceOracleUpdated(priceOracle);
    }

    function getCounterOracle() external view override returns (address) {
        return getAddress(LENDING_RATE_ORACLE);
    }

    function setCounterOracle(address lendingRateOracle) external override onlyOwner {
        _addresses[LENDING_RATE_ORACLE] = lendingRateOracle;
        emit LendingRateOracleUpdated(lendingRateOracle);
    }

    function _setMarketId(string memory marketId) internal {
        _marketId = marketId;
        emit MarketIdSet(marketId);
    }

}