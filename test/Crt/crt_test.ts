import { hre } from "../../helpers/hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";

import { Counter } from "../../typechain-types";

import { TokenContractName } from '../../helpers/types';
import { approveToken4Counter, getCounter } from "../../helpers/contracts-helpers";
import { getTokenContract } from '../../helpers/contracts-getter';

import { deployOnMainnet } from "../../scripts/deploy/deployOnMainnetFork";
import { DAIHolder, ETHHolder, USDCHolder } from "../../helpers/holder";
import { checkBalance, borrowTokenWithCRT, depositERC20, depositWETH, transferErc20, repayErc20 } from "../helper/operationHelper";

describe("test CRT Function", function() {
    var counter: Counter;
    var assetToken;
    var admin: SignerWithAddress;
    var user0: SignerWithAddress;
    var user1: SignerWithAddress;
    var tokens = Object.keys(TokenContractName);
    // var tokensAddresses = Mainnet.ReserveAssetsAddress.Mainnet;
    var USDCuser: SignerWithAddress;    
    var DAIuser: SignerWithAddress;
    var ETHuser: SignerWithAddress;
    before(async () => {
        await deployOnMainnet();
        await impersonateAccount(USDCHolder);
        let signers = await hre.ethers.getSigners()
        admin = signers[0];
        user0 = signers[1];
        user1 = signers[2];
        USDCuser = await hre.ethers.getSigner(USDCHolder);
        DAIuser = await hre.ethers.getSigner(DAIHolder);
        ETHuser = await hre.ethers.getSigner(ETHHolder);
        counter = await getCounter(admin);
        let depositAmount = "1000";
        let riskTier = 1;
        await depositERC20(USDCuser, "USDC", riskTier, depositAmount);
        depositAmount = "2000";
        await depositERC20(DAIuser, "DAI", riskTier, depositAmount);
        await depositWETH(ETHuser, riskTier, depositAmount);
    })


    it('borrow DAI from Counter',async () => {
        let tokenSymbol = 'USDC';
        let token = await getTokenContract(tokenSymbol);
        let token_test = await token.symbol();
        expect(token_test).to.eq(tokenSymbol);

        let transferAmount = "400";
        await transferErc20(USDCuser, user0.address, token, transferAmount);
        await checkBalance(token, user0.address);
        let depositRisk = 1;
        let userAccountData = await counter.getUserAccountData(user0.address, depositRisk);
        let depositAmount = hre.ethers.utils.parseUnits(transferAmount, 6);
        await approveToken4Counter(user0, token, transferAmount);
        await counter.connect(user0).deposit(token.address, depositRisk, depositAmount, user0.address, 0);

        let fakeCRTamount = '250';

        let borrowAmount = "450";
        let borrowSymbol = 'DAI';
        let borrowRisk = 1;
        await borrowTokenWithCRT(user0, borrowSymbol, borrowRisk, borrowAmount, fakeCRTamount);
        userAccountData = await counter.getUserAccountData(user0.address, borrowRisk);
        console.log(userAccountData);
    });

    it('reapy DAI',async () => {
        let repayAmount = "460";
        let repaySymbol = "DAI";
        let repayRist = 1;
        let repaytoken = await getTokenContract(repaySymbol);
        await transferErc20(DAIuser, user0.address, repaytoken, repayAmount);
        let userAccountData = await counter.getUserAccountData(user0.address, repayRist);

        await approveToken4Counter(user0, repaytoken, repayAmount);
        await repayErc20(user0, repaySymbol, repayRist, repayAmount);
        userAccountData = await counter.getUserAccountData(USDCuser.address, repayRist);
        console.log(userAccountData);
    })
})
