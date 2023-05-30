import { HardhatRuntimeEnvironment } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { getPTokenContract, getTokenContract } from "../helpers/contracts-getter";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { DAIHolder, USDCHolder, ETHHolder } from "../helpers/holder";
import { ethers } from "hardhat";
const hre: HardhatRuntimeEnvironment = require('hardhat');

async function main() {
    console.log("Test paToken's balanceOf is equal to the amount of the underlying asset instead of atoken");

    // 修改不同的代币持有者
    await impersonateAccount(ETHHolder);
    const fakeSigner: SignerWithAddress = await hre.ethers.getSigner(ETHHolder);
    // 代币名字
    let tokenSymbol = 'ETH';
    let amount = '100';
    // 修改dicimals
    let inputAmount = ethers.utils.parseUnits(amount, 18);

    let to = "0xD5A832A6813631380b72C503c980a4d2B30934F1";

    // transfer ERC20 token
    // let Token = await getTokenContract(tokenSymbol);
    // let pToken = await getPTokenContract(tokenSymbol);

    // console.log("%s balance: ", tokenSymbol, await Token.balanceOf(to));

    // await Token.connect(fakeSigner).transfer(to, inputAmount);
    // console.log("%s balance: ", tokenSymbol, await Token.balanceOf(to));

    // transfer ETH
    const tx = {
        to: to,
        value: ethers.utils.parseEther("100")
    }
    const receipt = await fakeSigner.sendTransaction(tx)
    await receipt.wait() // 等待链上确认交易
    console.log(receipt)
    
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });