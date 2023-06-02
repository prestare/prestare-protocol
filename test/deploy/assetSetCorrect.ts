import { HardhatRuntimeEnvironment } from "hardhat/types";
import { BigNumber, Contract } from "ethers";
import { TokenContractName } from '../../helpers/types';
import { getCounter } from "../../helpers/contracts-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { deployOnMainnet } from "../../scripts/deploy/deployOnMainnetFork";
import { getCounterAssetInfo, getVariableDebtTokenContract, getTokenContract, getPTokenContract } from '../../helpers/contracts-getter';
import { expect } from "chai";
import { Counter } from "../../typechain-types";
import { Mainnet } from "../../markets/mainnet";
import { DataTypes } from "../../typechain-types/contracts/interfaces/ICounter";
import { oneEther, oneRay } from "../../helpers/constants";
const hre: HardhatRuntimeEnvironment = require('hardhat');

describe("check Asset Configuration", function() {
    var counter: Counter;
    var assetToken;
    var admin: SignerWithAddress;
    var tokens = Object.keys(TokenContractName);
    var tokensAddresses =  Object.values(Mainnet.ReserveAssetsAddress.Mainnet);
    // var tokensAddresses = Mainnet.ReserveAssetsAddress.Mainnet;
    before(async () => {
        await deployOnMainnet();
        admin = (await hre.ethers.getSigners())[0];
        counter = await getCounter(admin);
    })

    // it('check if all asset had added to reserveList in order',async () => {
    //     let reserveList = await counter.getReservesList();
    //     expect(reserveList.length).to.eq(tokens.length);
    //     let index = 0;
    //     // check the reserveList is set correct and in the right order;
    //     for (var i = 1; i < reserveList.length; i++) {
    //         expect(reserveList[index]).to.eq(tokensAddresses[index + 1]);
    //         index++;
    //     }
    // })

    it('check if all asset have correct Setting',async () => {
        var index = 0;
        for (let tokenSymbol of tokens) {
            // console.log(tokenSymbol);
            let token = await getTokenContract(tokenSymbol);
            let pToken: Contract = await getPTokenContract(tokenSymbol);
            let debtToken: Contract = await getVariableDebtTokenContract(tokenSymbol);
            let testSymbol = await token.symbol();
            expect(testSymbol).to.eq(tokenSymbol);
            let reserveData: DataTypes.ReserveDataStruct = await counter.getReserveData(token.address);
            // console.log(reserveData);
            expect(reserveData.liquidityIndex).to.eq(oneRay);
            expect(reserveData.variableBorrowIndex).to.eq(oneRay);
            expect(reserveData.currentLiquidityRate).to.eq(BigNumber.from(0));
            expect(reserveData.currentVariableBorrowRate).to.eq(BigNumber.from(0));
            expect(reserveData.pTokenAddress).to.eq(pToken.address);
            expect(reserveData.variableDebtTokenAddress).to.eq(debtToken.address);
            expect(reserveData.id).to.eq(BigNumber.from(index));
            index++;
        }
    });

    
})