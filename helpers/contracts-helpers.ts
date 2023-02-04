import { MainnetFork } from "../markets/mainnet";
import { Contract, ethers, Signer } from "ethers";
import { ContractName, Prestare, TokenContractName } from "./types";
import { getDb } from './utils';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { Counter, Counter__factory } from "../typechain-types";

const hre: HardhatRuntimeEnvironment = require('hardhat');

export const getReservesConfigByPool = (pool: Prestare) => {
    switch (pool) {
        case Prestare.MainnetFork:
            return MainnetFork.ReservesConfig;
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

export const getDbProperty = async (contractId: string, network:string) => {
  // await getDb().read();
  // console.log(network);
  // console.log(getDb().get(`${contractId}.${network}`).value());
  console.log(getDb().get(`ReserveLogic.${network}`).value());

  return 
}

export const rawInsertContractAddressInDb = async (id: string, address: string) =>
  await getDb()
    .set(`${id}.${hre.network.name}`, {
      address,
    })
    .write();

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

export const getWETHGateway = async (address?: string) =>
  await (await hre.ethers.getContractFactory("WETHGateway")).attach(
    address || (
        await getDb().get(`${ContractName.WETHGateway}.${hre.network.name}`).value()
      ).address,
  
);

export const authorizeWETHGateway = async (
  wethGateWay: string,
  Counter: string
) =>
  await (await hre.ethers.getContractFactory("WETHGateway"))
    .attach(wethGateWay)
    .authorizeCounter(Counter);

export const getCounterAddressesProvider = async (address?: string) => {
  return await (await hre.ethers.getContractFactory("CounterAddressesProvider")).attach(
    address ||
      (
        await getDb().get(`${ContractName.CounterAddressesProvider}.${hre.network.name}`).value()
      ).address,
  );
};

export const getCounter = async (admin: Signer, address?: string) => {
  console.log(address);
  return Counter__factory.connect(
    address ||
      (
        await getDb().get(`${ContractName.Counter}.${hre.network.name}`).value()
      ).address,
    admin
  )
};

export const getContractAddressWithJsonFallback = async (
  id: string,
): Promise<string> => {
  // const db = getDb();

  const contractAtDb = await getDb().get(`${id}.${hre.network.name}`).value();
  if (contractAtDb?.address) {
    return contractAtDb.address as string;
  }
  throw Error(`Missing contract address ${id} at Market config and JSON local db`);
};

export const getCounterConfigurator = async (address?: string) => {
  return await (await hre.ethers.getContractFactory("CounterConfigurator")).attach(
    address ||
      (
        await getDb().get(`${ContractName.CounterConfigurator}.${hre.network.name}`).value()
      ).address,
  );
};