import { HardhatRuntimeEnvironment } from "hardhat/types";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber, Contract } from "ethers";
import { TokenContractName } from '../../helpers/types';
import { approveToken4Counter, getCounter } from "../../helpers/contracts-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { deployOnMainnet } from "../../scripts/deploy/deployOnMainnetFork";
import { getCounterAssetInfo, getVariableDebtTokenContract, getTokenContract, getPTokenContract } from '../../helpers/contracts-getter';
import { expect } from "chai";
import { Counter } from "../../typechain-types";
import { Mainnet } from "../../markets/mainnet";
import { DataTypes } from "../../typechain-types/contracts/interfaces/ICounter";
import { oneEther, oneRay } from "../../helpers/constants";
import { checkBalance } from "../helper/operationHelper";
import { DAIHolder, USDCHolder } from "../../helpers/holder";
const hre: HardhatRuntimeEnvironment = require('hardhat');

describe("check deposit on Prestare", function() {
    var counter: Counter;
    var assetToken;
    var admin: SignerWithAddress;
    var user0: SignerWithAddress;
    var user1: SignerWithAddress;
    var tokens = Object.keys(TokenContractName);
    // var tokensAddresses = Mainnet.ReserveAssetsAddress.Mainnet;
    var DAIUser: SignerWithAddress;
    before(async () => {
        await deployOnMainnet();
        await impersonateAccount(USDCHolder);
        let signers = await hre.ethers.getSigners()
        admin = signers[0];
        user0 = signers[1];
        user1 = signers[2];
        DAIUser = await hre.ethers.getSigner(DAIHolder);
        counter = await getCounter(admin);
        // get DAI first and deploy to 
    })


    it('deposit DAI to Counter',async () => {
        let tokenSymbol = 'DAI';
        let token = await getTokenContract(tokenSymbol);
        let token_test = await token.symbol();
        expect(token_test).to.eq(tokenSymbol);
        let transferAmount = hre.ethers.utils.parseUnits("1", await token.decimals());
        console.log("test");
        await token.connect(DAIUser).transfer(user0.address, transferAmount);
        await checkBalance(token, user0.address);

        let userAccountData = await counter.getUserAccountData(user0.address);
        await approveToken4Counter(user0, token, transferAmount);
        await counter.connect(user0).deposit(token.address, transferAmount,user0.address, 0);
        userAccountData = await counter.getUserAccountData(user0.address);
        console.log(userAccountData);
    });
    
})