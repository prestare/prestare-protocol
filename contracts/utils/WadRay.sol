// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.3;

library WadRay {
    uint256 internal constant WAD = 1e18;
    uint256 internal constant RAY = 1e27;

    uint256 internal constant halfWAD = WAD / 2;
    uint256 internal constant halfRAY = RAY / 2;

    uint256 internal constant WAD_RAY_RATIO = 1e9;

    function ray() internal pure returns (uint256) {
        return RAY;
    }

    function wad() internal pure returns (uint256) {
        return WAD;
    }

    function halfRay() internal pure returns (uint256) {
        return halfRAY;
    }

    function halfWad() internal pure returns (uint256) {
        return halfWAD;
    }

}