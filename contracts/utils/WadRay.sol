// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.3;

// TODO: check 0.8后版本的wadray 计算是否正确

/**
 * @title WadRayMath library
 * @author Aave
 * @dev Provides mul and div function for wads (decimal numbers with 18 digits precision) and rays (decimals with 27 digits)
 **/

library WadRayMath {
    uint256 internal constant WAD = 1e18;
    uint256 internal constant halfWAD = WAD / 2;

    uint256 internal constant RAY = 1e27;
    uint256 internal constant halfRAY = RAY / 2;

    uint256 internal constant WAD_RAY_RATIO = 1e9;

    /**
    * @return One ray, 1e27
    **/
    function ray() internal pure returns (uint256) {
    return RAY;
    }

    /**
    * @return One wad, 1e18
    **/

    function wad() internal pure returns (uint256) {
    return WAD;
    }

    /**
    * @return Half ray, 1e27/2
    **/
    function halfRay() internal pure returns (uint256) {
    return halfRAY;
    }

    /**
    * @return Half ray, 1e18/2
    **/
    function halfWad() internal pure returns (uint256) {
    return halfWAD;
    }

    /**
    * @dev Multiplies two wad, rounding half up to the nearest wad
    * @param a Wad
    * @param b Wad
    * @return The result of a*b, in wad
    **/
    function wadMul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0 || b == 0) {
        return 0;
    }

    // TODO: Error
    require(a <= (type(uint256).max - halfWAD) / b, "ERROR");

    return (a * b + halfWAD) / WAD;
    }

    /**
    * @dev Divides two wad, rounding half up to the nearest wad
    * @param a Wad
    * @param b Wad
    * @return The result of a/b, in wad
    **/

    // TODO: Error
    function wadDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    
    // TODO: Error
    require(b != 0, "ERROR");
    uint256 halfB = b / 2;

    // TODO: Error
    require(a <= (type(uint256).max - halfB) / WAD, "ERROR");

    return (a * WAD + halfB) / b;
    }

    /**
    * @dev Multiplies two ray, rounding half up to the nearest ray
    * @param a Ray
    * @param b Ray
    * @return The result of a*b, in ray
    **/
    function rayMul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0 || b == 0) {
        return 0;
    }

    // TODO: Error
    require(a <= (type(uint256).max - halfRAY) / b, "ERROR");

    return (a * b + halfRAY) / RAY;
    }

    /**
    * @dev Divides two ray, rounding half up to the nearest ray
    * @param a Ray
    * @param b Ray
    * @return The result of a/b, in ray
    **/
    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    // TODO: Error
    require(b != 0, "ERROR");
    uint256 halfB = b / 2;

    // TODO: Error
    require(a <= (type(uint256).max - halfB) / RAY, "ERROR");

    return (a * RAY + halfB) / b;
    }

    /**
    * @dev Casts ray down to wad
    * @param a Ray
    * @return a casted to wad, rounded half up to the nearest wad
    **/
    function rayToWad(uint256 a) internal pure returns (uint256) {
    uint256 halfRatio = WAD_RAY_RATIO / 2;
    uint256 result = halfRatio + a;

    // TODO: Error
    require(result >= halfRatio, "ERROR");

    return result / WAD_RAY_RATIO;
    }

    /**
    * @dev Converts wad up to ray
    * @param a Wad
    * @return a converted in ray
    **/
    function wadToRay(uint256 a) internal pure returns (uint256) {
    uint256 result = a * WAD_RAY_RATIO;

    // TODO: Error
    require(result / WAD_RAY_RATIO == a, "ERROR");
    return result;
    }
}
