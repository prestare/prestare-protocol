// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {DataTypes} from '../types/DataTypes.sol';

/**
 * @title Helpers library
 */
library Helpers {
  /**
   * @dev Fetches the user current variable debt balances
   * @param user The user address
   * @param reserve The reserve data object
   * @return The variable debt balance
   **/
  function getUserCurrentDebt(address user, DataTypes.ReserveData storage reserve)
    internal
    view
    returns (uint256)
  {
    return (
      IERC20(reserve.variableDebtTokenAddress).balanceOf(user)
    );
  }

  function getUserCurrentDebtMemory(address user, DataTypes.ReserveData memory reserve)
    internal
    view
    returns (uint256)
  {
    return (
      IERC20(reserve.variableDebtTokenAddress).balanceOf(user)
    );
  }
}
