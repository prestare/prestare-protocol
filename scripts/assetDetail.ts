import { HardhatRuntimeEnvironment } from "hardhat/types";

const hre: HardhatRuntimeEnvironment = require('hardhat');
import { DAIHolder, ETHHolder, USDCHolder, USDTHolder } from "../helpers/holder";
import { checkBalance, depositERC20, depositWETH, transferErc20, transferETH } from "../test/helper/operationHelper";
import { getPTokenContract, getStrategyAddress, getTokenContract } from "../helpers/contracts-getter";
import { getCounter, getPToken, getCRT, getVariableDebtToken, getDefaultIRModel } from "../helpers/contracts-helpers";
import { BigNumber, Contract, Signer } from "ethers";
import { getPrestareOracle } from "../helpers/contracts-helpers";
import { constructTokenRiskName } from "../test/helper/operationHelper";
import { ethers } from "hardhat";
import { getLtv,getLiquidationThreshold, getLiquidationBonus, getReserveFactor } from "./configParser";

async function main() {

    let [admin,user1,] = await hre.ethers.getSigners();
    // console.log(user1.address)

    let counter = await getCounter(admin);
    console.log("counter", counter.address);
    let usdc = "USDC";
    let usdc_token = await getTokenContract(usdc);

    // 目前只有USDC-B 有进行借贷，所以supply rate
    // 2代表着B类资产
    let reserveInfo = await counter.getReserveData(usdc_token.address, 2);
    console.log(reserveInfo);

    let ray = ethers.utils.parseUnits("1", 27);
    let supplyIR = reserveInfo.currentLiquidityRate.mul(10000).div(ray);
    let borrowIR = reserveInfo.currentVariableBorrowRate.mul(10000).div(ray);
    console.log("Supply Interest Rate is %s %", (supplyIR.toNumber() / 100).toFixed(2));
    console.log("Borrow Interest Rate is %s %", (borrowIR.toNumber() / 100).toFixed(2));

    let assetConfig = await counter.getConfiguration(usdc_token.address, 2);
    let config = assetConfig.data
    console.log("MAX LTV: %d %", (getLtv(config) / 100).toFixed(2));
    console.log("LiquidationThreshold %d %", (getLiquidationThreshold(config) / 100).toFixed(2));
    console.log("Liquidation Bonus %d %", (getLiquidationBonus(config) / 100).toFixed(2));
    console.log("Reserve Factor %d %", (getReserveFactor(config) / 100).toFixed(2));

    let avaliableLiquidity = await usdc_token.balanceOf(reserveInfo.pTokenAddress);
    let pUSDC_C_debt = await getVariableDebtToken(reserveInfo.variableDebtTokenAddress);
    let totalVariableDebt = (await pUSDC_C_debt.scaledTotalSupply()).mul(reserveInfo.variableBorrowIndex).div(ray);
    // console.log(avaliableLiquidity);
    // console.log(totalVariableDebt);
    // 保留两位小数
    let Utilization = totalVariableDebt.mul(10000).div(avaliableLiquidity.add(totalVariableDebt)).toNumber();
    console.log("Utilization rate: %d %", (Utilization / 100).toFixed(2));

    // 曲线图，利用率导致利率变化的图
    let irStrategy = await getDefaultIRModel(reserveInfo.interestRateStrategyAddress);
    let variableRateSlope1 = await irStrategy.variableRateSlope1();
    let variableRateSlope2 = await irStrategy.variableRateSlope2();
    let OPTIMAL_UTILIZATION_RATE = await irStrategy.OPTIMAL_UTILIZATION_RATE();

    console.log("variableRateSlope1 is: ", (variableRateSlope1.mul(100).div(ray).toNumber() / 100).toFixed(2));
    console.log("variableRateSlope2 is: ", (variableRateSlope2.mul(100).div(ray).toNumber() / 100).toFixed(2));
    console.log("OPTIMAL_UTILIZATION_RATE is: ", (OPTIMAL_UTILIZATION_RATE.mul(100).div(ray).toNumber() / 100).toFixed(2));

    // Your wallet
    // 查看用户在该等级的资产中的情况，假设还是C等级，user1,存了DAI只借了USDC-c
    let pUSDC_C = await getPToken(reserveInfo.pTokenAddress);
    let riskTier = 2;
    let userAccount = await counter.getUserAccountData(user1.address, riskTier);
    let walletBalance = await pUSDC_C.balanceOf(user1.address);
    // console.log(userAccount);
    let factor = ethers.utils.parseUnits("1", 8)
    console.log("Available to Borrow: %s $", userAccount.availableBorrowsUSD.div(factor).toString());
}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });