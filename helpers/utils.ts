import { BigNumber, Signer, BigNumberish } from 'ethers';
import { getContractAddress } from 'ethers/lib/utils';
import low from 'lowdb';
import FileSync from 'lowdb/adapters/FileSync';
import { ZERO_ADDRESS } from './constants';
import { 
  deployPToken, 
  deployPTokenAAVE, 
  deployRateStrategy,
  deployStrategy,
  deployVariableDebtToken 
} from './contracts-deployments';
import { 
  getCounterAddressesProvider, 
  getCounter, 
  rawInsertContractAddressInDb,
  getContractAddressWithJsonFallback,
  getCounterConfigurator
} from './contracts-helpers';
import { 
  TokenMap,
  IReserveParams,
  IInterestRateStrategyParams
} from './types';
import {
  getPlatformInterestRateModel,
  getStrategyAddress
} from './contracts-getter';
export const getDb = () => low(new FileSync('./deployed-contracts.json'));

export const getAllTokenAddresses = (mockTokens: TokenMap) =>
  Object.entries(mockTokens).reduce(
    (accum: { [tokenSymbol: string]: string }, [tokenSymbol, tokenContract]) => ({
      ...accum,
      [tokenSymbol]: tokenContract.address,
    }),
    {}
);

export const getQuoteCurrencies = (oracleQuoteCurrency: string): string[] => {
  switch (oracleQuoteCurrency) {
    case 'USD':
      return ['USD'];
    case 'ETH':
    case 'WETH':
    default:
      return ['ETH', 'WETH'];
  }
};

export const omit = <T, U extends keyof T>(obj: T, keys: U[]): Omit<T, U> =>
  (Object.keys(obj) as U[]).reduce(
    (acc, curr) => (keys.includes(curr) ? acc : { ...acc, [curr]: obj[curr] }),
    {} as Omit<T, U>
);

export const getPairsTokenAggregator = (
  allAssetsAddresses: {
    [tokenSymbol: string]: string;
  },
  aggregatorsAddresses: { [tokenSymbol: string]: string },
  oracleQuoteCurrency: string
): [string[], string[]] => {
  const assetsWithoutQuoteCurrency = omit(
    allAssetsAddresses,
    getQuoteCurrencies(oracleQuoteCurrency)
  );

  const pairs = Object.entries(assetsWithoutQuoteCurrency).reduce<[string, string][]>(
    (acc, [tokenSymbol, tokenAddress]) => {
      const aggregatorAddressIndex = Object.keys(aggregatorsAddresses).findIndex(
        (value) => value === tokenSymbol
      );
      if (aggregatorAddressIndex >= 0) {
        const [, aggregatorAddress] = (
          Object.entries(aggregatorsAddresses) as [string, string][]
        )[aggregatorAddressIndex];
        return [...acc, [tokenAddress, aggregatorAddress]];
      }
      return acc;
    },
    []
  );

  const mappedPairs = pairs.map(([asset]) => asset);
  const mappedAggregators = pairs.map(([, source]) => source);

  return [mappedPairs, mappedAggregators];
};

export const initReservesByHelper = async (
  reservesParams:{ [key: string]: IReserveParams},
  tokenAddresses: { [symbol: string]: string },
  assetTiers: {[symbol: string]: number},
  admin: Signer,
  treasuryAddress: string,
  ) => {
  const addressProvider = await getCounterAddressesProvider();
  const aTokenIRModel = await getPlatformInterestRateModel();
  let reserveSymbols: string[] = [];
  
  let initInputParams: {
    pToken: string;
    variableDebtToken: string;
    assetRiskTier: BigNumber;
    underlyingAssetDecimals: BigNumber;
    interestRateStrategyAddress: string;
    underlyingAsset: string;
    treasury: string;
    incentivesController: string;
    underlyingAssetName: string;
    pTokenName: string;
    pTokenSymbol: string;
    variableDebtTokenName: string;
    variableDebtTokenSymbol: string;
    params: string;
  }[] = [];

  let strategyRates: [
    string, // addresses provider
    string,
    string,
    string,
    string,
  ];

  const reserves = Object.entries(reservesParams);
  let rateStrategies: Record<string, typeof strategyRates> = {};
  let strategyAddresses: Record<string, string> = {};

  for (let [symbol, params] of reserves) {
    // console.log(tokenAddresses);
    if (!tokenAddresses[symbol]) {
      console.log(`- Skipping init of ${symbol} due token address is not set at markets config`);
      continue;
    }
    const Counter = await getCounter(admin, await addressProvider.getCounter());

    const CounterReserve = await Counter.getReserveData(tokenAddresses[symbol], 2);

    if (CounterReserve.pTokenAddress !== ZERO_ADDRESS) {
      console.log(`- Skipping init of ${symbol} due is already initialized`);
      continue;
    }

    const { strategy, pToken, reserveDecimals } = params;
    // check if we have deploy the interest rate Contract
    let strategyAddress = strategyAddresses[strategy.name];
    console.log(strategy.name);
    if (!strategyAddress && strategy.name.charAt(0) != 'a') {
      console.log("null strategyAddress");
      console.log("test deployStrategy");
      console.log("deploy strategyAddress is: ", strategy.name);
      let obj = await deployStrategy(strategy as IInterestRateStrategyParams, addressProvider.address);
      console.log(obj);
      rateStrategies[strategy.name] = obj.rateStrategy;
      strategyAddresses[strategy.name] = obj.strategyAddress;
      console.log("Insert %s to db", strategy.name);
      rawInsertContractAddressInDb(strategy.name, strategyAddresses[strategy.name]);
    } else {
      strategyAddresses[strategy.name] = strategyAddress;
      console.log("strategyAddress", strategyAddress);
    }
    if (strategy.name.charAt(0) == 'a') {
      strategyAddresses[strategy.name] = aTokenIRModel.address;
      console.log("find atoken and ir address is: ", strategyAddresses[strategy.name]);
    }

    // console.log(rateStrategies);
    // if (!strategyAddresses[strategy.name] && strategy.name.charAt(0) != 'a') {
    //   const {
    //     optimalUtilizationRate,
    //     baseVariableBorrowRate,
    //     variableRateSlope1,
    //     variableRateSlope2,
    //   } = strategy as IInterestRateStrategyParams;

    //   rateStrategies[strategy.name] = [
    //     addressProvider.address,
    //     optimalUtilizationRate,
    //     baseVariableBorrowRate,
    //     variableRateSlope1,
    //     variableRateSlope2,
    //   ];
    //   strategyAddresses[strategy.name] = await deployRateStrategy(
    //     strategy.name,
    //     rateStrategies[strategy.name]
    //   );

    //   rawInsertContractAddressInDb(strategy.name, strategyAddresses[strategy.name]);
    // }
    // console.log("token is: ", symbol);
    reserveSymbols.push(symbol);
    let pTokenContract;
    let RiskSymbol = symbol + "-C";
    if (symbol.charAt(0) == 'a') {
      // console.log("find AToken ", symbol);
      pTokenContract = await deployPTokenAAVE(admin, RiskSymbol);
    } else {
      pTokenContract = await deployPToken(admin, RiskSymbol);
    }
    let variableDebtContract = await deployVariableDebtToken(admin, symbol);
    initInputParams.push({
      pToken: pTokenContract.address,
      variableDebtToken: variableDebtContract.address,
      interestRateStrategyAddress: strategyAddresses[strategy.name],
      underlyingAsset: tokenAddresses[symbol],
      treasury: treasuryAddress,
      incentivesController: ZERO_ADDRESS,
      underlyingAssetName: symbol,
      pTokenName: `p ${symbol}-C`,
      pTokenSymbol: `p${symbol}-C`,
      variableDebtTokenName: `variableDebt Prestare ${symbol}-C`,
      variableDebtTokenSymbol: `variableDebt ${symbol}-C`,
      //pTokenName: `prestare ${symbol}`,
      //pTokenSymbol: `p${symbol}`,
      //variableDebtTokenName: `variableDebt Prestare ${symbol}`,
      //variableDebtTokenSymbol: `variableDebt ${symbol}`,
      assetRiskTier: BigNumber.from(2),
      underlyingAssetDecimals: BigNumber.from(reserveDecimals),
      params: '0x10',
    });
  }
    
  console.log("finish initInputParams");
  const configurator = await getCounterConfigurator();
  for (let index = 0; index < initInputParams.length; index++) {
    // console.log("initReserve %s...",initInputParams[index]);
    await configurator.connect(admin).initReserve(initInputParams[index]);
    if (initInputParams[index].interestRateStrategyAddress == aTokenIRModel.address) {
      // console.log("%s Special interestRateStrategy", initInputParams[index].pTokenSymbol);
      let underAsset = tokenAddresses[initInputParams[index].pTokenSymbol.slice(2, -2)];
      let aTokenAddress = initInputParams[index].underlyingAsset;

      await aTokenIRModel.connect(admin).createMarket(
        underAsset,
        aTokenAddress,
        initInputParams[index].pToken,
        "5000"
      )
    }
  }
  // console.log("finish initReserve.");
};

export const upgradeReservesByHelper = async(
  reservesParams:{ [key: string]: IReserveParams},
  tokenAddresses: { [symbol: string]: string },
  assetTiers: {[symbol: string]: number},
  admin: Signer,
  treasuryAddress: string,
) => {
  const addressProvider = await getCounterAddressesProvider();
  const aTokenIRModel = await getPlatformInterestRateModel();
  let reserveSymbols: string[] = [];
  
  let upgradeInputParams: {
    pToken: string;
    variableDebtToken: string;
    assetRiskTier: BigNumber;
    underlyingAssetDecimals: BigNumber;
    interestRateStrategyAddress: string;
    underlyingAsset: string;
    treasury: string;
    incentivesController: string;
    underlyingAssetName: string;
    pTokenName: string;
    pTokenSymbol: string;
    variableDebtTokenName: string;
    variableDebtTokenSymbol: string;
    params: string;
  }[] = [];

  let strategyRates: [
    string, // addresses provider
    string,
    string,
    string,
    string,
  ];

  const reserves = Object.entries(reservesParams);
  let rateStrategies: Record<string, typeof strategyRates> = {};
  let strategyAddresses: Record<string, string> = {};
  for (let [symbol, params] of reserves) {
    // console.log(tokenAddresses);
    if (!tokenAddresses[symbol]) {
      console.log(`- Skipping init of ${symbol} due token address is not set at markets config`);
      continue;
    }
    const Counter = await getCounter(admin, await addressProvider.getCounter());
    const target = (await Counter.getAssetClass(tokenAddresses[symbol])) - 1;
    console.log("target tier is: ", target);
    let risk_tier = "C";
    if (target == 1) {
      risk_tier = "B";
    } else if (target == 0){
      risk_tier = "A";
    }
    const CounterReserve = await Counter.getReserveData(tokenAddresses[symbol], target);

    if (CounterReserve.pTokenAddress !== ZERO_ADDRESS) {
      console.log(`- Skipping init of ${symbol} due is already initialized`);
      continue;
    }

    const { strategy, pToken, reserveDecimals } = params;
    // check if we have deploy the interest rate Contract
    let strategyAddress = strategyAddresses[strategy.name];
    console.log(strategy.name);
    if (!strategyAddress && strategy.name.charAt(0) != 'a') {
      console.log("null strategyAddress");
      console.log("test deployStrategy");
      let obj = await deployStrategy(strategy as IInterestRateStrategyParams, addressProvider.address);
      console.log(obj);
      rateStrategies[strategy.name] = obj.rateStrategy;
      strategyAddresses[strategy.name] = obj.strategyAddress;
      rawInsertContractAddressInDb(strategy.name, strategyAddresses[strategy.name]);
    } else {
      strategyAddresses[strategy.name] = strategyAddress;
      console.log("strategyAddress", strategyAddress);
    }
    if (strategy.name.charAt(0) == 'a') {
      strategyAddresses[strategy.name] = aTokenIRModel.address;
      console.log("find atoken and ir address is: ", strategyAddresses[strategy.name]);
    }

    reserveSymbols.push(symbol);
    let pTokenContract;
    let symbol_riskTier: string = symbol + "-" + risk_tier;
    if (symbol_riskTier.charAt(0) == 'a') {
      // console.log("find AToken ", symbol);
      pTokenContract = await deployPTokenAAVE(admin, symbol_riskTier);
    } else {
      pTokenContract = await deployPToken(admin, symbol_riskTier);
    }
    let variableDebtContract = await deployVariableDebtToken(admin, symbol_riskTier);
    upgradeInputParams.push({
      pToken: pTokenContract.address,
      variableDebtToken: variableDebtContract.address,
      interestRateStrategyAddress: strategyAddresses[strategy.name],
      underlyingAsset: tokenAddresses[symbol],
      treasury: treasuryAddress,
      incentivesController: ZERO_ADDRESS,
      underlyingAssetName: symbol,
      pTokenName: `p ${symbol}-${risk_tier}`,
      pTokenSymbol: `p${symbol}-${risk_tier}`,
      variableDebtTokenName: `variableDebt Prestare ${symbol}-${risk_tier}`,
      variableDebtTokenSymbol: `variableDebt ${symbol}-${risk_tier}`,
      //pTokenName: `prestare ${symbol}`,
      //pTokenSymbol: `p${symbol}`,
      //variableDebtTokenName: `variableDebt Prestare ${symbol}`,
      //variableDebtTokenSymbol: `variableDebt ${symbol}`,
      assetRiskTier: BigNumber.from(2),
      underlyingAssetDecimals: BigNumber.from(reserveDecimals),
      params: '0x10',
    });
  }

  console.log("finish initInputParams");
  const configurator = await getCounterConfigurator();
  for (let index = 0; index < upgradeInputParams.length; index++) {
    // console.log("initReserve %s...",initInputParams[index]);
    await configurator.connect(admin).upgradeAssetClass(upgradeInputParams[index]);
    // if (upgradeInputParams[index].interestRateStrategyAddress == aTokenIRModel.address) {
    //   // console.log("%s Special interestRateStrategy", initInputParams[index].pTokenSymbol);
    //   let underAsset = tokenAddresses[upgradeInputParams[index].pTokenSymbol.slice(2, -2)];
    //   let aTokenAddress = upgradeInputParams[index].underlyingAsset;

    //   await aTokenIRModel.connect(admin).createMarket(
    //     underAsset,
    //     aTokenAddress,
    //     upgradeInputParams[index].pToken,
    //     "5000"
    //   )
    // }
  }

}

// configureReservesByHelper帮助设置tokenaddress中对应的assetTier
export const configureReservesByHelper =async (
  reservesParams:{ [key: string]: IReserveParams},
  tokenAddresses: { [symbol: string]: string },
  assetTiers: number,
  admin: Signer,
) => {
  console.log("configureReservesByHelper...");
  const addressProvider = await getCounterAddressesProvider();
  const tokens: string[] = [];
  const symbols: string[] = [];

  const inputParams: {
    asset: string;
    riskTier: number;
    baseLTV: BigNumberish;
    liquidationThreshold: BigNumberish;
    liquidationBonus: BigNumberish;
    reserveFactor: BigNumberish;
    borrowingEnabled: boolean;
  }[] = [];

  for (const [reserveSymbol, {
    baseLTVAsCollateral,
    liquidationBonus,
    liquidationThreshold,
    reserveFactor,
    borrowingEnabled,
  }] of Object.entries(reservesParams) as [string, IReserveParams][]) {
    if (!tokenAddresses[reserveSymbol]) {
      console.log(
        `- Skipping init of ${reserveSymbol} due token address is not set at markets config`
      );
      continue;
    }
    if (baseLTVAsCollateral === '-1') continue;

    const assetAddressIndex = Object.keys(tokenAddresses).findIndex(
      (value) => value === reserveSymbol
    );
    // var [, assetTier] = (Object.entries(assetTiers) as [string, number][])[
    //   assetAddressIndex
    // ];
    // var assetTier = 3;
    // console.log("assetTier is", assetTier);
    const [, tokenAddress] = (Object.entries(tokenAddresses) as [string, string][])[
      assetAddressIndex
    ];
    inputParams.push({
        asset: tokenAddress,
        riskTier: assetTiers,
        baseLTV: baseLTVAsCollateral,
        liquidationThreshold: liquidationThreshold,
        liquidationBonus: liquidationBonus,
        reserveFactor: reserveFactor,
        borrowingEnabled: borrowingEnabled,
      });

    tokens.push(tokenAddress);
    symbols.push(reserveSymbol);
  }

  if (tokens.length) {
    const configurator = await getCounterConfigurator();
    for (let index = 0; index < inputParams.length; index++) {
      // console.log(inputParams[index]);
      await configurator.connect(admin).configureReserveAsCollateral(
        inputParams[index].asset,
        inputParams[index].riskTier,
        inputParams[index].baseLTV,
        inputParams[index].liquidationThreshold,
        inputParams[index].liquidationBonus,
      );
      if (inputParams[index].borrowingEnabled) {
        await configurator.connect(admin).enableBorrowingOnReserve(
          inputParams[index].asset,
          inputParams[index].riskTier,
          false
        );
      }
      await configurator.setReserveFactor(inputParams[index].asset,inputParams[index].riskTier, inputParams[index].reserveFactor);
    }
    // console.log("finish configure Reserve.");
  }
}

export const enableReservesBorrowing = async (
  tokenAddresses: { [symbol: string]: string },
  assetTiers: { [symbol: string]: number},
  admin: Signer,
  ) => {
    const addressProvider = await getCounterAddressesProvider();
    const configurator = await getCounterConfigurator(await addressProvider.getCounterConfigurator())
    const reserves = Object.entries(tokenAddresses);

    for (let [symbol, address] of reserves) {
      const assetAddressIndex = Object.keys(tokenAddresses).findIndex(
        (value) => value === symbol
      );
      var [, assetTier] = (Object.entries(assetTiers) as [string, number][])[
        assetAddressIndex
      ];
      for (; assetTier <= 3; assetTier += 1) {
        console.log("Enable %s token—— %d risk tier  to be borrowed", symbol, assetTier);
        await configurator.connect(admin).enableBorrowingOnReserve(address, assetTier, false);
      }
    }
  }

export const configRiskTierByHelper = async (
  reservesParams:{ [key: string]: IReserveParams},
  tokenAddresses: { [symbol: string]: string },
  riskTiers: { [symbol: string]: number},
  admin: Signer,
) => {

}