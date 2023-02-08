import { ethers, Signer, BigNumber, Contract } from 'ethers';
import { getCounterAddress, getTokenAddress, getTokenContract } from '../helpers/contracts-getter';
import { getDb } from '../helpers/utils';
import { deployMintableERC20 } from '../helpers/contracts-deployments';

import { getProvider } from '../test/connectUrl';
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractName, TokenContractName } from '../helpers/types';
import { getCounter, approveToken4Counter } from '../helpers/contracts-helpers';
import { Counter } from '../typechain-types';
import { token } from '../typechain-types/@openzeppelin/contracts';

const hre: HardhatRuntimeEnvironment = require('hardhat');

async function depositToken(tokenName: string, amount: string) {
    const [signer,t2,] = await hre.ethers.getSigners();
    console.log(signer.address);
    console.log(t2.address);

    const ContractFac = await hre.ethers.getContractFactory("MintableERC20");
    const contract = await ContractFac.connect(signer).deploy(tokenName, tokenName, '18');
    await contract.deployed();

    // const contract = await deployMintableERC20([tokenName, tokenName, '18'], signer);

    console.log(contract.address);
    let name = await contract.name();
    let mintTx = await contract.connect(signer).mint(amount);
    console.log(name);
    let tx = await contract.connect(signer).approve(t2.address, amount);
    const balanceAfter = await contract.allowance(signer.getAddress(), t2.address);
    console.log("   After  Approve, allowance is: ", balanceAfter.toString());
  
    console.log("finish");

}

async function main() {
    let amount = '10';
    // let tokens = Object.keys(TokenContractName)
    // for (let tokenSymbol of tokens) {
    //     // console.log(tokenSymbol);
    //     await mintToken(tokenSymbol, amount);
    // }
    await depositToken('BBB', amount);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });