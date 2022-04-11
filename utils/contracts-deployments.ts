import { withSaveAndVerify, insertContractAddressInDb } from './contracts-helpers';
import { HRE } from './misc-utils';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { MintableERC20 } from '../typechain/MintableERC20';
import { MintableERC20__factory } from '../typechain/factories/MintableERC20__factory';
import { PriceOracle__factory } from '../typechain/factories/PriceOracle__factory';
import { CounterConfigurator__factory } from '../typechain/factories/CounterConfigurator__factory';
import { PTokenAndRatesHelper__factory } from '../typechain/factories/PTokenAndRatesHelper__factory';
import { LendingRateOracle__factory } from '../typechain/factories/LendingRateOracle__factory';
import { PrestareDataProvider__factory } from '../typechain/factories/PrestareDataProvider__factory';
import { WETH9Mocked__factory } from '../typechain/factories/WETH9Mocked__factory';
import { CounterAddressProvider__factory } from '../typechain/factories/CounterAddressProvider__factory';
import { PToken__factory } from '../typechain/factories/PToken__factory';
import { Counter__factory } from '../typechain/factories/Counter__factory';
import { MockAggregator__factory } from '../typechain/factories/MockAggregator__factory';
import { TestInterestRateModel__factory } from '../typechain/factories/TestInterestRateModel__factory';
import { CounterLibraryAddresses } from '../typechain/factories/Counter__factory';
import { ReserveLogic__factory } from '../typechain/factories/ReserveLogic__factory';

import { getFirstSigner } from './contracts-getters';
import { 
    eContractid, 
    eEthereumNetwork,
    tEthereumAddress,
    tStringTokenSmallUnits
} from './common';

const readArtifact = async (id: string) => {
    if (HRE.network.name === eEthereumNetwork.builderEvm) {
        return HRE.artifacts.readArtifact(HRE.config.paths.artifacts);
    }
    return HRE.artifacts.readArtifact(id);
}

export const deployCounter = async (verify?: boolean) => {
    const libraries = await deployPrestareLibraries(verify);
    const CounterImpl = await new Counter__factory(libraries, await getFirstSigner()).deploy();
    await insertContractAddressInDb(eContractid.CounterImpl, CounterImpl.address);
    return withSaveAndVerify(CounterImpl, eContractid.CounterImpl, [], verify);
}

// TODO: te be modified
export const deployPrestareLibraries = async (
    verify?: boolean): Promise<CounterLibraryAddresses> => {
        const reserveLogic = await deployReserveLogicLibrary(verify);
    // Hardcoded solidity placeholders, if any library changes path this will fail.
    // The '__$PLACEHOLDER$__ can be calculated via solidity keccak, but the LendingPoolLibraryAddresses Type seems to
    // require a hardcoded string.
    //
    //  how-to:
    //  1. PLACEHOLDER = solidityKeccak256(['string'], `${libPath}:${libName}`).slice(2, 36)
    //  2. LIB_PLACEHOLDER = `__$${PLACEHOLDER}$__`
    // or grab placeholdes from LendingPoolLibraryAddresses at Typechain generation.
    //
    // libPath example: contracts/libraries/logic/GenericLogic.sol
    // libName example: GenericLogic
    return {
        // TODO:
        ['contracts/ReserveLogic.sol:ReserveLogic']: reserveLogic.address,
    };
}

export const deployReserveLogicLibrary = async (verify?: boolean) =>
    withSaveAndVerify(
        await new ReserveLogic__factory(await getFirstSigner()).deploy(),
        eContractid.ReserveLogic,
        [],
        verify
    );
// export const deployKoios = async (
//     verify?: boolean) => {
//         const KoiosArtifact = await readArtifact(eContractid.Koios);

//         const Koios = await (await Koios__factory.deploy()).deployed();
// }

export const deployCounterConfigurator = async (verify?: boolean) => {
    const lendingPoolConfiguratorImpl = await new CounterConfigurator__factory(await getFirstSigner()
).deploy();
    await insertContractAddressInDb(
        eContractid.CounterConfiguratorImpl,
        lendingPoolConfiguratorImpl.address
    );
    return withSaveAndVerify(
        lendingPoolConfiguratorImpl,
        eContractid.CounterConfigurator,
        [],
        verify
    );
};

// export const deployStableAndVariableTokensHelper = async (
//     args: [tEthereumAddress, tEthereumAddress],
//     verify?: boolean);
// ) =>
//     withSaveAndVerify(
//         await new StableAndVariableTokensHelperFactory(await getFirstSigner()).deploy(...args),
//         eContractid.StableAndVariableTokensHelper,
//         args,
//         verify
// );

export const deployPTokensAndRatesHelper = async (
    args: [tEthereumAddress, tEthereumAddress, tEthereumAddress],
    verify?: boolean
) =>
    withSaveAndVerify(
        await new PTokenAndRatesHelper__factory(await getFirstSigner()).deploy(...args),
        eContractid.PTokensAndRatesHelper,
        args,
        verify
);

export const deployPriceOracle = async (verify?: boolean) =>
    withSaveAndVerify(
        await new PriceOracle__factory(await getFirstSigner()).deploy(),
        eContractid.PriceOracle,
        [],
        verify
);

// export const deployPrestareOracle = async (
//     args: [tEthereumAddress[], tEthereumAddress[], tEthereumAddress, tEthereumAddress],
//     verify?: boolean
// ) => ()
//     withSaveAndVerify(
//         await new PrestareOracleFactory(await getFirstSigner()).deploy(...args),
//         eContractid.PrestareOracle,
//         args,
//         verify
// );

export const deployLendingRateOracle = async (verify?: boolean) =>
    withSaveAndVerify(
        await new LendingRateOracle__factory(await getFirstSigner()).deploy(),
        eContractid.LendingRateOracle,
        [],
        verify
);

export const deployMockAggregator = async (price: tStringTokenSmallUnits, verify?: boolean) => 
        withSaveAndVerify(
            await new MockAggregator__factory(await getFirstSigner()).deploy(price),
            eContractid.MockAggregator,
            [price],
            verify
        )

export const deployPrestareDataProvider = async (
    addressesProvider: tEthereumAddress,
    verify?: boolean
) =>
    withSaveAndVerify(
        await new PrestareDataProvider__factory(await getFirstSigner()).deploy(addressesProvider),
        eContractid.PrestareProtocolDataProvider,
        [addressesProvider],
        verify
);

// export const deployMockAggregator = async (price: tStringTokenSmallUnits, verify?: boolean) =>
//     withSaveAndVerify(
//         await new MockAggregatorFactory(await getFirstSigner()).deploy(price),
//         eContractid.MockAggregator,
//         [price],
//         verify
// );

export const deployMintableERC20 = async (
    args: [string, string, string],
    verify?: boolean
): Promise<MintableERC20> => withSaveAndVerify(
    await new MintableERC20__factory(await getFirstSigner()).deploy(...args),
    eContractid.MintableERC20,
    args,
    verify
)

export const deployWETHMocked = async (verify?: boolean)  => 
    withSaveAndVerify(
        await new WETH9Mocked__factory(await getFirstSigner()).deploy(),
        eContractid.WETHMocked,
        [],
        verify
    );

export const deployCounterAddressProvider = async (marketId: string, verify?: boolean) => 
    withSaveAndVerify(
        await new CounterAddressProvider__factory(await getFirstSigner()).deploy(marketId),
        eContractid.CounterAddressProvider,
        [marketId],
        verify
    );

// export const deployCounterAddressProviderRegistry = async (verify?: boolean) =>
//     withSaveAndVerify(
//         await new CounterAddressesProviderRegistryFactory(await getFirstSigner()).deploy(),
//         eContractid.CounterAddressesProviderRegistry,
//         [],
//         verify
//     );

export const deployTestInterestRateModel = async (
    args: [tEthereumAddress, string, string, string, string],
    verify: boolean
) =>
    withSaveAndVerify(
        await new TestInterestRateModel__factory(await getFirstSigner()).deploy(...args),
        eContractid.DefaultReserveInterestRateStrategy,
        args,
        verify
);


// export const deployDelegationAwarePToken = async (
//     [pool, underlyingAssetAddress, treasuryAddress, incentivesController, name, symbol]: [
//         tEthereumAddress,
//         tEthereumAddress,
//         tEthereumAddress,
//         tEthereumAddress,
//         string,
//         string
//     ],
//     verify: boolean
// ) => {
//     const instance = await withSaveAndVerify(
//         await new DelegationAwarePTokenFactory(await getFirstSigner()).deploy(),
//         eContractid.DelegationAwarePToken,
//         [],
//         verify
//     );

//     await instance.initialize(
//         pool,
//         treasuryAddress,
//         underlyingAssetAddress,
//         incentivesController,
//         '18',
//         name,
//         symbol,
//         '0x10'
//     );

//     return instance;
// };

// export const deployDelegationAwarePTokenImpl = async (verify: boolean) =>
//     withSaveAndVerify(
//         await new DelegationAwarePTokenFactory(await getFirstSigner()).deploy(),
//         eContractid.DelegationAwarePToken,
//         [],
//         verify
// );

// export const deployGenericPToken = async (
//     [poolAddress, underlyingAssetAddress, treasuryAddress, incentivesController, name, symbol]: [
//         tEthereumAddress,
//         tEthereumAddress,
//         tEthereumAddress,
//         tEthereumAddress,
//         string,
//         string
//     ],
//     verify: boolean
// ) => {
//     const instance = await withSaveAndVerify(
//         await new PToken__factory(await getFirstSigner()).deploy(),
//         eContractid.PToken,
//         [],
//         verify
//     );

//     await instance.initialize(
//         poolAddress,
//         treasuryAddress,
//         underlyingAssetAddress,
//         incentivesController,
//         '18',
//         name,
//         symbol,
//         '0x10'
//     );

//     return instance;
// };

export const deployGenericPTokenImpl = async (verify: boolean) =>
    withSaveAndVerify(
        await new PToken__factory(await getFirstSigner()).deploy(),
        eContractid.PToken,
        [],
        verify
    );

// 不需要
// export const deployGenericStableDebtToken = async () =>
//     withSaveAndVerify(
//         await new StableDebtTokenFactory(await getFirstSigner()).deploy(),
//         eContractid.StableDebtToken,
//         [],
//         false
// );

// 不需要
// export const deployGenericVariableDebtToken = async () =>
//     withSaveAndVerify(
//         await new VariableDebtTokenFactory(await getFirstSigner()).deploy(),
//         eContractid.VariableDebtToken,
//         [],
//         false
// );

// // 不需要
// export const deployStableDebtToken = async (
//     args: [tEthereumAddress, tEthereumAddress, tEthereumAddress, string, string],
//     verify: boolean
// ) => {
//     const instance = await withSaveAndVerify(
//         await new StableDebtTokenFactory(await getFirstSigner()).deploy(),
//         eContractid.StableDebtToken,
//         [],
//         verify
//     );

//     await instance.initialize(args[0], args[1], args[2], '18', args[3], args[4], '0x10');

//     return instance;
// };

// // 不需要
// export const deployVariableDebtToken = async (
//     args: [tEthereumAddress, tEthereumAddress, tEthereumAddress, string, string],
//     verify: boolean
// ) => {
//     const instance = await withSaveAndVerify(
//         await new VariableDebtTokenFactory(await getFirstSigner()).deploy(),
//         eContractid.VariableDebtToken,
//         [],
//         verify
//     );

//     await instance.initialize(args[0], args[1], args[2], '18', args[3], args[4], '0x10');

//     return instance;
// };

// export const deployCounterCollateralManager = async (verify?: boolean) => {
//     const collateralManagerImpl = await new CounterCollateralManagerFactory(
//         await getFirstSigner()
//     ).deploy();
//     await insertContractAddressInDb(
//         eContractid.CounterCollateralManagerImpl,
//         collateralManagerImpl.address
//     );
//     return withSaveAndVerify(
//         collateralManagerImpl,
//         eContractid.CounterCollateralManager,
//         [],
//         verify
//     );
// };