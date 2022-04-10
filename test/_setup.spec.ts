import rawBRE from 'hardhat';
import { Signer } from 'ethers';
import { MockContract } from 'ethereum-waffle';
import { PrestareConfig } from '../markets/prestare';
import { waitForTx, HRE } from '../utils/misc-utils';
import { ZERO_ADDRESS } from '../utils/constants';
import { initReservesByHelper, configureReservesByHelper } from '../utils/init-helpers';
import {
    setInitialAssetPricesInOracle,
    deployAllMockAggregators,
    setInitialMarketRatesInRatesOracleHelper
} from '../utils/oracle-helper';
import { 
    insertContractAddressInDb,
    getEtherSigners,
    registerContractInJsonDb,
} from '../utils/contracts-helpers';
import { 
    getCounterConfiguratorProxy,
    getPairsTokenAggregator,
    getCounter
} from '../utils/contracts-getters';
import { 
    deployMintableERC20,
    deployCounterAddressProvider,
    deployWETHMocked,
    deployCounter,
    deployCounterConfigurator,
    // deployStableAndVariableTokensHelper,
    deployPTokensAndRatesHelper,
    deployPriceOracle,
    deployLendingRateOracle,
    deployPrestareDataProvider,
} from '../utils/contracts-deployments';
import { getReservesConfigByPool, loadPoolConfig, ConfigNames, getTreasuryAddress } from '../utils/configuration';
import { MintableERC20 } from '../typechain/MintableERC20';
import { WETH9Mocked } from '../typechain/WETH9Mocked';
import { 
    PrestareCounters,
    TokenContractId,
    eContractid,
    tEthereumAddress
} from '../utils/common';
import { initializeMakeSuite } from './helper/make-suit';


const MOCK_USD_PRICE_IN_WEI = PrestareConfig.ProtocolGlobalParams.MockUsdPriceInWei;
const ALL_ASSETS_INITIAL_PRICE = PrestareConfig.Mocks.AllAssetsInitialPrices;
const MOCK_CHAINLINK_AGGREGATORS_PRICES = PrestareConfig.Mocks.AllAssetsInitialPrices;
const LENDING_RATE_ORACLE_RATES_COMMON = PrestareConfig.LendingRateOracleRatesCommon;

before(async () => {
    await rawBRE.run('set-HRE');
    const [deployer] = await getEtherSigners();
    const MAINNET_FORK = process.env.MAINNET_FORK === 'true';

    if (MAINNET_FORK) {
        await rawBRE.run('prestare:mainnet');
    } else {
        console.log('-> Deploying test environment...');
        await setUpTestEnv(deployer);
    }

    await initializeMakeSuite();
    console.log('\n***************');
    console.log('Setup and snapshot finished');
    console.log('***************\n');
});

const setUpTestEnv = async (deployer: Signer) => {
    // 计算执行时间
    console.time('setup');
    const prestareAdmin = await deployer.getAddress();

    const mockTokens = await deployMockTokens();
    console.log('mocks deployed successfully');

    const addressProvider = await deployCounterAddressProvider(PrestareConfig.MarketId);
    await waitForTx(await addressProvider.setCounterAdmin(prestareAdmin));

    // TODO: continue!!!!
    // //setting users[1] as emergency admin, which is in position 2 in the DRE addresses list
    // const addressList = await Promise.all(
    //     (await HRE.ethers.getSigners()).map((signer) => signer.getAddress())
    // );
    // await waitForTx(await addressProvider.setEmergencyAdmin(addressList[2]));

    // const addressProviderRegistry = await deployCounterAddressProviderRegistry();
    // await waitForTx(addressProviderRegistry.registerAddressProvider(addressProvider.address, 1));

    const counterImpl = await deployCounter();
    await waitForTx(await addressProvider.setCounterImpl(counterImpl.address));

    const counterAddress = await addressProvider.getCounter();
    const counterProxy = await getCounter(counterAddress);
    await insertContractAddressInDb(eContractid.Counter, counterProxy.address);
    
    const counterConfigurationImpl = await deployCounterConfigurator();
    await waitForTx(await addressProvider.setCounterConfiguratorImpl(counterConfigurationImpl.address));
    const counterConfigurationProxy = await getCounterConfiguratorProxy(await addressProvider.getCounterConfigurator());
    await insertContractAddressInDb(eContractid.CounterConfigurator, counterConfigurationProxy.address);

    // Deploy deployment helpers
    // await deployStableAndVariableTokensHelper([counterProxy.address, addressProvider.address]);
    await deployPTokensAndRatesHelper([
        counterProxy.address, 
        addressProvider.address, 
        counterConfigurationProxy.address
    ]);

    const fallbackOracle = await deployPriceOracle();
    // await waitForTx(await fallbackOracle.setEthUsdPrice(MOCK_USD_PRICE_IN_WEI));
    await setInitialAssetPricesInOracle(
        ALL_ASSETS_INITIAL_PRICE,
        {
            WETH: mockTokens.WETH.address,
            DAI: mockTokens.DAI.address,
            USDC: mockTokens.USDC.address,
            USDT: mockTokens.USDT.address,
            USD: mockTokens.USD.address,
        },
        fallbackOracle
    );

    // const mockAggregator = await deployAllMockAggregators(MOCK_CHAINLINK_AGGREGATORS_PRICES);
    console.log('Mock aggregator deployed');

    const allTokenAddresses = Object.entries(mockTokens).reduce(
        (accum: { [tokenSymbol: string]: tEthereumAddress }, [tokenSymbol, tokenContract]) => ({
            ...accum,
            [tokenSymbol]: tokenContract.address,
        }),
        {}
    );
    // const allAggregatorsAddresses = Object.entries(mockAggregator).reduce(
    //     (accum: { [tokenSymbol: string]: tEthereumAddress }, [tokenSymbol, aggregator]) => ({
    //         ...accum,
    //         [tokenSymbol]: aggregator.address,
    //     }),
    //     {}
    // );

    // const [tokens, aggregators] = getPairsTokenAggregator(allTokenAddresses, allAggregatorsAddresses);
    // await deployPrestareOracle([tokens, aggregators, fallbackOracle.address, mockTokens.WETH.address]);
    await waitForTx(await addressProvider.setPriceOracle(fallbackOracle.address));

    const rateOracle = await deployLendingRateOracle();
    await waitForTx(await addressProvider.setLendingRateOracle(rateOracle.address));

    const { USD, ...tokenAddressWithoutUsd } = allTokenAddresses;
    const allReservesAddresses = { ...tokenAddressWithoutUsd };
    // await setInitialMarketRatesInRatesOracleHelper(
    //     LENDING_RATE_ORACLE_RATES_COMMON,
    //     allReservesAddresses,
    //     rateOracle,
    //     prestareAdmin
    // );

    const reservesParams = getReservesConfigByPool(PrestareCounters.proto);
    const testHelpers = await deployPrestareDataProvider(addressProvider.address);
    // await insertContractAddressInDb(eContractid.PrestareProtocolDataProvider, testHelpers.address);
    const admin = await deployer.getAddress();

    console.log('Initialize configuration');
    const config = loadPoolConfig(ConfigNames.Prestare);

    const { PTokenNamePrefix, StableDebtTokenNamePrefix, VariableDebtTokenNamePrefix,SymbolPrefix } = config;
    const treasuryAddress = await getTreasuryAddress(config);
    await initReservesByHelper(
        reservesParams,
        allReservesAddresses,
        PTokenNamePrefix,
        SymbolPrefix,
        admin,
        treasuryAddress,
        ZERO_ADDRESS,
        false
    );
    await configureReservesByHelper(
        reservesParams,
        allReservesAddresses,
        testHelpers,
        admin
    );

    // const collateralManager = await deployCounterCollateralManager();
    // await waitForTx(await addressProvider.setCounterCollateralManager(collateralManager.address));
    // // TODO: FlashLoan and uniswapRouter
    // await deployWalletBalancerProvider();
    // const gateWay = await deployWETHGateway([mockTokens.WETH.address]);
    // await authorizeWETHGateway(gateWay.address, counterAddress);

    console.timeEnd('setup');

};

const deployMockTokens = async () => {
    const tokens: { [symbol: string]: MockContract | MintableERC20 | WETH9Mocked } = {};
    const protoConfigData = getReservesConfigByPool(PrestareCounters.proto)
    
    for (const tokenSymbol of Object.keys(TokenContractId)) {
        if (tokenSymbol === 'WETH') {
            tokens[tokenSymbol] = await deployWETHMocked();
            await registerContractInJsonDb(tokenSymbol.toUpperCase(), tokens[tokenSymbol]);
            continue;
        }
        let decimals = 18;
        let configData = (<any>protoConfigData)[tokenSymbol];

        if (!configData) {
            decimals = 18;
        }

        tokens[tokenSymbol] = await deployMintableERC20([
            tokenSymbol, 
            tokenSymbol,
            configData ? configData.reserveDecimals : 18,
        ]); 
        
        await registerContractInJsonDb(tokenSymbol.toUpperCase(), tokens[tokenSymbol]);
    }
    return tokens;
}


