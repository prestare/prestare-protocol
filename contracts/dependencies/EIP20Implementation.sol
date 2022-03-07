// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import './Context.sol';
import './EIP20Interface.sol';
import '../math/PMath.sol';

/**
 * @title Prestare Implementation of the EIP20 interface
 * @notice The implmentation of ERC20 is a slight different to the original version
 * Under the OpenZeppelin guidelines, we use this way [supply Implmentation]https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226
 * to design our supply mechanism.
 * 
 * We add 'decreaseAllowance' and 'increaseAllowance' like Aave does.
 * TODO decide visiblity used by each function
 */
contract EIP20Implementation is Context, EIP20Interface, PMath {

    // using PMath for uint256;
    // Maybe we can add some address check like Aave does.

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @notice initialization function
     * @dev Now we use the constructor temporarily, 
     * but if we switch to a proxy contract later, 
     * we need to pay attention that the initialization function can not use the constructor.
     * @param name set the name of the token.
     * @param symbol set the symbol of the token.
     */
    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        // check the p_math file and use ray or wad
        _decimals = 18;
    }


    /** Implementation of EIP20Interface.sol */

    /**
     * @dev See detailed information in EIP20Interface
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See detailed information in EIP20Interface
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See detailed information in EIP20Interface
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See detailed information in EIP20Interface
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See detailed information in EIP20Interface
     */
    function balanceOf(address owner) public view override returns (uint256) {
        return _balances[owner];
    }        

    /**
     * @dev See detailed information in EIP20Interface
     */
    function transfer(address dst, uint256 amount) public override returns (bool) {
        
        // TODO If we add the actual msgsender like Aave does, or implement like compound 
        _transferInternal(_msgsender(), dst, amount);
        return true;
    }

    /**
     * @dev See detailed information in EIP20Interface
     */
    function transferFrom(address src, address dst, uint256 amount) public override returns (bool) {
        address spender = _msgSender();
        
        _spendAllowance(src, spender, amount);
        _transferInternal(src, dst, amount);
        
        return true;
    }

    /**
     * @dev See detailed information in EIP20Interface
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approveInternal(_msgsender(), spender, amount);
        return true;
    }

    /**
     * @dev See detailed information in EIP20Interface
     */
    function allowance(address owner, address spender) public view override returns (uint256 remaining) {
        return _allowances[owner][spender];
    }

    /**
     * @notice increases the allowance granted to spender by msg.sender
     * @param spender the spender that increase allowance by msg.sender
     * @param amount the amound of allowance increased.
     * @return a boolean value indicating whether the operation succeeded.
     */
    function increaseAllowance(address spender, uint256 amount) 
        public 
        virtual 
        returns (bool) 
    {
        (MathError matherr, uint256 allowanceNew) = _allowances[src][_msgSender()].addUint256(amount);
        require(matherr == NO_ERROR, "ERC 20: Math err");
        _approveInternal(_msgSender(), spender, allowanceNew);
        return true;
    }

    /**
     * @notice decrease the allowance granted to spender by msg.sender
     * @param spender the spender that increase allowance by msg.sender
     * @param amount the amound of allowance decreased.
     * @return a boolean value indicating whether the operation succeeded.
     */
    function decreaseAllowance(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        (MathError matherr, uint256 allowanceNew) = _allowances[src][_msgSender()].subUint256(amount);
        require(matherr == NO_ERROR, "ERC 20: Math err");
        _approveInternal(_msgSender(), spender, allowanceNew);
        return true;
    }

    /**
     * @notice Updates `owner` s allowance for `spender` based on spent `amount`.
     * @dev emit transfer even 
     * @param owner The address of the source account
     * @param spender The address of the spender account
     * @param amount The number of allowance
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = _allowances[owner][spender];
        if (currentAllowance != type(uint256).max) {
            MathError matherr;
            uint256 allowanceNew;
            (matherr, allowanceNew) = currentAllowance.subUint256(amount);
            require(matherr == NO_ERROR, "ERC20: insufficient allowance");
            _approveInternal(owner, spender, allowanceNew);
        }
    }

    /**
     * @notice Move tokens 'amount' form 'src' to 'dst'
     * @dev emit transfer even 
     * @param src The address of the source account
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     * @return a boolean value indicating whether the operation succeeded.
     */
    function _transferInternal(address src, address dst, uint256 amount) 
        internal 
        virtual {
        require(src != address(0), "ERC20: transfer from the zero address");
        require(dst != address(0), "ERC20: transfer to the zero address");
        
        MathError matherr;
        uint newbalance;
        (matherr, newbalance) = _balancesp[src].subUint256(amount);
        require(matherr == NO_ERROR, "ERC20: transfer amount exceeds balance");
        _balances[src] = newbalance;

        (matherr, newbalance) = _balances[recipient].addUint256(amount);
        // error rarely happen
        require(matherr == NO_ERROR, "ERC20: transfer amount overflow");
        _balances[dst] = newbalance;

        emit Transfer(src, dst, amount);
    }

    /**
     * @notice Create tokens 'amount' to 'dst'
     * @dev emit a transfer even 
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     * @return a boolean value indicating whether the operation succeeded.
     */
    function _mint(address dst, uint256 amount) internal virtual {
        require(dst != address(0), 'ERC20: mint to the zero address');

        MathError matherr;
        uint256 result;
        (matherr, result) = _totalSupply.addUint256(amount);
        require(matherr == NO_ERROR, "ERC20: transfer amount overflow");
        _totalSupply = result;

        (matherr, result) = _balances[account].addUint256(amount);
        require(matherr == NO_ERROR, "ERC20: transfer amount overflow");
        _balances[dst] = result;

        emit Transfer(address(0), account, amount);
    }

    /**
     * @notice burn tokens 'amount' from 'src'
     * @dev emit a transfer even 
     * @param src The address of the source account
     * @param amount The number of tokens to transfer
     * @return a boolean value indicating whether the operation succeeded.
     */
    function _burn(address src, uint256 amount) internal virtual {
        require(src != address(0), 'ERC20: burn from the zero address');

        MathError matherr;
        uint256 result;
        (matherr, result) = _balances[account].subUint256(amount);
        require(matherr == NO_ERROR, "ERC20: burn amount exceeds balance");
        _balances[src] = result;

        (matherr, result) = _totalSupply.subUint256(amount);
        // This error will never happen because total supply is absolutely larger the one balance amount.
        require(matherr == NO_ERROR, "ERC20: burn amount exceeds total supply");
        _totalSupply = result;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @notice Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     * @dev emit a approval even 
     * @param owner The address of the source account
     * @param spender The number of tokens to transfer
     * @param amount The number of allowance granted from owner
     * @return a boolean value indicating whether the operation succeeded.
     */
    function _approveInternal(address owner, address spender, uint256 amount) 
        internal  
    {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        require(_balances[owner] >= amount, "ERC20: approve amount exceed the balance of owners");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @notice set the new deciamals
     * @param decimals_ The address of the source account
     * @return a boolean value indicating whether the operation succeeded.
     * TODO actual value set to the decimals or wadray?
     */
    function _setupDecimals(uint8 decimals_) internal {
        if (decimals_ > 18) {
            _decimals = 27;
            _decimals = ray;
        }
        else {
            _decimals = decimals_;
        }
        
    }
}