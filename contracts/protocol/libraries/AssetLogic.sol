// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AssetStorage} from "../../DataType/AssetStorage.sol";
import {WadRayMath} from "../../utils/WadRay.sol";
/**
 * @title ReserveLogic library
 * @author Aave
 * @notice Implements the logic to update the reserves state
 */
library AssetLogic {
    using AssetLogic for AssetStorage.AssetProfile;
    /**
     * @dev Emitted when the state of a reserve is updated
     * @param asset The address of the underlying asset of the reserve
     * @param liquidityRate The new liquidity rate
     * @param variableBorrowRate The new variable borrow rate
     * @param ExchangeRate The new liquidity index
     * @param variableBorrowIndex The new variable borrow index
    **/
    event ReserveDataUpdated(
        address indexed asset,
        uint256 liquidityRate,
        uint256 variableBorrowRate,
        uint256 ExchangeRate,
        uint256 variableBorrowIndex
    );
    
    /**
     * @dev Initializes a reserve
     * @param reserve The reserve object
     * @param pTokenAddress The address of the overlying atoken contract
     * @param interestRateStrategyAddress The address of the interest rate strategy contract
    **/
    function init(
        AssetStorage.AssetProfile storage reserve,
        address pTokenAddress,
        address crtAddress,
        address interestRateStrategyAddress
    ) external {
        require(reserve.pTokenAddress == address(0), "Error");

        reserve.ExchangeRate = uint128(WadRayMath.ray());
        reserve.borrowIndex = uint128(WadRayMath.ray());
        reserve.pTokenAddress = pTokenAddress;
        reserve.crtAddress = crtAddress;
        reserve.interestRateStrategyAddress = interestRateStrategyAddress;
    }
}