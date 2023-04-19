import { ethers, Signer, BigNumber, Contract } from 'ethers';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { getCounterAssetInfo, getVariableDebtTokenContract, getTokenContract, getPTokenContract } from '../../helpers/contracts-getter';
import { getCounter, approveToken4Counter, getCRT } from '../../helpers/contracts-helpers';

import { Counter } from '../../typechain-types';

export async function checkBalance(contract: Contract, address: string) {
    const tokenName = await contract.name();
    const balance = await contract.balanceOf(address);
    console.log(`   Token %s user %s`, tokenName, address);
    console.log(`   balance is %s`, balance.toString());
}

export async function mintToken(signer: SignerWithAddress, tokenName: string, amount: string) {
    console.log();
    console.log("mint %s ...", tokenName);
    // console.log("signer ETH Balance: ", await (await signer.getBalance()).toString());
    // console.log("tx2 ETH Balance: ", await (await tx2.getBalance()).toString());
    // console.log("tx3 ETH Balance: ", await (await tx3.getBalance()).toString());

    const tokenContract = await getTokenContract(tokenName);

    console.log("   Contract address is: ", tokenContract.address);
    console.log("   Contract Name is: ", await tokenContract.name());
    const decimals = await tokenContract.decimals();
    console.log("   Contract Decimals is: ", decimals.toString());
    console.log("   Before Mint: ");
    await checkBalance(tokenContract, signer.address);
    const mintAmount = ethers.utils.parseUnits(amount, decimals);
    await tokenContract.connect(signer).mint(mintAmount);
    console.log("   mint token %s success.", tokenName);

    console.log("   After Mint:");
    await checkBalance(tokenContract, signer.address);
    // const wei = ethers.utils.parseEther("1");
}

export async function depositToken(signer: SignerWithAddress,tokenName: string, amount: string) {
    console.log();
    console.log("deposit %s ...", tokenName);
    const counter: Counter = await getCounter(signer);
    const token: Contract = await getTokenContract(tokenName);
    const pToken: Contract = await getPTokenContract(tokenName);

    const name = await token.name();
    const decimals = await token.decimals();
    console.log("Token is: ", name);
    const depositAmount = ethers.utils.parseUnits(amount, decimals);
    const approveTx = await approveToken4Counter(signer, token, depositAmount);
    console.log("   Before deposit, ");
    await checkBalance(token, signer.address);
    await checkBalance(pToken, signer.address);
    const tx = await counter.deposit(token.address, depositAmount, signer.address, 0);
    console.log("   After deposit, ");
    await checkBalance(token, signer.address);
    await checkBalance(pToken, signer.address);

    const counterInfo = await getCounterAssetInfo(signer, token.address);
    console.log("");
}

export async function borrowToken(signer: SignerWithAddress,tokenName: string, amount: string) {
    console.log();
    console.log("Borrow...")
    const counter: Counter = await getCounter(signer);
    const token: Contract = await getTokenContract(tokenName);
    const debtToken: Contract = await getVariableDebtTokenContract(tokenName);

    const name = await token.name();
    const decimals = await token.decimals();
    console.log("Token is: ", name);
    console.log("   Token decimals is: ", decimals);
    console.log("   Before Borrow ");
    await checkBalance(token, signer.address);
    await checkBalance(debtToken, signer.address);

    const borrowAmount = ethers.utils.parseUnits(amount, decimals);
    
    let crtenable = false;
    let userConfig = await counter.getUserConfiguration(signer.address);
    console.log(userConfig);
    const tx = await counter.connect(signer).borrow(token.address, borrowAmount, 2, 0, signer.address, crtenable);
    console.log("   After Borrow ");
    await checkBalance(token, signer.address);
    await checkBalance(debtToken, signer.address);

    const counterInfo = await getCounterAssetInfo(signer, token.address);
    console.log("");
}

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

export async function borrowTokenWithCRT(signer: SignerWithAddress,tokenName: string, amount: string, crtAmount: string) {
    console.log();
    console.log("Borrow...")
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

export async function repayToken(signer: SignerWithAddress,tokenName: string, amount: string) {
    console.log();
    console.log("repay %s ...", tokenName);
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

    const repayApprove = ethers.constants.MaxUint256;
    const repayAmount = ethers.utils.parseUnits(amount, decimals);
    const approveTx = await approveToken4Counter(signer, token, repayApprove);

    const tx = await counter.connect(signer).repay(token.address, repayAmount, 2, signer.address);

    const balanceT1: BigNumber = await token.balanceOf(signer.address);
    const debtT1: BigNumber = await debtToken.balanceOf(signer.address);
    console.log("   After repay borrower balance is: ", balanceT1.toString());
    console.log("   After repay, borrower debt balance is: ", debtT1.toString());
    const counterInfo = await getCounterAssetInfo(signer, token.address);
    console.log("");
}
