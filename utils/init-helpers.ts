import {
    eContractid,
    eEthereumNetwork,
    eNetwork,
    iMultiPoolsAssets,
    IReserveParams,
    tEthereumAddress,
} from './common';
import { PrestareDataProvider } from '../typechain/PrestareDataProvider';
import { chunk, HRE, getDb, waitForTx } from './misc-utils';
import {
    getCounterAddressProvider,
    getCounterConfiguratorProxy,
    getStableAndVariableTokensHelper,
    getPTokensAndRatesHelper
} from './contracts-getters';
import { rawInsertContractAddressInDb } from './contracts-helpers';
import { BigNumber, BigNumberish, Signer } from 'ethers';
import {
    // deployDefaultReserveInterestRateStrategy,
    // deployDelegationAwarePTokenImpl,
    deployGenericPToken,
    deployGenericPTokenImpl,
    deployTestInterestRateModel,
} from './contracts-deployments';
import { ZERO_ADDRESS } from './constants';
import { isZeroAddress } from 'ethereumjs-util';
// import { DefaultReserveInterestRateStrategy, DelegationAwareAToken } from '../typechain';

export const initReservesByHelper = async (
    reservesParams: iMultiPoolsAssets<IReserveParams>,
    tokenAddresses: { [symbol: string]: tEthereumAddress },
    pTokenNamePrefix: string,
    symbolPrefix: string,
    admin: tEthereumAddress,
    treasuryAddress: tEthereumAddress,
    incentivesController: tEthereumAddress,
    verify: boolean
): Promise<BigNumber> => {
    let gasUsage = BigNumber.from('0');
    // const stableAndVariableDeployer = await getStableAndVariableTokensHelper();

    const addressProvider = await getCounterAddressProvider();

    // CHUNK CONFIGURATION
    // TODO: To be changed
    const initChunks = 1;

    // Initialize variables for future reserves initialization
    let reserveTokens: string[] = [];
    let reserveInitDecimals: string[] = [];
    let reserveSymbols: string[] = [];

    let initInputParams: {
        pTokenImpl: string;
        underlyingAssetDecimals: BigNumberish;
        interestRateStrategyAddress: string;
        underlyingAsset: string;
        treasury: string;
        incentivesController: string;
        underlyingAssetName: string;
        pTokenName: string;
        pTokenSymbol: string;
        params: string;
    }[] = [];

    let strategyRates: [
        string, // addresses provider
        string,
        string,
        string,
        string,
    ];
    let rateStrategies: Record<string, typeof strategyRates> = {};
    let strategyAddresses: Record<string, tEthereumAddress> = {};
    let strategyAddressPerAsset: Record<string, string> = {};
    let pTokenType: Record<string, string> = {};
    let delegationAwareATokenImplementationAddress = '';
    let pTokenImplementationAddress = '';

    // NOT WORKING ON MATIC, DEPLOYING INDIVIDUAL IMPLs INSTEAD
    // const tx1 = await waitForTx(
    //   await stableAndVariableDeployer.initDeployment([ZERO_ADDRESS], ["1"])
    // );
    // console.log(tx1.events);
    // tx1.events?.forEach((event, index) => {
    //   stableDebtTokenImplementationAddress = event?.args?.stableToken;
    //   variableDebtTokenImplementationAddress = event?.args?.variableToken;
    //   rawInsertContractAddressInDb(`stableDebtTokenImpl`, stableDebtTokenImplementationAddress);
    //   rawInsertContractAddressInDb(`variableDebtTokenImpl`, variableDebtTokenImplementationAddress);
    // });
    //gasUsage = gasUsage.add(tx1.gasUsed);
    // stableDebtTokenImplementationAddress = await (await deployGenericStableDebtToken()).address;
    // variableDebtTokenImplementationAddress = await (await deployGenericVariableDebtToken()).address;

    const pTokenImplementation = await deployGenericPTokenImpl(verify);
    pTokenImplementationAddress = pTokenImplementation.address;
    rawInsertContractAddressInDb(`aTokenImpl`, pTokenImplementationAddress);

    const delegatedAwareReserves = Object.entries(reservesParams).filter(
        ([_, { pTokenImpl }]) => pTokenImpl === eContractid.DelegationAwarePToken
    ) as [string, IReserveParams][];

    // if (delegatedAwareReserves.length > 0) {
    //     const delegationAwareATokenImplementation = await deployDelegationAwarePTokenImpl(verify);
    //     delegationAwareATokenImplementationAddress = delegationAwareATokenImplementation.address;
    //     rawInsertContractAddressInDb(
    //         `delegationAwareATokenImpl`,
    //         delegationAwareATokenImplementationAddress
    //     );
    // }

    const reserves = Object.entries(reservesParams).filter(
        ([_, { pTokenImpl }]) =>
        pTokenImpl === eContractid.DelegationAwarePToken || pTokenImpl === eContractid.PToken
    ) as [string, IReserveParams][];

    for (let [symbol, params] of reserves) {
        const { strategy, pTokenImpl, reserveDecimals } = params;
        const {
            optimalUtilizationRate,
            baseVariableBorrowRate,
            variableRateSlope1,
            variableRateSlope2,
        } = strategy;
        if (!strategyAddresses[strategy.name]) {
            // Strategy does not exist, create a new one
            rateStrategies[strategy.name] = [
            addressProvider.address,
            optimalUtilizationRate,
            baseVariableBorrowRate,
            variableRateSlope1,
            variableRateSlope2
            ];
            strategyAddresses[strategy.name] = (await deployTestInterestRateModel(rateStrategies[strategy.name], verify)).address;
            // This causes the last strategy to be printed twice, once under "DefaultReserveInterestRateStrategy"
            // and once under the actual `strategyASSET` key.
            rawInsertContractAddressInDb(strategy.name, strategyAddresses[strategy.name]);
        }
        strategyAddressPerAsset[symbol] = strategyAddresses[strategy.name];
        console.log('Strategy address for asset %s: %s', symbol, strategyAddressPerAsset[symbol]);
    
        if (pTokenImpl === eContractid.PToken) {
            pTokenType[symbol] = 'generic';
        } else if (pTokenImpl === eContractid.DelegationAwarePToken) {
            pTokenType[symbol] = 'delegation aware';
        }
    
        reserveInitDecimals.push(reserveDecimals);
        reserveTokens.push(tokenAddresses[symbol]);
        reserveSymbols.push(symbol);
    }

    for (let i = 0; i < reserveSymbols.length; i++) {
        let pTokenToUse: string;
        if (pTokenType[reserveSymbols[i]] === 'generic') {
            pTokenToUse = pTokenImplementationAddress;
        } else {
            pTokenToUse = delegationAwareATokenImplementationAddress;
        }
    
        initInputParams.push({
            pTokenImpl: pTokenToUse,
            underlyingAssetDecimals: reserveInitDecimals[i],
            interestRateStrategyAddress: strategyAddressPerAsset[reserveSymbols[i]],
            underlyingAsset: reserveTokens[i],
            treasury: treasuryAddress,
            incentivesController: ZERO_ADDRESS,
            underlyingAssetName: reserveSymbols[i],
            pTokenName: `${pTokenNamePrefix} ${reserveSymbols[i]}`,
            pTokenSymbol: `a${symbolPrefix}${reserveSymbols[i]}`,
            params: '0x10'
        });
    }

    // Deploy init reserves per chunks
    const chunkedSymbols = chunk(reserveSymbols, initChunks);
    const chunkedInitInputParams = chunk(initInputParams, initChunks);

    const configurator = await getCounterConfiguratorProxy();
    //await waitForTx(await addressProvider.setPoolAdmin(admin));

    console.log(`- Reserves initialization in ${chunkedInitInputParams.length} txs`);
    for (let chunkIndex = 0; chunkIndex < chunkedInitInputParams.length; chunkIndex++) {
        // console.log(`***${chunkedInitInputParams[chunkIndex][0].pTokenName}`);
        const tx3 = await waitForTx(
            await configurator.batchInitReserve(chunkedInitInputParams[chunkIndex])
        );
        console.log(`  - Reserve ready for: ${chunkedSymbols[chunkIndex].join(', ')}`);
        console.log('    * gasUsed', tx3.gasUsed.toString());
        gasUsage = gasUsage.add(tx3.gasUsed);
    }

    return gasUsage; // Deprecated
};


export const configureReservesByHelper = async (
    reservesParams: iMultiPoolsAssets<IReserveParams>,
    tokenAddresses: { [symbol: string]: tEthereumAddress },
    helpers: PrestareDataProvider,
    admin: tEthereumAddress
) => {
    const addressProvider = await getCounterAddressProvider();
    const ptokenAndRatesDeployer = await getPTokensAndRatesHelper();
    const tokens: string[] = [];
    const symbols: string[] = [];
    const baseLTVA: string[] = [];
    const liquidationThresholds: string[] = [];
    const liquidationBonuses: string[] = [];
    const reserveFactors: string[] = [];
    const stableRatesEnabled: boolean[] = [];
    const inputParams: {
        asset: string;
        baseLTV: BigNumberish;
        liquidationThreshold: BigNumberish;
        liquidationBonus: BigNumberish;
        reserveFactor: BigNumberish;
        stableBorrowingEnabled: boolean;
    }[] = [];

    for (const [
        assetSymbol,
        {
            baseLTVAsCollateral,
            liquidationBonus,
            liquidationThreshold,
            reserveFactor,
            stableBorrowRateEnabled,
        },
    ] of Object.entries(reservesParams) as [string, IReserveParams][]) {
        if (baseLTVAsCollateral === '-1') continue;

        const assetAddressIndex = Object.keys(tokenAddresses).findIndex(
            (value) => value === assetSymbol
        );
        const [, tokenAddress] = (Object.entries(tokenAddresses) as [string, string][])[
            assetAddressIndex
        ];
        const { usageAsCollateralEnabled: alreadyEnabled } = await helpers.getReserveConfigurationData(
            tokenAddress
        );
    
        if (alreadyEnabled) {
            console.log(`- Reserve ${assetSymbol} is already enabled as collateral, skipping`);
            continue;
        }
        // Push data
    
        inputParams.push({
            asset: tokenAddress,
            baseLTV: baseLTVAsCollateral,
            liquidationThreshold: liquidationThreshold,
            liquidationBonus: liquidationBonus,
            reserveFactor: reserveFactor,
            stableBorrowingEnabled: stableBorrowRateEnabled,
        });
    
        tokens.push(tokenAddress);
        symbols.push(assetSymbol);
        baseLTVA.push(baseLTVAsCollateral);
        liquidationThresholds.push(liquidationThreshold);
        liquidationBonuses.push(liquidationBonus);
        reserveFactors.push(reserveFactor);
        stableRatesEnabled.push(stableBorrowRateEnabled);
    }
    if (tokens.length) {
        // Set aTokenAndRatesDeployer as temporal admin
        await waitForTx(await addressProvider.setCounterAdmin(ptokenAndRatesDeployer.address));

        // Deploy init per chunks
        const enableChunks = 20;
        const chunkedSymbols = chunk(symbols, enableChunks);
        const chunkedInputParams = chunk(inputParams, enableChunks);
        
        console.log(`- Configure reserves in ${chunkedInputParams.length} txs`);
        for (let chunkIndex = 0; chunkIndex < chunkedInputParams.length; chunkIndex++) {
            await waitForTx(
            await ptokenAndRatesDeployer.configureReserves(chunkedInputParams[chunkIndex], {
                gasLimit: 12000000,
            })
            );
            console.log(`  - Init for: ${chunkedSymbols[chunkIndex].join(', ')}`);
        }
        // Set deployer back as admin
        await waitForTx(await addressProvider.setCounterAdmin(admin));
    }
};

export const getPairsTokenAggregator = (
    allAssetsAddresses: {
        [tokenSymbol: string]: tEthereumAddress;
    },
    aggregatorsAddresses: { [tokenSymbol: string]: tEthereumAddress }
): [string[], string[]] => {
    const { ETH, USD, WETH, ...assetsAddressesWithoutEth } = allAssetsAddresses;

    const pairs = Object.entries(assetsAddressesWithoutEth).map(([tokenSymbol, tokenAddress]) => {
        if (tokenSymbol !== 'WETH' && tokenSymbol !== 'ETH') {
            const aggregatorAddressIndex = Object.keys(aggregatorsAddresses).findIndex(
                (value) => value === tokenSymbol
            );
            const [, aggregatorAddress] = (Object.entries(aggregatorsAddresses) as [
                string,
                tEthereumAddress
            ][])[aggregatorAddressIndex];
            return [tokenAddress, aggregatorAddress];
        }
    }) as [string, string][];

    const mappedPairs = pairs.map(([asset]) => asset);
    const mappedAggregators = pairs.map(([, source]) => source);

    return [mappedPairs, mappedAggregators];
};