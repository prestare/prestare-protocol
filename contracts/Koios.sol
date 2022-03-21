// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Koios: God of intellect and the axis of heaven around which the constellations revolved.

import {AssetsLib} from "./DataType/TypeLib.sol";
import {AssetsConfiguration} from "./AssetsConfiguration.sol";

library KoiosJudgement {
    
    /**
    * @dev Verify a deposit action
    * @param asset The asset the user is depositing
    * @param amount The amount to be deposited
    */
    function DepositJudgement(AssetsLib.AssetProfile storage asset, uint256 amount) external view {

        (bool isAlive, bool isStuned, ,) = asset.AssetsConfiguration.getFlags();

        //1. 数量不能为0
        //2. Asset pool should be alive and should not be frozen
        require(amount != 0, "ERROR");
        require(isAlive, "ERROR");
        require(!isStuned, "ERROR");
    }

    /**
    * @dev Verify a withdraw action
    * @param assetAddr The address of the reserve
    * @param amount The amount to be withdrawn
    * @param userBalance The balance of the user
    * @param assetData The asset state
    * @param userConfig The user configuration
    * @param assets The addresses of the reserves
    * @param assetNumber The number of reserves
    * @param oracle The price oracle
    */
    function WithdrawJudgement(
    address assetAddr, 
    uint256 amount, 
    uint256 userBalance,
    mapping(address => AssetsLib.AssetProfile) memory assetData,
    AssetsLib.UserConfigurationMapping storage userConfig,
    mapping(uint256 => address) storage assets,
    uint256 assetNumber,
    address oracle
    ) external view {

    // assetAddr 不是空
    // TODO: 添加修改错误类型
    require(amount != 0, "ERROR");
    require(amount <= userBalance, "ERROR");

    (bool isAlive, , , ) = assetData[assetAddr].configuration.getFlags();
    require(isAlive, "ERROR");

    // TODO: 检查针对用户是否可以赎回 比如赎回的话是否会低于清算值
    }

    function BorrowJudgement(
        AssetsLib.AssetProfile storage asset,
        address assetAddr, 
        uint256 borrowAmount,
        uint256 crtRequired,
        uint256 crtBalance,
        uint256 userBalance
    ) external view {
        (bool isAlive, bool isStuned, bool borrowingEnabled,) = asset.AssetsConfiguration.getFlags();
        
        require(isAlive, "ERROR");
        require(!isStuned, "ERROR");
        require(borrowAmount != 0, "ERROR");
        require(crtRequired <= crtBalance, "ERROR");
    }

    function RepayJudgement(
        AssetsLib.AssetProfile storage asset, 
        address assetAddr, 
        uint256 amount,
        address debtor
        ) external view {
            (bool isAlive, , ,) = asset.AssetsConfiguration.getFlags();
        
            require(isAlive, "ERROR");
            require(amount > 0, "ERROR");

        }
}
