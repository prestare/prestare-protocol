import { HardhatRuntimeEnvironment } from "hardhat/types";
import { TokenContractName } from '../../helpers/types';

import { repayToken } from '../helper/operationHelper';
const hre: HardhatRuntimeEnvironment = require('hardhat');

async function main() {

    let tokens = Object.keys(TokenContractName)

    let [signer,] = await hre.ethers.getSigners();

    let tokenSymbol = 'DAI';

    let repayAmount = '120';

    // await repayToken(signer, tokenSymbol, repayAmount);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });