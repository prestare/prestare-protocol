import { Mainnet } from "../markets/mainnet";
import { Contract, ethers, Signer } from "ethers";
import { ContractName, Prestare, TokenContractName } from "./types";
import { getDb } from './utils';
import { getCounterAddress } from './contracts-getter';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { Counter, Counter__factory } from "../typechain-types";
import { MintableERC20} from '../typechain-types/contracts/mocks/tokens/MintableERC20';
import { ERC20 } from "../typechain-types/contracts/CRT/openzeppelin";
import { getPlatformInterestRateModel } from "./contracts-getter";
import { checkBalance } from "../test/helper/operationHelper";

const hre: HardhatRuntimeEnvironment = require('hardhat');

export const getReservesConfigByPool = (pool: Prestare) => {
    switch (pool) {
        case Prestare.Mainnet:
            return Mainnet.ReservesConfig;
    }
}

export const getReserveAssetsAddress = (pool: Prestare) => {
  switch (pool) {
      case Prestare.Mainnet:
          return Mainnet.ReserveAssetsAddress.Mainnet;
      case Prestare.Goerli:
          return Mainnet.ReserveAssetsAddress.Goerli;
  }
}
export const registerContractInJsonDb = async (contractId: string, contractInstance: Contract) => {
    const currentNetwork = hre.network.name;
    const FORK: boolean = process.env.FORK === 'true' ? true : false;
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
  const result = getDb().get(`${contractId}.${network}`).value()
  // console.log(getDb().get(`ReserveLogic.${network}`).value());
  return result
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

export const getAllAssetTokens = async (reserveAddress: any) => {
    const tokens: {[key: string]: Contract} = await Object.keys(TokenContractName).reduce(
      async (acc, tokenSymbol) => {
        const accumulator: any = await acc;
        console.log(tokenSymbol);
        const address = reserveAddress[tokenSymbol];
        console.log(address);
        accumulator[tokenSymbol] = await getMintableERC20(address);
        return Promise.resolve(acc);
      },
      Promise.resolve({})
    );
    return tokens;
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

export const insertAllAssetToken = async (network: Prestare) => {
    const tokens: { [symbol: string]: Contract | MintableERC20} = {};

    const protocolReserveAsset = getReserveAssetsAddress(network);

    for (const tokenSymbol of Object.keys(TokenContractName)) {
        let decimals = '18';
        let assetAddress = (<any>protocolReserveAsset)[tokenSymbol];
        await rawInsertContractAddressInDb(tokenSymbol, assetAddress);
    }
};

export const getMintableERC20 = async (address: string) =>
  await (await hre.ethers.getContractFactory("MintableERC20")).attach(
    address || (
        await getDb().get(`${ContractName.MintableERC20}.${hre.network.name}`).value()
      ).address,
);

export const getStandardERC20 = async (address: string) =>
  await (await hre.ethers.getContractFactory("contracts/CRT/openzeppelin/ERC20.sol:ERC20")).attach(
    address || (
        await getDb().get(`${ContractName.MintableERC20}.${hre.network.name}`).value()
      ).address,
);

export const getPToken = async (address:string) => 
  await (await hre.ethers.getContractFactory("PToken")).attach(
    address || (
        await getDb().get(`${ContractName.PToken}.${hre.network.name}`).value()
    ).address,
);

export const getVariableDebtToken =async (address:string) =>
  await (await hre.ethers.getContractFactory("VariableDebtToken")).attach(
    address || (
      await getDb().get(`${ContractName.PToken}.${hre.network.name}`).value()
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
  // console.log(address);
  return Counter__factory.connect(
    address ||
      (
        await getDb().get(`${ContractName.Counter}.${hre.network.name}`).value()
      ).address,
    admin
  )
};

export const getCounterConfigurator = async (address?: string) => {
  return await (await hre.ethers.getContractFactory("CounterConfigurator")).attach(
    address ||
      (
        await getDb().get(`${ContractName.CounterConfigurator}.${hre.network.name}`).value()
      ).address,
  );
};

export const getCounterCollateralManager = async (address?: string) => {
  return await (await hre.ethers.getContractFactory("CounterCollateralManager")).attach(
    address || 
      (
        await getDb().get(`${ContractName.CounterCollateralManager}.${hre.network.name}`).value()
      ).address,
  )
}

export const getCRT = async (address?: string) => {
  return await (await hre.ethers.getContractFactory("MockCRT")).attach(
    address ||
      (
        await getDb().get(`${ContractName.CRT}.${hre.network.name}`).value()
      ).address,
  );
}

export const getPRS = async (address?: string) => {
  return await (await hre.ethers.getContractFactory("PRS")).attach(
    address ||
      (
        await getDb().get(`${ContractName.PRS}.${hre.network.name}`).value()
      ).address,
  );
}

export const getPrestareOracle = async (address?: string) => {
  return await (await hre.ethers.getContractFactory("PrestareOracle")).attach(
    address ||
      (
        await getDb().get(`${ContractName.PrestareOracle}.${hre.network.name}`).value()
      ).address,
  );
}

export const getATokenRateModel =async (address:string) => {
  return await (await hre.ethers.getContractFactory("PlatformTokenInterestRateModel")).attach(
    address ||
      (
        await getDb().get(`${ContractName.PlatformTokenInterestRateModel}.${hre.network.name}`).value()
      ).address,
  );
}

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


export const approveToken4Counter = async (signer: Signer, token: Contract, amount: string) => {
  const counterAddress = await getCounterAddress()
  const balanceBefore = await token.allowance(signer.getAddress(), counterAddress.address);
  console.log("token %s", token.address);
  console.log("   Before Approve, allowance is: ", balanceBefore.toString());
  // console.log(counterAddress.address);
  let approveAmount = ethers.utils.parseUnits(amount, await token.decimals());
  // console.log(approveAmount)
  await checkBalance(token, await signer.getAddress());
  console.log(counterAddress.address)
  let tx = await token.connect(signer).approve(counterAddress.address, approveAmount);
  const balanceAfter = await token.allowance(signer.getAddress(), counterAddress.address);
  console.log("   After  Approve, allowance is: ", balanceAfter.toString());
}

export const setPlatformTokenIRModel =async (admin: Signer, PoolAddress:string) => {
  const PlatformTokenIRModel = await getPlatformInterestRateModel();
  let tx = await PlatformTokenIRModel.connect(admin).setPool(PoolAddress);
}

export const getDefaultIRModel = async (address?: string) => {
  return await (await hre.ethers.getContractFactory("DefaultReserveInterestRateStrategy")).attach(
    address || 
      (
        await getDb().get(`${ContractName.DefaultReserveInterestRateStrategy}.${hre.network.name}`).value()
      ).address
  )
}