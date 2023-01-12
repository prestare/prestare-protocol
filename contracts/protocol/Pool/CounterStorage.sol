// SPDX-License-Identifier: none
pragma solidity ^0.8.10;

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

  // Map of reserves and their data (underlyingAssetOfReserve => reserveData)
  mapping(address => DataTypes.ReserveData) internal _reserves;

  // Map of users address and their configuration data (userAddress => userConfiguration)
  mapping(address => DataTypes.UserConfigurationMap) internal _usersConfig;

  // List of reserves as a map (reserveId => reserve).
  // It is structured as a mapping for gas savings reasons, using the reserve id as index
  mapping(uint256 => address) internal _reservesList;

  uint256 internal _reservesCount;

  bool internal _paused;

  uint256 internal _flashLoanPremiumTotal;

  uint256 internal _maxNumberOfReserves;

  uint256 internal _crtaddress;

}