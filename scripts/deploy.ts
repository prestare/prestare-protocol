import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Signer } from 'ethers';
import { 
    deployAllMockTokens,
    deployCounter, 
    deployCounterAddressesProvider,
    deployCounterConfigurator, 
    deployPriceOracle,
    deployAllMockAggregators,
    deployPrestareOracle
} from "../helpers/contracts-deployments";
import {
    getAllMockedTokens,
} from '../helpers/contracts-helpers';
import { getAllTokenAddresses, getPairsTokenAggregator, getQuoteCurrencies } from "../helpers/utils";
import { setInitialAssetPricesInOracle } from "../helpers/oracle-helpers";
import { TokenContractName } from "../helpers/types";
import { MainnetFork } from '../markets/mainnet';
const hre: HardhatRuntimeEnvironment = require('hardhat');

async function main() {

    const admin: Signer = (await hre.ethers.getSigners())[0];
    console.log("admin is: ", admin.getAddress());
    // 1. deploy addressesProvider
    const addressesProvider = await deployCounterAddressesProvider("Prestare Market", admin);

    await addressesProvider.connect(admin).setPoolAdmin(admin.getAddress());
    await addressesProvider.connect(admin).setEmergencyAdmin(admin.getAddress());
    
    // 2. deploy Counter
    const Counter = await deployCounter(admin);

    await addressesProvider.connect(admin).setCounter(Counter.address);
    const CounterAddress: string = await addressesProvider.getCounter();
    console.log("Counter is deploy to: ", CounterAddress);
    
    // 3. deploy CounterConfigurator
    const CounterConfigurator = await deployCounterConfigurator(admin);
    await addressesProvider.setCounterConfigurator(CounterConfigurator.address);
    const CounterConfiguratorAddress = await addressesProvider.getCounterConfigurator();

    console.log("CounterConfiguratorAddress is deploy to: ", CounterConfiguratorAddress);

    // 4. deploy All Mock Token
    await deployAllMockTokens(admin);
    const defaultTokenList: { [key: string]: string} = {
        ...Object.fromEntries(Object.keys(TokenContractName).map((symbol) => [symbol, '']))
    }

    const mockTokens = await getAllMockedTokens();
    const mockTokensAddress = Object.keys(mockTokens).reduce<{ [key: string]: string }>(
        (prev, curr) => {
          prev[curr] = mockTokens[curr].address;
          return prev;
        },
        defaultTokenList
      );
    
    // 5. deploy Oracle 
    const fallbackOracle = await deployPriceOracle(admin);
    await fallbackOracle.setEthUsdPrice(MainnetFork.MockUsdPriceInWei);
    await setInitialAssetPricesInOracle(MainnetFork.Mocks.AllMockAssetPrice, mockTokensAddress, fallbackOracle);
    
    const mockAggregators = await deployAllMockAggregators(MainnetFork.Mocks.AllMockAssetPrice);
    // console.log(mockAggregators);

    const allTokenAddresses = getAllTokenAddresses(mockTokens);

    const [tokens, aggregator] = getPairsTokenAggregator(
        allTokenAddresses,
        mockAggregators,
        MainnetFork.OracleQuoteUnit
    )

    console.log(tokens);
    console.log(aggregator);

    const prestareOracle = await deployPrestareOracle([
        tokens,
        aggregator,
        fallbackOracle.address,
        MainnetFork.WETH.MainnetFork,
        MainnetFork.OracleQuoteUnit,
    ]);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });