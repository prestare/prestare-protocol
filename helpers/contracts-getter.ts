import { getCounter, getDbProperty } from './contracts-helpers';
import { getMintableERC20, getPToken } from './contracts-helpers';
import { ContractName } from './types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { Signer } from 'ethers';

const hre: HardhatRuntimeEnvironment = require('hardhat');

export const getCrtAddress =async () => {
    let crtInfo = await getDbProperty(ContractName.CRT, hre.network.name);
    return crtInfo;
}

export const getTokenAddress = async (tokenName:string) => {
    let tokenInfo = await getDbProperty(tokenName, hre.network.name);
    return tokenInfo;
}

export const getTokenContract = async (tokenName: string) => {
    let tokenAddress = (await getTokenAddress(tokenName)).address;
    let tokenContract = await getMintableERC20(tokenAddress);
    return tokenContract;
}

export const getPTokenAddress = async (tokenName:string) => {
    let pToken = 'p' + tokenName;
    let pTokenInfo = await getDbProperty(pToken, hre.network.name);
    return pTokenInfo;
}

export const getPTokenContract = async (tokenName:string) => {
    let tokenAddress = (await getPTokenAddress(tokenName)).address;
    let pTokenContract = await getPToken(tokenAddress);
    return pTokenContract;
}

export const getVariableDebtTokenAddress = async (tokenName:string) => {
    let debtToken = "variable Debt p" + tokenName;
    let debtTokenInfo = await getDbProperty(debtToken, hre.network.name);
    return debtTokenInfo;
}

export const getCounterAddress = async () => {
    let counterInfo = await getDbProperty(ContractName.Counter, hre.network.name);
    return counterInfo
}

export const getCounterAssetInfo = async (user: Signer, reserveAddress: string) => {
    let counter = await getCounter(user);
    let reserveData = await counter.getReserveData(reserveAddress);
    console.log("ReserveAddress %s", reserveAddress);
    console.log("Data");
    console.log("   Asset id is: ",  reserveData.id.toString());
    console.log("   liquidityIndex: ", reserveData.liquidityIndex.toString());
    console.log("   variableBorrowIndex: ", reserveData.variableBorrowIndex.toString());
    console.log("   currentLiquidityRate: ", reserveData.currentLiquidityRate.toString());
    console.log("   currentVariableBorrowRate: ", reserveData.currentVariableBorrowRate.toString());
    console.log("   pTokenAddress: ", reserveData.pTokenAddress.toString());
    console.log("   variableDebtTokenAddress: ", reserveData.variableDebtTokenAddress.toString());
    console.log("   interestRateStrategyAddress: ", reserveData.interestRateStrategyAddress.toString());
    console.log("");
    return reserveData;
}

