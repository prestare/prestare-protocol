import {ethers} from 'ethers';
export const oneRay = ethers.utils.parseUnits('1.0', 27);
export const oneEther = ethers.utils.parseUnits('1.0', 18);
export const MOCK_CHAINLINK_AGGREGATORS_PRICES = {
    // record date 2023/1/14
    BUSD: ethers.utils.parseEther('0.000648803').toString(),
    USDT: ethers.utils.parseEther('0.000654967').toString(),
    USDC: ethers.utils.parseEther('0.0006533967').toString(),
    DAI: ethers.utils.parseEther('0.0006520403').toString(),
    WETH: ethers.utils.parseEther('1').toString(),
}
