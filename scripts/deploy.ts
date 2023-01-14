import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Signer } from 'ethers';
import { 
    deployAllMockTokens,
    deployCounter, 
    deployCounterAddressesProvider,
    deployCounterConfigurator 
} from "../helpers/contracts-deployments";
import { TokenContractName } from "../helpers/types";
const hre: HardhatRuntimeEnvironment = require('hardhat');

async function main() {

    const admin: Signer = (await hre.ethers.getSigners())[0];
    console.log("admin is: ", admin.getAddress());
    // 1. deploy addressesProvider
    // const addressesProvider = await deployCounterAddressesProvider("Prestare Market", admin);

    // await addressesProvider.connect(admin).setPoolAdmin(admin.getAddress());
    // await addressesProvider.connect(admin).setEmergencyAdmin(admin.getAddress());
    
    // // 2. deploy Counter
    // const Counter = await deployCounter(admin);

    // await addressesProvider.connect(admin).setCounter(Counter.address);
    // const CounterAddress: string = await addressesProvider.getCounter();
    // console.log("Counter is deploy to: ", CounterAddress);
    
    // // 3. deploy CounterConfigurator
    // const CounterConfigurator = await deployCounterConfigurator(admin);
    // await addressesProvider.setCounterConfigurator(CounterConfigurator.address);
    // const CounterConfiguratorAddress = await addressesProvider.getCounterConfigurator();

    // console.log("CounterConfiguratorAddress is deploy to: ", CounterConfiguratorAddress);

    // 4. deploy All Mock Token
    await deployAllMockTokens(admin);
    const defaultTokenList: { [key: string]: string} = {
        ...Object.fromEntries(Object.keys(TokenContractName).map((symbol) => [symbol, '']))
    }


    console.log(defaultTokenList);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });