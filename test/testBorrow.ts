import { ethers, Signer, BigNumber, Contract } from 'ethers';
import { getCounterAssetInfo, getVariableDebtTokenContract, getTokenContract } from '../helpers/contracts-getter';
import { getDb } from '../helpers/utils';

import { getProvider } from '../test/connectUrl';
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractName, TokenContractName } from '../helpers/types';
import { getCounter, approveToken4Counter } from '../helpers/contracts-helpers';
import { Counter } from '../typechain-types';
import { token } from '../typechain-types/@openzeppelin/contracts';
import { mintToken, depositToken } from './testDeposit';

const hre: HardhatRuntimeEnvironment = require('hardhat');

export async function borrowToken(tokenName: string, amount: string) {
    console.log();
    console.log("Borrow...")
    const [signer,] = await hre.ethers.getSigners();
    const counter: Counter = await getCounter(signer);
    const token: Contract = await getTokenContract(tokenName);
    const debtToken: Contract = await getVariableDebtTokenContract(tokenName);

    const decimals = await token.decimals();
    console.log("   Token decimals is: ", decimals);
    const balanceT0: BigNumber = await token.balanceOf(signer.address);
    console.log("   Before Borrow, borrower balance is: ", balanceT0.toString());
    const debtT0: BigNumber = await debtToken.balanceOf(signer.address);
    console.log("   Before Borrow, borrower debt balance is: ", debtT0.toString());

    const borrowAmount = ethers.utils.parseUnits(amount, decimals);
    
    let crtenable = false;
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
    let amount = '10';
    let tokens = Object.keys(TokenContractName)

    let tokenSymbol = 'DAI';
    await borrowToken(tokenSymbol, amount);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });