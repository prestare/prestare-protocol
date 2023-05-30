import {
    strategyDAI_C,
    strategyWETH_C,
    strategyUSDC_C,
    strategyUSDT_C,
    aTokenStrategy,
    strategyDAI_B,
    strategyWETH_B,
    strategyUSDC_B,
    strategyUSDT_B,
    strategyUSDC_A,
    strategyUSDT_A
} from "./reserveConfig";
import { MOCK_CHAINLINK_AGGREGATORS_PRICES, oneUSD, ZERO_ADDRESS } from "../../helpers/constants";
import { EthereumNetwork } from "../../helpers/types";

export const Mainnet = {
    MockUsdPriceInWei: '209414684000',
    oracleQuoteCurrency: 'USD',
    OracleQuoteUnit: oneUSD.toString(),
    
    ReservesConfig: {
        DAI: strategyDAI_C,
        WETH: strategyWETH_C,
        USDC: strategyUSDC_C,
        USDT: strategyUSDT_C,
        // BUSD: strategyBUSD,
        aDAI: aTokenStrategy,
        aWETH: aTokenStrategy,
        aUSDC: aTokenStrategy,
        aUSDT: aTokenStrategy
    },
    assetBClassConfig: {
        DAI: strategyDAI_B,
        WETH: strategyWETH_B,
        USDC: strategyUSDC_B,
        USDT: strategyUSDT_B,
    },
    assetAClassConfig: {
        USDC: strategyUSDC_A,
        USDT: strategyUSDT_A,
    },
    AssetTier: {
        DAI: 1,
        WETH: 1,
        USDC: 0,
        USDT: 0,
        // BUSD: strategyBUSD,
        aDAI: 2,
        aWETH: 2,
        aUSDC: 2,
        aUSDT: 2
    },
    BRiskTierReservesConfig: {
        DAI: strategyDAI_B,
        WETH: strategyWETH_B,
        USDC: strategyUSDC_B,
        USDT: strategyUSDT_B
    },
    
    ARiskTierReservesConfig: {
        USDC: strategyUSDC_A,
        USDT: strategyUSDT_A
    },

    Mocks: {
        AllMockAssetPrice: {
            ...MOCK_CHAINLINK_AGGREGATORS_PRICES,
        }
    },
    ReserveAssetsAddress: {
        [EthereumNetwork.Mainnet]: {
            USD: ZERO_ADDRESS,
            DAI:  '0x6B175474E89094C44Da98b954EedeAC495271d0F',
            WETH: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
            USDC: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
            USDT: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
            aDAI:  "0x028171bCA77440897B824Ca71D1c56caC55b68A3",
            aWETH: "0x030bA81f1c18d280636F32af80b9AAd02Cf0854e",
            aUSDC: "0xBcca60bB61934080951369a648Fb03DF4F96263C",
            aUSDT: "0x3Ed3B47Dd13EC9a98b44e6204A523E766B225811",
        },
        // goerli 中记录都是aave goerli中的资产，都属于mintable的
        [EthereumNetwork.Goerli]: {
            USD: ZERO_ADDRESS,
            DAI: '0x75Ab5AB1Eef154C0352Fc31D2428Cef80C7F8B33',
            WETH: '0xCCa7d1416518D095E729904aAeA087dBA749A4dC',
            USDC: '0x9FD21bE27A2B059a288229361E2fA632D8D2d074',
            USDT: '0x65E2fe35C30eC218b46266F89847c63c2eDa7Dc7',
            aDAI: '0x31f30d9A5627eAfeC4433Ae2886Cf6cc3D25E772',
            aWETH: '0x22404B0e2a7067068AcdaDd8f9D586F834cCe2c5',
            aUSDC: '0x935c0F6019b05C787573B5e6176681282A3f3E05',
            aUSDT: '0xDCb84F51dd4BeA1ce4b6118F087B260a71BB656c'
        },
    },
    ChainlinkAggregator: {
        [EthereumNetwork.Mainnet]: {
            DAI: '0xaed0c38402a5d19df6e4c03f4e2dced6e29c1ee9',
            WETH: '0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419',
            USDC: '0x8fffffd4afb6115b954bd326cbe7b4ba576818f6',
            USDT: '0x3e7d1eab13ad0104d2750b8863b489d65364e32d',
            // atoken use the same chainlink aggregator
            aDAI: '0xaed0c38402a5d19df6e4c03f4e2dced6e29c1ee9',
            aWETH: '0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419',
            aUSDC: '0x8fffffd4afb6115b954bd326cbe7b4ba576818f6',
            aUSDT: '0x3e7d1eab13ad0104d2750b8863b489d65364e32d'
        },
        // goerli 中记录都是aave v3 伪造的price aggregator
        [EthereumNetwork.Goerli]: {
            USD: ZERO_ADDRESS,
            DAI: '0x73221008d4d6908f4120d99b0Dd66D5F24095f6f',
            WETH: '0xCaD38d22431460c5c4C71F4a0f4896E895dc8907',
            USDC: '0x6078279E3f3F09D49c21bdCD87906da4CBCd4f5b',
            USDT: '0xBF1a17E93c04B1DA5F49d23DBB0811F6D14429a1',
            // atoken use the same chainlink aggregator
            aDAI: '0x73221008d4d6908f4120d99b0Dd66D5F24095f6f',
            aWETH: '0xCaD38d22431460c5c4C71F4a0f4896E895dc8907',
            aUSDC: '0x6078279E3f3F09D49c21bdCD87906da4CBCd4f5b',
            aUSDT: '0xBF1a17E93c04B1DA5F49d23DBB0811F6D14429a1'
        },
    }
}