import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Signer } from 'ethers';
import { getAllAssetTokens, getPrestareOracle } from "../../helpers/contracts-helpers";
import { getTokenContract } from "../../helpers/contracts-getter";
import { MainnetFork } from "../../markets/mainnet";
const hre: HardhatRuntimeEnvironment = require('hardhat');

async function main() {
    console.log("Test if aWETH and WETH use the same chainlink source to getPrice...");
    let [signer,] = await hre.ethers.getSigners();
    let prestareOracle = await getPrestareOracle();
    let WETH = await getTokenContract("WETH");
    let aWETH = await getTokenContract("aWETH");
    let wethPrice = await prestareOracle.getAssetPrice(WETH.address);
    let aWETHPrice = await prestareOracle.getAssetPrice(aWETH.address);
    console.log("   WETH price is ", wethPrice.toString());
    console.log("   aWETH price is ", aWETHPrice.toString());
    // later we will use expect to write testcase
    const ReserveAssetsAddress = MainnetFork.ReserveAssetsAddress.MainnetFork;
    let assets = await getAllAssetTokens(ReserveAssetsAddress);
    let tokens = Object.entries(assets);
    for (let [symbol, token] of tokens) {
        let price = await prestareOracle.getAssetPrice(token.address);
        console.log(`${symbol} price is ${price.toString()}`);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });