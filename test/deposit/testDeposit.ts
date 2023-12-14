import { HardhatRuntimeEnvironment } from "hardhat/types";
import { TokenContractName } from '../../helpers/types';
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";

const hre: HardhatRuntimeEnvironment = require('hardhat');
import { mintToken } from '../helper/operationHelper';
import { DAIHolder, ETHHolder, USDCHolder, USDTHolder } from "../../helpers/holder";
import { checkBalance, depositERC20, depositWETH, transferErc20, transferETH } from "../helper/operationHelper";
import { getTokenContract } from '../../helpers/contracts-getter';
import { approveToken4Counter, getCounter } from "../../helpers/contracts-helpers";
import { Signer } from "ethers";
import { getCounterAddress } from "../../helpers/contracts-getter";

async function depositAll(admin:Signer) {

    let DAIUser = await hre.ethers.getSigner(DAIHolder);
    let USDCUser = await hre.ethers.getSigner(USDCHolder);
    let ETHUser = await hre.ethers.getSigner(ETHHolder);
    let USDTUser = await hre.ethers.getSigner(USDTHolder);

    await depositERC20(DAIUser, "DAI", 2, "10000");
    await depositERC20(DAIUser, "DAI", 1, "10000");
    await depositERC20(USDCUser, "USDC", 2, "10000");
    await depositERC20(USDCUser, "USDC", 1, "10000");
    await depositERC20(USDCUser, "USDC", 0, "10000");

    // await depositERC20(USDTUser, "USDT", 2, "1000");
    // await depositERC20(USDTUser, "USDT", 1, "10000");    
    // await depositERC20(USDTUser, "USDT", 0, "10000");

    // let token = await getTokenContract("USDT");
    // const approveTx = await approveToken4Counter(USDTUser, token, "10000");
    await depositWETH(ETHUser, 2, "100")
    await depositWETH(ETHUser, 1, "100")
}

async function main() {
    await impersonateAccount(DAIHolder);
    await impersonateAccount(ETHHolder);
    await impersonateAccount(USDCHolder);
    await impersonateAccount(USDTHolder);

    let [admin,user1,] = await hre.ethers.getSigners();
    console.log(user1.address)
    await depositAll(admin);

    let depositRisk = 1;
    let counter = await getCounter(admin);
    let userAccountData = await counter.getUserAccountData(user1.address, depositRisk);

    let tokenSymbol = 'DAI';
    let transferAmount = "1200";
    let token = await getTokenContract(tokenSymbol);
    let depositAmount = hre.ethers.utils.parseUnits(transferAmount, 18);
    let DAIUser = await hre.ethers.getSigner(DAIHolder);
    await transferErc20(DAIUser, user1.address, token, transferAmount);
    await checkBalance(token, user1.address);

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