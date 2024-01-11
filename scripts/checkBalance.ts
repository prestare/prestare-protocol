import { HardhatRuntimeEnvironment } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { getPTokenContract, getTokenContract } from "../helpers/contracts-getter";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { ETHHolder } from "../helpers/holder";
import { transferETH } from "../test/helper/operationHelper";

const hre: HardhatRuntimeEnvironment = require('hardhat');

async function main() {
    // console.log("Test paToken's balanceOf is equal to the amount of the underlying asset instead of atoken");
    
    // await impersonateAccount(aDAIHolder);
    // const fakeSigner: SignerWithAddress = await hre.ethers.getSigner(aDAIHolder);
    // let tokenSymbol = 'aDAI';
    // let amount = '200';
    // // await depositToken(fakeSigner, tokenSymbol, amount);

    // let aDAI = await getTokenContract(tokenSymbol);
    // let paDAI = await getPTokenContract(tokenSymbol);
    // let balanceOf = await paDAI.balanceOf(fakeSigner.address);
    // console.log(`User paDai balanceOf is ${balanceOf.toString()} DAI`);

    // let daiAddress = await paDAI.UNDERLYING_ASSET_ADDRESS();
    // let aaveLendingPool = await getAAVELendingPool(LENDING_POOL_V2);
    // //  normalizedIncome
    // let normalizedIncome = await aaveLendingPool.getReserveNormalizedIncome(daiAddress);
    // let value = BigNumber.from(amount).mul(normalizedIncome).mul(oneEther).div(oneRay);
    // console.log(`According to AAVE Platform, ${amount} ${tokenSymbol} is equal ${value.toString()} DAI`);
    let [admin,user1,user2, user3,user4] = await hre.ethers.getSigners();
    let ETHUser = await hre.ethers.getSigner(ETHHolder);

    let pro = hre.ethers.provider;
    let balance = await pro.getBalance(admin.address);
    let bal2 = await pro.getBalance(user1.address);
    console.log(balance);
    console.log(bal2);
    let amount = "1";
    let tx = await transferETH(ETHUser, user1.address, amount);
    balance = await pro.getBalance(user1.address);
    console.log(balance);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });