// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.10;

/**
 * @title IReserveInterestRateStrategyInterface interface
 * @dev Interface for the calculation of the interest rates
 * @author Aave
 */
interface IReserveInterestRateStrategy {
  function baseVariableBorrowRate() external view returns (uint256);

  function getMaxVariableBorrowRate() external view returns (uint256);

  function calculateInterestRates(
    address reserve,
    uint256 availableLiquidity,
    uint256 totalVariableDebt,
    uint256 reserveFactor
  )
    external
    view
    returns (
      uint256,
      uint256
    );

  function calculateInterestRates(
    address reserve,
    address pToken,
    uint256 liquidityAdded,
    uint256 liquidityTaken,
    uint256 totalVariableDebt,
    uint256 reserveFactor
  )
    external
    view
    returns (
      uint256 liquidityRate,
      uint256 variableBorrowRate
    );
}
