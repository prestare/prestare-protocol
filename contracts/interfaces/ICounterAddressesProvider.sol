// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

/**
 * @title CounterAddressesProvider contract
 * @dev Main registry of addresses part of or connected to the protocol, including permissioned roles
 * - Acting also as factory of proxies and admin of those, so with right to change its implementations
 * - Owned by the Prestare Community
 * @author Prestare
 **/

interface ICounterAddressesProvider {
  event MarketIdSet(string newMarketId);
  event CounterUpdated(address indexed newAddress);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event CounterConfiguratorUpdated(address indexed newAddress);
  event CounterCollateralManagerUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  function getMarketId() external view returns (string memory);

  function setMarketId(string calldata marketId) external;

  function setAddress(bytes32 id, address newAddress) external;

  // function setAddressAsProxy(bytes32 id, address impl) external;

  function getAddress(bytes32 id) external view returns (address);

  function getCounter() external view returns (address);

  // function setCounterImpl(address pool) external;

  function getCounterConfigurator() external view returns (address);

  // function setCounterConfiguratorImpl(address configurator) external;

  function getCounterCollateralManager() external view returns (address);

  function setCounterCollateralManager(address manager) external;

  function getPoolAdmin() external view returns (address);

  function setPoolAdmin(address admin) external;

  function getEmergencyAdmin() external view returns (address);

  function setEmergencyAdmin(address admin) external;

  function getPriceOracle() external view returns (address);

  function setPriceOracle(address priceOracle) external;

  function getCounterOracle() external view returns (address);

  function setCounterOracle(address lendingRateOracle) external;
}