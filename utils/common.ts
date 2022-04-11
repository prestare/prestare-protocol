import BigNumber from 'bignumber.js';

export type eNetwork = eEthereumNetwork;

// 各个网络及其内部有的测试链
export enum eEthereumNetwork {
    builderEvm = 'builderEvm',
    kovan = 'kovan',
    ropsten = 'ropsten',
    main = 'main',
    coverage = 'coverage',
    hardhat = 'hardhat',
    tenderly = 'tenderly',
}

export interface iEthereumParamsPerNetwork<T> {
    [eEthereumNetwork.coverage]: T;
    [eEthereumNetwork.builderEvm]: T;
    [eEthereumNetwork.kovan]: T;
    [eEthereumNetwork.ropsten]: T;
    [eEthereumNetwork.main]: T;
    [eEthereumNetwork.hardhat]: T;
    [eEthereumNetwork.tenderly]: T;
}

export type iParamsPerNetwork<T> =
    | iEthereumParamsPerNetwork<T>

export enum ePolygonNetwork {
    matic = 'matic',
    mumbai = 'mumbai',
}

export enum eXDaiNetwork {
    xdai = 'xdai',
}

export enum eAvalancheNetwork {
    avalanche = 'avalanche',
    fuji = 'fuji',
}

export enum eContractid {
    IERC20Detailed = 'IERC20Detailed',
    Counter = 'Counter',
    PToken = 'PToken',
    MintableERC20 = 'MintableERC20',
    CounterAddressProvider = 'CounterAddressProvider',
    CounterAddressesProviderRegistry = 'CounterAddressesProviderRegistry',
    WETHMocked = 'WETHMocked',
    CounterImpl = 'CounterImpl',
    CounterConfiguratorImpl = 'CounterConfiguratorImpl',
    CounterConfigurator = 'CounterConfigurator',
    StableAndVariableTokensHelper = 'StableAndVariableTokensHelper',
    PTokensAndRatesHelper = 'PTokensAndRatesHelper',
    PriceOracle = 'PriceOracle',
    MockAggregator = 'PriceOracle',
    PrestareOracle = 'PrestareOracle',
    LendingRateOracle = 'LendingRateOracle',
    PrestareProtocolDataProvider = 'PrestareProtocolDataProvider',
    DefaultReserveInterestRateStrategy = 'DefaultReserveInterestRateStrategy',
    DelegationAwarePToken = 'DelegationAwarePToken',
    //不需要
    StableDebtToken = 'StableDebtToken',
    //不需要
    VariableDebtToken = 'VariableDebtToken',
    CounterCollateralManagerImpl = 'CounterCollateralManagerImpl',
    CounterCollateralManager = 'CounterCollateralManager',
    Koios = 'Koios',
    ReserveLogic = 'ReserveLogic',
}

export enum PrestareCounters {
    proto = 'proto',
}

export type iMultiPoolsAssets<T> = iAssetCommon<T> | iPrestareCounterAssets<T>;

export enum TokenContractId {
    DAI = 'DAI',
    WETH = 'WETH',
    USDC = 'USDC',
    USDT = 'USDT',
    PRS = 'PRS',
    USD = 'USD',
}

export interface iAssetBase<T> {
    WETH: T;
    DAI: T;
    USDC: T;
    USDT: T;
    USD: T;
}

export type iAssetsWithoutUSD<T> = Omit<iAssetBase<T>, 'USD'>;

export type iPrestareCounterAssets<T> = Pick<
    iAssetsWithoutUSD<T>,
    | 'DAI'
    | 'USDC'
    | 'USDT'
    | 'WETH'
>;

export interface iAssetCommon<T> {
    [key: string]: T;
}

export type iAssetsWithoutETH<T> = Omit<iAssetBase<T>, 'ETH'>;
export type iAssetAggregatorBase<T> = iAssetsWithoutETH<T>;

export type iMultiCountersAssets<T> = iAssetCommon<T> | iPrestareCounterAssets<T>;

export interface IMarketRates {
    borrowRate: string;
}

export interface IReserveBorrowParams {
    // optimalUtilizationRate: string;
    // baseVariableBorrowRate: string;
    // variableRateSlope1: string;
    // variableRateSlope2: string;
    // stableRateSlope1: string;
    // stableRateSlope2: string;
    borrowingEnabled: boolean;
    stableBorrowRateEnabled: boolean;
    reserveDecimals: string;
}

export interface IReserveCollateralParams {
    baseLTVAsCollateral: string;
    liquidationThreshold: string;
    liquidationBonus: string;
}

export interface IReserveParams extends IReserveBorrowParams, IReserveCollateralParams {
    pTokenImpl: eContractid;
    reserveFactor: string;
    strategy: IInterestRateStrategyParams;
}

export interface IInterestRateStrategyParams {
    name: string;
    optimalUtilizationRate: string;
    baseVariableBorrowRate: string;
    variableRateSlope1: string;
    variableRateSlope2: string;
    stableRateSlope1: string;
    stableRateSlope2: string;
}

export interface iParamsPerCounter<T> {
    [PrestareCounters.proto]: T;
}

/*
 * Error messages 
 */ 
export enum ProtocolErrors {
    
    KOIOS_TRANSFER_NOT_ALLOWED = '1', // Transfer cannot be allowed

    WRONG_SENDER_BALANCE_AFTER_TRANSFER = 'Wrong sender balance after transfer',
    WRONG_RECEIVER_BALANCE_AFTER_TRANSFER = 'Wrong receiver balance after transfer',
    
}

// 定义tEthereumAddress 类型为string
export type tEthereumAddress = string;
export type tStringTokenSmallUnits = string; // 1 wei, or 1 basic unit of USDC, or 1 basic unit of DAI



export interface IProtocolGlobalConfig {
    TokenDistributorPercentageBase: string;
    MockUsdPriceInWei: string;
    UsdAddress: tEthereumAddress;
    NilAddress: tEthereumAddress;
    OneAddress: tEthereumAddress;
    PrestareReferral: string;
}

export interface IMocksConfig {
    AllAssetsInitialPrices: iAssetBase<string>;
}

export interface SymbolMap<T> {
    [symbol: string]: T;
}

export interface ICommonConfiguration {
    MarketId: string;
    PTokenNamePrefix: string;
    StableDebtTokenNamePrefix: string;
    VariableDebtTokenNamePrefix: string;
    SymbolPrefix: string;
    ProviderId: number;
    ProtocolGlobalParams: IProtocolGlobalConfig;
    Mocks: IMocksConfig;
    LendingRateOracleRatesCommon: iMultiPoolsAssets<IMarketRates>;
    ReserveFactorTreasuryAddress: iParamsPerNetwork<tEthereumAddress>;
    ReserveAssets: iParamsPerNetwork<SymbolMap<tEthereumAddress>>;
}

export interface IPrestareConfiguration extends ICommonConfiguration {
    ReservesConfig: iMultiCountersAssets<IReserveParams>;
}

export type PoolConfiguration = ICommonConfiguration | IPrestareConfiguration;