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
        BUSD: strategyBUSD,
    },
    Mocks: {
        AllMockAssetPrice: {
            ...MOCK_CHAINLINK_AGGREGATORS_PRICES,
        }
    },
    WETH: {
        [EthereumNetwork.MainnetFork]: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
    }
}