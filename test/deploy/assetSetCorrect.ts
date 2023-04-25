import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Contract } from "ethers";
import { TokenContractName } from '../../helpers/types';
import { getCounter } from "../../helpers/contracts-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { deployOnMainnetFork } from "../../scripts/deployOnMainnetFork";
import { getCounterAssetInfo, getVariableDebtTokenContract, getTokenContract, getPTokenContract } from '../../helpers/contracts-getter';
import { expect } from "chai";
import { Counter } from "../../typechain-types";
const hre: HardhatRuntimeEnvironment = require('hardhat');

describe("check Asset Configuration", function() {
    var counter: Counter;
    var assetToken;
    var admin: SignerWithAddress;
    var tokens = Object.keys(TokenContractName);
    before(async () => {
        await deployOnMainnetFork();
        admin = (await hre.ethers.getSigners())[0];
        counter = await getCounter(admin);
    })

    it('check if all asset had added to reserveList',async () => {
        let reserveList = await counter.getReservesList();
        console.log(reserveList);
    })

    it('check if all asset have correct Setting',async () => {
        for (let tokenSymbol of tokens) {
            console.log(tokenSymbol);
            let token = await getTokenContract(tokenSymbol);
            let pToken: Contract = await getPTokenContract(tokenSymbol);

            let testSymbol = await token.symbol();
            expect(testSymbol).to.eq(tokenSymbol);
            let reserveData = await counter.getReserveData(token.address);
            console.log(reserveData);
        }
    })
})