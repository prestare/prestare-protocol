import { HardhatRuntimeEnvironment } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";

const hre: HardhatRuntimeEnvironment = require('hardhat');
import { mintToken, mintCRT } from '../helper/operationHelper';
import { ethers } from "ethers";
import { getCRT } from "../../helpers/contracts-helpers";
// import { aDAIHolder, DAIHolder } from "../../helpers/holder";

async function main() {
    let [admin,user1,] = await hre.ethers.getSigners();
    let amount = '200';

    // await mintCRT(user1, amount);

    // let tokens = Object.keys(TokenContractName)
    // for (let tokenSymbol of tokens) {
    //     // console.log(tokenSymbol);
    //     await mintToken(tokenSymbol, amount);
    //     await depositToken(tokenSymbol, amount);
    // }

    let crtToken = await getCRT();
    let crtBalance = await crtToken.balanceOf(user1.address);

    let burnCRT = "10";
    let tokenDeci = await crtToken.decimals();
    let burnAmount = ethers.utils.parseUnits(burnCRT, tokenDeci).toString();
    let tx = await crtToken.connect(user1).burn(user1.address, burnAmount)

    crtBalance = await crtToken.balanceOf(user1.address);
    console.log("User Crt Balance is:", crtBalance);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });