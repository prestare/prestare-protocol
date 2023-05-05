// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IWETHGateway {
  function depositETH(
    address Counter,
    uint8 riskTier,
    address onBehalfOf,
    uint16 referralCode
  ) external payable;

  function withdrawETH(
    address Counter,
    uint8 riskTier,
    uint256 amount,
    address onBehalfOf
  ) external;

  function repayETH(
    address Counter,
    uint8 riskTier,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external payable;

  function borrowETH(
    address Counter,
    uint8 riskTier,
    uint256 amount,
    uint256 interesRateMode,
    uint16 referralCode,
    bool crtenable
  ) external;
}
