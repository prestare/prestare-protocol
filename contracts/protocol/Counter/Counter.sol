// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

// dependencies file
import {Address} from "../../dependencies/openzeppelin/contracts/Address.sol";
import {IERC20} from "../../dependencies/openzeppelin/contracts/IERC20.sol";
import {SafeERC20} from "../../dependencies/openzeppelin/contracts/SafeERC20.sol";
// import {SafeMath256} from "../../dependencies/openzeppelin/contracts/SafeMath.sol";

// interfaces file
import {ICounter} from "../../interfaces/ICounter.sol";
import {IPToken} from "../../interfaces/IPToken.sol";

// 
import {CounterStorage} from "./CounterStorage.sol";
import {AssetStorage} from "../../DataType/AssetStorage.sol";
// import {PrestareMarketStorage} from "../../DataType/PrestareStorage.sol";
import {KoiosJudgement} from "../../Koios.sol";

import {CounterAddressProvider} from "../configuration/CounterAddressProvider.sol";
import {ReserveLogic} from "../../ReserveLogic.sol";
import {WadRayMath} from "../../utils/WadRay.sol";
import {CreditToken} from "../../CreditToken.sol";

import {Error} from "../../utils/Error.sol";

import "hardhat/console.sol";
/**
 * @title Counter Contract
 * @author Prestare
 * @notice The bridge between User and Prestare Lending Market
 * - What user can do?
 *  # Deposit to provide liquidity
 *  # Withdraw
 *  # Borrow with or without CreditToken(CRT)
 *  # Repay and Get CRT
 *  # Liquidate positions
 *  # Flash Loan(not yet)
 * @dev 
 */
contract Counter is CounterStorage, ICounter {
    // using SafeMath256 for uint256;
    using ReserveLogic for AssetStorage.AssetProfile;
    using SafeERC20 for IERC20;

    uint256 public constant REVISION = 0x1;

    function getRevision() internal pure override returns (uint256) {
        return LENDINGPOOL_REVISION;
    }
    
    function initialize(CounterAddressProvider provider) public {
        _addressProvider = provider;
        _maxNumberOfReserves = 128;
    }
    
    // TODO： 设置函数调用权限或者状态
    // ICounter function
    function deposit (address assetAddr, uint256 amount, address depositor) external override whenNotPaused {

        PrestareCounterStorage.CounterProfile storage assetData = _assetData[assetAddr];

        KoiosJudgement.DepositJudgement(assetData, amount);
        address pTokenAddr = assetData.pTokenAddress;
        // 更新资产的状态变量
        assetData.AssetUpdate();
        // 更新资产的利率模型变量
        assetData.UpdateInterestRates(assetAddr, pTokenAddr, amount, 0);

        IERC20(asset).safeTransferFrom(msg.sender, pTokenAddr, amount);
        
        bool status = IPToken(pTokenAddr).mint(depositor, amount, assetData.liquidityIndex);
        
        emit Deposit(assetAddr, msg.sender, provider, amount);
    }

    // ICount function
    function withdraw (address assetAddr, uint256 amount, address to) external returns (uint256) {

        AssetStorage.AssetProfile storage assetData = _assetData[assetAddr];
        address pTokenAddr = assetData.pTokenAddress;
        // interface 要改
        uint256 userBalance = IPToken(pTokenAddr).balanceOf(msg.sender); 
        uint256 withdrawAmount = amount;

        if (amount == type(uint256).max) {
            withdrawAmount = userBalance;
        }
        // todo check if user can withdraw amount of token
        KoiosJudgement.WithdrawJudgement(
            assetAddr, 
            withdrawAmount,
            userBalance,
            _reserves,
            _usersConfig[msg.sender],
            _reservesList,
            _reservesCount,
            _addressesProvider.getPriceOracle()
        );

        assetData.updateState();
        assetData.updateInterestRates(assetAddr, pTokenAddr, 0, withdrawAmount);

        // TODO: release CRT


        // TODO: burn 掉相应数量的pToken(pToken part)
        IPToken(pTokenAddr).burn(msg.sender, to. withdrawAmount, reserve.liquidity);
        emit Withdraw(assetAddr, msg.sender, to, withdrawAmount);
        return withdrawAmount;
    }

    /**
    @param crtQuota CRT decay level. Default value is 10(consider all the crt user has).
     */
    function borrow (
        address assetAddr, 
        uint256 amount, 
        address borrower, 
        uint8 crtQuota
    ) external override {
        AssetStorage.AssetProfile storage assetData = _assetData[assetAddr];
        _borrow(
            BorrowParams(
                assetAddr,
                borrower,
                amount,
                assetData.pTokenAddress,
                _assetData[assetAddr].crtAddress,
                crtQuota
            )
        );
    }

    function repay(address assetAddr, uint256 amount, address borrower) external override {

        AssetStorage.AssetProfile storage assetData = _assetData[assetAddr];

        // // TODO 1. 获取用户total 债务（1. conpound 链上存信息？ 2. aave 发债务token）
        uint256 debtBalance;
        uint256 principal;
        (uint256 debtBalance, uint256 principal) = Helper.getdebtBalance(borrower);

        KoiosJudgement.RepayJudgement(
            assetData,
            amount,
            borrower,
            debtBalance,
            principal
        );
        
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
            // crt.mint();
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

        assetData.updateState();
        
        IDebtToken(assetData.pdebtTokenAddress).burn(borrower, repayAmount, assetData.variableBorrowIndex);
        address pTokenAddr = assetData.pTokenAddress;
        assetData.updateInterestRates(assetAddr, pTokenAddr, repayAmount, 0);
        
        IERC20(assetAddr).safeTransferForm(msg.sender, pToken, repayAmount);
        IPToken(pTokenAddr).handleRepayment(msg.sender, repayAmount);

        emit Repay(assetAddr, debtor, repayAmount);
    }


    function liquidationCall(
        address collateralCurrency, 
        address debtAsset, 
        address debtor, 
        uint256 LiquiAmount, 
        uint8 liquidationMode
    ) external override {
        if (liquidationMode == 0) {
            externalLiquidation(collateralCurrency, debtAsset, debtor, LiquiAmount);
        } 
        else if (liquidationMode == 1) {
            internalLiquidation(collateralCurrency, debtAsset, debtor, LiquiAmount);
        }
        else if (liquidationMode == 2) {

        }
        else {
            // TODO: return an error
        }
    }

    function externalLiquidation(
        address collateralCurrency, 
        address debtCurrency, 
        address debtor, 
        uint256 LiquiAmount
    ) internal returns (bool, string memory){
        AssetStorage.AssetProfile storage collateralAsset = _assetData[collateralCurrency];
        AssetStorage.AssetProfile storage debtAsset = _assetData[debtCurrency];
        AssetStorage.CounterConfigMapping storage userConfig = userConfig[debtor];
        // update debt asset state
        debtAsset.updateState();

        // todo check how to pass oracle address
        uint256 healthFactor = GenericLogic.calculateUserAccountData(
            _assetData,
            userConfig,
            debtor,
            oracle
        );
        
        DebtAmount = Helpers.getUserCurrentDebt(debtor, debtAsset);

        (bool success, bytes memory err) = KoiosJudgement.LiquidationJudgement(
            collateralAsset,
            debtAsset,
            userConfig,
            healthFactor,
            DebtAmount
        );

        if (success != true) {
            return (success, err);
        }

        IPToken collateralPToken = IPToken(collateralAsset.pTokenAddress);
        uint256 userCollateralBalance = collateralPToken.balanceOf(debtor);

        uint256 actualDebtToLiquidate = LiquiAmount > DebtAmount 
            ? DebtAmount
            : LiquiAmount;
        
        (
            uint256 maxCollateralToLiquidate, 
            uint256 debtAmountNeed
        ) = _calculateAvailableCollateralToLiquidate(
            collateralAsset,
            debtAsset,
            collateralCurrency,
            debtCurrency,
            actualDebtToLiquidate,
            userCollateralBalance
        );
        // If debtAmountNeeded < actualDebtToLiquidate, there isn't enough
        // collateral to cover the actual amount that is being liquidated, hence we liquidate
        // a smaller amount
        if (debtAmountNeed < actualDebtToLiquidate) {
            actualDebtToLiquidate = debtAmountNeed;
        }
        
        debtAsset.updateState();

        // 检查此次清算是否偿还所有的债务
        if (DebtAmount >= actualDebtToLiquidate) {
            IDebtToken(debtAsset.pdebtTokenAddress).burn(
                user,
                actualDebtToLiquidate,
                debtAsset.variableBorrowIndex
            );
        } else {
            if (DebtAmount > 0) {
                IDebtToken(debtAsset.pdebtTokenAddress).burn(
                    user,
                    DebtAmount,
                    debtAsset.variableBorrowIndex
                );
            }
        }

        debtAsset.updateInterestRates(
            debtCurrency,
            debtAsset.pTokenAddress,
            actualDebtToLiquidate,
        );

        uint256 liquidatorPreviousATokenBalance = IERC20(collateralPToken).balanceOf(msg.sender);
        collateralPToken.transferOnLiquidation(debt, msg.sender, maxCollateralToLiquidate);

        collateralPToken.burn(
            debtor,
            msg.sender,
            maxCollateralToLiquidate,
            collateralAsset.ExchangeRate
        );

        IERC20(debtAsset).safeTransferFrom(
            msg.sender, 
            debtAsset.pTokenAddress,
            actualDebtToLiquidate
        );

        emit liquidationCall(
            collateralAsset, 
            debtAsset, 
            debtor, 
            actualDebtToLiquidate, 
            maxCollateralToLiquidate,
            msg.sender,
            liquidationMode
        );
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
        PrestareCounterStorage.CounterProfile storage assetData = _assetData[vars.currency];

        PrestareCounterStorage.UserConfigurationMapping storage userConfig = _userConfig[vars.debtor];

        // TODO: 获取预言机价格

        // TODO: 更新池子状态
        // 更新资产的状态变量
        // assetData.updateState();

        // TODO: calculation

        // TODO: 发射事件
    }





    function validateTransfer(
        address asset, 
        address sender,
        address receiver,
        uint256 amount
    ) external override {
        require(msg.sender == _assetData[asset].pTokenAddress, "Error");

        KoiosJudgement.transferJudgment(
            sender,
            _assetData,
            _userConfig[sender],
            _reservesList,
            _reservesCount
        );
    }


    function getAssetData(address asset) 
      external 
      view 
      override
      returns (AssetStorage.AssetProfile memory) 
    {
        return _assetData[asset];
    }

    function getCRTData(address asset) external view returns (MarketStorage.CreditTokenStorage memory);

    function getUserData(address user, address assetAddr)
      external 
      view 
      override
      returns (MarketStorage.UserBalanceByAsset memory) 
    {
        return _userDataByAsset[user][assetAddr];
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
        returns (PrestareCounterStorage.CounterConfigMapping memory)
    {
        return _assetData[asset].configuration;
    }

    /**
     * @dev Returns the state and configuration of the reserve
     * @param asset The address of the underlying asset of the reserve
     * @return The state of the reserve
     */
    function getReserveData(address asset)
        external
        view
        override
        returns (PrestareCounterStorage.CounterProfile memory)
    {
        return _assetData[asset];
    }

    /**
   * @dev Initializes a reserve, activating it, assigning an aToken and credit tokens and an
   * interest rate strategy
   * - Only callable by the LendingPoolConfigurator contract
   * @param asset The address of the underlying asset of the reserve
   * @param pTokenAddress The address of the pToken that will be assigned to the reserve
   * @param interestRateStrategyAddress The address of the interest rate strategy contract
   **/

    // TODO: Whether all the counters can be assigned to a credit token address / Or the zero crtAddress
    // can be set in the initial configuration for counters dont need crtAddress
    function initReserve(
        address asset,
        address pTokenAddress,
        address crtAddress,
        address interestRateStrategyAddress
    ) external override onlyCounterConfigurator {
        require(Address.isContract(asset), "Error");
        _assetData[asset].init(pTokenAddress, crtAddress, interestRateStrategyAddress);
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

    function _borrow(BorrowParams memory vars) internal {
        AssetStorage.AssetProfile storage assetData = _assetData[vars.assetAddress];
        AssetStorage.UserConfigurationMapping storage userConfig = _userConfig[borrower];
        
        // mapping(uint8 => uint8) memory _crtValueMapping = assetData.crtValueMapping;
        // uint256 userBalance = EIP20Interface(pTokenAddr).balanceOf(msg.sender); 
        // get user's balance of CRT
        console.log(vars.crtAddress);
        console.log("11111");
        uint256 crtBalance = CreditToken(vars.crtAddress).balanceOf(vars.borrower);
        console.log("11111");

        // // 通过oracle 将用户的所有存款转为 usd单位 assetValueInUSD
        // uint256 assetValueInUSD;
        address oracle = _addressProvider.getPriceOracle();
        uint256 priceByUSD = IPriceOracleGetter(oracle).getAssetPrice(vars.assetAddress);
        uint256 amountInUSD = priceByETH * vars.amount / 10**assetData.configuration.getDecimals();

        KoiosJudgement.BorrowJudgement(
            vars.assetAddress,
            assetData,
            vars.borrower,
            amountInUSD,
            vars.interestRateMode,
            _assetData,
            userConfig,
            _reservesList,
            _reservesCount,
            oralce
        );

        // CRT required according to crtQuota provided by user
        uint256 crtRequired;
        // 这一段放入Koios中用来判断是否满足借款条件
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

        // Update User's balance
        reserve.updateState();
        // PrestareMarketStorage.UserBalanceByAsset storage userBlance = _userDataByAsset[vars.borrower][vars.assetAddress];
        // uint256 lastTotalBorrow = userBlance.totalBorrows;
        // uint256 lastBorrowPrincipal = userBlance.principal;

        // (bool statusOne, uint256 newAccTotalBorrows) = lastTotalBorrow.tryAdd(vars.amount);
        // require(statusOne, Error.SAFEMATH_ADDITION_OVERFLOW);
        // (bool statusTwo, uint256 newAccBorrowPrincipal) = lastBorrowPrincipal.tryAdd(vars.amount);
        // require(statusTwo, Error.SAFEMATH_ADDITION_OVERFLOW);

        // userBlance.totalBorrows = newAccTotalBorrows;
        // userBlance.principal = newAccBorrowPrincipal;
        // updata reserve interestRates
        reserve.updateInterestRates(
            vars.assetAddress, 
            vars.pTokenAddress,
            0,
            vars.amount
        );

        IPToken(vars.pTokenAddress).transferUnderlyingTo(vars.borrower, vars.amount);

        emit Borrow(
            vars.assetAddress, 
            vars.user, 
            vars.borrower,
            vars.amount,
            vars.interestRateMode,
            vars.referralCode
        );
    }

    /**
   * @dev Returns the state and configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The state of the reserve
   **/
    function getCounterData(address asset) external view override
        returns (PrestareCounterStorage.CounterProfile memory)
    {
        return _assetData[asset];
    }

    function getCRTData(address asset) external view override returns (PrestareMarketStorage.CreditTokenStorage memory) {
        return _crt[asset];
    }

    function getUserData(address user, address assetAddr) external view override 
        returns (PrestareMarketStorage.UserBalanceByAsset memory)
    {
        return _userDataByAsset[user][assetAddr];
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