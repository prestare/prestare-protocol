import { ethers, Signer, BigNumber, Contract } from 'ethers';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { getCounterAssetInfo, getVariableDebtTokenContract, getTokenContract, getPTokenContract } from '../../helpers/contracts-getter';
import { getCounter, approveToken4Counter, getCRT, getWETHGateway } from '../../helpers/contracts-helpers';

import { Counter } from '../../typechain-types';

export async function checkBalance(contract: Contract, address: string) {
    // console.log(contract.address)
    const tokenSymbol = await contract.symbol();
    console.log(tokenSymbol)
    const balance = await contract.balanceOf(address);
    // console.log(balance)
    console.log(`   Token %s user %s`, tokenSymbol, address);
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

export const transferErc20 = async (from: Signer, to: string, token: Contract, transferAmount: string) => {
    let transfer = ethers.utils.parseUnits(transferAmount, await token.decimals());
    console.log(transfer.toString());
    let receipt = await token.connect(from).transfer(to, transfer);
    await receipt.wait();
}

export const transferETH =async (from: Signer, to: string, transferAmount: string) => {
    let transfer = ethers.utils.parseEther(transferAmount);
    let tx = {
        to: to,
        value: transfer
    }
    let receipt = await from.sendTransaction(tx);
    await receipt.wait();
}
export const constructTokenRiskName = (tokenName: string, riskTier: number) => {
    if (riskTier == 2) {
        tokenName = tokenName + "-C";
    } else if (riskTier == 1) {
        tokenName = tokenName + "-B";
    } else if (riskTier == 0) {
        tokenName = tokenName + "-A";
    }
    return tokenName;
}
export async function depositERC20(signer: SignerWithAddress, tokenName: string, riskTier: number, amount: string) {
    console.log();
    console.log("deposit %s ...", tokenName);
    const counter: Counter = await getCounter(signer);
    const token: Contract = await getTokenContract(tokenName);
    tokenName = constructTokenRiskName(tokenName, riskTier);
    const pToken: Contract = await getPTokenContract(tokenName);
    console.log(await pToken.symbol());
    const name = await token.name();
    const decimals = await token.decimals();
    console.log("Token is: ", name);
    // const approveTx = await approveToken4Counter(signer, token, amount);
    const depositAmount = ethers.utils.parseUnits(amount, decimals);
    console.log("   Before deposit, ");
    await checkBalance(token, signer.address);
    // console.log("check",pToken);
    await checkBalance(pToken, signer.address);
    const tx = await counter.connect(signer).deposit(token.address, riskTier, depositAmount, signer.address, 0);
    // await tx.wait();
    console.log("   After deposit, ");
    await checkBalance(token, signer.address);
    await checkBalance(pToken, signer.address);

    const counterInfo = await getCounterAssetInfo(signer, token.address, riskTier);
    console.log("");
}

export const depositWETH =async (signer: SignerWithAddress, riskTier: number,amount: string) => {
    console.log();
    const WETHGATEWAY: Contract = await getWETHGateway();
    const counter: Contract = await getCounter(signer);
    const depositETHAmount = ethers.utils.parseEther(amount);
    let WETHRiskName = constructTokenRiskName("WETH", riskTier);
    const pToken: Contract = await getPTokenContract(WETHRiskName);
    console.log("   Before deposit, ");
    await checkBalance(pToken, signer.address);
    await WETHGATEWAY.connect(signer).depositETH(counter.address, riskTier, signer.address, 0, {value: depositETHAmount});
    console.log("   After deposit, ");
    await checkBalance(pToken, signer.address);
}

export async function borrowERC20(signer: SignerWithAddress,tokenName: string, riskTier: number, amount: string) {
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
    const tx = await counter.connect(signer).borrow(token.address, riskTier, borrowAmount, 2, 0, signer.address, crtenable);
    console.log("   After Borrow ");
    await checkBalance(token, signer.address);
    await checkBalance(debtToken, signer.address);

    const counterInfo = await getCounterAssetInfo(signer, token.address, riskTier);
    console.log("");
}

export async function mintCRT(signer: SignerWithAddress, amount: string, address?: string) {
    const crt: Contract = await getCRT();
    const mintAmount = ethers.utils.parseUnits(amount, await crt.decimals());
    console.log("Mint CRT...")
    const balanceT0 = await crt.balanceOf(signer.address);
    console.log("   Before mint, signer CRT balance is: ", balanceT0);
    const tx = await crt.connect(signer).mint(signer.address, mintAmount);
    const balanceT1 = await crt.balanceOf(signer.address);
    console.log("   After mint, signer CRT balance is: ", balanceT1);
};

export async function borrowTokenWithCRT(signer: SignerWithAddress,tokenName: string, riskTier: number,amount: string, crtAmount: string) {
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
    const tx = await counter.connect(signer).borrow(token.address, riskTier, borrowAmount, 2, 0, signer.address, crtenable);
    
    const balanceT1: BigNumber = await token.balanceOf(signer.address);
    const debtT1: BigNumber = await debtToken.balanceOf(signer.address);
    const scaledTotalSupplyT1: BigNumber = await debtToken.scaledTotalSupply();
    const TotalSupplyT1: BigNumber = await debtToken.totalSupply();

    console.log("   After Borrow borrower balance is: ", balanceT1.toString());
    console.log("   After Borrow, borrower debt balance is: ", debtT1.toString());
    console.log("   After Borrow, scaled debt token totalSupply is: ", scaledTotalSupplyT1.toString());
    console.log("   After Borrow, debt token totalSupply is: ", TotalSupplyT1.toString());
    const counterInfo = await getCounterAssetInfo(signer, token.address, riskTier);
    console.log("");

}

export async function repayErc20(signer: SignerWithAddress,tokenName: string, riskTier:number, amount: string) {
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
    // const approveTx = await approveToken4Counter(signer, token, repayApprove);

    const tx = await counter.connect(signer).repay(token.address, riskTier, repayAmount, 2, signer.address);

    const balanceT1: BigNumber = await token.balanceOf(signer.address);
    const debtT1: BigNumber = await debtToken.balanceOf(signer.address);
    console.log("   After repay borrower balance is: ", balanceT1.toString());
    console.log("   After repay, borrower debt balance is: ", debtT1.toString());
    const counterInfo = await getCounterAssetInfo(signer, token.address, riskTier);
    console.log("");
}
