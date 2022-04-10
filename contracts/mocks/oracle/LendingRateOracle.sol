// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {LendingRateOracleInterface} from "../../Interfaces/LendingRateOracle.sol";
import {Ownable} from "../../dependencies/Ownable.sol";

contract LendingRateOracle is LendingRateOracleInterface, Ownable {
    mapping(address => uint256) borrowRates;
    mapping(address => uint256) liquidityRates;

    function getMarketBorrowRate(address _asset) external view override returns (uint256) {
        return borrowRates[_asset];
    }

    function setMarketBorrowRate(address _asset, uint256 _rate) external override onlyOwner {
        borrowRates[_asset] = _rate;
    }

    function getMarketLiquidityRate(address _asset) external view returns (uint256) {
        return liquidityRates[_asset];
    }

    function setMarketLiquidityRate(address _asset, uint256 _rate) external onlyOwner {
        liquidityRates[_asset] = _rate;
    }
}