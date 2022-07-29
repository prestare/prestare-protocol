// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;


library MarketStorage {

  struct CreditTokenStorage {
    uint id;
    address crtAddress;
  }

  struct UserBalanceByAsset {
    // principal amount borrowed by the user
    uint256 principal;
    // principal + interest accured by the user
    uint256 totalBorrows;
  }

  struct UserBalanceSummary {
    // total borrow balance in ETH
    uint256 totalBorrowsInETH;
  }

  // struct MarketStorage {
  //   mapping(address => BorrowSnapshot) accountBorrowSnapshot; // Mapping of account addresses to outstanding borrow balances
  // }
}