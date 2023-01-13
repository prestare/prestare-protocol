import { Contract, Signer} from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { eContractid } from './types';
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
