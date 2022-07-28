// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import {PrestareCounterStorage, PrestareMarketStorage} from "../DataType/PrestareStorage.sol";

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
    * @param user The address of the user initiating the borrow(), receiving the funds on borrow()
    * @param to The address that will be getting the debt
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
    * @param user The address of the borrower getting liquidated
    * @param debtToCover The debt amount of borrowed `asset` the liquidator wants to cover
    * @param liquidatedCollateralAmount The amount of collateral received by the liquidator
    * @param liquidator The address of the liquidator
    * @param receivePToken True if the liquidators wants to receive the collateral pTokens, `false` if he wants
    * to receive the underlying collateral asset directly
    **/
    event LiquidationCall(
        address indexed collateralAsset,
        address indexed debtAsset,
        address indexed user,
        uint256 debtToCover,
        uint256 liquidatedCollateralAmount,
        address liquidator,
        bool receivePToken
    );

    /**
   * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying pTokens.
   * - E.g. User deposits 100 USDC and gets in return 100 pUSDC
   * @param assetAddr The address of the underlying asset to deposit
   * @param amount The amount to be deposited
   * @param to The address that will receive the pTokens, same as msg.sender if the user
   *   wants to receive them on his own wallet, or a different address if the beneficiary of pTokens
   *   is a different wallet
   **/
    function deposit(
        address assetAddr,
        uint256 amount,
        address depositor
    ) external;

    // AAVE V3 use EIP-2612 TO PRODUCE permit function, but fow now we dont apply permit function in our contracts.


    function borrow(
        address assetAddr,
        uint256 amount,
        address borrower,
        uint8 crtQuota
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
    function getCounterData(address asset) external view returns (PrestareCounterStorage.CounterProfile memory);

    function getCRTData(address asset) external view returns (PrestareMarketStorage.CreditTokenStorage memory);

    function getUserData(address user, address assetAddr) external view returns (PrestareMarketStorage.UserBalanceByAsset memory);

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
        returns (PrestareCounterStorage.CounterConfigMapping memory);

    /**
     * @dev Returns the state and configuration of the reserve
     * @param asset The address of the underlying asset of the reserve
     * @return The state of the reserve
     */
    function getReserveData(address asset) external view returns (PrestareCounterStorage.CounterProfile memory);

}
