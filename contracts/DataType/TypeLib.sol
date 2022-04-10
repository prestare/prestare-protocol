// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

library AssetsLib {

  // The reserve infomation which refer to the whitepaper
  struct AssetProfile {
    //stores the reserve configuration
    AssetConfigMapping configuration;
    //
    AssetData _assetData;

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
    //tokens addresses
    address pTokenAddress;
    //address of the interest rate strategy
    address interestRateStrategyAddress;
    //the id of the reserve. Represents the position in the list of the active reserves
    uint8 id;
  }

  struct AssetData {
    // 记录scb
    uint256 scaledBorrowedAmount;
  }

  struct AssetConfigMapping {
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
