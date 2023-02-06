import { getDbProperty } from './contracts-helpers';
import { getMintableERC20 } from './contracts-helpers';
import { ContractName } from './types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

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

export const getVariableDebtTokenAddress = async (tokenName:string) => {
    let debtToken = "variable Debt p" + tokenName;
    let debtTokenInfo = await getDbProperty(debtToken, hre.network.name);
    return debtTokenInfo;
}

export const getCounterAddress = async () => {
    let counterInfo = await getDbProperty(ContractName.Counter, hre.network.name);
    return counterInfo
}
