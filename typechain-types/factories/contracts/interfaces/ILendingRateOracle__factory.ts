/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  ILendingRateOracle,
  ILendingRateOracleInterface,
} from "../../../contracts/interfaces/ILendingRateOracle";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "asset",
        type: "address",
      },
    ],
    name: "getMarketBorrowRate",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "asset",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "rate",
        type: "uint256",
      },
    ],
    name: "setMarketBorrowRate",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

export class ILendingRateOracle__factory {
  static readonly abi = _abi;
  static createInterface(): ILendingRateOracleInterface {
    return new utils.Interface(_abi) as ILendingRateOracleInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): ILendingRateOracle {
    return new Contract(address, _abi, signerOrProvider) as ILendingRateOracle;
  }
}
