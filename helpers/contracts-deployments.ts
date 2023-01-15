import { Contract, Signer, ethers} from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { ContractName, TokenContractName } from './types';
import { getDb } from './utils';
import { deployAndSave, registerContractInJsonDb } from './contracts-helpers';
import { Prestare } from './types';
import { getReservesConfigByPool } from './contracts-helpers';
import {MintableERC20} from '../typechain-types/contracts/mocks/tokens/MintableERC20';

const hre: HardhatRuntimeEnvironment = require('hardhat');


export const deployCounterAddressesProvider = async (
    marketId: string, 
    admin: Signer
    ): Promise<Contract> => {
    const ContractFac = await hre.ethers.getContractFactory('CounterAddressesProvider');
    return deployAndSave(
      await ContractFac.connect(admin).deploy(marketId),
      ContractName.CounterAddressesProvider
    )
}

export const deployReserveLogic =async (admin: Signer) => {
    const ContractFac = await hre.ethers.getContractFactory("ReserveLogic");
    return deployAndSave(
      await ContractFac.connect(admin).deploy(),
      ContractName.ReserveLogic
    )
};

export const deployGenericLogic =async (admin: Signer) => {
    const ContractFac = await hre.ethers.getContractFactory("GenericLogic");
    return deployAndSave(
      await ContractFac.connect(admin).deploy(),
      ContractName.GenericLogic
    )
}

export const deployCRTLogic =async (admin: Signer) => {
    const ContractFac = await hre.ethers.getContractFactory("CRTLogic");
    return deployAndSave(
      await ContractFac.connect(admin).deploy(),
      ContractName.CRTLogic
    )
}

export const deployValidationLogic =async (admin: Signer, CRTLogic: Contract, genericLogic: Contract) => {
    const ContractFac = await hre.ethers.getContractFactory("ValidationLogic", {
      libraries:{
        CRTLogic: CRTLogic.address,
        GenericLogic: genericLogic.address,
      },
    });
    return deployAndSave(
      await ContractFac.connect(admin).deploy(),
      ContractName.ValidationLogic
    )
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
  return deployAndSave(
    await ContractFac.connect(admin).deploy(),
    ContractName.Counter
  )
}

export const deployCounterConfigurator =async (admin: Signer) => {
    const ContractFac = await hre.ethers.getContractFactory("CounterConfigurator");
    return deployAndSave(
      await ContractFac.connect(admin).deploy(),
      ContractName.CounterConfigurator
    )
}

export const deployAllMockTokens = async (admin: Signer) => {
    const tokens: { [symbol: string]: Contract | MintableERC20} = {};

    const protocolConfig = getReservesConfigByPool(Prestare.MainnetFork);

    for (const tokenSymbol of Object.keys(TokenContractName)) {
        let decimals = '18';
        let configData = (<any>protocolConfig)[tokenSymbol];

        tokens[tokenSymbol] = await deployMintableERC20(
          [tokenSymbol, tokenSymbol, configData ? configData.reserveDecimals : decimals],
          admin
        )
        await registerContractInJsonDb(tokenSymbol.toUpperCase(), tokens[tokenSymbol]);
    }
    return tokens
}

export const deployMintableERC20 = async (
  args:[string, string, string],
  admin: Signer
): Promise<Contract> => {
    const ContractFac = await hre.ethers.getContractFactory("MintableERC20");
    return deployAndSave(
      await ContractFac.connect(admin).deploy(...args),
      ContractName.MintableERC20
    )
}

export const deployPriceOracle = async (admin:Signer) => {
  const ContractFac = await hre.ethers.getContractFactory("PriceOracle");
  return deployAndSave(
    await ContractFac.connect(admin).deploy(),
    ContractName.PriceOracle
  )
}

export const deployMockAggregator = async (price: string) => {
  const ContractFac = await hre.ethers.getContractFactory("MockAggregator");
  return deployAndSave(
    await ContractFac.deploy(price),
    ContractName.MockAggregator
  )
};

export const deployAllMockAggregators = async (
  initialPrices: { [symbol: string]: string}
) => {
  const aggregators: { [tokenSymbol: string]: string } = {};
  for (const tokenContractName of Object.keys(initialPrices)) {
    if (tokenContractName !== 'ETH') {
      const priceIndex = Object.keys(initialPrices).findIndex(
        (value) => value === tokenContractName
      );
      const [, price] = (Object.entries(initialPrices) as [string, string][])[priceIndex];
      aggregators[tokenContractName] = (await deployMockAggregator(price)).address;
    }
  }
  return aggregators;
};

export const deployPrestareOracle = async (
  args: [string[], string[], string, string, string],
) => {
  const ContractFac = await hre.ethers.getContractFactory("PrestareOracle");
  return deployAndSave(
    await ContractFac.deploy(...args),
    ContractName.PrestareOracle
  )
};

export const deployCounterCollateralManager = async (admin: Signer) => {
  const ContractFac = await hre.ethers.getContractFactory("CounterCollateralManager");
  return deployAndSave(
    await ContractFac.deploy(),
    ContractName.CounterCollateralManager
  )
};

export const deployWETHGateway = async (args: [string]) => {
  const ContractFac = await hre.ethers.getContractFactory("WETHGateway");
  return deployAndSave(
    await ContractFac.deploy(...args),
    ContractName.WETHGateway
  )
}

