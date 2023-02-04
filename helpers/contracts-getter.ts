import { getDbProperty } from './contracts-helpers';
import { ContractName } from './types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

const hre: HardhatRuntimeEnvironment = require('hardhat');

export const getCrt =async () => {
    await getDbProperty(ContractName.CRT, hre.network.name);
}