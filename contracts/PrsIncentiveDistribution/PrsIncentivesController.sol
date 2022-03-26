// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.4;

import {EIP20Interface} from "../dependencies/EIP20Interface.sol";
import {SafeERC20} from "../dependencies/SafeERC20.sol";
import {IScaledBalanceToken} from "../interfaces/IScaledBalanceToken.sol";
import {DistributionTypes} from "../DataType/DistributionTypes.sol";
import {PrsDistributionManager} from "./PrsDistributionManager.sol";
import {IPrsIncentiveController} from "../interfaces/IPrsIncentiveController.sol";

abstract contract PrsIncentiveController is 
    IPrsIncentiveController,
    PrsDistributionManager
{
    using SafeERC20 for uint256;

    EIP20Interface public immutable override REWARD_TOKEN;
    address public immutable override DISTRIBUTION_MANAGER;
    
    mapping(address => uint256) internal _usersUnclaimedRewards;
    mapping(address => address) internal _authorizedClaimers;

    modifier onlyAuthorizedClaimers(address claimer, address user) {
        require(_authorizedClaimers[user] == claimer, "CLAIMER_UNAUTHORIZED");
        _;
    }

    modifier onlyDistributionManager() {
        require(msg.sender == DISTRIBUTION_MANAGER, "ONLY_DISTRIBUTION_MANAGER_ALLOWED");
        _;
    }

    constructor(EIP20Interface rewardToken, address distributionManager)
    {
        REWARD_TOKEN = address(rewardToken);
        DISTRIBUTION_MANAGER = distributionManager;
    }

    function configureAssets(address[] calldata assets, uint256[] calldata emissionPerSecond)
        external
        override
        onlyDistributionManager
    {
        require(assets.length == emissionPerSecond, "INVALID_CONFIGURATION");
        DistributionTypes.AssetConfigInput[] memory assetsConfig = 
            new DistributionTypes.AssetConfigInput[](assets.length);
        
        for (uint256 i = 0; i < assets.length; i++) {
            require(uint104(emissionPerSecond[i]) == emissionPerSeconde[i], "Index_overflow_emissionsPerSecond");
            assetsConfig[i].underlyingAsset = assets[i];
            assetsConfig[i].emissionPerSecond = uint104(emissionsPerSecond[i]);
            assetsConfig[i].totalStaked = IScaledBalanceToken(assets[i]).scaledTotalSupply();
        }
        _configureAssets(assetConfig);
    }

    function handleAction(
        address user,
        uint256 totalSupply,
        uint256 userBalance
    ) external override {
        // msg.sender is ptoken address
        // 计算此次ptoken变动后累计的收益
        uint256 accruedRewards = _updateUserAssetInternal(user, msg.sender, userBalance, totalSupply);
        if (accruedRewards != 0) {
            _usersUnclaimedRewards[user] = _usersUnclaimedRewards[user].add(accruedRewards);
            emit RewardsAccrued(user, accruedRewards);
        }
    }

    function getRewardsBalance(address[] calldata assets, address user)
        external
        view
        override
        returns (uint256)
    {
        // user已记录在案的未取收益
        uint256 unclaimedRewards = _usersUnclaimedRewards[user];
        DistributionTypes.UserStakeInput[] memory userState = 
            new DistributionTypes.UserStakeInput[](assets.length);
        
        for (uint256 i = 0; i < assets.length; i++) {
            userState[i].underlyingAsset = assets[i];
            (userState[i].stakedByUser, userState[i].totalStaked) = IScaledBalanceToken(assets[i])
                .getScaledUserBalanceAndSupply(user);
        }

        unclaimedRewards = unclaimedRewards.add(_getUnclaimedRewards(user, userState));
        return unclaimedRewards;
    }

    function claimRewards(
        address[] calldata assets,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(to != address(0), "INVALID_TO_ADDRESS");
        return _claimRewards(assets, amount, msg.sender, msg.sender, to);
    }

    function claimRewardsOnBehalf(
        address[] calldata assets,
        uint256 amount,
        address user,
        address to
    ) external override onlyAuthorizedClaimers(msg.sender, user) returns (uint256) {
        require(user != address(0), "INVALID_USER_ADDRESS");
        require(to != address(0), "INVALID_TO_ADDRESS");
        return _claimRewards(assets, amount, msg.sender, user, to);
    }

    function claimRewardsToSelf(address[] calldata assets, uint256 amount)
        external
        override
        returns (uint256)
    {
        return _claimRewards(assets, amount, msg.sender, msg.sender, msg.sender);
    }

    function setClaimer(address user, address caller) external override onlyDistributionManager {
        _authorizedClaimers[user] = caller;
        emit ClaimSet(user, caller);
    }

    function getClaimer(address user) external view override returns (address) {
        return _authorizedClaimers[user];
    }

    function getUserUnclaimedRewards(address _user) external view override returns (uint256) {
        return _usersUnclaimedRewards[_user];
    }

    function _claimRewards(
        address[] calldata assets,
        uint256 amount,
        address claimer,
        address user,
        address to
    ) internal returns (uint256) {
        if (amount == 0) {
            return 0;
        }

        uint256 unclaimedRewards = _usersUnclaimedRewards[user];

        if (amount > unclaimedRewards) {
            DistributionTypes.UserStakeInput[] memory userState =
                new DistributionTypes.UserStakeInput[](assets.length);
            for (uint256 i = 0; i < assets.length; i++) {
                userState[i].underlyingAsset = assets[i];
                (userState[i].stakedByUser, userState[i].totalStaked) = IScaledBalanceToken(assets[i])
                .getScaledUserBalanceAndSupply(user);
            }

            uint256 accruedRewards = _claimRewards(user, userState);
            if (accruedRewards != 0) {
                unclaimedRewards = unclaimedRewards.add(accruedRewards);
                emit RewardsAccrued(user, accruedRewards);
            }
        }

        if (unclaimedRewards == 0) {
        return 0;
        }

        uint256 amountToClaim = amount > unclaimedRewards ? unclaimedRewards : amount;
        _usersUnclaimedRewards[user] = unclaimedRewards - amountToClaim; // Safe due to the previous line

        _transferRewards(to, amountToClaim);
        emit RewardsClaimed(user, to, claimer, amountToClaim);

        return amountToClaim;
    }

}