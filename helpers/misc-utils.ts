import BigNumber from 'bignumber.js';

// runtime Enviroment
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { BuidlerRuntimeEnvironment } from '@nomiclabs/buidler/types';


export let DRE: HardhatRuntimeEnvironment | BuidlerRuntimeEnvironment;

export const evmSnapshot = async () => await DRE.ethers.provider.send('evm_snapshot', []);
export const evmRevert = async (id: string) => DRE.ethers.provider.send('evm_revert', [id]);