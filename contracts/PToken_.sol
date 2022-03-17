// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "./PTokenInterfaces.sol";
import "./math/PMath.sol";
import "./dependencies/EIP20Implementation.sol";
import "./dependencies/SafeMath.sol";
import {Errors} from "./utils/ErrorList.sol";


// TODO: is ptoken a abstract contract??????

abstract contract PToken is PTokenStorage, PMath, ErrorReporter, EIP20Implementation {

    using SafeMath for uint256;
    
    function initialize(string memory name_,
                        string memory symbol_) public
    {
        require(msg.sender == admin, "only admin may initialize the contract");

        require(accrualBlockNumber == 0 && borrowIndex == 9, "1 currency market only be initalized once");

        // Initialize the block number and borrow index
        accrualBlockNumber = getBlockNumber();
        borrowIndex = mantissa;

        symbol = symbol_;

        _notEntered = true;
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

    function mint(address user, uint256 amount, uint256 index) external override onlyLendingPool returns(bool) {
        uint256 lastBalance = super.balanceOf(user);
        // check this math function carefully
        uint256 amountStandardized = amount.tryRayDiv_(index);

        require(amountStandardized != 0, Errors.TO_BE_DIFNED_2);
        _mint(user, amountStandardized);

        emit Transfer(address(0), user, amount);
        emit Mint(user, amount, index);

        return lastBalance == 0;
    }

    /*** borrow ***/

    function borrowInternal(uint borrowAmount) internal nonReentrant returns (uint) 
    {
        uint error = accrueInterest();

        return borrowFresh(payable(msg.sender), borrowAmount);
    }

    struct BorrowLocalVars 
    {
        MathError mathErr;
        uint accountBorrows;
        uint accountBorrowsNew;
        uint totalBorrowsNew;
    }

    function borrowFresh(address payable borrower, uint borrowAmount) internal returns (uint) 
    {
        BorrowLocalVars memory vars;

        // TODO: check the credit tokens! 
        // TODO: calculate account borrows and total market borrows
        // TODO: update account borrows and market variables

        emit Borrow(borrower, borrowAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);

        return uint(Error.NO_ERROR);
    }

    function redeemInternal(uint redeemTokens) internal nonReentrant returns (uint) 
    {
        uint error = accrueInterest();
        // redeemFresh emits redeem-specific logs on errors, so we don't need to
        return redeemFresh(payable(msg.sender), redeemTokens, 0);
    }

    struct RedeemLocalVars 
    {
        Error err;
        MathError mathErr;
        uint exchangeRateMantissa;
        uint redeemTokens;
        uint redeemAmount;
        uint totalSupplyNew;
        uint accountTokensNew;
    }

    function redeemFresh(address payable redeemer, uint redeemTokensIn, uint redeemAmountIn) internal returns (uint) 
    {
        
        // TODO: 1 p-eth can redeem ? eth. 
        // TODO: calculate the amount redeemed.
        // TODO: update account supply and total supply

        RedeemLocalVars memory vars;

        /* We emit a Transfer event, and a Redeem event */
        emit Transfer(redeemer, address(this), vars.redeemTokens);
        emit Redeem(redeemer, vars.redeemAmount, vars.redeemTokens);

        return uint(Error.NO_ERROR);
    }

    function repayBorrowInternal(uint repayAmount) internal nonReentrant returns (uint, uint) 
    {
        uint error = accrueInterest();
        return repayBorrowFresh(msg.sender, msg.sender, repayAmount);
    }
    
    struct RepayBorrowLocalVars 
    {
        Error err;
        MathError mathErr;
        uint repayAmount;
        uint borrowerIndex;
        uint accountBorrows;
        uint accountBorrowsNew;
        uint totalBorrowsNew;
        uint actualRepayAmount;
    }

    function repayBorrowFresh(address payer, address borrower, uint repayAmount) internal returns (uint, uint) 
    {

        RepayBorrowLocalVars memory vars;

        /* We remember the original borrowerIndex for verification purposes */
        vars.borrowerIndex = accountBorrows[borrower].interestIndex;

        // TODO: fetch the account borrows
        // TODO: check if the repay amount is legal
        // TODO: calculate and update the account borrow and total market variables

        emit RepayBorrow(payer, borrower, vars.actualRepayAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);

        return (uint(Error.NO_ERROR), vars.actualRepayAmount);
    }

    function internalLiquidateManager() internal returns (uint)
    {
        
    }

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


    modifier onlyLendingPool {
    require(_msgSender() == address(_pool), Errors.TOBEDEFINED_1);
    _;
    }



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