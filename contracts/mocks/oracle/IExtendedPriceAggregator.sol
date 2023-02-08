// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IExtendedPriceAggregator {
  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);

  function getToken() external view returns (address);

  function getTokenType() external view returns (uint256);

  function getPlatformId() external view returns (uint256);

  function getSubTokens() external view returns (address[] memory);

  function latestAnswer() external view returns (int256);
}
