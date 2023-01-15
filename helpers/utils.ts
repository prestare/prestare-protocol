import { BigNumber, Signer } from 'ethers';
import { getContractAddress } from 'ethers/lib/utils';
import low from 'lowdb';
import FileSync from 'lowdb/adapters/FileSync';
import { ZERO_ADDRESS } from './constants';
import { deployRateStrategy } from './contracts-deployments';
import { 
  getCounterAddressesProvider, 
  getCounter, 
  rawInsertContractAddressInDb,
  getContractAddressWithJsonFallback
} from './contracts-helpers';
import { 
  TokenMap,
  IReserveParams
} from './types';
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
  let reserveSymbols: string[] = [];
  
  let initInputParams: {
    pToken: string;
    variableDebtTokenImpl: string;
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
    const Counter = await getCounter(await addressProvider.getCounter());
    const CounterReserve = await Counter.getReserveData(tokenAddresses[symbol]);
    if (CounterReserve.pTokenAddress !== ZERO_ADDRESS) {
      console.log(`- Skipping init of ${symbol} due is already initialized`);
      continue;
    }

    const { strategy, pToken, reserveDecimals } = params;

    let rateStrategies: Record<string, typeof strategyRates> = {};
    let strategyAddresses: Record<string, string> = {};

    const {
      optimalUtilizationRate,
      baseVariableBorrowRate,
      variableRateSlope1,
      variableRateSlope2,
    } = strategy;

    if (!strategyAddresses[strategy.name]) {
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

    reserveSymbols.push(symbol);
    // initInputParams.push({
    //   pToken: ,
    //   variableDebtTokenImpl: ,
    //   underlyingAssetDecimals: ,
    //   interestRateStrategyAddress: strategyAddresses[strategy.name],
    //   underlyingAsset: tokenAddresses[symbol],
    //   treasury: treasuryAddress,
    //   incentivesController: ZERO_ADDRESS,
    //   underlyingAssetName: symbol,
    //   pTokenName: `p ${symbol}`,
    //   pTokenSymbol: `a ${symbol}`,
    //   variableDebtTokenName: `variableDebt Prestare ${symbol}`,
    //   variableDebtTokenSymbol: `variableDebt ${symbol}`,
    //   params: ,
    // })
  }
};



