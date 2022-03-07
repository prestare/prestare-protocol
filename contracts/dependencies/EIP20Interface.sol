// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

/**
 * @title ERC 20 Token Standard Interface
 * @notice Accourding to EIP20 
    https://eips.ethereum.org/EIPS/eip-20
 */
interface EIP20Interface {

    /**
     * @dev Emitted when transfer function return true. 
     * The value can be zero.
     */
    event Transfer(address indexed src, address indexed dst, uint256 amount);
    
    /**
     * @dev Emitted when the approve function return true.
     * The value is the new allowance
     */
    event Approval(address indexed src, address indexed dst, uint256 amount);

    /**
     * @notice Get the name of the Token
     * @return Returns the name of this token
     */
    function name() external view returns (string memory);

    /**
     * @notice Get the symbol of this token
     * @return Returns the symbol of this token, like PRS
     */
    function symbol() external view returns (string memory);

    /**
     * @notice Get the decimals ues in this token
     * @return the number of decimals used to get its user representation.
     */
    function decimals() external view returns (uint8);

    /**
     * @notice Get the total number of tokens in circulation
     * @return Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Gets the balance of the specified address
     * @param owner The address from which the balance will be retrieved
     * @return Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @notice Moves `amount` tokens from the caller's account to `recipient`.
     * @dev Emits a {Transfer} event.
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     * @return a boolean value indicating whether the operation succeeded.
     * 
     */
    function transfer(address dst, uint256 amount) external returns (bool);

    /**
      * @notice Transfer `amount` tokens from `src` to `dst`
      * @param src The address of the source account
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      * @return a boolean value indicating whether the operation succeeded.
      */
    function transferFrom(address src, address dst, uint256 amount) external returns (bool);

    /**
      * @notice Approve `spender` to transfer up to `amount` from `src`
      * @dev Emits an {Approval} event.
      * 
      * IMPORTANT: 
      *  This will overwrite the approval amount for `spender`
      *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
      *  
      * @param spender The address of the account which may transfer tokens
      * @param amount The number of tokens that are approved (-1 means infinite)
      * @return a boolean value indicating whether the operation succeeded.
      */
    function approve(address spender, uint256 amount) external returns (bool); 

    /**
      * @notice Get the current allowance from `owner` for `spender`. 
      * @dev Remaining is a zero by default. And spender can ues the allowance by the method transferfrom
      * @param owner The address of the account which owns the tokens to be spent
      * @param spender The address of the account which may transfer tokens
      * @return remaining The number of tokens allowed to be spent (-1 means infinite)
      */
    function allowance(address owner, address spender) external view returns (uint256);

}