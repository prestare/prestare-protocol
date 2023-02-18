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
import { borrowToken } from './testBorrow';
const hre: HardhatRuntimeEnvironment = require('hardhat');

export async function repayToken(tokenName: string, amount: string) {
    console.log();
    console.log("repay %s ...", tokenName);
    let [signer,] = await hre.ethers.getSigners();
    const counter: Counter = await getCounter(signer);
    const token: Contract = await getTokenContract(tokenName);
    const debtToken: Contract = await getVariableDebtTokenContract(tokenName);

    console.log("   Contract Name is: ", await token.name());
    const decimals = await token.decimals();
    console.log("   Token decimals is: ", decimals);
    const balanceT0: BigNumber = await token.balanceOf(signer.address);
    console.log("   Before repay, borrower balance is: ", balanceT0.toString());
    const debtT0: BigNumber = await debtToken.balanceOf(signer.address);
    console.log("   Before repay, borrower debt balance is: ", debtT0.toString());

    const repayAmount = ethers.constants.MaxUint256;

    const approveTx = await approveToken4Counter(signer, token, repayAmount);

    const tx = await counter.connect(signer).repay(token.address, repayAmount, 2, signer.address);

    const balanceT1: BigNumber = await token.balanceOf(signer.address);
    const debtT1: BigNumber = await debtToken.balanceOf(signer.address);
    console.log("   After repay borrower balance is: ", balanceT1.toString());
    console.log("   After repay, borrower debt balance is: ", debtT1.toString());
    const counterInfo = await getCounterAssetInfo(signer, token.address);
    console.log("");
}

async function main() {
    let mintAmount = '1000';
    let depositAmount = '50';
    let tokens = Object.keys(TokenContractName)
    // for (let tokenSymbol of tokens) {
    //     // console.log(tokenSymbol);
    //     const [result1, result2] = await Promise.all([
    //         mintToken(tokenSymbol, mintAmount),
    //         depositToken(tokenSymbol, depositAmount),
    //     ])
    // }

    let tokenSymbol = 'DAI';
    let borrowAmount =  '10';

    // let tx = await Promise.all([borrowToken(tokenSymbol, borrowAmount)]);

    let repayAmount = '10';
    await repayToken(tokenSymbol, repayAmount);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });