// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import {PrestareCounterStorage} from "./../DataType/PrestareStorage.sol";
import {PrestareMarketStorage} from "./../DataType/PrestareStorage.sol";


interface CounterInterface {
    /**
    * @dev Emitted on deposit()
    * @param assetAddr The address of the underlying asset of the reserve
    * @param user The address initiating the deposit
    * @param receiver The beneficiary of the deposit, receiving the pTokens
    * @param amount The amount deposited
    **/
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
    **/
    event Withdraw(address indexed asset, address indexed user, address indexed to, uint256 amount);

    event Borrow(address indexed asset, address indexed to, uint256 amount);

    event Repay(address indexed asset, address indexed from, uint256 amount);

    /**
   * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
   * - E.g. User deposits 100 USDC and gets in return 100 aUSDC
   * @param asset The address of the underlying asset to deposit
   * @param amount The amount to be deposited
   * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user
   *   wants to receive them on his own wallet, or a different address if the beneficiary of aTokens
   *   is a different wallet
   **/
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external;

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
}
