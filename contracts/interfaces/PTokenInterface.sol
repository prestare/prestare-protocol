// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import {EIP20Interface} from "./dependencies/EIP20Interface.sol";
import {IScaledBalanceToken} from "./interfaces/IScaledBalanceToken.sol";
import {InitialPToken} from "./interfaces/InitialPToken.sol";

interface PTokenInterface is EIP20Interface, IScaledBalanceToken, InitialPToken {
    
    /**
     * @dev Emitted after the mint action
     * @param form The address performing the mint
     * @param value The amount being
     * @param index The new liquidity index of the reserve
     */
    event Mint(address indexed from, uint256 value, uint256 newindex);
    
    /**
     * @dev Emitted after the burn action
     * @param user The owner of the pTokens, getting them burned
     * @param receiverOfUnderlying The address that will receive the underlying
     * @param amount The amount being burned
     * @param newIndex The new liquidity index of the reserve
     */
    event Burn(
        address indexed user, 
        address indexed receiverOfUnderlying, 
        uint256 amount, 
        uint256 newIndex
    );

    /**
     * @dev Emitted after the transfer action
     * @param form The address performing the transaction
     * @param to The address receive this token
     * @param value The amount of tokens getting transferred
     */
    event Transfer(address indexed from, address indexed to, uint256 value);


    /**
     * @dev Emitted during the transfer action
     * @param from The user whose tokens are being transferred
     * @param to The recipient
     * @param value The amount being transferred
     * @param index The new liquidity index of the reserve
     */
    event BalanceTransfer(address indexed from, address indexed to, uint256 value, uint256 index);

    /**
     * @dev Mints `amount` pTokens to `user`
     * @param user The address receiving the minted tokens
     * @param amount The amount of tokens getting minted
     * @param newindex The new liquidity index of the reserve
     * @return `true` if the the previous balance of the user was 0
     */
    function mint(
        address user,
        uint256 amount,
        uint256 newindex
    ) external returns (bool);

    /**
     * @dev Mints pTokens to the reserve treasury
     * @param amount The amount of tokens getting minted
     * @param index The new liquidity index of the reserve
     */
    function mintTogasStation(uint256 amount, uint256 index) external;

    /**
     * @dev Burns pTokens from `user` and sends the equivalent amount of underlying to `receiverOfUnderlying`
     * @param user The owner of the pTokens, getting them burned
     * @param receiverOfUnderlying The address that will receive the underlying
     * @param amount The amount being burned
     * @param newIndex The new liquidity index of the reserve
     */
    function burn(
        address user,
        address receiverOfUnderlying,
        uint256 amount,
        uint256 newIndex
    ) external;

    /**
     * @dev Transfers pTokens in the event of a borrow being liquidated, in case the liquidators reclaims the pToken
     * @param from The address getting liquidated, current owner of the pTokens
     * @param to The recipient
     * @param value The amount of tokens getting transferred
     */
    function transferOnLiquidation(
        address from,
        address to,
        uint256 value
    ) external;

    /**
     * @notice Transfer pToken to CRT pool
     * Question 通过CRT清算的方法，如何将财产转化为稳定币存储到CRT中
     * @param from The address getting liquidated, current owner of the pTokens
     * @param value The amount of tokens getting transferred
     */
    function transferOnCRT(
        address from,
        uint256 value
    ) external;

    /**
     * @dev Transfers the underlying asset to `target`. Used by the LendingPool to transfer
     * assets in borrow(), withdraw() and flashLoan()
     * @param user The recipient of the underlying
     * @param amount The amount getting transferred
     * @return The amount transferred
     */
    function transferUnderlyingTo(address user, uint256 amount) external returns (uint256);

    /**
     * @dev Returns the address of the incentives controller contract
     */
    function getIncentivesController() external view returns (IAaveIncentivesController);

    /**
     * @dev Returns the address of the underlying asset of this pToken (E.g. WETH for aWETH)
    */
    function UNDERLYING_ASSET_ADDRESS() external view returns (address);
}

contract PTokenStorage {
    /**
     * @dev Guard variable for re-entrancy checks
     */
    bool internal _notEntered;

    /**
     * @notice EIP-20 token name for this token
     */
    string public name;

    /**
     * @notice Administrator for this contract
     */
    // TODO: From Solidity 0.8.0 you don't need to declare the address as payable explicitly, but when you are transferring an amount to such address.
    address public admin;

    /**
    * @notice Block number that interest last accured at
    */
    uint public accrualBlockNumber;

    /**
    * @notice Total earned interest rate accumulated since the opening of the market
    */ 
    uint public borrowIndex;

    /**
     * @notice Total amount of outstanding borrows of the underlying in this market
     */
    uint public totalBorrows;

    /**
     * @notice Total amount of reserves of the underlying held in this market
     */
    uint public totalReserves;

    /**
     * @notice Total number of tokens in circulation
     */
    uint public totalSupply;

    /**
    * token symbol for this token
    */
    string public symbol;

    /**
     * @notice Official record of token balances for each account
     */
    mapping (address => uint) internal accountTokens;

    /**
     * @notice Approved token transfer amounts on behalf of others
     */
    mapping (address => mapping (address => uint)) internal transferAllowances;

    /**
     * @notice Container for borrow balance information
     * @member principal Total balance (with accrued interest), after applying the most recent balance-changing action
     * @member interestIndex Global borrowIndex as of the most recent balance-changing action
     */
    struct BorrowSnapshot 
    {
        uint principal;
        uint interestIndex;
    }

    /**
     * @notice Mapping of account addresses to outstanding borrow balances
     */
    mapping(address => BorrowSnapshot) internal accountBorrows;

    /*** Market Events ***/

    /**
     * @notice Event emitted when interest is accrued
     */
    event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);

    /**
     * @notice Event emitted when tokens are minted
     */
    event Mint(address minter, uint mintAmount, uint mintTokens);

    /**
     * @notice Event emitted when underlying is borrowed
     */
    event Borrow(address borrower, uint borrowAmount, uint accountBorrows, uint totalBorrows);

    /**
     * @notice Event emitted when tokens are redeemed
     */
    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens);

    /*** Admin Events ***/

    /**
     * @notice EIP20 Transfer event
     */
    event Transfer(address indexed from, address indexed to, uint amount);

    /**
     * @notice Event emitted when a borrow is repaid
     */
    event RepayBorrow(address payer, address borrower, uint repayAmount, uint accountBorrows, uint totalBorrows);
}