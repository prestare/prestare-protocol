import {
    strategyDAI,
    strategyWETH,
    strategyUSDC,
    strategyUSDT,
    strategyBUSD,
} from "./reserveConfig";
import { MOCK_CHAINLINK_AGGREGATORS_PRICES, oneUSD, ZERO_ADDRESS } from "../../helpers/constants";
import { EthereumNetwork } from "../../helpers/types";

export const MainnetFork = {
    MockUsdPriceInWei: '209414684000',
    oracleQuoteCurrency: 'USD',
    OracleQuoteUnit: oneUSD.toString(),
    
    ReservesConfig: {
        DAI: strategyDAI,
        WETH: strategyWETH,
        USDC: strategyUSDC,
        USDT: strategyUSDT,
        // BUSD: strategyBUSD,
        aDAI: strategyDAI,
        aWETH: strategyWETH,
        aUSDC: strategyUSDC,
        aUSDT: strategyUSDT
    },
    Mocks: {
        AllMockAssetPrice: {
            ...MOCK_CHAINLINK_AGGREGATORS_PRICES,
        }
    },
    ReserveAssetsAddress: {
        [EthereumNetwork.MainnetFork]: {
            USD: ZERO_ADDRESS,
            DAI: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
            USDC: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
            USDT: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
            WETH: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
            aDAI: '0x028171bCA77440897B824Ca71D1c56caC55b68A3',
            aWETH: '0x030bA81f1c18d280636F32af80b9AAd02Cf0854e',
            aUSDC: '0xBcca60bB61934080951369a648Fb03DF4F96263C',
            aUSDT: '0x3Ed3B47Dd13EC9a98b44e6204A523E766B225811'
        },
    },
    ChainlinkAggregator: {
        [EthereumNetwork.MainnetFork]: {
            DAI: '0xaed0c38402a5d19df6e4c03f4e2dced6e29c1ee9',
            USDC: '0x8fffffd4afb6115b954bd326cbe7b4ba576818f6',
            USDT: '0x3e7d1eab13ad0104d2750b8863b489d65364e32d',
            WETH: '0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419',
        }
    }
}