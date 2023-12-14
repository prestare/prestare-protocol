import { HardhatRuntimeEnvironment } from "hardhat/types";

const hre: HardhatRuntimeEnvironment = require('hardhat');
import { DAIHolder, ETHHolder, USDCHolder, USDTHolder } from "../helpers/holder";
import { checkBalance, depositERC20, depositWETH, transferErc20, transferETH } from "../test/helper/operationHelper";
import { getPTokenContract, getTokenContract } from "../helpers/contracts-getter";
import { getCounter, getPToken } from "../helpers/contracts-helpers";
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
    // let priceOrcale = await getPrestareOracle();
    // let oracle_dicimals = ethers.utils.parseUnits("1", 8);
    console.log()
    let reservelist = await counter.getReservesList();
    // console.log(reservelist);

    let dai = "DAI";
    let dai_token = await getTokenContract(dai);
    // console.log("DAI is", dai_token.address)
    
    // 获取所有等级pToken对应的token总量
    let daiTotalDeposit = await calAssetTotalDeposit(dai, 1);
    // 获取价格预言机上的价格，计算总价格
    let dai_totalAmount = await calculateTotalAssetUSD(dai_token, daiTotalDeposit);

    let usdc = "USDC";
    let usdc_token = await getTokenContract(usdc);
    // 获取所有等级pToken对应的token总量
    let usdcTotalDeposit = await calAssetTotalDeposit(usdc, 1);
    // 获取价格预言机上的价格，计算总价格
    let usdc_totalAmount = await calculateTotalAssetUSD(usdc_token, usdcTotalDeposit);

    let weth = "WETH";
    let weth_token = await getTokenContract(weth);
    let wethTotalDeposit = await calAssetTotalDeposit(weth, 1);
    // 获取价格预言机上的价格，计算总价格
    let weth_totalAmount = await calculateTotalAssetUSD(weth_token, wethTotalDeposit);


}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });