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
}

export enum TokenContractName {
    DAI = 'DAI',
    WETH = 'WETH',
    USDC = 'USDC',
    USDT = 'USDT',
    BUSD = 'BUSD',
}

export interface IInterestRateStrategyParams {
    name: string;
    optimalUtilizationRate: string;
    baseVariableBorrowRate: string;
    variableRateSlope1: string;
    variableRateSlope2: string;
}

export enum Prestare {
    MainnetFork = 'MainnetFork',
}