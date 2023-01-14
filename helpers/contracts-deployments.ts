import { Contract, Signer} from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { eContractid } from './types';
import { getDb } from './utils';
const hre: HardhatRuntimeEnvironment = require('hardhat');

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

export const deployCounterAddressesProvider = async (
    marketId: string, 
    admin: Signer
    ): Promise<Contract> => {
    const CounterAddressesProvider = await hre.ethers.getContractFactory('CounterAddressesProvider');
    const contract = await CounterAddressesProvider.connect(admin).deploy(marketId);
    await contract.deployed();
    await registerContractInJsonDb(eContractid.CounterAddressesProvider, contract);
    return contract
}

export const deployReserveLogic =async (admin: Signer) => {
    const ContractFac = await hre.ethers.getContractFactory("ReserveLogic");
    const contract = await ContractFac.connect(admin).deploy();
    await contract.deployed();
    await registerContractInJsonDb(eContractid.ReserveLogic, contract);
    return contract;
};

export const deployGenericLogic =async (admin: Signer) => {
    const ContractFac = await hre.ethers.getContractFactory("GenericLogic");
    const contract = await ContractFac.connect(admin).deploy();
    await contract.deployed();
    await registerContractInJsonDb(eContractid.GenericLogic, contract);
    return contract;
}

export const deployCRTLogic =async (admin: Signer) => {
    const ContractFac = await hre.ethers.getContractFactory("CRTLogic");
    const contract = await ContractFac.connect(admin).deploy();
    await contract.deployed();
    await registerContractInJsonDb(eContractid.CRTLogic, contract);
    return contract;
}

export const deployValidationLogic =async (admin: Signer, CRTLogic: Contract, genericLogic: Contract) => {
    const ContractFac = await hre.ethers.getContractFactory("ValidationLogic", {
      libraries:{
        CRTLogic: CRTLogic.address,
        GenericLogic: genericLogic.address,
      },
    });
    const contract = await ContractFac.connect(admin).deploy();
    await contract.deployed();
    await registerContractInJsonDb(eContractid.ValidationLogic, contract);
    return contract;
}

export const deployPrestareLib = async (admin: Signer) => {
  const reserveLogic = await deployReserveLogic(admin);
  const genericLogic = await deployGenericLogic(admin);
  const CRTLogic = await deployCRTLogic(admin);
  const validationLogic = await deployValidationLogic(admin, CRTLogic, genericLogic);
  return {
    "reserveLogic": reserveLogic.address,
    "genericLogic": genericLogic.address,
    "CRTLogic": CRTLogic.address,
    "validationLogic": validationLogic.address,
  }
}

export const deployCounter =async (admin: Signer) => {
  const libraries = await deployPrestareLib(admin);
  const ContractFac = await hre.ethers.getContractFactory("Counter", {
    libraries: {
      ReserveLogic: libraries.reserveLogic,
      CRTLogic: libraries.CRTLogic,
      ValidationLogic: libraries.validationLogic,
    },
  });
  const contract = await ContractFac.connect(admin).deploy();
  await contract.deployed();
  await registerContractInJsonDb(eContractid.Counter, contract);
  return contract;
}
