// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract MockAggregator {
  int256 private _latestAnswer;

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);

  constructor(int256 _initialAnswer) public {
    _latestAnswer = _initialAnswer;
    emit AnswerUpdated(_initialAnswer, 0, block.timestamp);
  }

  function latestAnswer() external view returns (int256) {
    return _latestAnswer;
  }

  function getTokenType() external view returns (uint256) {
    return 1;
  }

  // function getSubTokens() external view returns (address[] memory) {
  // TODO: implement mock for when multiple subtokens. Maybe we need to create diff mock contract
  // to call it from the migration for this case??
  // }
}
