import { HardhatRuntimeEnvironment } from "hardhat/types";
import { TokenContractName } from '../../helpers/types';
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";

const hre: HardhatRuntimeEnvironment = require('hardhat');
import { mintToken } from '../helper/operationHelper';
import { DAIHolder, ETHHolder, USDCHolder, aDAIHolder } from "../../helpers/holder";
import { checkBalance, depositERC20, depositWETH, transferErc20, transferETH } from "../helper/operationHelper";
import { getTokenContract } from '../../helpers/contracts-getter';
import { approveToken4Counter, getCounter } from "../../helpers/contracts-helpers";


async function main() {
    await impersonateAccount(DAIHolder);
    let tokenSymbol = 'DAI';
    let token = await getTokenContract(tokenSymbol);
    console.log("token address", token.address)
    let transferAmount = '200';
    let half = '100';
    let [admin,user1,] = await hre.ethers.getSigners();
    let DAIUser = await hre.ethers.getSigner(DAIHolder);
    let ETHUser = await hre.ethers.getSigner(ETHHolder);
    await checkBalance(token, DAIUser.address);
    
    // await transferETH(ETHUser, user0.address, transferAmount);

    await transferErc20(DAIUser, user1.address, token, transferAmount);
    await checkBalance(token, user1.address);
    let depositRisk = 2;
    let counter = await getCounter(admin);

    let userAccountData = await counter.getUserAccountData(user1.address, depositRisk);
    let depositAmount = hre.ethers.utils.parseUnits(transferAmount, 18);
    await approveToken4Counter(user1, token, transferAmount);
    
    await counter.connect(user1).deposit(token.address, depositRisk, depositAmount, user1.address, 0);
    userAccountData = await counter.getUserAccountData(user1.address, depositRisk);
    console.log(userAccountData);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });