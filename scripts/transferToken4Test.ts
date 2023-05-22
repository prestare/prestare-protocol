import { HardhatRuntimeEnvironment } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { getPTokenContract, getTokenContract } from "../helpers/contracts-getter";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { DAIHolder, USDCHolder } from "../helpers/holder";
import { ethers } from "hardhat";
const hre: HardhatRuntimeEnvironment = require('hardhat');

async function main() {
    console.log("Test paToken's balanceOf is equal to the amount of the underlying asset instead of atoken");

    // 修改不同的代币持有者
    await impersonateAccount(USDCHolder);
    const fakeSigner: SignerWithAddress = await hre.ethers.getSigner(USDCHolder);
    // 代币名字
    let tokenSymbol = 'USDC';
    let amount = '1000';
    // 修改dicimals
    let inputAmount = ethers.utils.parseUnits(amount, 6);

    // await depositToken(fakeSigner, tokenSymbol, amount);
    let to = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
    let Token = await getTokenContract(tokenSymbol);
    let pToken = await getPTokenContract(tokenSymbol);

    console.log("%s balance: ", tokenSymbol, await Token.balanceOf(to));

    await Token.connect(fakeSigner).transfer(to, inputAmount);
    console.log("%s balance: ", tokenSymbol, await Token.balanceOf(to));
    
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });