import { ethers, Signer, BigNumber, Contract } from 'ethers';
import { getCounterAddress, getTokenAddress, getTokenContract } from '../helpers/contracts-getter';
import { getDb } from '../helpers/utils';

import { getProvider } from '../test/connectUrl';
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractName, TokenContractName } from '../helpers/types';
import { getCounter, approveToken4Counter } from '../helpers/contracts-helpers';
import { Counter } from '../typechain-types';
import { token } from '../typechain-types/@openzeppelin/contracts';

const hre: HardhatRuntimeEnvironment = require('hardhat');

async function mintToken(tokenName: string, amount: string) {
    console.log();
    console.log("mint %s ...", tokenName);
    let [signer,] = await hre.ethers.getSigners();

    const tokenContract = await getTokenContract(tokenName);

    console.log("   Contract address is: ", tokenContract.address);
    console.log("   Contract Name is: ", await tokenContract.name());
    const decimals = await tokenContract.decimals();
    console.log("   Contract Decimals is: ", decimals.toString());

    const mintAmount = ethers.utils.parseUnits(amount, decimals);
    await tokenContract.connect(signer).mint(mintAmount);
    console.log("   mint token %s success.", tokenName);

    const balanceT0: BigNumber = await tokenContract.balanceOf(signer.address);
    // const wei = ethers.utils.parseEther("1");
    console.log("   Account Balance is:", balanceT0.toString());
}

async function depositToken(tokenName: string, amount: string) {
    const [signer,] = await hre.ethers.getSigners();
    const counter: Counter = await getCounter(signer);
    const token: Contract = await getTokenContract(tokenName);

    const decimals = await token.decimals();
    console.log("Token decimals is: ", decimals);
    const depositAmount = ethers.utils.parseUnits(amount, decimals);
    // const approveTx = await approveToken4Counter(signer, token, depositAmount);

    // const tx = await counter.deposit(token.address, depositAmount, signer.address, 0);
    // console.log(tx);
}

async function main() {
    let amount = '10';
    let tokens = Object.keys(TokenContractName)
    // for (let tokenSymbol of tokens) {
    //     // console.log(tokenSymbol);
    //     await mintToken(tokenSymbol, amount);
    // }
    await depositToken('DAI', amount);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });