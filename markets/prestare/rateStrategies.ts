import BigNumber from 'bignumber.js';
import { oneRay } from '../../utils/constants';
import { IInterestRateStrategyParams } from '../../utils/common';


// DAI TUSD
export const rateStrategyStableTwo: IInterestRateStrategyParams = {
    name: "rateStrategyStableTwo",
    optimalUtilizationRate: new BigNumber(0.8).multipliedBy(oneRay).toFixed(),
    baseVariableBorrowRate: new BigNumber(0).multipliedBy(oneRay).toFixed(),
    variableRateSlope1: new BigNumber(0.04).multipliedBy(oneRay).toFixed(),
    variableRateSlope2: new BigNumber(0.75).multipliedBy(oneRay).toFixed(),
    stableRateSlope1: new BigNumber(0.02).multipliedBy(oneRay).toFixed(),
    stableRateSlope2: new BigNumber(0.75).multipliedBy(oneRay).toFixed(),
}

// USDC USDT
export const rateStrategyThree: IInterestRateStrategyParams = {
    name: "rateStrategyStableThree",
    optimalUtilizationRate: new BigNumber(0.9).multipliedBy(oneRay).toFixed(),
    baseVariableBorrowRate: new BigNumber(0).multipliedBy(oneRay).toFixed(),
    variableRateSlope1: new BigNumber(0.04).multipliedBy(oneRay).toFixed(),
    variableRateSlope2: new BigNumber(0.60).multipliedBy(oneRay).toFixed(),
    stableRateSlope1: new BigNumber(0.02).multipliedBy(oneRay).toFixed(),
    stableRateSlope2: new BigNumber(0.60).multipliedBy(oneRay).toFixed(),
}

// PRS
export const rateStrategyPRS: IInterestRateStrategyParams = {
    name: "rateStrategyPRS",
    optimalUtilizationRate: new BigNumber(0.45).multipliedBy(oneRay).toFixed(),
    baseVariableBorrowRate: '0',
    variableRateSlope1: '0',
    variableRateSlope2: '0',
    stableRateSlope1: '0',
    stableRateSlope2: '0',
}

// WETH
export const rateStrategyWETH: IInterestRateStrategyParams = {
    name: "rateStrategyWETH",
    optimalUtilizationRate: new BigNumber(0.65).multipliedBy(oneRay).toFixed(),
    baseVariableBorrowRate: new BigNumber(0).multipliedBy(oneRay).toFixed(),
    variableRateSlope1: new BigNumber(0.08).multipliedBy(oneRay).toFixed(),
    variableRateSlope2: new BigNumber(1).multipliedBy(oneRay).toFixed(),
    stableRateSlope1: new BigNumber(0.1).multipliedBy(oneRay).toFixed(),
    stableRateSlope2: new BigNumber(1).multipliedBy(oneRay).toFixed(),
}