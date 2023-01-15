import { Signer } from 'ethers';
import low from 'lowdb';
import FileSync from 'lowdb/adapters/FileSync';
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
  treasuryAddress: String
  ) => {
  
}
