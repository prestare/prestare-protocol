import { HardhatRuntimeEnvironment } from "hardhat/types";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";

import { BigNumber, Contract } from "ethers";
import { TokenContractName } from '../../helpers/types';
import { getCounter } from "../../helpers/contracts-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { deployOnMainnet } from "../../scripts/deployOnMainnetFork";
import { getCounterAssetInfo, getVariableDebtTokenContract, getTokenContract, getPTokenContract } from '../../helpers/contracts-getter';
import { expect } from "chai";
import { Counter } from "../../typechain-types";
import { Mainnet } from "../../markets/mainnet";
import { DataTypes } from "../../typechain-types/contracts/interfaces/ICounter";
import { oneRay } from "../../helpers/constants";
import { aDAIHolder, DAIHolder } from "../../helpers/holder";
import { borrowTokenWithCRT, depositToken, repayToken } from "../helper/operationHelper";
const hre: HardhatRuntimeEnvironment = require('hardhat');

describe("check borrow Configuration", function() {
    var counter: Counter;
    var assetToken;
    var admin: SignerWithAddress;
    var aDaiUser: SignerWithAddress;
    var DaiUser: SignerWithAddress;
    before(async () => {
        await deployOnMainnet();
        admin = (await hre.ethers.getSigners())[0];
        counter = await getCounter(admin);
        await impersonateAccount(aDAIHolder);
        aDaiUser = await hre.ethers.getSigner(aDAIHolder);
        await impersonateAccount(DAIHolder);
        DaiUser = await hre.ethers.getSigner(DAIHolder);
        let amount = '200';
        let half = '100';
        let tokenSymbol = 'USDC';
        await depositToken(aDaiUser, tokenSymbol, half);
        // await depositToken(signer2, tokenSymbol, half);
        tokenSymbol = 'DAI';
        await depositToken(DaiUser, tokenSymbol, amount);
    })

    it('check if user can borrow with atoken collateral',async () => {
        let tokenSymbol = 'DAI';
        let crtAmount = "200";
        let amount = '120';

        // // await borrowToken(fakeSigner, tokenSymbol, amount);
        await borrowTokenWithCRT(aDaiUser, tokenSymbol, amount, crtAmount);
        let repayAmount = '60';
        await repayToken(aDaiUser, tokenSymbol, repayAmount);
    })
})
// 1500 0000 0799 0867 5730 7101 01
// 4050 0000 4315 0685 0095 2059 1
// 3000 0000 1598 1735 1461 4202 016 calculateInterestRates - utilizationRate
// 1500 0000 0799 0867 5730 7101 01  currentVariableBorrowRate