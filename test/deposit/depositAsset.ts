import { HardhatRuntimeEnvironment } from "hardhat/types";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { TokenContractName } from '../../helpers/types';
import { approveToken4Counter, getCounter } from "../../helpers/contracts-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { deployOnMainnet } from "../../scripts/deploy/deployOnMainnetFork";
import { getTokenContract } from '../../helpers/contracts-getter';
import { expect } from "chai";
import { Counter } from "../../typechain-types";

import { checkBalance, transferErc20 } from "../helper/operationHelper";
import { DAIHolder, USDCHolder } from "../../helpers/holder";
import { hre } from "../../helpers/hardhat";

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
        await impersonateAccount(DAIHolder);
        let signers = await hre.ethers.getSigners()
        admin = signers[0];
        user0 = signers[1];
        user1 = signers[2];
        DAIUser = await hre.ethers.getSigner(DAIHolder);
        counter = await getCounter(admin);
    })


    it('deposit DAI-C to Counter when Counter is empty',async () => {
        let tokenSymbol = 'DAI';
        let token = await getTokenContract(tokenSymbol);
        let token_test = await token.symbol();
        expect(token_test).to.eq(tokenSymbol);

        let transferAmount = "1";
        await transferErc20(DAIUser, user0.address, token, transferAmount);
        await checkBalance(token, user0.address);

        let userAccountData = await counter.getUserAccountData(user0.address);
        let depositAmount = hre.ethers.utils.parseUnits(transferAmount, 18);
        await approveToken4Counter(user0, token, transferAmount);
        await counter.connect(user0).deposit(token.address, 2, depositAmount, user0.address, 0);
        userAccountData = await counter.getUserAccountData(user0.address);
        console.log(userAccountData);
    });

    // it('deposit DAI to Counter second time',async () => {
    //     let tokenSymbol = 'DAI';
    //     let token = await getTokenContract(tokenSymbol);
    //     let token_test = await token.symbol();
    //     expect(token_test).to.eq(tokenSymbol);

    //     let transferAmount = "2";
    //     await transferErc20(DAIUser, user0.address, token, transferAmount);
    //     await checkBalance(token, user0.address);

    //     let userAccountData = await counter.getUserAccountData(user0.address);
    //     let depositAmount = hre.ethers.utils.parseUnits("1", 18);

    //     await approveToken4Counter(user0, token, transferAmount);
    //     await counter.connect(user0).deposit(token.address, depositAmount, user0.address, 0);
    //     userAccountData = await counter.getUserAccountData(user0.address);
    //     console.log(userAccountData);
    //     await counter.connect(user0).deposit(token.address, depositAmount, user0.address, 0);
    //     userAccountData = await counter.getUserAccountData(user0.address);
    // });
})