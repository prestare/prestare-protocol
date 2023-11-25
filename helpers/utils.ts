import { BigNumber, Signer, BigNumberish } from 'ethers';
import { getContractAddress } from 'ethers/lib/utils';
import low from 'lowdb';
import FileSync from 'lowdb/adapters/FileSync';
import { ZERO_ADDRESS } from './constants';
import { 
  deployPToken, 
  deployPTokenAAVE, 
  deployRateStrategy,
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
  getPlatformInterestRateModel
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
  admin: Signer,
  treasuryAddress: string,
  ) => {
  const addressProvider = await getCounterAddressesProvider();
  const aTokenIRModel = await getPlatformInterestRateModel();
  let reserveSymbols: string[] = [];
  
  let initInputParams: {
    pToken: string;
    variableDebtToken: string;
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

  for (let [symbol, params] of reserves) {
    if (!tokenAddresses[symbol]) {
      console.log(`- Skipping init of ${symbol} due token address is not set at markets config`);
      continue;
    }
    const Counter = await getCounter(admin, await addressProvider.getCounter());

    const CounterReserve = await Counter.getReserveData(tokenAddresses[symbol]);

    if (CounterReserve.pTokenAddress !== ZERO_ADDRESS) {
      console.log(`- Skipping init of ${symbol} due is already initialized`);
      continue;
    }

    const { strategy, pToken, reserveDecimals } = params;

    let rateStrategies: Record<string, typeof strategyRates> = {};
    let strategyAddresses: Record<string, string> = {};
 
    strategyAddresses["aTokenrateStrategy"] = aTokenIRModel.address;
    if (!strategyAddresses[strategy.name] && strategy.name.charAt(0) != 'a') {
      const {
        optimalUtilizationRate,
        baseVariableBorrowRate,
        variableRateSlope1,
        variableRateSlope2,
      } = strategy as IInterestRateStrategyParams;

      rateStrategies[strategy.name] = [
        addressProvider.address,
        optimalUtilizationRate,
        baseVariableBorrowRate,
        variableRateSlope1,
        variableRateSlope2,
      ];
      strategyAddresses[strategy.name] = await deployRateStrategy(
        strategy.name,
        rateStrategies[strategy.name]
      );

      rawInsertContractAddressInDb(strategy.name, strategyAddresses[strategy.name]);
    }
    // console.log("token is: ", symbol);
    reserveSymbols.push(symbol);
    let pTokenContract;
    if (symbol.charAt(0) == 'a') {
      // console.log("find AToken ", symbol);
      pTokenContract = await deployPTokenAAVE(admin, symbol);
    } else {
      pTokenContract = await deployPToken(admin, symbol);
    }
    let variableDebtContract = await deployVariableDebtToken(admin, symbol);
    initInputParams.push({
      pToken: pTokenContract.address,
      variableDebtToken: variableDebtContract.address,
      underlyingAssetDecimals: BigNumber.from(reserveDecimals),
      interestRateStrategyAddress: strategyAddresses[strategy.name],
      underlyingAsset: tokenAddresses[symbol],
      treasury: treasuryAddress,
      incentivesController: ZERO_ADDRESS,
      underlyingAssetName: symbol,
      pTokenName: `prestare ${symbol}`,
      pTokenSymbol: `p${symbol}`,
      variableDebtTokenName: `variableDebt Prestare ${symbol}`,
      variableDebtTokenSymbol: `variableDebt ${symbol}`,
      params: '0x10',
    });
  }
  
  console.log("finish initInputParams");
  const configurator = await getCounterConfigurator();
  for (let index = 0; index < initInputParams.length; index++) {
    // console.log(initInputParams[index]);
    await configurator.connect(admin).initReserve(initInputParams[index]);
    if (initInputParams[index].interestRateStrategyAddress == aTokenIRModel.address) {
      // console.log("%s Special interestRateStrategy", initInputParams[index].pTokenSymbol);
      let underlyingAsset = tokenAddresses[initInputParams[index].pTokenSymbol.slice(2)];
      let aToken = initInputParams[index].underlyingAsset;
      // console.log("aToken is,", aToken);
      // console.log("underlyingAsset is", underlyingAsset);
      // console.log("initInputParams[index].pToken is", initInputParams[index].pToken)
      await aTokenIRModel.connect(admin).createMarket(
        underlyingAsset,
        aToken,
        initInputParams[index].pToken,
        "5000"
      )
    }
  }
  // console.log("finish initReserve.");
};

export const configureReservesByHelper =async (
  reservesParams:{ [key: string]: IReserveParams},
  tokenAddresses: { [symbol: string]: string },
  admin: Signer,
) => {
  const addressProvider = await getCounterAddressesProvider();
  const tokens: string[] = [];
  const symbols: string[] = [];

  const inputParams: {
    asset: string;
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

    const [, tokenAddress] = (Object.entries(tokenAddresses) as [string, string][])[
      assetAddressIndex
    ];

    inputParams.push({
      asset: tokenAddress,
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
        inputParams[index].baseLTV,
        inputParams[index].liquidationThreshold,
        inputParams[index].liquidationBonus,
      );
      if (inputParams[index].borrowingEnabled) {
        await configurator.connect(admin).enableBorrowingOnReserve(
          inputParams[index].asset,
          false
        );
      }
      await configurator.setReserveFactor(inputParams[index].asset, inputParams[index].reserveFactor);
    }
    // console.log("finish configure Reserve.");
  }
}

export const enableReservesBorrowing = async (
  tokenAddresses: { [symbol: string]: string },
  admin: Signer,
  ) => {
    const addressProvider = await getCounterAddressesProvider();
    const configurator = await getCounterConfigurator(await addressProvider.getCounterConfigurator())
    const reserves = Object.entries(tokenAddresses);

    for (let [symbol, address] of reserves) {
      console.log("Enable %s token to be borrowed", symbol);
      await configurator.connect(admin).enableBorrowingOnReserve(address, false);
    }

  }
