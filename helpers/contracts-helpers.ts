import { MainnetFork } from "../markets/mainnet";
import { Contract, ethers, Signer } from "ethers";
import { ContractName, Prestare, TokenContractName } from "./types";
import { getDb } from './utils';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

const hre: HardhatRuntimeEnvironment = require('hardhat');

export const getReservesConfigByPool = (pool: Prestare) => {
    switch (pool) {
        case Prestare.MainnetFork:
            return MainnetFork.ReserveConfig;
    }
}

export const registerContractInJsonDb = async (contractId: string, contractInstance: Contract) => {
    const currentNetwork = hre.network.name;
    const FORK = process.env.FORK;
    if (FORK || (currentNetwork !== 'hardhat' && !currentNetwork.includes('coverage'))) {
      console.log(`*** ${contractId} ***\n`);
      console.log(`Network: ${currentNetwork}`);
      console.log(`tx: ${contractInstance.deployTransaction.hash}`);
      console.log(`contract address: ${contractInstance.address}`);
      console.log(`deployer address: ${contractInstance.deployTransaction.from}`);
      console.log(`gas price: ${contractInstance.deployTransaction.gasPrice}`);
      console.log(`gas used: ${contractInstance.deployTransaction.gasLimit}`);
      console.log(`\n******`);
      console.log();
    }

    await getDb()
    .set(`${contractId}.${currentNetwork}`, {
      address: contractInstance.address,
      deployer: contractInstance.deployTransaction.from,
    })
    .write();
};

export const deployAndSave = async (
    contract: Contract,
    contractName: string,
  ): Promise<Contract> => {
    await contract.deployed();
    await registerContractInJsonDb(contractName, contract);
    return contract;
}

export const getAllMockedTokens = async () => {
    const db = getDb();
    const tokens: any = await Object.keys(TokenContractName).reduce(
      async (acc, tokenSymbol) => {
        const accumulator: any = await acc;
        const address = db.get(`${tokenSymbol.toUpperCase()}.${hre.network.name}`).value().address;
        accumulator[tokenSymbol] = await getMintableERC20(address);
        return Promise.resolve(acc);
      },
      Promise.resolve({})
    );
    return tokens;
};

export const getMintableERC20 = async (address: string) =>
  await (await hre.ethers.getContractFactory("MintableERC20")).attach(
    address || (
        await getDb().get(`${ContractName.MintableERC20}.${hre.network.name}`).value()
      ).address,
);
