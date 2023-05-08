// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;


interface ICounterCollateralManager {
  /**
   * @dev Emitted when a borrower is liquidated
   * @param collateral The address of the collateral being liquidated
   * @param principal The address of the reserve
   * @param user The address of the user being liquidated
   * @param debtToCover The total amount liquidated
   * @param liquidatedCollateralAmount The amount of collateral being liquidated
   * @param liquidator The address of the liquidator
   * @param receivepToken true if the liquidator wants to receive pTokens, false otherwise
   **/
  event LiquidationCall(
    address indexed collateral,
    address indexed principal,
    address indexed user,
    uint256 debtToCover,
    uint256 liquidatedCollateralAmount,
    address liquidator,
    bool receivepToken
  );

  /**
   * @dev Emitted when a reserve is disabled as collateral for an user
   * @param reserve The address of the reserve
   * @param user The address of the user
   **/
  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);

  /**
   * @dev Emitted when a reserve is enabled as collateral for an user
   * @param reserve The address of the reserve
   * @param user The address of the user
   **/
  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);

  struct ExcuteLiqudationParams {
    address collateralAsset;
    uint8 collateralRiskTier;
    address debtAsset;
    uint8 debtRiskTier;
    address user;
    uint256 debtToCover;
    bool receivePToken;
  }
  /**
   * @dev Function to liquidate a position if its Health Factor drops below 1
   * - The caller (liquidator) covers `debtToCover` amount of debt of the user getting liquidated, and receives
   *   a proportionally amount of the `collateralAsset` plus a bonus to cover market risk
   * @param liqParams contain:
   *  collateralAsset The address of the underlying asset used as collateral, to receive as result of the liquidation
   *  collateralRiskTier The risk tier of the collateralAsset
   *  debtAsset The address of the underlying borrowed asset to be repaid with the liquidation
   *  debtRiskTier The risk tier of the debtAsset
   *  user The address of the borrower getting liquidated
   *  debtToCover The debt amount of borrowed `asset` the liquidator wants to cover
   *  receivePToken `true` if the liquidators wants to receive the collateral pTokens, `false` if he wants
   * to receive the underlying collateral asset directly
   **/
  function liquidationCall(
    ExcuteLiqudationParams memory liqParams
  ) external returns (uint256, string memory);
}
