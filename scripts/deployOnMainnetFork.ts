import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Signer } from 'ethers';
import { 
    deployAllMockTokens,
    deployCounter, 
    deployCounterAddressesProvider,
    deployCounterConfigurator, 
    deployPriceOracle,
    deployAllMockAggregators,
    deployPrestareOracle,
    deployCounterCollateralManager,
    deployWETHGateway,
    deployCRT,
    deployPlatformTokenInterestRateModel
} from "../helpers/contracts-deployments";
import {
    getAllMockedTokens,
    authorizeWETHGateway,
    getAllAssetTokens,
    insertAllAssetToken
} from '../helpers/contracts-helpers';
import { getAllTokenAddresses,
    getPairsTokenAggregator,
    initReservesByHelper, 
    enableReservesBorrowing,
    configureReservesByHelper
 } from "../helpers/utils";
import { setInitialAssetPricesInOracle } from "../helpers/oracle-helpers";
import { TokenContractName } from "../helpers/types";
import { MainnetFork } from '../markets/mainnet';
import { ZERO_ADDRESS } from "../helpers/constants";
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
    await Counter.connect(admin).initialize(addressesProvider.address);
    const CounterAddress: string = await addressesProvider.getCounter();
    console.log("Counter is deploy to: ", CounterAddress);
    
    // 3. deploy CounterConfigurator
    const CounterConfigurator = await deployCounterConfigurator(admin);
    await CounterConfigurator.connect(admin).initialize(addressesProvider.address)
    await addressesProvider.setCounterConfigurator(CounterConfigurator.address);
    const CounterConfiguratorAddress = await addressesProvider.getCounterConfigurator();

    console.log("CounterConfiguratorAddress is deploy to: ", CounterConfiguratorAddress);

    // 4. get All assetToken
    // await deployAllMockTokens(admin);
    await insertAllAssetToken();
    const defaultTokenList: { [key: string]: string} = {
        ...Object.fromEntries(Object.keys(TokenContractName).map((symbol) => [symbol, '']))
    }
    const ReserveAssetsAddress = MainnetFork.ReserveAssetsAddress.MainnetFork;
    console.log(ReserveAssetsAddress);
    const assetTokens = await getAllAssetTokens(ReserveAssetsAddress);
    // const mockTokensAddress = Object.keys(mockTokens).reduce<{ [key: string]: string }>(
    //     (prev, curr) => {
    //       prev[curr] = mockTokens[curr].address;
    //       return prev;
    //     },
    //     defaultTokenList
    //   );
    
    // 5. deploy Oracle 
    console.log();
    console.log("Deploy Oracle....");
    const fallbackOracle = await deployPriceOracle(admin);
    await fallbackOracle.setEthUsdPrice(MainnetFork.MockUsdPriceInWei);
    await setInitialAssetPricesInOracle(MainnetFork.Mocks.AllMockAssetPrice, ReserveAssetsAddress, fallbackOracle);
    
    console.log();
    console.log("Deploy Prestare Oracle....");
    // const mockAggregators = await deployAllMockAggregators(MainnetFork.Mocks.AllMockAssetPrice);
    const ChainlinkAggregator = MainnetFork.ChainlinkAggregator.MainnetFork;
    // console.log(mockAggregators);

    const allTokenAddresses = ReserveAssetsAddress;
    const [tokens, aggregator] = getPairsTokenAggregator(
        allTokenAddresses,
        ChainlinkAggregator,
        MainnetFork.oracleQuoteCurrency
    )

    console.log("token list: ", tokens);
    console.log("Aggregator list: ", aggregator);

    const prestareOracle = await deployPrestareOracle([
        tokens,
        aggregator,
        fallbackOracle.address,
        MainnetFork.ReserveAssetsAddress.MainnetFork.USD,
        MainnetFork.OracleQuoteUnit,
    ]);

    await addressesProvider.setPriceOracle(prestareOracle.address);

    // 6. deploy CounterCollateralManager
    console.log();
    console.log("Deploy CounterCollateralManager....");
    const collateralManager = await deployCounterCollateralManager(admin);
    await addressesProvider.setCounterCollateralManager(collateralManager.address);

    const treasuryAddress = await admin.getAddress();
    console.log(allTokenAddresses);

    // 7. deploy AToken IR model
    await deployPlatformTokenInterestRateModel(addressesProvider.address);

    // 8. deploy pToken for each asset & initialize all token
    await initReservesByHelper(
        MainnetFork.ReservesConfig,
        allTokenAddresses,
        admin,
        treasuryAddress,
    )
    await configureReservesByHelper(MainnetFork.ReservesConfig, allTokenAddresses, admin);

    // 9. WETHGateway
    // console.log("WETH is: ", [mockTokensAddress['WETH']]);
    const WETHGateway = await deployWETHGateway([ReserveAssetsAddress['WETH']]);
    console.log('WETH Gateway address is: ', WETHGateway.address);
    await authorizeWETHGateway(WETHGateway.address, CounterAddress);
    
    // 10. deploy set CRT
    const CRT = await deployCRT(admin);
    await CounterConfigurator.connect(admin).setCRT(CRT.address);
    
    await CounterConfigurator.connect(admin).setPoolPause(false);
    
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });