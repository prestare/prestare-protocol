// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { Ownable } from "../../dependencies/Ownable.sol";
import { CounterAddressProviderInterface } from "../../Interfaces/CounterAddressProviderInterface.sol";
import { InitializableImmutableAdminUpgradeabilityProxy } from "../utils/InitAdminUpgradeProxy.sol";

contract CounterAddressProvider is Ownable, CounterAddressProviderInterface {
    string private _marketId;
    mapping(bytes32 => address) private _addresses;

    bytes32 private constant COUNTER = "COUNTER";
    bytes32 private constant COUNTER_CONFIGURATOR = "COUNTER_CONFIGURATOR";
    bytes32 private constant COUNTER_ADMIN = "COUNTER_ADMIN";
    bytes32 private constant EMERGENCY_ADMIN = "EMERGENCY_ADMIN";
    bytes32 private constant COUNTER_COLLATERAL_MANAGER = "COLLATERAL_MANAGER";
    bytes32 private constant PRICE_ORACLE = "PRICE_ORACLE";
    bytes32 private constant LENDING_RATE_ORACLE = "LENDING_RATE_ORACLE";

    constructor(string memory marketId) public {
        _setMarketId(marketId);
    }

    /**
    * @dev Internal function to update the implementation of a specific proxied component of the protocol
    * - If there is no proxy registered in the given `id`, it creates the proxy setting `newAdress`
    *   as implementation and calls the initialize() function on the proxy
    * - If there is already a proxy registered, it just updates the implementation to `newAddress` and
    *   calls the initialize() function via upgradeToAndCall() in the proxy
    * @param id The id of the proxy to be updated
    * @param newAddress The address of the new implementation
    **/
    function _updateImpl(bytes32 id, address newAddress) internal {
        address payable proxyAddress = payable(_addresses[id]);

        InitializableImmutableAdminUpgradeabilityProxy proxy = InitializableImmutableAdminUpgradeabilityProxy(proxyAddress);
        bytes memory params = abi.encodeWithSignature("initialize(address)", address(this));

        if (proxyAddress == address(0)) {
            proxy = new InitializableImmutableAdminUpgradeabilityProxy(address(this));
            proxy.initialize(newAddress, params);
            _addresses[id] = address(proxy);
            emit ProxyCreated(id, address(proxy));
        } else {
        proxy.upgradeToAndCall(newAddress, params);
        }
    }

    function _setMarketId(string memory marketId) internal {
        _marketId = marketId;
        emit MarketIdSet(marketId);
    }

    /**
    * @dev Returns the id of the Aave market to which this contracts points to
    * @return The market id
    **/
    function getMarketId() external view override returns (string memory) {
        return _marketId;
    }

    /**
    * @dev Allows to set the market which this CounterAddressesProvider represents
    * @param marketId The market id
    */
    function setMarketId(string memory marketId) external override onlyOwner {
        _setMarketId(marketId);
    }

    /**
    * @dev General function to update the implementation of a proxy registered with
    * certain `id`. If there is no proxy registered, it will instantiate one and
    * set as implementation the `implementationAddress`
    * IMPORTANT Use this function carefully, only for ids that don't have an explicit
    * setter function, in order to avoid unexpected consequences
    * @param id The id
    * @param implementationAddress The address of the new implementation
    */
    function setAddressAsProxy(bytes32 id, address implementationAddress)
        external
        override
        onlyOwner
    {
        _updateImpl(id, implementationAddress);
        emit AddressSet(id, implementationAddress, true);
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
    * @dev Returns the address of the Counter proxy
    * @return The Counter proxy address
    **/
    function getCounter() external view override returns (address) {
        return getAddress(COUNTER);
    }

    /**
    * @dev Updates the implementation of the Counter, or creates the proxy
    * setting the new `pool` implementation on the first time calling it
    * @param pool The new Counter implementation
    **/
    function setCounterImpl(address pool) external override onlyOwner {
        _updateImpl(COUNTER, pool);
        emit CounterUpdated(pool);
    }

    /**
    * @dev Returns the address of the CounterConfigurator proxy
    * @return The CounterConfigurator proxy address
    **/
    function getCounterConfigurator() external view override returns (address) {
        return getAddress(COUNTER_CONFIGURATOR);
    }

    /**
    * @dev Updates the implementation of the CounterConfigurator, or creates the proxy
    * setting the new `configurator` implementation on the first time calling it
    * @param configurator The new CounterConfigurator implementation
    **/
    function setCounterConfiguratorImpl(address configurator) external override onlyOwner {
        _updateImpl(COUNTER_CONFIGURATOR, configurator);
        emit CounterConfiguratorUpdated(configurator);
    }

    /**
   * @dev Returns the address of the CounterCollateralManager. Since the manager is used
   * through delegateCall within the Counter contract, the proxy contract pattern does not work properly hence
   * the addresses are changed directly
   * @return The address of the CounterCollateralManager
   **/

    function getCounterCollateralManager() external view override returns (address) {
        return getAddress(COUNTER_COLLATERAL_MANAGER);
    }

    /**
    * @dev Updates the address of the CounterCollateralManager
    * @param manager The new CounterCollateralManager address
    **/
    function setCounterCollateralManager(address manager) external override onlyOwner {
        _addresses[COUNTER_COLLATERAL_MANAGER] = manager;
        emit CounterCollateralManagerUpdated(manager);
    }

    /**
    * @dev The functions below are getters/setters of addresses that are outside the context
    * of the protocol hence the upgradable proxy pattern is not used
    **/

    function getCounterAdmin() external view override returns (address) {
        return getAddress(COUNTER_ADMIN);
    }

    function setCounterAdmin(address admin) external override onlyOwner {
        _addresses[COUNTER_ADMIN] = admin;
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

    function getLendingRateOracle() external view override returns (address) {
        return getAddress(LENDING_RATE_ORACLE);
    }

    function setLendingRateOracle(address lendingRateOracle) external override onlyOwner {
        _addresses[LENDING_RATE_ORACLE] = lendingRateOracle;
        emit LendingRateOracleUpdated(lendingRateOracle);
    }
}