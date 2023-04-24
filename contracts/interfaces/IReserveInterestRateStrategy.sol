// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import {IBaseRateModel} from './IBaseRateModel.sol';

/**
 * @title IReserveInterestRateStrategyInterface interface
 * @dev Interface for the calculation of the interest rates
 */
interface IReserveInterestRateStrategy is IBaseRateModel {
  function baseVariableBorrowRate() external view returns (uint256);

  function getMaxVariableBorrowRate() external view returns (uint256);

}
