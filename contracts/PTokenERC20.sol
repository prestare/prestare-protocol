// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Context} from "./dependencies/utils/Context.sol";
import {EIP20Interface} from "./dependencies/EIP20Interface.sol";
import {IERC20Detailed} from "./dependencies/ERC20Detailed.sol";
import {SafeMath256} from "./dependencies/SafeMath.sol";
import {Error} from "./utils/Error.sol";

import "hardhat/console.sol";

/**
 * @title ERC20
 * @notice Basic ERC20 implementation
 * @author Aave, inspired by the Openzeppelin ERC20 implementation
 **/
abstract contract PTokenERC20 is Context, EIP20Interface, IERC20Detailed {
    using SafeMath256 for uint256;

    mapping(address => uint256) internal _balances;

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
        return _balances[account];
    }

    /**
    * @dev Executes a transfer of tokens from _msgSender() to recipient
    * @param recipient The recipient of the tokens
    * @param amount The amount of tokens being transferred
    * @return `true` if the transfer succeeds, `false` otherwise
    **/
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
        return _allowances[owner][spender];
    }

    /**
    * @dev Allows `spender` to spend the tokens owned by _msgSender()
    * @param spender The user allowed to spend _msgSender() tokens
    * @return `true`
    **/
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    // /**
    // * @dev Executes a transfer of token from sender to recipient, if _msgSender() is allowed to do so
    // * @param sender The owner of the tokens
    // * @param recipient The recipient of the tokens
    // * @param amount The amount of tokens being transferred
    // * @return `true` if the transfer succeeds, `false` otherwise
    // **/
    // function transferFrom(
    //     address sender,
    //     address recipient,
    //     uint256 amount
    // ) public virtual override returns (bool) {
    //     _transfer(sender, recipient, amount);
    //     _approve(
    //     sender,
    //     _msgSender(),
    //     _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
    //     );
    //     emit Transfer(sender, recipient, amount);
    //     return true;
    // }

    // /**
    // * @dev Increases the allowance of spender to spend _msgSender() tokens
    // * @param spender The user allowed to spend on behalf of _msgSender()
    // * @param addedValue The amount being added to the allowance
    // * @return `true`
    // **/
    // function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    //     _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    //     return true;
    // }

    // /**
    // * @dev Decreases the allowance of spender to spend _msgSender() tokens
    // * @param spender The user allowed to spend on behalf of _msgSender()
    // * @param subtractedValue The amount being subtracted to the allowance
    // * @return `true`
    // **/
    // function decreaseAllowance(address spender, uint256 subtractedValue)
    //     public
    //     virtual
    //     returns (bool)
    // {
    //     _approve(
    //     _msgSender(),
    //     spender,
    //     _allowances[_msgSender()][spender].sub(
    //         subtractedValue,
    //         "ERC20: decreased allowance below zero"
    //     )
    //     );
    //     return true;
    // }

    function _transfer(
        address sender,
        address receiver,
        uint256 amount
    ) internal virtual {
        // TODO: 这种error是需要加在ErrorList中还是直接用string类型错误表示出来
        require(sender != address(0), Error.PTOKENERC20_TRANSFER_FROM_ZERO_ADDRESS);
        require(receiver != address(0), Error.PTOKENERC20_TRANSFER_TO_ZERO_ADDRESS);

        _beforeTokenTransfer(sender, receiver, amount);

        (bool calStatusOne, uint256 newSenderBalance) = _balances[sender].trySub(amount);
        require(calStatusOne, Error.PTOKENERC20_TRANSFER_AMOUNT_EXCEEDS_BALANCE);
        _balances[sender] = newSenderBalance;

        (bool calStatusTwo, uint256 newReceiverBalance) = _balances[receiver].tryAdd(amount);
        require(calStatusTwo, Error.SAFEMATH_ADDITION_OVERFLOW);
        _balances[receiver] = newReceiverBalance;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), Error.PTOKENERC20_MINT_TO_ZERO_ADDRESS);

        _beforeTokenTransfer(address(0), account, amount);

        (bool calStatusOne, uint256 newSupply) = _totalSupply.tryAdd(amount);
        require(calStatusOne, Error.SAFEMATH_ADDITION_OVERFLOW);
        _totalSupply = newSupply;

        (bool calStatusTwo, uint256 newAccountBalance) = _balances[account].tryAdd(amount);
        require(calStatusTwo, Error.SAFEMATH_ADDITION_OVERFLOW);
        _balances[account] = newAccountBalance;

    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 oldTotalSupply = _totalSupply;
        // _totalSupply = oldTotalSupply.sub(amount);

        uint256 oldAccountBalance = _balances[account];
        // _balances[account] = oldAccountBalance.sub(amount, "ERC20: burn amount exceeds balance");

        // if (address(_getIncentivesController()) != address(0)) {
        // _getIncentivesController().handleAction(account, oldTotalSupply, oldAccountBalance);
        // }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
