// SPDX-License-Identifier: none
pragma solidity ^0.8.10;

import {ReserveConfiguration} from '../configuration/ReserveConfiguration.sol';
import {UserConfiguration} from '../configuration/UserConfiguration.sol';
import {Errors} from '../helpers/Errors.sol';
import {ReserveLogic} from './ReserveLogic.sol';
import {WadRayMath} from '../math/WadRayMath.sol';
import {PercentageMath} from '../math/PercentageMath.sol';
import {DataTypes} from '../types/DataTypes.sol';

/**
 * @title ReserveLogic library
 * @author Prestare
 * @notice Implements functions to validate the different actions of the protocol
 */
library ValidationLogic {
  using ReserveLogic for DataTypes.ReserveData;
  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;

  uint256 public constant REBALANCE_UP_LIQUIDITY_RATE_THRESHOLD = 4000;
  uint256 public constant REBALANCE_UP_USAGE_RATIO_THRESHOLD = 0.95 * 1e27; //usage ratio of 95%

  /**
   * @dev Validates a deposit action
   * @param reserve The reserve object on which the user is depositing
   * @param amount The amount to be deposited
   */
  function validateDeposit(DataTypes.ReserveData storage reserve, uint256 amount) external view {
    (bool isActive, bool isFrozen, , ) = reserve.configuration.getFlags();

    require(amount != 0, Errors.VL_INVALID_AMOUNT);
    require(isActive, Errors.VL_NO_ACTIVE_RESERVE);
    require(!isFrozen, Errors.VL_RESERVE_FROZEN);
  }

  
}
