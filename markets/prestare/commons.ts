import { ICommonConfiguration, eEthereumNetwork } from '../../utils/common';
import { MOCK_CHAINLINK_AGGREGATORS_PRICES, oneRay } from '../../utils/constants';

export const CommonsConfig: ICommonConfiguration = {
    MarketId: 'Commons',
    PTokenNamePrefix: 'Prestare',
    StableDebtTokenNamePrefix: '',
    VariableDebtTokenNamePrefix: '',
    SymbolPrefix: '',
    ProviderId: 0, // Overriden in index.ts
    ProtocolGlobalParams: {
        TokenDistributorPercentageBase: '10000',
        MockUsdPriceInWei: '5848466240000000',
        UsdAddress: '0x10F7Fc1F91Ba351f9C629c5947AD69bD03C05b96',
        NilAddress: '0x0000000000000000000000000000000000000000',
        OneAddress: '0x0000000000000000000000000000000000000001',
        PrestareReferral: '0',
    },
    Mocks: {
        AllAssetsInitialPrices: {
            ...MOCK_CHAINLINK_AGGREGATORS_PRICES,
        },
    }, 
    LendingRateOracleRatesCommon: {
        WETH: {
            borrowRate: oneRay.multipliedBy(0.03).toFixed(),
        },
        DAI: {
            borrowRate: oneRay.multipliedBy(0.039).toFixed(),
        },
        USDC: {
            borrowRate: oneRay.multipliedBy(0.039).toFixed(),
        },
        USDT: {
            borrowRate: oneRay.multipliedBy(0.035).toFixed(),
        },
    },
    // TODO
    ReserveFactorTreasuryAddress: {
        [eEthereumNetwork.coverage]: '0x0000000000000000000000000000000000000000',
        [eEthereumNetwork.hardhat]: '0x0000000000000000000000000000000000000000',
        [eEthereumNetwork.builderEvm]: '0x0000000000000000000000000000000000000000',
        [eEthereumNetwork.kovan]: '0x0000000000000000000000000000000000000000',
        [eEthereumNetwork.ropsten]: '0x0000000000000000000000000000000000000000',
        [eEthereumNetwork.main]: '0x0000000000000000000000000000000000000000',
        [eEthereumNetwork.tenderly]: '0x0000000000000000000000000000000000000000',
    },
    ReserveAssets: {
        [eEthereumNetwork.coverage]: {},
        [eEthereumNetwork.hardhat]: {},
        [eEthereumNetwork.builderEvm]: {},
        [eEthereumNetwork.main]: {},
        [eEthereumNetwork.kovan]: {},
        [eEthereumNetwork.ropsten]: {},
        [eEthereumNetwork.tenderly]: {},
    }
};