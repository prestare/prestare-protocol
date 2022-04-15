// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;


library PrestareMarketStorage {

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

// Storage By Counter
library PrestareCounterStorage {

  // The reserve infomation which refer to the whitepaper
  struct CounterProfile {
    //stores the reserve configuration
    CounterConfigMapping configuration;
    //
    CounterData _assetData;

    //the liquidity index. Expressed in ray
    uint128 liquidityIndex;
    //borrow index. Expressed in ray
    uint128 borrowIndex;
    //the current supply rate. Expressed in ray
    uint128 currentLiquidityRate;
    //the current variable borrow rate. Expressed in ray
    uint128 currentBorrowRate;
    //the current stable borrow rate. Expressed in ray
    uint128 currentStableBorrowRate;
    uint40 lastUpdateTimestamp;
    //tokens address
    address pTokenAddress;
    // credit token address
    address crtAddress;
    //address of the interest rate strategy
    address interestRateStrategyAddress;
    //the id of the reserve. Represents the position in the list of the active reserves
    uint8 id;
  }

  struct CounterData {
    // 记录scb
    uint256 scaledBorrowedAmount;
  }

  struct CounterConfigMapping {
    //bit 0-15: LTV
    //bit 16-31: Liq. threshold
    //bit 32-47: Liq. bonus
    //bit 48-55: Decimals
    //bit 56: Reserve is active
    //bit 57: reserve is frozen
    //bit 58: borrowing is enabled
    //bit 59: stable rate borrowing enabled
    //bit 60-63: reserved
    //bit 64-79: reserve factor
    uint256 data;
  }

  struct UserConfigurationMapping {
    uint256 data;
  }

  enum InterestRateMode {NONE, STABLE, VARIABLE}
}
