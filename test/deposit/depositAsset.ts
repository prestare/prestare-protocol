import { HardhatRuntimeEnvironment } from "hardhat/types";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { TokenContractName } from '../../helpers/types';
import { approveToken4Counter, getCounter } from "../../helpers/contracts-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { deployOnMainnet } from "../../scripts/deploy/deployOnMainnetFork";
import { getTokenContract } from '../../helpers/contracts-getter';
import { expect } from "chai";
import { Counter } from "../../typechain-types";

import { checkBalance, depositERC20, depositWETH, transferErc20, transferETH } from "../helper/operationHelper";
import { DAIHolder, ETHHolder, USDCHolder, aDAIHolder } from "../../helpers/holder";
import { hre } from "../../helpers/hardhat";
// not unit test, just test usage scenario
describe("check deposit on Prestare", function() {
    var counter: Counter;
    var assetToken;
    var admin: SignerWithAddress;
    var user0: SignerWithAddress;
    var user1: SignerWithAddress;
    var tokens = Object.keys(TokenContractName);
    // var tokensAddresses = Mainnet.ReserveAssetsAddress.Mainnet;
    var USDCUser: SignerWithAddress;    
    var DAIUser: SignerWithAddress;
    var ETHUser: SignerWithAddress;
    before(async () => {
        await deployOnMainnet();
        await impersonateAccount(DAIHolder);
        await impersonateAccount(aDAIHolder);
        let signers = await hre.ethers.getSigners()
        admin = signers[0];
        user0 = signers[1];
        user1 = signers[2];
        USDCUser = await hre.ethers.getSigner(USDCHolder);
        DAIUser = await hre.ethers.getSigner(DAIHolder);
        ETHUser = await hre.ethers.getSigner(ETHHolder);
        counter = await getCounter(admin);
    })

    it('deposit DAI-C to Counter',async () => {
        console.log();
        console.log("deposit DAI-C to Counter");
        let tokenSymbol = 'DAI';
        let token = await getTokenContract(tokenSymbol);
        let token_test = await token.symbol();
        expect(token_test).to.eq(tokenSymbol);

        let transferAmount = "1000";
        await transferErc20(DAIUser, user0.address, token, transferAmount);
        await checkBalance(token, user0.address);
        let depositRisk = 2;
        let userAccountData = await counter.getUserAccountData(user0.address, depositRisk);
        let depositAmount = hre.ethers.utils.parseUnits(transferAmount, 18);
        await approveToken4Counter(user0, token, transferAmount);
        await counter.connect(user0).deposit(token.address, depositRisk, depositAmount, user0.address, 0);
        userAccountData = await counter.getUserAccountData(user0.address, depositRisk);
        console.log(userAccountData);
    });

    it('deposit DAI-B to Counter',async () => {
        let tokenSymbol = 'DAI';
        let token = await getTokenContract(tokenSymbol);
        let token_test = await token.symbol();
        expect(token_test).to.eq(tokenSymbol);

        let transferAmount = "1000";
        await transferErc20(DAIUser, user0.address, token, transferAmount);
        await checkBalance(token, user0.address);
        let depositRisk = 1;
        let userAccountData = await counter.getUserAccountData(user0.address, depositRisk);
        await depositERC20(user0, tokenSymbol, depositRisk, transferAmount);
        // let depositAmount = hre.ethers.utils.parseUnits(transferAmount, 18);
        // await approveToken4Counter(user0, token, transferAmount);
        // await counter.connect(user0).deposit(token.address, depositRisk, depositAmount, user0.address, 0);
        // userAccountData = await counter.getUserAccountData(user0.address, depositRisk);
        // console.log(userAccountData);
    });

    it('deposit WETH-C to Counter when Counter is empty',async () => {
        let tokenSymbol = 'WETH';
        let token = await getTokenContract(tokenSymbol);
        let token_test = await token.symbol();
        expect(token_test).to.eq(tokenSymbol);

        let transferAmount = "1000";
        await transferETH(ETHUser, user0.address, transferAmount);
        await checkBalance(token, user0.address);
        let depositRisk = 2;
        let userAccountData = await counter.getUserAccountData(user0.address, depositRisk);
        await depositWETH(user0, depositRisk, transferAmount);
        // let depositAmount = hre.ethers.utils.parseUnits(transferAmount, 18);
        // await approveToken4Counter(user0, token, transferAmount);
        // await counter.connect(user0).deposit(token.address, depositRisk, depositAmount, user0.address, 0);
        userAccountData = await counter.getUserAccountData(user0.address, depositRisk);
        console.log(userAccountData);
    });

    it('deposit aDAI-C to Counter',async () => {
        let tokenSymbol = 'aDAI';
        let token = await getTokenContract(tokenSymbol);
        let token_test = await token.symbol();
        expect(token_test).to.eq(tokenSymbol);
        let aDAIUser = await hre.ethers.getSigner(aDAIHolder);
        let transferAmount = "100";
        await transferErc20(aDAIUser, user0.address, token, transferAmount);
        await checkBalance(token, user0.address);
        let depositRisk = 2;
        let userAccountData = await counter.getUserAccountData(user0.address, depositRisk);
        await depositERC20(user0, tokenSymbol, depositRisk, transferAmount);
        // let depositAmount = hre.ethers.utils.parseUnits(transferAmount, 18);
        // await approveToken4Counter(user0, token, transferAmount);
        // await counter.connect(user0).deposit(token.address, depositRisk, depositAmount, user0.address, 0);
        userAccountData = await counter.getUserAccountData(user0.address, depositRisk);
        console.log(userAccountData);
    });
})