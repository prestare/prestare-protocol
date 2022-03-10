// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Author: Aave

import {SafeMath256} from "./../dependencies/SafeMath.sol";


library functions {
    using SafeMath256 for uint256;

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
    (bool status, uint256 timeDifference) = SafeMath256.trySub_(block.timestamp, lastUpdateTimestamp);

    // TODO: Add an error here
    require(status == true, "TO BE ADDED ERROR");

    // TODO: 这里是不是最好新写一个 mul 后 add的函数
    // TODO: timeDifference / SECONDS_PER_YEAR需不需要坚持
    uint256 deltaYear = timeDifference / SECONDS_PER_YEAR;
    uint256 ray = SafeMath256.ray();
    uint256 result = _mulThenAdd(rate, deltaYear, ray);

    return result;
    }
    
    function _mulThenAdd(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
        (bool status1, uint256 tmp1) = SafeMath256.tryMul_(a, b);
        require(status1 == true, "TO BE ADDED ERROR");

        (bool status2, uint256 result) = SafeMath256.tryAdd_(tmp1, c);
        require(status2 == true, "TO BE ADDED ERROR");

        return result;
    }
}