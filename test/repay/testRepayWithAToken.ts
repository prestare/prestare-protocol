import { HardhatRuntimeEnvironment } from "hardhat/types";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers, Signer, BigNumber, Contract } from 'ethers';

import { getCounterAssetInfo, getVariableDebtTokenContract, getTokenContract, getPTokenContract } from '../../helpers/contracts-getter';

import { TokenContractName } from '../../helpers/types';
import { aDAIHolder } from "../../helpers/holder";

import { repayToken } from '../helper/operationHelper';
const hre: HardhatRuntimeEnvironment = require('hardhat');

async function main() {

    let tokens = Object.keys(TokenContractName)
    await impersonateAccount(aDAIHolder);
    const fakeSigner: SignerWithAddress = await hre.ethers.getSigner(aDAIHolder);
    

    let tokenSymbol = 'DAI';

    let repayAmount = '120';
    
    await repayToken(fakeSigner, tokenSymbol, repayAmount);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });