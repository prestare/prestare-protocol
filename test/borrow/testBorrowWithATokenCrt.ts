import { HardhatRuntimeEnvironment } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { borrowTokenWithCRT } from '../helper/operationHelper';
import { getCounterAssetInfo } from '../../helpers/contracts-getter';

const hre: HardhatRuntimeEnvironment = require('hardhat');
import { aDAIHolder } from "../../helpers/holder";

// user should deposit atoken to Prestare first
async function main() {

    let amount = '120';
    await impersonateAccount(aDAIHolder);
    const fakeSigner: SignerWithAddress = await hre.ethers.getSigner(aDAIHolder);
    
    let tokenSymbol = 'DAI';
    let crtAmount = "200";

    // // await borrowToken(fakeSigner, tokenSymbol, amount);
    await borrowTokenWithCRT(fakeSigner, tokenSymbol, amount, crtAmount);

    console.log("");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });