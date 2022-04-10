// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import {AssetsStorage} from "../../AssetsStorage.sol";
import {Address} from "../../dependencies/Address.sol";
import {AssetsLib} from "../..//DataType/TypeLib.sol";
import {KoiosJudgement} from "../../Koios.sol";
import {EIP20Interface} from "../../dependencies/EIP20Interface.sol";
import {CounterInterface} from "../../Interfaces/CounterInterface.sol";
import {CounterAddressProvider} from "../configuration/CounterAddressProvider.sol";
import {ReserveLogic} from "../../ReserveLogic.sol";
import {WadRayMath} from "../../utils/WadRay.sol";


import "hardhat/console.sol";

contract Counter is AssetsStorage, CounterInterface {
    using ReserveLogic for AssetsLib.AssetProfile;

    function initialize(CounterAddressProvider provider) public {
        _addressProvider = provider;
        _maxNumberOfReserves = 128;
    }
    
    // TODO： 设置函数调用权限或者状态
    function deposit (address assetAddr, uint256 amount, address provider) external override whenNotPaused {

        AssetsLib.AssetProfile storage assetData = _assetData[assetAddr];

        // KoiosJudgement.DepositJudgement(assetAddr, amount);

        address pTokenAddr = assetData.pTokenAddress;

        // TODO: 更新池子状态
        // 更新资产的状态变量
        // assetData.updateState();
        // 更新资产的利率模型变量
        // assetData.updateInterestRates(assetAddr, pTokenAddr, amount, 0);

        // msg.sender的权限问题
        // msg.sender的封装
        // EIP20Interface(assetAddr).safeTransferFrom(msg.sender, pTokenAddr, amount);

        emit Deposit(assetAddr, msg.sender, provider, amount);
    }

    function withdraw (address assetAddr, uint256 amount, address to) external {

        AssetsLib.AssetProfile storage assetData = _assetData[assetAddr];
        address pTokenAddr = assetData.pTokenAddress;
        // interface 要改
        uint256 userBalance = EIP20Interface(pTokenAddr).balanceOf(msg.sender); 
        uint256 withdrawAmount = amount;

        if (amount == type(uint256).max) {
            withdrawAmount = userBalance;
        }

        // KoiosJudgement.WithdrawJudgement(assetAddr, withdrawAmount);

        // assetData.updateState();
        // assetData.updateInterestRates(assetAddr, pTokenAddr, 0, withdrawAmount);

        // TODO: burn 掉相应数量的pToken(pToken part)

        emit Withdraw(assetAddr, msg.sender, to, withdrawAmount);
    }

    /**
    @param crtQuota CRT decay level. Default value is 10(consider all the crt user has).
     */
    function borrow (address assetAddr, uint256 amount, address borrower, uint8 crtQuota) external {
        
        AssetsLib.AssetProfile storage assetData = _assetData[assetAddr];
        AssetsLib.UserConfigurationMapping storage userConfig = _userConfig[borrower];
        // mapping(uint8 => uint8) memory _crtValueMapping = assetData.crtValueMapping;

        address pTokenAddr = assetData.pTokenAddress;
        uint256 userBalance = EIP20Interface(pTokenAddr).balanceOf(msg.sender); 
        // 用户的crtBalance怎么获取
        uint256 crtBalance;

        // 通过oracle 将用户的所有存款转为 usd单位 assetValueInUSD
        uint256 assetValueInUSD;

        // // CRT used according to crtQuota
        // uint256 crtRequired = 0;
        // for (uint8 i = 1; i <= crtQuota; i++) {
        //     // 数学方法待定
        //     // 0.1 要怎么表示
        //     uint256 addedValue = assetValueInUSD * 0.1 / _crtValueMapping[i];
        //     crtRequired += addedValue;
        // }
        // KoiosJudgement.BorrowJudgement(assetData, assetAddr, amount, crtRequired, crtBalance);

        // TODO: 将CRT Staking Pool中对应的CRT 锁住 怎么锁？  加一个locked value
        // TODO: 借款成功后把 额度发给用户

        // assetData.updateState();
        // assetData.updateInterestRates(assetAddr, pTokenAddr, 0, amount);

        emit Borrow(assetAddr, borrower, amount);

    }

    function repay(address assetAddr, uint256 repayAmount, address debtor) external {

        AssetsLib.AssetProfile storage assetData = _assetData[assetAddr];

        // // TODO 1. 获取用户total 债务（1. conpound 链上存信息？ 2. aave 发债务token）
        uint256 debtBalance;
        uint256 principal;
        // (uint256 debtBalance, uint256 principal) = getdebtBalance(debtor);

        
        //      2. 调整债务；
        // 如果 还款额 a. 小于 b. 等于 c. 大于 借款额
        // 如果repayAmount 大于 debt Balance 怎么处理
        require(debtBalance >= repayAmount, "ERROR");

        // 会记录用户的 借款本金 利息 和 总债务， 其中 总债务 = 借款本金 100  + 利息 10        3 4 5 7 7 8
        // if 偿还额度 小于 总债务额度
        //    if 偿还额度 大于 初始本金
        //        则大于本金额度的部分 可以 mint CRT
        //    elif 偿还额度 小于初始本金 
        //        则先还利息， 利息还到0后， 剩下的repayAmount用来还用户的借款本金， 此时不能mint CRT 否则用户可以多次频繁小额repay刷取CRT 但是本金并没有还多少
        // elif 偿还额度 = 总债务额度 即一次还清
        //    mint CRT
        if (repayAmount == debtBalance) {
            // 计算还款利息
            uint256 repaidInterest = repayAmount - principal;
            // @chen zihao crt.mint()
            // 更新用户债务信息

        }
        else {
            if (repayAmount > principal) {
                uint256 repaidInterest = repayAmount - principal;
                // @chen zihao crt.mint()
                // 更新用户债务信息
            }
            else {
                // 更新用户债务信息
            }
        }
        // KoiosJudgement.RepayJudgement(assetData, assetAddr, repayAmount, debtor);

        // assetData.updateState();
        // address pTokenAddr = assetData.pTokenAddress;
        // assetData.updateInterestRates(assetAddr, pTokenAddr, repayAmount, 0);

        emit Repay(assetAddr, debtor, repayAmount);
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
        AssetsLib.AssetProfile storage assetData = _assetData[vars.currency];

        AssetsLib.UserConfigurationMapping storage userConfig = _userConfig[vars.debtor];

        // TODO: 获取预言机价格

        // TODO: 更新池子状态
        // 更新资产的状态变量
        // assetData.updateState();

        // TODO: calculation

        // TODO: 发射事件
    }

    /**
   * @dev Returns the list of the initialized reserves
   **/
    function getReservesList() external view override returns (address[] memory) {
        address[] memory _activeReserves = new address[](_reservesCount);
        // console.log(_reservesCount);

        for (uint256 i = 0; i < _reservesCount; i++) {
            _activeReserves[i] = _reservesList[i];
        }
        return _activeReserves;
    }

    /**
   * @dev Sets the configuration bitmap of the reserve as a whole
   * - Only callable by the LendingPoolConfigurator contract
   * @param asset The address of the underlying asset of the reserve
   * @param configuration The new configuration bitmap
   **/
    function setConfiguration(address asset, uint256 configuration)
        external
        override
        onlyCounterConfigurator
    {
        _assetData[asset].configuration.data = configuration;
    }


    /**
   * @dev Returns the configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The configuration of the reserve
   **/
    function getConfiguration(address asset)
        external
        view
        override
        returns (AssetsLib.AssetConfigMapping memory)
    {
        return _assetData[asset].configuration;
    }

    /**
   * @dev Initializes a reserve, activating it, assigning an aToken and debt tokens and an
   * interest rate strategy
   * - Only callable by the LendingPoolConfigurator contract
   * @param asset The address of the underlying asset of the reserve
   * @param pTokenAddress The address of the aToken that will be assigned to the reserve
   * @param interestRateStrategyAddress The address of the interest rate strategy contract
   **/
    function initReserve(
        address asset,
        address pTokenAddress,
        address interestRateStrategyAddress
    ) external override onlyCounterConfigurator {
        require(Address.isContract(asset), "Error");
        _assetData[asset].init(pTokenAddress, interestRateStrategyAddress);
        _addReserveToList(asset);
    }

    function _addReserveToList(address asset) internal {
        uint256 reservesCount = _reservesCount;

        require(reservesCount < _maxNumberOfReserves, "Error");

        bool reserveAlreadyAdded = _assetData[asset].id != 0 || _reservesList[0] == asset;

        if (!reserveAlreadyAdded) {
            _assetData[asset].id = uint8(reservesCount);
            _reservesList[reservesCount] = asset;

            _reservesCount = reservesCount + 1;
        }
    }

    /**
   * @dev Returns the state and configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The state of the reserve
   **/
    function getReserveData(address asset) external view override
        returns (AssetsLib.AssetProfile memory)
    {
        // console.log("124867");
        // console.log(_assetData[asset].pTokenAddress);
        return _assetData[asset];
        
    }

    function _onlyCounterConfigurator() internal view {
        require(
        _addressProvider.getCounterConfigurator() == msg.sender,
        "Error"
        );
    }

    modifier onlyCounterConfigurator() {
        _onlyCounterConfigurator();
        _;
    }

    modifier whenNotPaused() {
        _whenNotPaused();
        _;
    }

    function _whenNotPaused() internal view {
        require(!_paused, "Error");
    }
}