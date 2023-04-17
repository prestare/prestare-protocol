import {
    strategyDAI,
    strategyWETH,
    strategyUSDC,
    strategyUSDT,
    strategyBUSD,
} from "./reserveConfig";
import { MOCK_CHAINLINK_AGGREGATORS_PRICES, oneEther } from "../../helpers/constants";
import { EthereumNetwork } from "../../helpers/types";

export const MainnetFork = {
    MockUsdPriceInWei: '5848466240000000',
    oracleQuoteCurrency: 'ETH',
    OracleQuoteUnit: oneEther.toString(),
    
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
            DAI: '0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD',
            WETH:'0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
            USDC: '0xe22da380ee6B445bb8273C81944ADEB6E8450422',
            USDT: '0x13512979ADE267AB5100878E2e0f485B568328a4',
            aDAI: '0x028171bCA77440897B824Ca71D1c56caC55b68A3',
            aWETH: '0x030bA81f1c18d280636F32af80b9AAd02Cf0854e',
            aUSDC: '0xBcca60bB61934080951369a648Fb03DF4F96263C',
            aUSDT: '0x3Ed3B47Dd13EC9a98b44e6204A523E766B225811'
        },
    }
}