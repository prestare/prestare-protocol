import { ethers, Signer, BigNumber, Contract } from 'ethers';
import { getCounterAssetInfo, getVariableDebtTokenContract, getTokenContract } from '../helpers/contracts-getter';
import { getDb } from '../helpers/utils';

import { getProvider } from '../test/connectUrl';
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractName, TokenContractName } from '../helpers/types';
import { getCounter, approveToken4Counter, getCRT } from '../helpers/contracts-helpers';
import { Counter } from '../typechain-types';
import { token } from '../typechain-types/@openzeppelin/contracts';
import { mintToken, depositToken } from './testDeposit';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

const hre: HardhatRuntimeEnvironment = require('hardhat');

export async function mintCRT(signer: SignerWithAddress, amount: string, address?: string) {
    const crt: Contract = await getCRT();
    const mintAmount = ethers.utils.parseEther(amount);
    console.log("Mint CRT...")
    const balanceT0 = await crt.balanceOf(signer.address);
    console.log("   Before mint, signer CRT balance is: ", balanceT0);
    const tx = crt.connect(signer).mint(signer.address, mintAmount);
    const balanceT1 = await crt.balanceOf(signer.address);
    console.log("   After mint, signer CRT balance is: ", balanceT1);
};

export async function borrowTokenWithCRT(tokenName: string, amount: string, crtAmount: string) {
    console.log();
    console.log("Borrow...")
    const [signer,] = await hre.ethers.getSigners();
    const counter: Counter = await getCounter(signer);
    const token: Contract = await getTokenContract(tokenName);
    const crt: Contract = await getCRT();
    const debtToken: Contract = await getVariableDebtTokenContract(tokenName);

    console.log("   Mint CRT first...");
    await mintCRT(signer, crtAmount);

    const decimals = await token.decimals();
    console.log("   Token decimals is: ", decimals);
    const balanceT0: BigNumber = await token.balanceOf(signer.address);
    console.log("   Before Borrow, borrower balance is: ", balanceT0.toString());
    const debtT0: BigNumber = await debtToken.balanceOf(signer.address);
    console.log("   Before Borrow, borrower debt balance is: ", debtT0.toString());

    const borrowAmount = ethers.utils.parseUnits(amount, decimals);
    
    let crtenable = true;
    let userConfig = await counter.getUserConfiguration(signer.address);
    console.log(userConfig);
    const tx = await counter.connect(signer).borrow(token.address, borrowAmount, 2, 0, signer.address, crtenable);
    
    const balanceT1: BigNumber = await token.balanceOf(signer.address);
    const debtT1: BigNumber = await debtToken.balanceOf(signer.address);
    console.log("   After Borrow borrower balance is: ", balanceT1.toString());
    console.log("   After Borrow, borrower debt balance is: ", debtT1.toString());

    const counterInfo = await getCounterAssetInfo(signer, token.address);
    console.log("");

}

async function main() {
    let amount = '120';
    let tokens = Object.keys(TokenContractName)

    let tokenSymbol = 'DAI';
    let crtAmount = "2000";
    await borrowTokenWithCRT(tokenSymbol, amount, crtAmount);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });