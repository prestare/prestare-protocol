// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.43;

import {EIP20Interface} from "./dependencies/EIP20Interface.sol";
import {EIP20Implementation} from "./dependencies/EIP20Implementation.sol";
import {SafeERC20} from "./dependencies/SafeERC20.sol";
import {PCounter} from "./interface/PCounter.sol";
// 关于WadRayMath的用法
import "./dependencies/SafeMath.sol";
import {Errors} from "./utils/ErrorList.sol";
import {KoiosJudgement} from "./Koios.sol";

// TODO: is ptoken a abstract contract?????? No

// TODO DISCUSS aToken use VersionedInitializable Contract to help initizalize contract
// 
contract PToken is 
    EIP20Implementation("PTOKEN_IMPL", "PTOKEN", 0),
    IPToken 
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
     * @dev inherit from InitializablePtoken interface
     * @param counter The address of the counter where this pToken will be used
     * @param gasStation The address of the Aave treasury, receiving the fees on this pToken
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
    ) external override onlyAdmin
    {  
        // TODO 后续可能在继承的EIP20中通过函数的方式设置。
        _name = pTokenName;
        _symbol = pTokenSymbol;
        _decimals = pTokenDecimals;
        _crt_pool = crt;

        _counter = counter;
        _gasStation = gasStation;
        _underlyingAsset = underlyingAsset;

        require(msg.sender == admin, "only admin may initialize the contract");

        // Initialize the block number and borrow index
        // accrualBlockNumber = getBlockNumber();
        // borrowIndex = mantissa;

        // symbol = symbol_;

        // _notEntered = true;

    }

    /**
     * @notice Mints {amout} pToken to {user}
     * @dev only Counter can call this function
     * @param amount The amount of tokens getting minted
     * @param user The address receiving the minted tokens
     * @param index The new liquidity index of the reserve
     */
    function mint(
        uint256 amount,
        address user,
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

    /**
     * @dev Mints aTokens to the reserve treasury
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
     * @dev Burns aTokens from `user` and sends the equivalent amount of underlying to `receiverOfUnderlying`
     * - Only callable by the LendingPool, as extra state updates there need to be managed
     * @param user The owner of the aTokens, getting them burned
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
     * @dev Transfers pTokens in the event of a borrow being liquidated, in case the liquidators reclaims the aToken
     * - Only callable by the LendingPool
     * @param from The address getting liquidated, current owner of the aTokens
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
     * @param from The address getting liquidated, current owner of the aTokens
     * @param value The amount of tokens getting transferred
     */
    function transferOnCRT(
        address from
        uint256 value
    ) external override onlyCounter {
        address crt = _crt_pool;

        // TODO 如何转化传输
        _transfer(from, crt, value, false);

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
        return super.balanceOf(user).rayMul(_pool.getReserveNormalizedIncome(_underlyingAsset));
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
     * @dev calculates the total supply of the specific aToken
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
     * @param target The recipient of the aTokens
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






















    function getBlockNumber() internal view returns (uint) 
    {
        return block.number;
    }

    function transferTokens(address executor, address payer, address payee, uint amount) internal returns(uint)
    {   
        // Self-transfers are not allowed
        if (executor == payer)
        {
            return fail(Error.INPUT_ERROR, FailureInfo.SELF_TRANSFER_IS_NOT_ALLOWED);
        }
        
        //TODO: executor 是否有allowance？
        // Get the allowance, infinite for the account owner

        MathError mathError;
        uint payerTokensNew; 
        uint payeeTokensNew; 

        (mathError, payerTokensNew) = subUint256(accountTokens[payer], amount);
        if (mathError != MathError.NO_ERROR)
        {
            return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_NOT_ALLOWED);
        }

        (mathError, payeeTokensNew) = addUint256(accountTokens[payee], amount);
        if (mathError != MathError.NO_ERROR)
        {
            return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_NOT_ALLOWED);
        }

        // update accountTokens
        accountTokens[payer] = payerTokensNew;
        accountTokens[payee] = payeeTokensNew;

        emit Transfer(payer, payee, amount);

        return uint(Error.NO_ERROR);
    }

    function transfer(address payee, uint256 amount) external nonReentrant returns (bool) 
    {
        return transferTokens(msg.sender, msg.sender, payee, amount) == uint(Error.NO_ERROR);
    }

    function transferFrom(address payer, address payee, uint256 amount) external nonReentrant returns (bool) {
        return transferTokens(msg.sender, payer, payee, amount) == uint(Error.NO_ERROR);
    }

    function accrueInterest() public returns (uint) 
    {
        /* Remember the initial block number */
        uint currentBlockNumber = getBlockNumber();
        uint accrualBlockNumberPrior = accrualBlockNumber;

        /* Short-circuit accumulating 0 interest */
        if (accrualBlockNumberPrior == currentBlockNumber) 
        {
            return uint(Error.NO_ERROR);
        }

        /* Read the previous values out of storage */
        uint cashPrior = getCashPrior();
        uint borrowsPrior = totalBorrows;
        uint reservesPrior = totalReserves;
        uint borrowIndexPrior = borrowIndex;

        // TODO: interest rate model? 
        // TODO: hardcode
        uint borrowRateMantissa = 1;

        /* Calculate the number of blocks elapsed since the last accrual */
        (MathError mathErr, uint blockDelta) = subUint256(currentBlockNumber, accrualBlockNumberPrior);
        require(mathErr == MathError.NO_ERROR, "could not calculate block delta");

        exponential memory simpleInterestFactor;
        uint interestAccumulated;
        uint totalBorrowsNew;
        uint totalReservesNew;
        uint borrowIndexNew;

        // TODO: calculate interest model
        // TODO: update current market varaibles
        // TODO: new interest generated

        /* We emit an AccrueInterest event */
        emit AccrueInterest(cashPrior, interestAccumulated, borrowIndexNew, totalBorrowsNew);

        return uint(Error.NO_ERROR);
    }


    /*** mint ***/

    // struct MintLocalVars 
    // {
    //     Error err;
    //     MathError mathErr;
    //     uint exchangeRateMantissa;
    //     uint mintTokens;
    //     uint totalSupplyNew;
    //     uint accountTokensNew;
    //     uint actualMintAmount;
    // }

    // function mintInternal(uint mintAmount) internal nonReentrant returns (uint, uint) 
    // {
    //     uint error = accrueInterest();

    //     // TODO: update error list 

    //     // mintFresh emits the actual Mint event if successful and logs on errors, so we don't need to
    //     return mintFresh(msg.sender, mintAmount);
    // }

    // function mintFresh(address minter, uint mintAmount) internal returns (uint, uint) 
    // {

    //     MintLocalVars memory vars;

    //     // TODO: calculate the exchange rate  
    //     // TODO: calculate the real amount minted
    //     // TODO: calculate the real ptokens minted
    //     // TODO: update the market variables (total pTokens / user's pTokens)

    //     /* We emit a Mint event, and a Transfer event */
    //     emit Mint(minter, vars.actualMintAmount, vars.mintTokens);
    //     emit Transfer(address(this), minter, vars.mintTokens);

    //     return (uint(Error.NO_ERROR), vars.actualMintAmount);
    // }


    /*** borrow ***/

    // function borrowInternal(uint borrowAmount) internal nonReentrant returns (uint) 
    // {
    //     uint error = accrueInterest();

    //     return borrowFresh(payable(msg.sender), borrowAmount);
    // }

    // struct BorrowLocalVars 
    // {
    //     MathError mathErr;
    //     uint accountBorrows;
    //     uint accountBorrowsNew;
    //     uint totalBorrowsNew;
    // }

    // function borrowFresh(address payable borrower, uint borrowAmount) internal returns (uint) 
    // {
    //     BorrowLocalVars memory vars;

    //     // TODO: check the credit tokens! 
    //     // TODO: calculate account borrows and total market borrows
    //     // TODO: update account borrows and market variables

    //     emit Borrow(borrower, borrowAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);

    //     return uint(Error.NO_ERROR);
    // }

    // function redeemInternal(uint redeemTokens) internal nonReentrant returns (uint) 
    // {
    //     uint error = accrueInterest();
    //     // redeemFresh emits redeem-specific logs on errors, so we don't need to
    //     return redeemFresh(payable(msg.sender), redeemTokens, 0);
    // }

    // struct RedeemLocalVars 
    // {
    //     Error err;
    //     MathError mathErr;
    //     uint exchangeRateMantissa;
    //     uint redeemTokens;
    //     uint redeemAmount;
    //     uint totalSupplyNew;
    //     uint accountTokensNew;
    // }

    // function redeemFresh(address payable redeemer, uint redeemTokensIn, uint redeemAmountIn) internal returns (uint) 
    // {
        
    //     // TODO: 1 p-eth can redeem ? eth. 
    //     // TODO: calculate the amount redeemed.
    //     // TODO: update account supply and total supply

    //     RedeemLocalVars memory vars;

    //     /* We emit a Transfer event, and a Redeem event */
    //     emit Transfer(redeemer, address(this), vars.redeemTokens);
    //     emit Redeem(redeemer, vars.redeemAmount, vars.redeemTokens);

    //     return uint(Error.NO_ERROR);
    // }

    // function repayBorrowInternal(uint repayAmount) internal nonReentrant returns (uint, uint) 
    // {
    //     uint error = accrueInterest();
    //     return repayBorrowFresh(msg.sender, msg.sender, repayAmount);
    // }
    
    // struct RepayBorrowLocalVars 
    // {
    //     Error err;
    //     MathError mathErr;
    //     uint repayAmount;
    //     uint borrowerIndex;
    //     uint accountBorrows;
    //     uint accountBorrowsNew;
    //     uint totalBorrowsNew;
    //     uint actualRepayAmount;
    // }

    // function repayBorrowFresh(address payer, address borrower, uint repayAmount) internal returns (uint, uint) 
    // {

    //     RepayBorrowLocalVars memory vars;

    //     /* We remember the original borrowerIndex for verification purposes */
    //     vars.borrowerIndex = accountBorrows[borrower].interestIndex;

    //     // TODO: fetch the account borrows
    //     // TODO: check if the repay amount is legal
    //     // TODO: calculate and update the account borrow and total market variables

    //     emit RepayBorrow(payer, borrower, vars.actualRepayAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);

    //     return (uint(Error.NO_ERROR), vars.actualRepayAmount);
    // }

    // function internalLiquidateManager() internal returns (uint)
    // {
        
    // }

    /*** liquidation ***/

    // function liquidateInternal(address borrower, uint repayAmount, PToken pTokenCollateral) internal nonReentrant returns (uint, uint) 
    // {
    //     uint error = accrueInterest();

    //     error = pTokenCollateral.accrueInterest();

    //     // liquidateBorrowFresh emits borrow-specific logs on errors, so we don't need to
    //     return liquidateFresh(msg.sender, borrower, repayAmount, pTokenCollateral);
    // }

    // function liquidateFresh(address liquidator, address borrower, uint repayAmount, PTokenStorage pTokenCollateral) internal returns (uint, uint) 
    // {
    //     return uint(0);
    // }


    function getCashPrior() virtual internal view returns (uint);


    /*** Reentrancy Guard ***/

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     */
    modifier nonReentrant() {
        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true; // get a gas-refund post-Istanbul
    }
}