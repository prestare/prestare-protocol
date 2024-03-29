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
    deployCRT
} from "../helpers/contracts-deployments";
import {
    getAllMockedTokens,
    authorizeWETHGateway
} from '../helpers/contracts-helpers';
import { getAllTokenAddresses,
    getPairsTokenAggregator,
    initReservesByHelper, 
    enableReservesBorrowing,
    configureReservesByHelper
 } from "../helpers/utils";
import { setInitialAssetPricesInOracle } from "../helpers/oracle-helpers";
import { TokenContractName } from "../helpers/types";
import { Mainnet } from '../markets/mainnet';
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
    // console.log("Counter is deploy to: ", CounterAddress);
    
    // 3. deploy CounterConfigurator
    const CounterConfigurator = await deployCounterConfigurator(admin);
    await CounterConfigurator.connect(admin).initialize(addressesProvider.address)
    await addressesProvider.setCounterConfigurator(CounterConfigurator.address);
    const CounterConfiguratorAddress = await addressesProvider.getCounterConfigurator();

    // console.log("CounterConfiguratorAddress is deploy to: ", CounterConfiguratorAddress);

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
    await fallbackOracle.setEthUsdPrice(Mainnet.MockUsdPriceInWei);
    await setInitialAssetPricesInOracle(Mainnet.Mocks.AllMockAssetPrice, mockTokensAddress, fallbackOracle);
    
    const mockAggregators = await deployAllMockAggregators(Mainnet.Mocks.AllMockAssetPrice);
    // console.log(mockAggregators);

    const allTokenAddresses = getAllTokenAddresses(mockTokens);

    const [tokens, aggregator] = getPairsTokenAggregator(
        allTokenAddresses,
        mockAggregators,
        Mainnet.OracleQuoteUnit
    )

    console.log("token list: ", tokens);
    console.log("Aggregator list: ", aggregator);

    const prestareOracle = await deployPrestareOracle([
        tokens,
        aggregator,
        fallbackOracle.address,
        Mainnet.ReserveAssetsAddress.Mainnet.USD,
        Mainnet.OracleQuoteUnit,
    ]);

    await addressesProvider.setPriceOracle(prestareOracle.address);

    // 6. deploy CounterCollateralManager
    const collateralManager = await deployCounterCollateralManager(admin);
    await addressesProvider.setCounterCollateralManager(collateralManager.address);

    const treasuryAddress = await admin.getAddress();

    // 8. deploy pToken for each asset & initialize all token
    await initReservesByHelper(
        Mainnet.ReservesConfig,
        allTokenAddresses,
        admin,
        treasuryAddress,
    )
    await configureReservesByHelper(Mainnet.ReservesConfig, allTokenAddresses, admin);

    // 9. WETHGateway
    // console.log("WETH is: ", [mockTokensAddress['WETH']]);
    const WETHGateway = await deployWETHGateway([mockTokensAddress['WETH']]);
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