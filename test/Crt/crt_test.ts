import { hre } from "../../helpers/hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";

import { Counter } from "../../typechain-types";

import { TokenContractName } from '../../helpers/types';
import { getCounter } from "../../helpers/contracts-helpers";

import { deployOnMainnet } from "../../scripts/deploy/deployOnMainnetFork";
import { DAIHolder, ETHHolder, USDCHolder } from "../../helpers/holder";
import { borrowERC20, depositERC20, depositWETH } from "../helper/operationHelper";

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
        let riskTier = 2;
        await depositERC20(USDCuser, "USDC", riskTier, depositAmount);
        depositAmount = "1000";
        await depositERC20(DAIuser, "DAI", riskTier, depositAmount);
        await depositWETH(ETHuser, riskTier, depositAmount);
    })


    it('borrow DAI from Counter',async () => {

        let borrowAmount = "500";
        let borrowSymbol = 'DAI';
        let borrowRisk = 2;
        await borrowERC20(USDCuser, borrowSymbol, borrowRisk, borrowAmount);
        let userAccountData = await counter.getUserAccountData(USDCuser.address, borrowRisk);
        console.log(userAccountData);
    });
})
