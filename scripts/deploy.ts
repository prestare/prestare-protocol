import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Signer } from 'ethers';
import { deployCounter, deployCounterAddressesProvider } from "../helpers/contracts-deployments";
import { deployContract } from "@nomiclabs/hardhat-ethers/types";
const hre: HardhatRuntimeEnvironment = require('hardhat');

async function main() {

    const admin: Signer = (await hre.ethers.getSigners())[0];
    console.log("admin is: ", admin.getAddress());

    const addressesProvider = await deployCounterAddressesProvider("Prestare Market", admin);

    await addressesProvider.connect(admin).setPoolAdmin(admin.getAddress());
    await addressesProvider.connect(admin).setEmergencyAdmin(admin.getAddress());
    
    const Counter = await deployCounter(admin);

    await addressesProvider.connect(admin).setCounter(Counter.address);
    const CounterAddress: string = await addressesProvider.getCounter();
    console.log("Counter is deploy to: ", CounterAddress);
    
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });