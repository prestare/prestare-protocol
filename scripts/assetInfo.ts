import { HardhatRuntimeEnvironment } from "hardhat/types";

const hre: HardhatRuntimeEnvironment = require('hardhat');
import { DAIHolder, ETHHolder, USDCHolder, USDTHolder } from "../helpers/holder";
import { checkBalance, depositERC20, depositWETH, transferErc20, transferETH } from "../test/helper/operationHelper";
import { getPTokenContract, getTokenContract } from "../helpers/contracts-getter";
import { getCounter, getPToken, getCRT, getVariableDebtToken } from "../helpers/contracts-helpers";
import { BigNumber, Contract, Signer } from "ethers";
import { getPrestareOracle } from "../helpers/contracts-helpers";
import { constructTokenRiskName } from "../test/helper/operationHelper";
import { ethers } from "hardhat";


async function main() {

    let [admin,user1,] = await hre.ethers.getSigners();
    // console.log(user1.address)

    let counter = await getCounter(admin);
    console.log("counter", counter.address);
    let usdc = "USDC";
    let usdc_token = await getTokenContract(usdc);

    // 目前只有USDC-C 有进行借贷，所以supply rate
    // 2代表着C类资产, 1代表B类资产，0代表A类资产
    let reserveInfo = await counter.getReserveData(usdc_token.address, 2);
    console.log(reserveInfo);
    //     5 00000 0000 0000 0000 0000 0000
    // 1000000000000000000000000000
    //       11320 3984 3656 6107 4079 3674 = 0.1%
    //        2252 8375 1984 3275 0483 5695 = 0.02%
    //    10 01250 0138 6524 9614 5460 6071 = 10%
    //    10 06250 04715312049687699255
    let ray = ethers.utils.parseUnits("1", 27);
    let supplyIR = reserveInfo.currentLiquidityRate.mul(10000).div(ray);
    let borrowIR = reserveInfo.currentVariableBorrowRate.mul(10000).div(ray);
    console.log("Supply Interest Rate is %s %", (supplyIR.toNumber() / 100).toFixed(2));
    console.log("Borrow Interest Rate is %s %", (borrowIR.toNumber() / 100).toFixed(2));

    // 获取pToken地址可以从reserveInfo中获取
    let pUSDC_C = await getPToken(reserveInfo.pTokenAddress);
    let pUSDC_CSupply = await pUSDC_C.totalSupply(); 
    console.log("pUSDC_C total Supply is", pUSDC_CSupply);
    let pUSDC_C_debt = await getVariableDebtToken(reserveInfo.variableDebtTokenAddress);
    let pUSDC_C_debtSupply = await pUSDC_C_debt.totalSupply();
    console.log("pUSDC_B debt Token total Supply is", pUSDC_C_debtSupply);
    console.log("USDC-C Tier is C")
}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });