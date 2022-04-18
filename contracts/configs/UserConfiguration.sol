// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {PrestareCounterStorage} from "../DataType/PrestareStorage.sol";

library UserConfiguration {

    /**
   * @dev Used to validate if a user has not been using any reserve
   * @param self The configuration object
   * @return True if the user has been borrowing any reserve, false otherwise
   **/
    function isEmpty(PrestareCounterStorage.UserConfigurationMapping memory self) internal pure returns (bool) {
    return self.data == 0;
    }

    /**
   * @dev  check if a user has been using the reserve for borrowing or as collateral
   * @param self The configuration object
   * @param reserveIndex The index of the reserve in the bitmap
   * @return True if the user has been using a reserve for borrowing or as collateral, false otherwise
   **/

    function isUsingAsCollateralOrBorrowing(
        PrestareCounterStorage.UserConfigurationMapping memory self,
        uint256 reserveIndex
    ) internal pure returns (bool) {
        require(reserveIndex < 128, "Error");
        return (self.data >> (reserveIndex * 2)) & 3 != 0;
    }
}