import { HardhatRuntimeEnvironment } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";

const hre: HardhatRuntimeEnvironment = require('hardhat');
import { mintToken, depositToken } from '../helper/operationHelper';
import { aDAIHolder, DAIHolder } from "../../helpers/holder";

async function main() {
    await impersonateAccount(aDAIHolder);
    const fakeSigner: SignerWithAddress = await hre.ethers.getSigner(aDAIHolder);
    await impersonateAccount(DAIHolder);
    const fakeSigner2: SignerWithAddress = await hre.ethers.getSigner(DAIHolder);
    let amount = '200';
    let half = '100';
    // let tokens = Object.keys(TokenContractName)
    // for (let tokenSymbol of tokens) {
    //     // console.log(tokenSymbol);
    //     await mintToken(tokenSymbol, amount);
    //     await depositToken(tokenSymbol, amount);
    // }
    let tokenSymbol = 'aDAI';
    await depositToken(fakeSigner, tokenSymbol, half);
    // await depositToken(signer2, tokenSymbol, half);
    tokenSymbol = 'DAI';
    await depositToken(fakeSigner2, tokenSymbol, amount);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });