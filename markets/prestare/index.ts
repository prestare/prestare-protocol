import { IPrestareConfiguration, eEthereumNetwork } from '../../utils/common';
import { CommonsConfig } from './commons';
import { 
    strategyUSDT,
    strategyPRS,
    strategyDAI,
    strategyUSDC,
    strategyWETH
} from './reserve';

export const PrestareConfig: IPrestareConfiguration = {
    ...CommonsConfig,
    MarketId: 'Prestare market',
    ProviderId: 1,
    ReservesConfig: {
        PRS: strategyPRS,
        DAI: strategyDAI,
        USDC: strategyUSDC,
        WETH: strategyWETH,
        USDT: strategyUSDT,
    },
    ReserveAssets: {
        [eEthereumNetwork.builderEvm]: {},
        [eEthereumNetwork.coverage]: {},
        [eEthereumNetwork.kovan]: {},
        [eEthereumNetwork.ropsten]: {},
        [eEthereumNetwork.main]: {},
        [eEthereumNetwork.hardhat]: {},
        [eEthereumNetwork.tenderly]:{},
    }
}