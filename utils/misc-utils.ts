import { ContractTransaction } from 'ethers';
import BigNumber from 'bignumber.js';
import low from 'lowdb';
import FileSync from 'lowdb/adapters/FileSync'

// runtime Enviroment
import { HardhatRuntimeEnvironment } from 'hardhat/types';
// import { BuidlerRuntimeEnvironment } from '@nomiclabs/buidler/types';


export let HRE: HardhatRuntimeEnvironment;

export const getDb = () => low(new FileSync('./deployed-contracts.json'));

export const evmSnapshot = async () => await HRE.ethers.provider.send('evm_snapshot', []);
export const evmRevert = async (id: string) => HRE.ethers.provider.send('evm_revert', [id]);

export const waitForTx = async (tx: ContractTransaction) => await tx.wait(1);

export const chunk = <T>(arr: Array<T>, chunkSize: number): Array<Array<T>> => {
    return arr.reduce(
        (prevVal: any, currVal: any, currIndx: number, array: Array<T>) =>
            !(currIndx % chunkSize)
            ? prevVal.concat([array.slice(currIndx, currIndx + chunkSize)])
            : prevVal,
        []
    );
};

export const setHRE = (_HRE: HardhatRuntimeEnvironment) => {
    HRE = _HRE;
};