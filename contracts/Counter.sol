// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import {AssetsStorage} from "./AssetsStorage.sol";
import {AssetsLib} from "./DataType/TypeLib.sol";
import {KoiosJudgement} from "./Koios.sol";
import {EIP20Interface} from "./dependencies/EIP20Interface.sol";
import {CounterInterface} from "./Interfaces/CounterInterface.sol";

contract Counter is AssetsStorage, PCounter {
    
    function deposit (address currency, uint256 amount, address provider) external {

        AssetsLib.AssetProfile storage assetData = _AssetData[currency];

        KoiosJudgement.DepositJudgement(currency, amount);

        address aTokenAddr = assetData.aTokenAddress;

        // TODO: 更新池子状态
        // 更新资产的状态变量
        assetData.updateState();
        // 更新资产的利率模型变量
        assetData.updateInterestRates(currency, aToken, amount, 0);

        EIP20Interface(currency).safeTransferFrom(msg.sender, aTokenAddr, amount);

        emit Deposit(currency, msg.sender, provider, amount);
    }

    function withdraw (address asscurrencyet, uint256 amount, address to) external {

        AssetsLib.AssetProfile storage assetData = _AssetData[currency];
        address aTokenAddr = assetData.aTokenAddress;
        uint256 userBalance = EIP20Interface(aTokenAddr).balanceOf(msg.sender); 
        uint256 withdrawAmount = amount;

        if (amount == type(uint256).max) {
            withdrawAmount = userBalance;
        }

        KoiosJudgement.WithdrawJudgement(currency, amount);

        // TODO: burn 掉相应数量的atoken

        emit Withdraw(currency, msg.sender, to, withdrawAmount);
    }

    /**
    @param crtAmount input value sent by user.
     */
    function borrow (address currency, uint256 amount, uint256 interestRate, address borrower, uint256 crtAmount) external {
        
        // TODO: Q: 两个选择：1. 告诉用户有多少crt，用户可以选择用多少crt，然后我们去计算能borrow的最大数量
        //                  2. 用户明确知道自己想要借多少钱，因此用户只需要输入borrow amount，我们去根据用户的crt数量去计算是否低于清算标准（安全标准）

        //TODO: 1. check user's total crt 
        uint256 crtBalance; 
        //      2. compare the input crtAmount and the total crt.
        require(crtAmount <= crtBalance, "TO_BE_ADD_TO_ERROR_LIST");
        //      3. if false, return error
        //      4. if yes, calculate the real borrow amount

        AssetsLib.AssetProfile storage assetData = _AssetData[currency];
    }

    function repay(address currency, uint256 amount, address debtor) external {

        AssetsLib.AssetProfile storage assetData = _AssetData[currency];

        // TODO 1. 获取用户total 债务；
        //      2. 调整债务；
        //      3. 更新用户信息
        //      4. 发射事件
    }


    /** 
    * @param liquidationMode choose the liquidation way. 0: external liquidation, 1: internal liquidation, 2: flash loan
    */
    function liquidationCall(address collateralCurrency, address debtAsset, address debtor, uint256 amount, uint8 liquidationMode) external {

        if (liquidationMode == 0) {
            externalLiquidation(collateralCurrency, debtAsset, debtor, amount);
        } 
        else if (liquidationMode == 1) {
            internalLiquidation(collateralCurrency, debtAsset, debtor, amount);
        }
        else if (liquidationMode == 2) {

        }
        else {
            // TODO: return an error
        }
    }

    function externalLiquidation(address collateralCurrency, address debtAsset, address debtor, uint256 amount) internal {

    }

    function internalLiquidation(address collateralCurrency, address debtAsset, address debtor, uint256 amount) internal {

    }




    struct CalculateBorrowParams {
        address currency;
        address borrower;
        address debtor;
        uint256 amount;
        uint256 interestRate;
        address pTokenAddress;
        bool borrowStatus;
    }

    function _borrowCalulation(CalculateBorrowParams memory vars) internal {
        AssetsLib.AssetProfile storage assetData = _AssetData[vars.currency];

        AssetsLib.UserConfigurationMapping storage userConfig = _userConfig[vars.debtor];

        // TODO: 获取预言机价格

        // TODO: 更新池子状态
        // 更新资产的状态变量
        assetData.updateState();

        // TODO: calculation

        // TODO: 发射事件
    }
}