// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.6.12;

import { ERC20 } from "../openzeppelin/ERC20.sol";
import { ICRT } from '../ICRT.sol';

/**
 * @notice implementation of the Crt
 * @author Prestare
 */
contract CrtToken is ERC20, ICRT {
    string internal constant NAME = "Credit Token";
    string internal constant SYMBOL = "CRT";
    // uint8 internal constant DECIMALS = 18;

    uint256 public constant REVISION = 1;

    mapping(address => uint256) private _locked;
    
    /// @dev for support of permit()
    mapping(address => uint256) public _nonces;

    bytes32 public DOMAIN_SEPARATOR;
    bytes public constant EIP712_REVISION = bytes("1");
    bytes32 internal constant EIP712_DOMAIN = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    constructor() ERC20(NAME, SYMBOL) public {
        uint256 chainId;

        //solium-disable-next-line
        assembly {
            chainId := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712_DOMAIN,
            keccak256(bytes(NAME)),
            keccak256(EIP712_REVISION),
            chainId,
            address(this)
        ));
    }

        /**
    * @dev implements the permit function as for https://github.com/ethereum/EIPs/blob/8a34d644aacf0f9f8f00815307fd7dd5da07655f/EIPS/eip-2612.md
    * @param owner the owner of the funds
    * @param spender the spender
    * @param value the amount
    * @param deadline the deadline timestamp, type(uint256).max for no deadline
    * @param v signature param
    * @param s signature param
    * @param r signature param
    */

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(owner != address(0), "INVALID_OWNER");
        //solium-disable-next-line
        require(block.timestamp <= deadline, "INVALID_EXPIRATION");
        uint256 currentValidNonce = _nonces[owner];
        bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(PERMIT_TYPEHASH, owner, spender, value, currentValidNonce, deadline))
                    )
        );

        require(owner == ecrecover(digest, v, r, s), "INVALID_SIGNATURE");
        _nonces[owner] = currentValidNonce + 1;
        _approve(owner, spender, value);
    }

    /**
    * @dev returns the revision of the implementation contract
    */
    function getRevision() internal pure returns (uint256) {
        return REVISION;
    }

    function lockBalance(address account) external override view returns (uint256) {
        return _locked[account];
    }

    function lockCRT(address account, uint256 amount) external override returns (bool) {
        require(account != address(0), "CRT: lock zero adddress");
        
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "CRT: lock amount exceeds balance");
        _balances[account] = accountBalance.sub(amount);
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
        _locked[account] = _locked[account].add(amount);
        emit LockCRT(account, amount);
        return true;
    }

    function unlockCRT(address account, uint256 amount) external override returns (bool) {
        require(account != address(0), "CRT: unlock zero adddress");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "CRT: lock amount exceeds balance");
        _locked[account] = _locked[account].sub(amount);
        _balances[account] = accountBalance.add(amount);
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
        return true;

    }
}