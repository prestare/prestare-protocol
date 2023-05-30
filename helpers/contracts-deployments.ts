import { Contract, Signer, ethers} from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { ContractName, TokenContractName } from './types';
import { getDb } from './utils';
import { deployAndSave, registerContractInJsonDb } from './contracts-helpers';
import { Prestare } from './types';
import { getReservesConfigByPool } from './contracts-helpers';
import {MintableERC20} from '../typechain-types/contracts/mocks/tokens/MintableERC20';
import { 
  TokenMap,
  IReserveParams,
  IInterestRateStrategyParams
} from './types';
import { 
  getCounterAddressesProvider, 
  getCounter, 
  rawInsertContractAddressInDb,
  getContractAddressWithJsonFallback,
  getCounterConfigurator
} from './contracts-helpers';
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

    const protocolConfig = getReservesConfigByPool(Prestare.Mainnet);

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

export const deployMockAggregator = async (tokenName:string, price: string) => {
  const ContractFac = await hre.ethers.getContractFactory("MockAggregator");
  let name = ContractName.MockAggregator + "-" + tokenName;
  return deployAndSave(
    await ContractFac.deploy(price),
    name
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
      aggregators[tokenContractName] = (await deployMockAggregator(tokenContractName, price)).address;
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
    await ContractFac.connect(admin).deploy(),
    ContractName.CounterCollateralManager
  )
};

export const deployPToken = async (
  admin: Signer,
  symbol: string) => {
    const ContractFac = await hre.ethers.getContractFactory("PToken");
    return deployAndSave(
      await ContractFac.connect(admin).deploy(),
      `p${symbol}`
    )
};

export const deployPTokenAAVE = async (
  admin: Signer,
  symbol: string) => {
    const ContractFac = await hre.ethers.getContractFactory("PTokenAAVE");
    return deployAndSave(
      await ContractFac.connect(admin).deploy(),
      `p${symbol}`
    )
};

export const deployVariableDebtToken = async (
  admin: Signer,
  symbol: string) => {
    const ContractFac = await hre.ethers.getContractFactory("VariableDebtToken");
    return deployAndSave(
      await ContractFac.connect(admin).deploy(),
      `variable Debt p${symbol}`
    )
};

export const deployWETHGateway = async (args: [string]) => {
  const ContractFac = await hre.ethers.getContractFactory("WETHGateway");
  return deployAndSave(
    await ContractFac.deploy(...args),
    ContractName.WETHGateway
  )
}

export const deployCRT = async (admin: Signer) => {
  const ContractFac = await hre.ethers.getContractFactory("MockCRT");
  return deployAndSave(
    await ContractFac.connect(admin).deploy(),
    ContractName.CRT
  )
}

export const deployRateStrategy = async (
  strategyName: string,
  args: [string, string, string, string, string],
): Promise<string> => {
  switch (strategyName) {
    default:
      return await (
        await deployDefaultReserveInterestRateStrategy(args)
      ).address;
  }
};

export const deployPlatformTokenInterestRateModel = async (
  provider: string,
) => {
  const ContractFac = await hre.ethers.getContractFactory("PlatformTokenInterestRateModel");
  return deployAndSave(
    await ContractFac.deploy(provider),
    ContractName.PlatformTokenInterestRateModel
  )
};

export const deployDefaultReserveInterestRateStrategy = async (
  args: [string, string, string, string, string],
) => {
  const ContractFac = await hre.ethers.getContractFactory("DefaultReserveInterestRateStrategy");
  return deployAndSave(
    await ContractFac.deploy(...args),
    ContractName.DefaultReserveInterestRateStrategy
  )
};

export const deployStrategy = async (
  strategy: IInterestRateStrategyParams,
  addressProviderAddress: string,
) => {
  const {
    optimalUtilizationRate,
    baseVariableBorrowRate,
    variableRateSlope1,
    variableRateSlope2,
  } = strategy;

  let rateStrategy: [string, string, string, string, string] = [
    addressProviderAddress,
    optimalUtilizationRate,
    baseVariableBorrowRate,
    variableRateSlope1,
    variableRateSlope2,
  ];
  let strategyAddress = await deployRateStrategy(
    strategy.name,
    rateStrategy
  );

  rawInsertContractAddressInDb(strategy.name, strategyAddress);
  console.log(strategyAddress);
  console.log(rateStrategy);
  return {strategyAddress, rateStrategy}
};