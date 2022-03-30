
import { evmRevert, evmSnapshot, DRE} from '../../helpers/misc-utils';
// what is signer https://docs.ethers.io/v5/api/signer/
import { Signer} from 'ethers';

// 获得各个合约的地址, contract-getters保存着得到各个地址的方法或者说变量
import {
    getLendingPool,
    getLendingPoolAddressesProvider,
    getAaveProtocolDataProvider,
    getAToken,
    getMintableERC20,
    getLendingPoolConfiguratorProxy,
    getPriceOracle,
    getLendingPoolAddressesProviderRegistry,
    getWETHMocked,
    getWETHGateway,
    getUniswapLiquiditySwapAdapter,
    getUniswapRepayAdapter,
    getFlashLiquidationAdapter,
    getParaSwapLiquiditySwapAdapter,
} from '../../helpers/contract-getters';

// 导入网络相关类型
import {eEthereumNetwork, eNetwork, tEthereumAddress} from '../../helpers/types';

