import { HardhatRuntimeEnvironment } from "hardhat/types";
import { borrowToken } from './helper/operationHelper';
const hre: HardhatRuntimeEnvironment = require('hardhat');

async function main() {
    let amount = '10';
    const [signer,] = await hre.ethers.getSigners();

    let tokenSymbol = 'DAI';
    await borrowToken(signer, tokenSymbol, amount);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });