import { ethers, Signer, Contract} from 'ethers';
import { verifyContract } from './etherscan-verification';
import { 
    tEthereumAddress,
    eContractid,
    PrestareCounters,
    iParamsPerCounter,
    eEthereumNetwork,
    iEthereumParamsPerNetwork,
    eNetwork,
    iParamsPerNetwork
} from './common';
import { getDb, HRE, waitForTx } from './misc-utils';

import { getEIP20Interface } from './contracts-getters';
import { usingTenderly } from './tenderly-utils';


export const registerContractInJsonDb = async (contractId: string, contractInstance: Contract) => {
    const currentNetwork = HRE.network.name;
    const MAINNET_FORK = process.env.MAINNET_FORK === 'true';
    if (MAINNET_FORK || (currentNetwork !== 'hardhat' && !currentNetwork.includes('coverage'))) {
        console.log(`*** ${contractId} ***\n`);
        console.log(`Network: ${currentNetwork}`);
        console.log(`tx: ${contractInstance.deployTransaction.hash}`);
        console.log(`contract address: ${contractInstance.address}`);
        console.log(`deployer address: ${contractInstance.deployTransaction.from}`);
        console.log(`gas price: ${contractInstance.deployTransaction.gasPrice}`);
        console.log(`gas used: ${contractInstance.deployTransaction.gasLimit}`);
        console.log(`\n******`);
        console.log();
    }

    await getDb()
    .set(`${contractId}.${currentNetwork}`, {
        address: contractInstance.address,
        deployer: contractInstance.deployTransaction.from,
    })
    .write();
}

export const convertToCurrencyDecimals = async (tokenAddress: tEthereumAddress, amount: string) => {
    const token = await getEIP20Interface(tokenAddress);
    let decimals = (await token.decimals()).toString();

    return ethers.utils.parseUnits(amount, decimals);
};


export const insertContractAddressInDb = async (id: eContractid, address: tEthereumAddress) =>
    await getDb()
    .set(`${id}.${HRE.network.name}`, {
        address,
    })
    .write();

export const rawInsertContractAddressInDb = async (id: string, address: tEthereumAddress) =>
    await getDb()
    .set(`${id}.${HRE.network.name}`, {
    address,
    })
    .write();

export const getEtherSigners = async (): Promise<Signer[]> =>
    await Promise.all(await HRE.ethers.getSigners());


export const withSaveAndVerify = async <ContractType extends Contract>(
    instance: ContractType,
    id: string,
    args: (string | string[])[],
    verify?: boolean
): Promise<ContractType> => {
    await waitForTx(instance.deployTransaction);
    await registerContractInJsonDb(id, instance);
    if (usingTenderly()) {
        console.log();
        console.log('Doing Tenderly contract verification of', id);
        await (HRE as any).tenderlyRPC.verify({
            name: id,
            address: instance.address, 
        });
        console.log(`Verified ${id} at Tenderly!`);
        console.log();
    }

    if (verify) {
        await verifyContract(instance.address, args);
    }

    return instance;
}

export const getParamPerPool = <T>({ proto }: iParamsPerCounter<T>, counter: PrestareCounters) => {
    switch (counter) {
        case PrestareCounters.proto:
            return proto
    }
}

export const getParamPerNetwork = <T>(param: iParamsPerNetwork<T>, network: eNetwork) => {
    const {
        main,
        ropsten,
        kovan,
        coverage,
        builderEvm,
        tenderly,
    } = param as iEthereumParamsPerNetwork<T>;
    const MAINNET_FORK = process.env.MAINNET_FORK === 'true';
    if (MAINNET_FORK) {
        return main;
    }

    switch (network) {
        case eEthereumNetwork.coverage:
            return coverage;
        case eEthereumNetwork.builderEvm:
            return builderEvm;
        case eEthereumNetwork.hardhat:
            return builderEvm;
        case eEthereumNetwork.kovan:
            return kovan;
        case eEthereumNetwork.ropsten:
            return ropsten;
        case eEthereumNetwork.main:
            return main;
        case eEthereumNetwork.tenderly:
            return tenderly;
    }
};
