import { Contract } from "ethers";

export type TokenMap = { [symbol: string]: Contract};

export enum ContractName {
    CounterAddressesProvider = 'CounterAddressesProvider',
    ReserveLogic = 'ReserveLogic',
    GenericLogic = 'GenericLogic',
    CRTLogic = 'CRTLogic',
    ValidationLogic = 'ValidationLogic',
    Counter = 'Counter',
    CounterConfigurator = 'CounterConfigurator',
    PToken = 'PToken',
    MintableERC20 = 'MintableERC20',
    PriceOracle = 'PriceOracle',
    MockAggregator = 'MockAggregator',
    PrestareOracle = 'PrestareOracle',
    CounterCollateralManager = 'CounterCollateralManager',
    WETHGateway = 'WETHGateway',
    DefaultReserveInterestRateStrategy = 'DefaultReserveInterestRateStrategy',
    PlatformTokenInterestRateModel = 'PlatformTokenInterestRateModel',
    CRT = 'CRT',
}

export enum EthereumNetwork {
    Mainnet = 'Mainnet',
    main = 'main',
    hardhat = 'hardhat',
    Goerli = 'Goerli',
}

export enum TokenContractName {
    DAI = 'DAI',
    WETH = 'WETH',
    USDC = 'USDC',
    USDT = 'USDT',
    // aDAI = 'aDAI',
    // aWETH = 'aWETH',
    // aUSDC = 'aUSDC',
    // aUSDT = 'aUSDT'
}

export interface IInterestRateStrategyParams {
    name: string;
    optimalUtilizationRate: string;
    baseVariableBorrowRate: string;
    variableRateSlope1: string;
    variableRateSlope2: string;
};

export interface IPlatformInterestRateStrategyParams {
    name: string;
    opSupplyIndex: string;
    opBorrowIndex: string;
    poolSupplyIndex: string;
    poolBorrowIndex: string;
}
export interface IReserveBorrowParams {
    borrowingEnabled: boolean;
    reserveDecimals: string;
}
export interface IReserveCollateralParams {
    baseLTVAsCollateral: string;
    liquidationThreshold: string;
    liquidationBonus: string;
};

export interface IReserveParams extends IReserveBorrowParams, IReserveCollateralParams {
    pToken: ContractName;
    reserveFactor: string;
    strategy: IInterestRateStrategyParams | IPlatformInterestRateStrategyParams;
}

export enum Prestare {
    Mainnet = 'Mainnet',
    Goerli = "Goerli"
}