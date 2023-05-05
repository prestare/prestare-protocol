import { ethers } from 'hardhat';
import { expect } from "chai";
import { Block } from "@ethersproject/abstract-provider"
import  { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { BigNumber } from 'bignumber.js';

const dfn = function(x: any, dflt: any) {
    return x == undefined ? dflt : x;
}

const etherMantissa = function(num: BigNumber.Value, scale = 1e18) {
    return new BigNumber(num).times(scale);
}

const etherUnsigned = function (num: BigNumber.Value) {
    return new BigNumber(num);
}
const fastForward = async(seconds: number, ethers_ = ethers) => {
    const block = await getBlock();
    await ethers_.provider.send('evm_setNextBlockTimestamp', [block.timestamp + seconds]);
    return block;
}

const getBlock = async (n?: any, ethers_ = ethers) => {
    const blockNumber = n == undefined ? await ethers_.provider.getBlockNumber() : n;
    return ethers_.provider.getBlock(blockNumber);
}

const harnessSetTotalsBasic = async(token: any, overrides = {}) => {
    const t0 = await token.totalBasic();
    // console.log(t0);
    const t1 = Object.assign({}, t0, overrides);
    // console.log("Assign ok",t1);
    await wait(token.harnessSetTotalsBasic(t1));
    return t1;
}

const UInt256Max = () => {
    return ethers.constants.MaxUint256;
}

const wait = async (tx: any) => {
    const tx_ = await tx;
    let receipt = await tx_.wait();
    return {
      ...tx_,
      receipt,
    };
}
// export const event = (tx: ethers.TransactionReceipt , index: number) => {
//     const ev: any = tx.receipt.events[index], args: any = {};
//     for (const k in ev.args) {
//       const v = ev.args[k];
//       if (isNaN(Number(k))) {
//         if (v._isBigNumber) {
//           args[k] = BigInt(v);
//         } else if (Array.isArray(v)) {
//           args[k] = convertToBigInt(v);
//         } else {
//           args[k] = v;
//         }
//       }
//     }
//     return { [ev.event]: args };
// }

module.exports = {
    dfn,
    ethers,
    etherMantissa,
    etherUnsigned,
    expect,
    fastForward,
    getBlock,
    harnessSetTotalsBasic,
    UInt256Max,
    wait,
};
  