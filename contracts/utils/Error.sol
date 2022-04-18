// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

library Error {
  string public constant PTOKEN_INVALID_MINT_AMOUNT = "1"; // PToken minted amount must be greater than 0

  //KoiosError:
  string public constant KOIOS_TRANSFER_NOT_ALLOWED = "10"; 

  //PTokenErc20Error: 
  string public constant PTOKENERC20_TRANSFER_FROM_ZERO_ADDRESS = "40";
  string public constant PTOKENERC20_TRANSFER_TO_ZERO_ADDRESS = "41";
  string public constant PTOKENERC20_MINT_TO_ZERO_ADDRESS = "42";
  string public constant PTOKENERC20_TRANSFER_AMOUNT_EXCEEDS_BALANCE = "43";

  // WadRayMath Error 
  string public constant RAY_DIVISION_BY_ZERO = "50";
  string public constant RAY_MULTIPLICATION_OVERFLOW = "51";

  // SafeMath Error
  string public constant SAFEMATH_ADDITION_OVERFLOW = "70";
  string public constant SAFEMATH_SUBTRACTION_OVERFLOW = "71";
}

