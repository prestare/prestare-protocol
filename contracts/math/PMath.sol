// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.3;

import "../dependencies/openzeppelin/contracts/SafeMath.sol"; 
import "../utils/WadRay.sol";
// import {ErrorReporter} from "../utils/ErrorList.sol";

contract PMath {
    // /**
    // * for unsigned integers
    //  */
    // using SafeMath256 for uint256;
    // using WadRay for uint256;

    // uint256 mantissa = 1e18;

    // function addUint256(uint256 a, uint256 b) internal pure returns (ErrorReporter.MathError, uint256) {
    //     uint256 c;
    //     bool status;

    //     (status, c) = SafeMath256.tryAdd_(a, b);
    //     if (status == true) {
    //         return (ErrorReporter.MathError.NO_ERROR, c);
    //     } else {
    //         return (ErrorReporter.MathError.INTEGER_OVERFLOW, 0);
    //     }
    // }

    // /**
    // * noticed that b <= a;
    //  */
    // function subUint256(uint256 a, uint256 b) internal pure returns (ErrorReporter.MathError, uint256) {
    //     uint256 c;
    //     bool status;

    //     (status, c) = SafeMath256.trySub_(a, b);
    //     if (status == true) {
    //         return (ErrorReporter.MathError.NO_ERROR, c);
    //     } else {
    //         // This error should be underflow (SafeMath said it is an overflow error)
    //         return (ErrorReporter.MathError.INTEGER_UNDERFLOW, 0);
    //     }
    // }

    // function mulUint256(uint256 a, uint256 b) internal pure returns (ErrorReporter.MathError, uint256) {
    //     uint256 c;
    //     bool status;

    //     (status, c) = SafeMath256.tryMul_(a, b);
    //     if (status == true) {
    //         return (ErrorReporter.MathError.NO_ERROR, c);
    //     } else {
    //         return (ErrorReporter.MathError.INTEGER_OVERFLOW, 0);
    //     }
    // }

    // function divUint256(uint256 a, uint256 b) internal pure returns (ErrorReporter.MathError, uint256) {
    //     uint256 c;
    //     bool status;

    //     (status, c) = SafeMath256.tryDiv_(a, b);
    //     if (status == true) {
    //         return (ErrorReporter.MathError.NO_ERROR, c);
    //     } else {
    //         return (ErrorReporter.MathError.INTEGER_OVERFLOW, 0);
    //     }
    // }

}