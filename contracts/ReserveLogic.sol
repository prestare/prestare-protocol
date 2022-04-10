// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AssetsLib} from "./DataType/TypeLib.sol";
import {WadRayMath} from "./utils/WadRay.sol";


library ReserveLogic {

    using ReserveLogic for AssetsLib.AssetProfile;

    /**
   * @dev Emitted when the state of a reserve is updated
   * @param asset The address of the underlying asset of the reserve
   * @param liquidityRate The new liquidity rate
   * @param variableBorrowRate The new variable borrow rate
   * @param liquidityIndex The new liquidity index
   * @param variableBorrowIndex The new variable borrow index
   **/
    event ReserveDataUpdated(
        address indexed asset,
        uint256 liquidityRate,
        uint256 variableBorrowRate,
        uint256 liquidityIndex,
        uint256 variableBorrowIndex
    );
    
    /**
   * @dev Initializes a reserve
   * @param reserve The reserve object
   * @param pTokenAddress The address of the overlying atoken contract
   * @param interestRateStrategyAddress The address of the interest rate strategy contract
   **/
    function init(
        AssetsLib.AssetProfile storage reserve,
        address pTokenAddress,
        address interestRateStrategyAddress
    ) external {
        require(reserve.pTokenAddress == address(0), "Error");

        reserve.liquidityIndex = uint128(WadRayMath.ray());
        reserve.borrowIndex = uint128(WadRayMath.ray());
        reserve.pTokenAddress = pTokenAddress;
        reserve.interestRateStrategyAddress = interestRateStrategyAddress;
    }
}