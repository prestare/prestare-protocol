import { 
    eContractid,
    tEthereumAddress
} from './common';
import { HRE, getDb } from './misc-utils';

import { EIP20Interface__factory } from '../typechain/factories/EIP20Interface__factory';
import { CounterConfigurator__factory } from '../typechain/factories/CounterConfigurator__factory';
import { CounterAddressProvider__factory } from '../typechain/factories/CounterAddressProvider__factory';
import { PTokenAndRatesHelper__factory } from '../typechain/factories/PTokenAndRatesHelper__factory';
import { PrestareDataProvider__factory }from '../typechain/factories/PrestareDataProvider__factory';
import { Counter__factory } from '../typechain/factories/Counter__factory';
import { PToken__factory } from '../typechain/factories/PToken__factory';
import { MintableERC20__factory } from '../typechain/factories/MintableERC20__factory';
import { WETH9Mocked__factory } from '../typechain/factories/WETH9Mocked__factory';


export const getFirstSigner = async () => (await HRE.ethers.getSigners())[0];


export const getPToken = async (address?: tEthereumAddress) =>
    await PToken__factory.connect(
        address || (await getDb().get(`${eContractid.PToken}.${HRE.network.name}`).value()).address,
        await getFirstSigner()
    );

export const getMintableERC20 = async (address: tEthereumAddress) =>
    await MintableERC20__factory.connect(
        address ||
        (await getDb().get(`${eContractid.MintableERC20}.${HRE.network.name}`).value()).address,
        await getFirstSigner()
    );
export const getEIP20Interface = async (address: tEthereumAddress) => 
    await EIP20Interface__factory.connect(
        address ||
            (await getDb().get(`${eContractid.EIP20Interface}.${HRE.network.name}`).value()).address,
        await getFirstSigner()
);

export const getCounterAddressProvider = async (address?: tEthereumAddress) =>
    await CounterAddressProvider__factory.connect(
        address ||
        (await getDb().get(`${eContractid.CounterAddressProvider}.${HRE.network.name}`).value())
            .address,
        await getFirstSigner()
    );

export const getCounter = async (address?: tEthereumAddress) =>
    await Counter__factory.connect(
        address ||
        (await getDb().get(`${eContractid.Counter}.${HRE.network.name}`).value()).address,
        await getFirstSigner()
    );

export const getWETHMocked = async (address?: tEthereumAddress) =>
    await WETH9Mocked__factory.connect(
        address || (await getDb().get(`${eContractid.WETHMocked}.${HRE.network.name}`).value()).address,
        await getFirstSigner()
    );

export const getCounterConfiguratorProxy = async (address?: tEthereumAddress) => {
    return await CounterConfigurator__factory.connect(
        address ||
        (await getDb().get(`${eContractid.CounterConfigurator}.${HRE.network.name}`).value())
            .address,
        await getFirstSigner()
    );
};

export const getPairsTokenAggregator = (
    allAssetsAddresses: {
        [tokenSymbol: string]: tEthereumAddress;
    },
    aggregatorsAddresses: { [tokenSymbol: string]: tEthereumAddress }
): [string[], string[]] => {
    const { ETH, USD, WETH, ...assetsAddressesWithoutEth } = allAssetsAddresses;

    const pairs = Object.entries(assetsAddressesWithoutEth).map(([tokenSymbol, tokenAddress]) => {
      //if (true/*tokenSymbol !== 'WETH' && tokenSymbol !== 'ETH' && tokenSymbol !== 'LpWETH'*/) {
        const aggregatorAddressIndex = Object.keys(aggregatorsAddresses).findIndex(
            (value) => value === tokenSymbol
        );
        const [, aggregatorAddress] = (Object.entries(aggregatorsAddresses) as [
            string,
            tEthereumAddress
        ][])[aggregatorAddressIndex];
        return [tokenAddress, aggregatorAddress];
        //}
    }) as [string, string][];

    const mappedPairs = pairs.map(([asset]) => asset);
    const mappedAggregators = pairs.map(([, source]) => source);

    return [mappedPairs, mappedAggregators];
};

export const getStableAndVariableTokensHelper = async (address?: tEthereumAddress) =>
    // await StableAndVariableTokensHelperFactory.connect(
    //     address ||
    //     (
    //         await getDb()
    //         .get(`${eContractid.StableAndVariableTokensHelper}.${HRE.network.name}`)
    //         .value()
    //     ).address,
        await getFirstSigner();

export const getPTokensAndRatesHelper = async (address?: tEthereumAddress) =>
    await PTokenAndRatesHelper__factory.connect(
        address ||
        (await getDb().get(`${eContractid.PTokensAndRatesHelper}.${HRE.network.name}`).value())
            .address,
        await getFirstSigner()
);

export const getPrestareDataProvider = async (address?: tEthereumAddress) =>
    await PrestareDataProvider__factory.connect(
        address ||
        (await getDb().get(`${eContractid.PrestareProtocolDataProvider}.${HRE.network.name}`).value())
            .address,
        await getFirstSigner()
    );
