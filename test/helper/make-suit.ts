import chai from 'chai';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { getEtherSigners } from '../../utils/contracts-helpers';
import { Signer } from 'ethers';
import { tEthereumAddress } from '../../utils/common';
import { Counter } from '../../typechain/Counter';
import { CounterConfigurator } from '../../typechain/CounterConfigurator';
import { PrestareDataProvider } from '../../typechain/PrestareDataProvider';
import { WETH9Mocked } from '../../typechain/WETH9Mocked';
import { PToken } from '../../typechain/PToken';
import { MintableERC20 } from '../../typechain/MintableERC20';
import { CounterAddressProvider } from '../../typechain/CounterAddressProvider';
// import { UniswapLiquiditySwapAdapter } from '../../typechain/UniswapLiquiditySwapAdapter';
// import { UniswapRepayAdapter } from '../../typechain/UniswapRepayAdapter';
// import { CounterAddressProviderRegistry } from '../../typechain/CounterAddressProviderRegistry';
// import { WETHGateway } from '../../typechain/WETHGateway';
import { PriceOracle } from '../../typechain/PriceOracle';
// import { FlashLiquidationAdaptor } from '../../typechain/FlashLiquidationAdaptor';
import { 
    getCounter,
    getCounterConfiguratorProxy,
    getCounterAddressProvider,
    getPrestareDataProvider,
    getPToken,
    getMintableERC20,
    getWETHMocked,
} from '../../utils/contracts-getters';

import { HRE, evmSnapshot, evmRevert } from '../../utils/misc-utils';
import { usingTenderly } from '../../utils/tenderly-utils';

import { almostEqual } from './almostEqual';
// @ts-ignore
import bignumberChai from 'chai-bignumber';
import solidity from 'ethereum-waffle';

chai.use(bignumberChai());
chai.use(almostEqual());
// chai.use(solidity);

export interface SignerWithAddress {
    signer: Signer;
    address: tEthereumAddress;
} 

export interface TestEnv {
    deployer: SignerWithAddress;
    users: SignerWithAddress[];
    counter: Counter;
    configurator: CounterConfigurator;
    helpersContract: PrestareDataProvider;
    oracle: PriceOracle;
    weth: WETH9Mocked;
    pWETH: PToken;
    dai: MintableERC20;
    pDai: PToken;
    usdc: MintableERC20;
    prs: MintableERC20;
    addressProvider: CounterAddressProvider;
    // uniswapLiquiditySwapAdaptor: UniswapLiquiditySwapAdapter;
    // uniswapRepayAdapter: UniswapRepayAdapter;
    // registry: CounterAddressProviderRegistry;
    // wethGateway: WETHGateway;
    // flashLiquidationAdaptor: FlashLiquidationAdaptor;
}

const testEnv: TestEnv = {
    deployer: {} as SignerWithAddress,
    users: [] as SignerWithAddress[],
    counter: {} as Counter,
    configurator: {} as CounterConfigurator,
    helpersContract: {} as PrestareDataProvider,
    oracle: {} as PriceOracle,
    weth: {} as WETH9Mocked,
    pWETH: {} as PToken,
    dai: {} as MintableERC20,
    pDai: {} as PToken,
    usdc: {} as MintableERC20,
    prs: {} as MintableERC20,
    addressProvider: {} as CounterAddressProvider,
    // uniswapLiquiditySwapAdaptor: {} as UniswapLiquiditySwapAdapter,
    // uniswapRepayAdapter: {} as UniswapRepayAdapter,
    // registry: {} as CounterAddressProviderRegistry,
    // wethGateway: {} as WETHGateway,
    // flashLiquidationAdaptor: {} as FlashLiquidationAdaptor,
} as TestEnv;

export async function initializeMakeSuite() {
    const [_deployer, ...restSigners] = await getEtherSigners();
    const deployer: SignerWithAddress = {
        address: await _deployer.getAddress(),
        signer: _deployer,
    };
    for (const signer of restSigners) {
        testEnv.users.push({
            signer,
            address: await signer.getAddress(),
        });
    }
    testEnv.deployer = deployer;
    testEnv.counter = await getCounter();
    testEnv.configurator = await getCounterConfiguratorProxy();
    testEnv.addressProvider = await getCounterAddressProvider();

    // if (process.env.MAINNET_FORK === 'true') {
    //     testEnv.registry = await getCounterAddressProviderRegistry(
    //         getParamPerNetWork(PrestareConfig.ProviderRegistry, eEthereumNetwork.main)
    //     );
    // } else {
    //     testEnv.registry = await getCounterAddressProviderRegistry();
    //     testEnv.oracle = await getPriceOracle();
    // }
    testEnv.helpersContract = await getPrestareDataProvider();
    const allTokens = await testEnv.helpersContract.getAllPTokens();
    const pDaiAddress = allTokens.find((pToken) => pToken.symbol === 'pDAI')?.tokenAddress;
    const pWEthAddress = allTokens.find((pToken) => pToken.symbol === 'pWETH')?.tokenAddress;

    const reservesTokens = await testEnv.helpersContract.getAllReservesTokens();
    const daiAddress = reservesTokens.find((token) => token.symbol === 'DAI')?.tokenAddress;
    const usdcAddress = reservesTokens.find((token) => token.symbol === 'USDC')?.tokenAddress;
    const prsAddress = reservesTokens.find((token) => token.symbol === 'PRS')?.tokenAddress;
    const wethAddress = reservesTokens.find((token) => token.symbol === 'WETH')?.tokenAddress;

    if (!pDaiAddress || !pWEthAddress) {
        process.exit(1);
    }
    if (!daiAddress || !usdcAddress || !prsAddress || !wethAddress) {
        process.exit(1);
    }

    testEnv.pDai = await getPToken(pDaiAddress);
    testEnv.pWETH = await getPToken(pWEthAddress);

    testEnv.dai = await getMintableERC20(daiAddress);
    testEnv.usdc = await getMintableERC20(usdcAddress);
    testEnv.weth = await getWETHMocked(wethAddress);
    // testEnv.wethGateway = await getWETHGateway();
}

let builderEvmSnapshotId: string = '0x1';
const setBuilderEvmSnapshotId = (id: string) => {
    builderEvmSnapshotId = id;
};


const setSnapshot = async () => {
    const hre = HRE as HardhatRuntimeEnvironment;
    // if (usingTenderly()) {
    //     setBuilderEvmSnapshotId((await hre.tenderlyRPC.getHead()) || '0x1');
    //     return;
    // } 
    setBuilderEvmSnapshotId(await evmSnapshot());
}

const revertHead = async () => {
    const hre = HRE as HardhatRuntimeEnvironment;
    // if (usingTenderly()) {
    //   await hre.tenderlyRPC.setHead(buidlerevmSnapshotId);
    //   return;
    // }
    await evmRevert(builderEvmSnapshotId);
}

// void: 该函数返回undefined值
export function makeSuite(name: string, tests: (testEnv: TestEnv) => void) {
    describe(name, () => {
        before(async () => {
            await setSnapshot();
        });
        tests(testEnv);
        after(async () => {
            await revertHead();
        });
    });
}


