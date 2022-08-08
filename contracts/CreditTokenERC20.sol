// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Context} from "./dependencies/openzeppelin/contracts/Context.sol";
import {EIP20Interface} from "./dependencies/EIP20Interface.sol";
import {SafeMath256} from "./dependencies/openzeppelin/contracts/SafeMath.sol";
import {Error} from "./utils/Error.sol";

import "hardhat/console.sol";

// TODO: or just simple inherit the PTokenERC20 (is there any attack chance?)

abstract contract CreditTokenERC20 is Context, EIP20Interface {
    using SafeMath256 for uint256;

    mapping(address => uint256) internal _crtBalances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
    * @return The name of the token
    **/
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
    * @return The symbol of the token
    **/
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
    * @return The decimals of the token
    **/
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
    * @return The total supply of the token
    **/
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
    * @return The balance of the token
    **/
    function balanceOf(address account) public view virtual override returns (uint256) {
        console.log("crtERC20");
        return _crtBalances[account];
    }

    /**
    * @dev Executes a transfer of tokens from _msgSender() to recipient
    * @param recipient The recipient of the tokens
    * @param amount The amount of tokens being transferred
    * @return `true` if the transfer succeeds, `false` otherwise
    **/
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        // _transfer(_msgSender(), recipient, amount);
        emit Transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
    * @dev Returns the allowance of spender on the tokens owned by owner
    * @param owner The owner of the tokens
    * @param spender The user allowed to spend the owner's tokens
    * @return The amount of owner's tokens spender is allowed to spend
    **/
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        // return _allowances[owner][spender];
    }

    /**
    * @dev Allows `spender` to spend the tokens owned by _msgSender()
    * @param spender The user allowed to spend _msgSender() tokens
    * @return `true`
    **/
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        // _approve(_msgSender(), spender, amount);
        return true;
    }


    function _setName(string memory newName) internal {
        _name = newName;
    }

    function _setSymbol(string memory newSymbol) internal {
        _symbol = newSymbol;
    }

    function _setDecimals(uint8 newDecimals) internal {
        _decimals = newDecimals;
    }
}