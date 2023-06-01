import { HardhatRuntimeEnvironment } from "hardhat/types";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { TokenContractName } from '../../helpers/types';
import { approveToken4Counter, getCounter } from "../../helpers/contracts-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { deployOnMainnet } from "../../scripts/deploy/deployOnMainnetFork";
import { getTokenContract } from '../../helpers/contracts-getter';
import { expect } from "chai";
import { Counter } from "../../typechain-types";
import { borrowToken, checkBalance, depositToken, transferErc20 } from "../helper/operationHelper";
import { DAIHolder, USDCHolder } from "../../helpers/holder";
import { hre } from "../constant";
import { ethers } from "hardhat";

describe("borrow Asset from Prestare", function() {
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
        ETHuser = await hre.ethers.getSigner(DAIHolder);
        counter = await getCounter(admin);
        let depositAmount = "1000";
        await depositToken(USDCuser, "USDC", depositAmount);
        depositAmount = "1000";
        await depositToken(DAIuser, "DAI", depositAmount);
    })


    it('borrow DAI from Counter',async () => {

        let borrowAmount = "500";
        let borrowSymbol = 'DAI';
        await borrowToken(USDCuser, borrowSymbol, borrowAmount);
        let userAccountData = await counter.getUserAccountData(USDCuser.address);
        console.log(userAccountData);
    });
})
