// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import {EIP20Interface} from "./dependencies/EIP20Interface.sol";
import {EIP20Implementation} from "./dependencies/EIP20Implementation.sol";
import {SafeERC20} from "./dependencies/SafeERC20.sol";
import {PCounter} from "./interface/PCounter.sol";
import {PTokenInterface} from "./interfaces/PTokenInterface.sol";
// 关于WadRayMath的用法
import "./dependencies/SafeMath.sol";
import {Errors} from "./utils/ErrorList.sol";
import {KoiosJudgement} from "./Koios.sol";

// TODO: is ptoken a abstract contract?????? No

// TODO DISCUSS aToken use VersionedInitializable Contract to help initizalize contract
// 
contract PToken is 
    EIP20Implementation("PTOKEN_IMPL", "PTOKEN", 0),
    PTokenInterface 
{
    // TODO use wadray directly?
    using SafeMath for uint256;
    
    PCounter internal _counter;
    address internal _gasStation;
    address internal _underlyingAsset;
    // TODO Aave add incentivesController to this contract

    address internal _crt_pool;

    /**
     * @notice Administrator for this contract
     */
    address internal _admin;

    // 为了permit函数所设置的
    bytes32 public DOMAIN_SEPARATOR;
    
    bytes public constant EIP712_REVISION = bytes('1');
    bytes32 internal constant EIP712_DOMAIN =
        keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)');
    
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256('Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)');
    
    /// @dev owner => next valid nonce to submit with permit()
    mapping(address => uint256) public _nonces;

    modifier onlyCounter {
        require(msg.sender == address(_counter), Errors.message);
        _;
    }

    modifier onlyAdmin {
        require(msg.sender == _admin, Errors.message);
        _;
    }

    /**
     * @notice Initializes the PToken 
     * @param counter The address of the counter where this pToken will be used
     * @param gasStation The address of the Prestare gasStation, receiving the fees on this pToken
     * @param underlyingAsset The address of the underlying asset of this pToken (E.g. WETH for aWETH)
     * incentivesController The smart contract managing potential incentives distribution
     * @param pTokenDecimals The decimals of the pToken, same as the underlying asset's
     * @param pTokenName The name of the pToken
     * @param pTokenSymbol The symbol of the pToken
     */
    // maybe we should add a initializer modify to check the status before call this function
    function initialize(
        PCOUNTER counter,
        address gasStation,
        address underlyingAsset,
        address crt
        uint8 pTokenDecimals,
        string callData pTokenName,
        string callData pTokenSymbol,
        bytes calldata params
    ) external override
    {  
        // TODO 后续可能在继承的EIP20中通过函数的方式设置。
        _name = pTokenName;
        _symbol = pTokenSymbol;
        _decimals = pTokenDecimals;
        _crt_pool = crt;

        _counter = counter;
        _gasStation = gasStation;
        _underlyingAsset = underlyingAsset;
        // 只允许admin改变，暂定
        require(msg.sender == admin, "only admin may initialize the contract");
        
        // 获取链id，用来区分不同 EVM 链的一个标识
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
            EIP712_DOMAIN,
            keccak256(bytes(pTokenName)),
            keccak256(EIP712_REVISION),
            chainId,
            address(this)
        )
        );
        // Initialize the block number and borrow index
        // accrualBlockNumber = getBlockNumber();
        // borrowIndex = mantissa;

        // symbol = symbol_;

        // _notEntered = true;
        emit Initialized(
            address(counter),
            gasStation,
            underlyingAsset,
            crt,
            pTokenDecimals,
            pTokenName,
            pTokenSymbol,
            params
        );
    }


    /**
     * @notice Mints {amout} pToken to {user}
     * @dev only Counter can call this function
     * @param amount The amount of tokens getting minted
     * @param user The address receiving the minted tokens
     * @param newindex The new liquidity index of the reserve
     */
    function mint(
        address user,
        uint256 amount,
        uint256 newindex
    ) external override onlyCounter returns (bool) {
        uint256 lastBalance = super.balanceOf(user);

        // nomorlized
        uint256 amountScaled = amount.tryRayDiv_(newindex);
        require(amountScaled != 0, Errors);

        // actual mint
        _mint(user, amountScaled);

        emit Transfer(address(0), user, amount);
        emit Mint(user, amount, cumulativeindex);

        return lastBalance == 0;
    }

    // TODO 后续该函数实际由ReserveLogic重写，在Aave的其他部分并未使用
    /**
     * @dev Mints pTokens to the reserve treasury
     * - Only callable by the Counter
     * @param amount The amount of tokens getting minted
     * @param index The new liquidity index of the reserve
     */
    function mintTogasStation(uint256 amount, uint256 index) external override onlyCounter {
        if (amount == 0) {
            return ;
        }
        address gasStation = _gasStation;
        _mint(gasStation, amount.rayDiv(index));

        emit Transfer(address(0), treasury, amount);
        emit Mint(treasury, amount, index);
    }

    /**
     * @dev Burns pTokens from `user` and sends the equivalent amount of underlying to `receiverOfUnderlying`
     * - Only callable by the LendingPool, as extra state updates there need to be managed
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
    ) external override onlyCounter {
        uint256 amountScaled = amount.Div(newIndex);
        require(amountScaled != 0, Errors);
        _burn(user, amountScaled);

        EIP20Interface(_underlyingAsset).safeTransfer(receiverOfUnderlying, amount);

        emit Transfer(user, address(0), amount);
        emit Burn(user, receiverOfUnderlying, amount, index);
    }

    /**
     * @dev Transfers pTokens in the event of a borrow being liquidated, in case the liquidators reclaims the pToken
     * - Only callable by the LendingPool
     * @param from The address getting liquidated, current owner of the pTokens
     * @param to The recipient
     * @param value The amount of tokens getting transferred
     */
    function transferOnLiquidation(
        address from,
        address to,
        uint256 value
    ) external override onlyCounter {
        // Being a normal transfer, the Transfer() and BalanceTransfer() are emitted
        // so no need to emit a specific event here
        _transfer(from, to, value, false);

        emit Transfer(from, to, value);
    }

    /**
     * @notice Transfer pToken to CRT pool
     * Question 通过CRT清算的方法，如何将财产转化为稳定币存储到CRT中
     * @param from The address getting liquidated, current owner of the pTokens
     * @param value The amount of tokens getting transferred
     */
    function transferOnCRT(
        address from
        uint256 value
    ) external override onlyCounter {
        address crt = _crt_pool;

        // TODO 如何转化传输
        CRTInterface(crt)._transfer(from, crt, value, false);

        emit Transfer(from, to, value);
    }

    /**
     * @dev Calculates the balance of the user: principal balance + interest generated by the principal
     * @param user The user whose balance is calculated
     * @return The balance of the user
     */
    function balanceOf(address user)
        public
        view
        override(EIP20Interface)
        returns (uint256)
    {
        return super.balanceOf(user).rayMul(_counter.getReserveNormalizedIncome(_underlyingAsset));
    }

    /**
     * @dev Returns the scaled balance of the user. The scaled balance is the sum of all the
     * updated stored balance divided by the reserve's liquidity index at the moment of the update
     * @param user The user whose balance is calculated
     * @return The scaled balance of the user
     */
    function scaledBalanceOf(address user) external view override returns (uint256) {
        return super.balanceOf(user);
    }

    /**
     * @dev Returns the scaled balance of the user and the scaled total supply.
     * @param user The address of the user
     * @return The scaled balance of the user
     * @return The scaled balance and the scaled total supply
     */
    function getScaledUserBalanceAndSupply(address user)
        external
        view
        override
        returns (uint256, uint256)
    {
        return (super.balanceOf(user), super.totalSupply());
    }

    /**
     * @dev calculates the total supply of the specific pToken
     * since the balance of every single user increases over time, the total supply
     * does that too.
     * @return the current total supply
     */
    function totalSupply() public view override(IncentivizedERC20, EIPInterface) returns (uint256) {
        uint256 currentSupplyScaled = super.totalSupply();
        if (currentSupplyScaled == 0) {
        return 0;
        }
        return currentSupplyScaled.rayMul(_pool.getReserveNormalizedIncome(_underlyingAsset));
    }

    /**
     * @dev Returns the scaled total supply of the variable debt token. Represents sum(debt/index)
     * @return the scaled total supply
     */
    function scaledTotalSupply() public view virtual override returns (uint256) {
        return super.totalSupply();
    }

    /**
     * @return the address of the gasStation(like treasury in Aave)
     */
    function getGasStation() public view returns (address) {
        return _gasStation;
    }

    /**
     * @return the address of the underlying asset of this pToken (like DAI for pDAI)
     */
    function getUnderlyingAssetAddress() public view returns (address) {
        return _underlyingAsset;
    }

    /**
     * @return the address of the underlying asset of this pToken (like DAI for pDAI)
     */
    function getCounter() public view returns (PCounter) {
        return _counter;
    }

    // TODO Add incentivesController like Aave do?
    /**
     * @dev For internal usage in the logic of the parent contract IncentivizedERC20
     */
    function _getIncentivesController() internal view override returns (IAaveIncentivesController) {
        return _incentivesController;
    }

    /**
     * @dev Returns the address of the incentives controller contract
     */
    function getIncentivesController() external view override returns (IAaveIncentivesController) {
        return _getIncentivesController();
    }

    /**
     * @dev Transfers the underlying asset to `target`. Used by the LendingPool to transfer
     * assets in borrow(), withdraw() and flashLoan()
     * @param target The recipient of the pTokens
     * @param amount The amount getting transferred
     * @return The amount transferred
     */
    function transferUnderlyingTo(address target, uint256 amount)
        external
        override
        onlyCounter
        returns (uint256)
    {
        EIPInterface(_underlyingAsset).safeTransfer(target, amount);
        return amount;
    }


    /**
     * @dev implements the permit function as for
     * https://github.com/ethereum/EIPs/blob/8a34d644aacf0f9f8f00815307fd7dd5da07655f/EIPS/eip-2612.md
     * @param owner The owner of the funds
     * @param spender The spender
     * @param value The amount
     * @param deadline The deadline timestamp, type(uint256).max for max deadline
     * @param v Signature param
     * @param s Signature param
     * @param r Signature param
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
        require(owner != address(0), 'INVALID_OWNER');
        //solium-disable-next-line
        require(block.timestamp <= deadline, 'INVALID_EXPIRATION');
        uint256 currentValidNonce = _nonces[owner];
        bytes32 digest =
        keccak256(
            abi.encodePacked(
            '\x19\x01',
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, currentValidNonce, deadline))
            )
        );
        require(owner == ecrecover(digest, v, r, s), 'INVALID_SIGNATURE');
        _nonces[owner] = currentValidNonce.add(1);
        _approve(owner, spender, value);
    }
    /**
     * @notice Transfers the pTokens between two users. Validates the transfer
     * (ie checks for valid factor after the transfer) if required
     * @dev such as when borrowe want to transfer token， we need to validates this transcation
     * @param from The source address
     * @param to The destination address
     * @param amount The amount getting transferred
     * @param validate `true` if the transfer needs to be validated
     */
    function _transfer(
        address from,
        address to,
        uint256 amount,
        bool validate
    ) internal {
        address underlyingAsset = _underlyingAsset;
        PCounter counter = _counter;

        uint256 index = counter.getReserveNormalizedIncome(underlyingAsset);

        uint256 fromBalanceBefore = super.balanceOf(from).rayMul(index);
        uint256 toBalanceBefore = super.balanceOf(to).rayMul(index);

        super._transfer(from, to, amount.rayDiv(index));

        if (validate) {
            counter.finalizeTransfer(underlyingAsset, from, to, amount, fromBalanceBefore, toBalanceBefore);
        }

        emit BalanceTransfer(from, to, amount, index);
    }

    /**
    * @dev Overrides the parent _transfer to force validated transfer() and transferFrom()
    * @param from The source address
    * @param to The destination address
    * @param amount The amount getting transferred
    **/
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        _transfer(from, to, amount, true);
    }
}