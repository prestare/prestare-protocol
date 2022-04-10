// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "./PToken.sol";
// import "./PTokenInterfaces.sol";

abstract contract PFeature is PToken {

    // constructor(string memory name_, 
    //             string memory symbol_,
    //             address payable admin_) public 
    // {
    //     admin = msg.sender;

    //     initialize(name_, symbol_);

    //     admin = admin_;
    // }


    // // mint / borrow / redeem / repay /liquidate

    // function mint(uint mintAmount) external  returns (uint) 
    // {
    //     (uint err, ) = mintInternal(mintAmount);
    //     return err;
    // }

    // function borrow(uint borrowAmount) external returns (uint)
    // {
    //     return borrowInternal(borrowAmount);
    // }

    // function redeem(uint redeemTokens) external returns (uint) 
    // {
    //     return redeemInternal(redeemTokens);
    // }

    // function repayBorrow() external payable 
    // {
    //     (uint err,) = repayBorrowInternal(msg.value);
    //     return err;
    // }

    // function internalLiquidate() external payable 
    // {
        
    // }
    // // function liquidate(address borrower, PToken pTokenCollateral) external payable 
    // // {
    // //     (uint err,) = liquidateInternal(borrower, msg.value, pTokenCollateral);
    // //     requireNoError(err, "liquidateBorrow failed");
    // // }








    // function getCashPrior() override internal view returns (uint) 
    // {
    //     (MathError err, uint startingBalance) = subUInt(address(this).balance, msg.value);
    //     require(err == MathError.NO_ERROR);
    //     return startingBalance;
    // }
}