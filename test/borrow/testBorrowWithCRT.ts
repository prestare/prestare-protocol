import { HardhatRuntimeEnvironment } from "hardhat/types";
import { TokenContractName } from '../../helpers/types';

import { borrowTokenWithCRT } from '../helper/operationHelper';
const hre: HardhatRuntimeEnvironment = require('hardhat');
async function main() {
    let amount = '120';
    let tokens = Object.keys(TokenContractName)
    const [signer,] = await hre.ethers.getSigners();

    let tokenSymbol = 'DAI';
    let crtAmount = "2000";
    await borrowTokenWithCRT(signer, tokenSymbol, amount, crtAmount);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });