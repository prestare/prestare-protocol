// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Author: Aave

import {SafeMath256} from "./../dependencies/SafeMath.sol";
import {WadRayMath} from "./../utils/WadRay.sol";

// TODO: math模块检查

library functions {
    using SafeMath256 for uint256;
    using WadRayMath for uint256;

    uint256 internal constant SECONDS_PER_YEAR = 365 days;

    /**
    * @dev Function to calculate the interest accumulated using a linear interest rate formula
    * @param rate The interest rate, in ray
    * @param lastUpdateTimestamp The timestamp of the last update of the interest
    * @return The interest rate linearly accumulated during the timeDelta, in ray
    **/
    function calculateLinearInterest(uint256 rate, uint40 lastUpdateTimestamp) internal view returns (uint256) {
    
    // TODO: whats the difference between a.trySub_(b) and trySub_(a, b)
    // TODO: check the warning: 是否会有人manipulate block time.
    (bool status, uint256 timeDifference) = SafeMath256.trySub(block.timestamp, lastUpdateTimestamp);

    // TODO: Add an error here
    require(status == true, "TO BE ADDED ERROR");

    // TODO: 这里是不是最好新写一个 mul 后 add的函数
    // TODO: timeDifference / SECONDS_PER_YEAR需不需要坚持
    uint256 deltaYear = timeDifference / SECONDS_PER_YEAR;
    // uint256 ray = SafeMath256.ray();
    uint256 ray;
    uint256 result = _mulThenAdd(rate, deltaYear, ray);

    return result;
    }

    /**
    * @dev Function to calculate the interest using a compounded interest rate formula
    * To avoid expensive exponentiation, the calculation is performed using a binomial approximation:
    *
    *  (1+x)^n = 1+n*x+[n/2*(n-1)]*x^2+[n/6*(n-1)*(n-2)*x^3...
    *
    * The approximation slightly underpays liquidity providers and undercharges borrowers, with the advantage of great gas cost reductions
    * The whitepaper contains reference to the approximation and a table showing the margin of error per different time periods
    *
    * @param rate The interest rate, in ray
    * @param lastUpdateTimestamp The timestamp of the last update of the interest
    * @return The interest rate compounded during the timeDelta, in ray
    **/
    function calculateCompoundedInterest(uint256 rate, uint40 lastUpdateTimestamp, uint256 currentTimestamp)  internal view returns (uint256) {

    (bool status, uint256 timeDiff) = SafeMath256.trySub(block.timestamp, lastUpdateTimestamp);

    // TODO: Add an error here
    require(status == true, "TO BE ADDED ERROR");

    // if (timeDiff == 0) {
    //     return SafeMath256.ray();
    // }

    uint256 diffMinusOne = timeDiff - 1;
    uint256 diffMinusTwo = timeDiff > 2 ? timeDiff - 2 : 0;
    uint256 ratePerSecond = rate / SECONDS_PER_YEAR;

    uint256 basePowerTwo = ratePerSecond.rayMul(ratePerSecond);
    uint256 basePowerThree = basePowerTwo.rayMul(ratePerSecond);

    uint256 secondTerm = timeDiff.mul(diffMinusOne).mul(basePowerTwo) / 2;
    uint256 thirdTerm = timeDiff.mul(diffMinusOne).mul(diffMinusTwo).mul(basePowerThree) / 6;

    return WadRayMath.ray().add(ratePerSecond.mul(timeDiff)).add(secondTerm).add(thirdTerm);
    }

    function _mulThenAdd(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
        (bool status1, uint256 tmp1) = SafeMath256.tryMul(a, b);
        require(status1 == true, "TO BE ADDED ERROR");

        (bool status2, uint256 result) = SafeMath256.tryAdd(tmp1, c);
        require(status2 == true, "TO BE ADDED ERROR");

        return result;
    }
}