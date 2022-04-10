import {
    tEthereumAddress,
    iAssetBase,
    iAssetAggregatorBase,
    iMultiPoolsAssets,
    IMarketRates
} from './common';
import { LendingRateOracle } from '../typechain/LendingRateOracle';
import { MockAggregator } from '../typechain/MockAggregator';
import { PriceOracle } from '../typechain/PriceOracle';
import { waitForTx, chunk } from './misc-utils';
import { deployMockAggregator } from './contracts-deployments';
import { getStableAndVariableTokensHelper } from './contracts-getters';


export const setInitialMarketRatesInRatesOracleHelper = async (
    marketRates: iMultiPoolsAssets<IMarketRates>,
    assetsAddresses: { [x: string]: tEthereumAddress },
    lendingRateOracleInstance: LendingRateOracle,
    admin: tEthereumAddress
) => {
    // const stableAndVariableTokenHelper = await getStableAndVariableTokensHelper();
    const assetAddresses: string[] = [];
    const borrowRates: string[] = [];
    const symbols: string[] = [];
    for (const [assetSymbol, { borrowRate }] of Object.entries(marketRates) as [
        string,
        IMarketRates
    ][]) {
        const assetAddressIndex = Object.keys(assetsAddresses).findIndex(
            (value) => value === assetSymbol
        );
        const [, assetAddress] = (Object.entries(assetsAddresses) as [string, string][])[
            assetAddressIndex
        ];
        assetAddresses.push(assetAddress);
        borrowRates.push(borrowRate);
        symbols.push(assetSymbol);
    }
    // Set borrow rates per chunks
    const ratesChunks = 20;
    const chunkedTokens = chunk(assetAddresses, ratesChunks);
    const chunkedRates = chunk(borrowRates, ratesChunks);
    const chunkedSymbols = chunk(symbols, ratesChunks);

    // // Set helper as owner
    // await waitForTx(
    //     await lendingRateOracleInstance.transferOwnership(stableAndVariableTokenHelper.address)
    // );

    // console.log(`- Oracle borrow initalization in ${chunkedTokens.length} txs`);
    // for (let chunkIndex = 0; chunkIndex < chunkedTokens.length; chunkIndex++) {
    //     const tx3 = await waitForTx(
    //         await stableAndVariableTokenHelper.setOracleBorrowRates(
    //         chunkedTokens[chunkIndex],
    //         chunkedRates[chunkIndex],
    //         lendingRateOracleInstance.address
    //         )
    //     );
    //     console.log(`  - Setted Oracle Borrow Rates for: ${chunkedSymbols[chunkIndex].join(', ')}`);
    // }
    // Set back ownership
    // await waitForTx(
    //     await stableAndVariableTokenHelper.setOracleOwnership(lendingRateOracleInstance.address, admin)
    // );
};

export const setInitialAssetPricesInOracle = async (
    prices: iAssetBase<tEthereumAddress>,
    assetsAddresses: iAssetBase<tEthereumAddress>,
    priceOracleInstance: PriceOracle
) => {
    for (const [assetSymbol, price] of Object.entries(prices) as [string, string][]) {
    
        console.log("Trying for ", assetsAddresses, assetSymbol);
        
        const assetAddressIndex = Object.keys(assetsAddresses).findIndex(
        (value) => value === assetSymbol
        );
        const [, assetAddress] = (Object.entries(assetsAddresses) as [string, string][])[
            assetAddressIndex
        ];
        await waitForTx(await priceOracleInstance.setAssetPrice(assetAddress, price));
    }
};

export const deployAllMockAggregators = async (
    initialPrices: iAssetAggregatorBase<string>,
    verify?: boolean
) => {
    const aggregators: { [tokenSymbol: string]: MockAggregator } = {};
    for (const tokenContractName of Object.keys(initialPrices)) {
        if (tokenContractName !== 'ETH') {
            const priceIndex = Object.keys(initialPrices).findIndex(
            (value) => value === tokenContractName
            );
            const [, price] = (Object.entries(initialPrices) as [string, string][])[priceIndex];
            aggregators[tokenContractName] = await deployMockAggregator(price, verify);
        }
    }
    return aggregators;
};