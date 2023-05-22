

import { HardhatRuntimeEnvironment } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";

const hre: HardhatRuntimeEnvironment = require('hardhat');

// V2 lending pool
const GOERLI_AAVE_LENDING_POOL = '0x4bd5643ac6f66a5237E18bfA7d47cF22f1c9F210';

async function main() {
    console.log("Test paToken's balanceOf is equal to the amount of the underlying asset instead of atoken");
    // const provider = new ethers.providers.JsonRpcProvider(hre.network.config.url!);
    const [signer,] = await hre.ethers.getSigners();    
    // console.log(provider);
    const abi = (await hre.artifacts.readArtifact("ILendingPool")).abi;
    const LENDING_POOL_GOERLI = new ethers.Contract(GOERLI_AAVE_LENDING_POOL, abi, signer);
    // console.log(LENDING_POOL_GOERLI);
    let tx = await LENDING_POOL_GOERLI.getReserveData("0x65E2fe35C30eC218b46266F89847c63c2eDa7Dc7");
    console.log(tx);
    
}

// [
//     '0x0B7a69d978DdA361Db5356D4Bd0206496aFbDD96',
//     '0x515614aA3d8f09152b1289848383A260c7D053Ff',
//     '0xa7c3Bf25FFeA8605B516Cf878B7435fe1768c89b',
//     DAI :'0x75Ab5AB1Eef154C0352Fc31D2428Cef80C7F8B33',
//     '0x1057DCaa0b66dFBcEc5241fD51F4326C210f201F',
//     '0x54Bc1D59873A5ABde98cf76B6EcF4075ff65d685',
//     LINK '0x7337e7FF9abc45c0e43f130C136a072F4794d40b',
//     '0x8d9EAc6f25470EFfD68f0AD22993CB2813c0c9B9',
//     '0x90be02599452FBC1a3D47E9EB62895330cfA05Ed',
//     '0x3160F3f3B55eF85d0D27f04A2d74d426c32de842',
//     '0xFc1Ab0379db4B6ad8Bf5Bc1382e108a341E2EaBb',
//     '0x4e62eB262948671590b8D967BDE048557bdd03eD',
//     '0xc048C1b6ac47393F073dA2b3d5D1cc43b94891Fd',
//     uni '0x981D8AcaF6af3a46785e7741d22fBE81B25Ebf1e',
//     USDC '0x9FD21bE27A2B059a288229361E2fA632D8D2d074',
//     USDT '0x65E2fe35C30eC218b46266F89847c63c2eDa7Dc7',
//     wbtc '0xf4423F4152966eBb106261740da907662A3569C5',
//     WETH '0xCCa7d1416518D095E729904aAeA087dBA749A4dC',
//     '0x6c260F702B6Bb9AC989DA4B0fcbE7fddF8f749c4',
//     '0xAcFd03DdF9C68015E1943FB02b60c5df56C4CB9e',
//     '0x45E18E77b15A02a31507e948A546a509A50a2376'
// ]
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });