import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Signer } from 'ethers';
import { deployCounterAddressesProvider } from "../helpers/contracts-deployments";
const hre: HardhatRuntimeEnvironment = require('hardhat');

async function main() {

    const admin: Signer = (await hre.ethers.getSigners())[0];
    console.log("admin is: ", admin.getAddress());

    const addressesProvider = await deployCounterAddressesProvider("Prestare Market", admin);

    await addressesProvider.setPoolAdmin(admin.getAddress());
    await addressesProvider.setEmergencyAdmin(admin.getAddress());
    
    
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });