import { HardhatRuntimeEnvironment } from "hardhat/types";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { TokenContractName } from '../../helpers/types';
import { USDCHolder } from "../../helpers/holder";
import { repayErc20 } from "../helper/operationHelper";
import { getTokenContract } from "../../helpers/contracts-getter";
import { transferErc20 } from "../helper/operationHelper";
import { approveToken4Counter, getCounter, getCRT } from "../../helpers/contracts-helpers";
const hre: HardhatRuntimeEnvironment = require('hardhat');

async function main() {
    let [admin,user1,] = await hre.ethers.getSigners();

    // await impersonateAccount(USDCHolder);
    // let USDCUser = await hre.ethers.getSigner(USDCHolder);

    let repayAmount = "25";
    let repaySymbol = "USDC";
    let repayRisk = 2;
    // let repaytoken = await getTokenContract(repaySymbol);

    // await transferErc20(USDCUser, user1.address, repaytoken, repayAmount);
    // await approveToken4Counter(user1, repaytoken, repayAmount);
    // await repayErc20(user1, repaySymbol, repayRisk, repayAmount);

    let counter = await getCounter(admin);

    let userAccountData = await counter.getUserAccountData(user1.address, repayRisk);
    console.log(userAccountData);

    let crtToken = await getCRT();
    let crtBalance = await crtToken.balanceOf(user1.address);
    console.log("User Crt Balance is:", crtBalance);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });