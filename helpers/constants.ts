import {ethers} from 'ethers';
export const oneRay = ethers.utils.parseUnits('1.0', 27);
export const oneEther = ethers.utils.parseUnits('1.0', 18);
export const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

export const MOCK_CHAINLINK_AGGREGATORS_PRICES = {
    // record date 2023/1/14
    USDT: ethers.utils.parseEther('1.0001').toString(),
    USDC: ethers.utils.parseEther('0.999940').toString(),
    DAI: ethers.utils.parseEther('0.99970811').toString(),
    WETH: ethers.utils.parseEther('1').toString(),        
    aDAI: ethers.utils.parseEther('0.99970811').toString(),
    aWETH: ethers.utils.parseEther('1').toString(),
    aUSDC: ethers.utils.parseEther('0.999940').toString(),
    aUSDT: ethers.utils.parseEther('1.0001').toString(),
}



