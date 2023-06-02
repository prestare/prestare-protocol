import { HardhatRuntimeEnvironment } from "hardhat/types";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { TokenContractName } from '../../helpers/types';
import { approveToken4Counter, getCounter, getCounterConfigurator } from "../../helpers/contracts-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { deployOnMainnet } from "../../scripts/deploy/deployOnMainnetFork";
import { getTokenContract } from '../../helpers/contracts-getter';
import { expect } from "chai";
import { Counter } from "../../typechain-types";

import { borrowERC20, depositERC20,checkBalance, transferErc20 } from "../helper/operationHelper";
import { DAIHolder, USDCHolder } from "../../helpers/holder";
import { hre } from "../../helpers/hardhat";

describe("change asset risk tier on Prestare", function() {
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
        let riskTIer = 2;
        await depositERC20(USDCuser, "USDC", riskTIer, depositAmount);
        depositAmount = "1000";
        await depositERC20(DAIuser, "DAI", riskTIer, depositAmount);
    })


    it('degrade DAI risk Tier to 2',async () => {
        let tokenSymbol = 'DAI';
        let token = await getTokenContract(tokenSymbol);
        let token_test = await token.symbol();
        expect(token_test).to.eq(tokenSymbol);

        let configurator = await getCounterConfigurator();
        let config = await counter.getConfiguration(token.address, 1);

        let tx = await configurator.connect(admin).degradeAssetClass(token.address);
        config = await counter.getConfiguration(token.address, 1);
        console.log(config);
    });
})