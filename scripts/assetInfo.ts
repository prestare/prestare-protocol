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

async function calAssetTotalDeposit(asset:string, highrisk: number) {
    let token = await getTokenContract(asset);
    let tokenTotalDeposit = BigNumber.from(0);
    // 从最低档的资产分类C开始，直到该资产的最高类别
    for (let risk = 2; risk >= highrisk; risk--) {
        let token_risk = constructTokenRiskName(asset, risk);
        let ptoken_risk = await getPTokenContract(token_risk);
        let tokenRiskDeposit = await token.balanceOf(ptoken_risk.address);
        tokenTotalDeposit = tokenRiskDeposit.add(tokenTotalDeposit);
    }
    return tokenTotalDeposit
}

async function calculateTotalAssetUSD(asset: Contract, assetAmount: BigNumber) {
    let priceOrcale = await getPrestareOracle();
    let oracle_dicimals = ethers.utils.parseUnits("1", 8);
    let asset_price = await priceOrcale.getAssetPrice(asset.address);
    let asset_decimal = await asset.decimals();
    console.log("Total DAI is: ", assetAmount);
    console.log("   Price is: ", asset_price);
    let divfactor = ethers.utils.parseUnits("1", asset_decimal)
    let totalAmount = assetAmount.div(divfactor).mul(asset_price).div(oracle_dicimals);
    console.log("Total %s in USD is: %s", await asset.symbol(),totalAmount);
}

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

    let pUSDC_B = await getPToken(reserveInfo.pTokenAddress);
    let pUSDC_BSupply = await pUSDC_B.totalSupply(); 
    console.log("pUSDC_B total Supply is", pUSDC_BSupply);
    let pUSDC_B_debt = await getVariableDebtToken(reserveInfo.variableDebtTokenAddress);
    let pUSDC_B_debtSupply = await pUSDC_B_debt.totalSupply();
    console.log("pUSDC_B debt Token total Supply is", pUSDC_B_debtSupply);
    console.log("USDC-B Tier is B")
}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });