// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import {AssetStorage} from "../DataType/AssetStorage.sol";
import {MarketStorage} from "../DataType/MarketStorage.sol";

/**
 * @title ICounter
 * @author Prestare
 * @notice Interface for Counter
 */
interface ICounter {
    /**
    * @dev Emitted on deposit()
    * @param assetAddr The address of the underlying asset of the reserve
    * @param user The address initiating the deposit
    * @param receiver The beneficiary of the deposit, receiving the pTokens
    * @param amount The amount deposited
    */
    event Deposit(
        address indexed assetAddr,
        address user,
        address indexed receiver,
        uint256 amount
    );

    /**
    * @dev Emitted on withdraw()
    * @param asset The address of the underlyng asset being withdrawn
    * @param user The address initiating the withdrawal, owner of pTokens
    * @param to Address that will receive the underlying
    * @param amount The amount to be withdrawn
    */
    event Withdraw(address indexed asset, address indexed user, address indexed to, uint256 amount);

    /**
    * @dev Emitted on borrow()
    * @param asset The address of the underlying asset being borrowed
    * @param user The address of the user initiating the borrow(),
    * @param to The address receving the fund from borrow()
    * @param amount The amount borrowed out
    * @param borrowRate The numeric rate at which the user has borrowed, expressed in ray
    */
    event Borrow(
        address indexed asset, 
        address indexed user,
        address indexed to, 
        uint256 amount,
        uint256 borrowRate
    );

    /**
    * @dev Emitted on repay()
    * @param asset The address of the underlying asset of the reserve
    * @param repayer The address of the user initiating the repay(), providing the funds
    * @param borrower The address of debt which will be repaid
    * @param amount The amount repaid
    * TODO DISCUSS There is three way to repay a debt in Prestare, it need to discuss how to show that msg
    * @param usePTokens True if the repayment is done using pTokens, `false` if done with underlying asset directly
    */
    event Repay(
        address indexed asset,
        address indexed repayer,
        address indexed borrower,
        uint256 amount,
        bool usePTokens
    );

    /**
    * @dev Emitted when a borrower is liquidated.
    * @param collateralAsset The address of the underlying asset used as collateral, to receive as result of the liquidation
    * @param debtAsset The address of the underlying borrowed asset to be repaid with the liquidation
    * @param debtor The address of the borrower getting liquidated
    * @param liquiAmount The debt amount of borrowed `asset` the liquidator wants to cover
    * @param liquidatedCollateralAmount The amount of collateral received by the liquidator
    * @param liquidator The address of the liquidator
    * @param liquidationMode choose the liquidation way. 0: external liquidation, 1: internal liquidation, 2: flash loan
    **/
    event LiquidationCall(
        address indexed collateralAsset,
        address indexed debtAsset,
        address indexed debtor,
        uint256 liquiAmount,
        uint256 liquidatedCollateralAmount,
        address liquidator,
        uint8 liquidationMode
    );

    /**
     * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying pTokens.
     * - E.g. User deposits 100 USDC and gets in return 100 pUSDC
     * @param assetAddr The address of the underlying asset to deposit
     * @param amount The amount to be deposited
     * @param depositor The address that will receive the pTokens, same as msg.sender if the user
     *   wants to receive them on his own wallet, or a different address if the beneficiary of pTokens
     *   is a different wallet
    */
    function deposit(
        address assetAddr,
        uint256 amount,
        address depositor
    ) external;

    // AAVE V3 use EIP-2612 TO PRODUCE permit function, but fow now we dont apply permit function in our contracts.

    /**
     * @dev Withdraws an 'amount' of underlying asset from the reserve, burn the equivalent pToken 
     * @param asset The address of the underlying asset to withdraw
     * @param amount The underlying amount to be withdrawn
     * @param to The address that receive the underlying
     * @return The actual amount be withdrawm 
     */
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

    /**
     * @dev Allow users to borrow a `amount` of the reserve underlying asset
     * @param assetAddr The address of the underlying asset to borrow
     * @param amount The amount to be borrowed
     * @param borrower The address of the borrower who receive the fund
     * @param crtQuota The level of the Crt
     */
    function borrow(
        address assetAddr,
        uint256 amount,
        address borrower,
        uint8 crtQuota
    ) external;

    /**
     * @dev Rpays a borrowed `amount` on a specific reserve
     * @param asset The address of the borrowed underlying
     * @param amount The amount to repay
     * @param borrower The address of the user who repay his debt
     * @return The final amount repaid 
     */
    function repay(
        address asset,
        uint256 amount,
        address borrower
    ) external returns (uint256);

    /**
     * @dev Function to liquidate a non-healthy position collateral-wise, with Health Factor below 1
     * @param collateralCurrency The address of the underlying asset used as collateral, to receive as result of the liquidation
     * @param debtAsset The address of the underlying borrowed asset to be repaid with the liquidation
     * @param debtor The address of the borrower getting liquidated
     * @param LiquiAmount The debt amount of borrowed `asset` the liquidator wants to cover
     * @param liquidationMode choose the liquidation way. 0: external liquidation, 1: internal liquidation, 2: flash loan
     */
    function liquidationCall(
        address collateralCurrency, 
        address debtAsset, 
        address debtor, 
        uint256 LiquiAmount, 
        uint8 liquidationMode
    ) external;

    function initReserve(
        address reserve,
        address pTokenAddress,
        address crtAddress,
        address interestRateStrategyAddress
    ) external;

    function validateTransfer(address aset, address sender, address receiver, uint256 amount) external;

    /**
   * @dev Returns the state and configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The state of the reserve
   **/
    function getAssetData(address asset) external view returns (AssetStorage.AssetProfile memory);

    function getCRTData(address asset) external view returns (MarketStorage.CreditTokenStorage memory);

    function getUserData(address user, address assetAddr) external view returns (MarketStorage.UserBalanceByAsset memory);

    function getReservesList() external view returns (address[] memory);

    function setConfiguration(address reserve, uint256 configuration) external;
    
    /**
   * @dev Returns the configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The configuration of the reserve
   **/
    function getConfiguration(address asset)
        external
        view
        returns (AssetStorage.CounterConfigMapping memory);

}
