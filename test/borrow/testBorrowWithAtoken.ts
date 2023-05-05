import { HardhatRuntimeEnvironment } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";

import { borrowToken } from '../helper/operationHelper';
const hre: HardhatRuntimeEnvironment = require('hardhat');
import { aDAIHolder } from "../../helpers/holder";

// user should deposit atoken to Prestare first
async function main() {

    let amount = '10';
    await impersonateAccount(aDAIHolder);
    const fakeSigner: SignerWithAddress = await hre.ethers.getSigner(aDAIHolder);
    
    let tokenSymbol = 'DAI';
    await borrowToken(fakeSigner, tokenSymbol, amount);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });