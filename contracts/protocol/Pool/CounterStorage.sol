// SPDX-License-Identifier: none
pragma solidity ^0.8.10;

import {ICounterAddressesProvider} from '../../interfaces/ICounterAddressesProvider.sol';

import {ReserveLogic} from '../libraries/logic/ReserveLogic.sol';
import {ReserveConfiguration} from '../libraries/configuration/ReserveConfiguration.sol';
import {UserConfiguration} from '../libraries/configuration/UserConfiguration.sol';
import {DataTypes} from '../libraries/types/DataTypes.sol';

/**
 * @title CounterStorage
 * @author Prestare
 * @notice Contract used as storage of the Counter contract.
 * @dev It defines the storage layout of the Counter contract.
 */
contract CounterStorage {

  ICounterAddressesProvider public _addressesProvider;

  // Map of reserves and map of their risk tier and their data (underlyingAssetOfReserve (Tier => reserveData))
  mapping(address => mapping(uint8 => DataTypes.ReserveData)) internal _reserves;
  // Map of asset and their class,  0 is highest
  mapping(address => uint8) internal _assetClass;
  // Map of users address and their configuration data (userAddress => userConfiguration)
  mapping(address => DataTypes.UserConfigurationMap) internal _usersConfig;
  
  // Map of users address and their lock Crt Value
  mapping(address => DataTypes.UserCreditData) internal _usersCredit;
  // List of reserves as a map (reserveId => reserve).
  // It is structured as a mapping for gas savings reasons, using the reserve id as index
  mapping(uint256 => DataTypes.RerserveAdTier) internal _reservesList;

  // count how many different asset and different risk tier was added in _reservesList
  uint256 internal _reservesCount;

  bool internal _paused;

  uint256 internal _flashLoanPremiumTotal;

  uint256 internal _maxNumberOfReserves;
  uint256 internal _maxAssetClass;

  address internal _crtaddress;

}