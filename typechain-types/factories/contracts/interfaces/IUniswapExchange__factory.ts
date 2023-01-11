/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  IUniswapExchange,
  IUniswapExchangeInterface,
} from "../../../contracts/interfaces/IUniswapExchange";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "provider",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "eth_amount",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "token_amount",
        type: "uint256",
      },
    ],
    name: "AddLiquidity",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "buyer",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "tokens_sold",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "eth_bought",
        type: "uint256",
      },
    ],
    name: "EthPurchase",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "provider",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "eth_amount",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "token_amount",
        type: "uint256",
      },
    ],
    name: "RemoveLiquidity",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "buyer",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "eth_sold",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "tokens_bought",
        type: "uint256",
      },
    ],
    name: "TokenPurchase",
    type: "event",
  },
];

export class IUniswapExchange__factory {
  static readonly abi = _abi;
  static createInterface(): IUniswapExchangeInterface {
    return new utils.Interface(_abi) as IUniswapExchangeInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IUniswapExchange {
    return new Contract(address, _abi, signerOrProvider) as IUniswapExchange;
  }
}