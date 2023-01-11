/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  ChainlinkUSDETHOracleI,
  ChainlinkUSDETHOracleIInterface,
} from "../../../../contracts/mocks/oracle/ChainlinkUSDETHOracleI";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "int256",
        name: "current",
        type: "int256",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "answerId",
        type: "uint256",
      },
    ],
    name: "AnswerUpdated",
    type: "event",
  },
];

export class ChainlinkUSDETHOracleI__factory {
  static readonly abi = _abi;
  static createInterface(): ChainlinkUSDETHOracleIInterface {
    return new utils.Interface(_abi) as ChainlinkUSDETHOracleIInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): ChainlinkUSDETHOracleI {
    return new Contract(
      address,
      _abi,
      signerOrProvider
    ) as ChainlinkUSDETHOracleI;
  }
}
