/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
  BigNumberish,
  BytesLike,
  CallOverrides,
  ContractTransaction,
  Overrides,
  PopulatedTransaction,
  Signer,
  utils,
} from "ethers";
import type {
  FunctionFragment,
  Result,
  EventFragment,
} from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type {
  TypedEventFilter,
  TypedEvent,
  TypedListener,
  OnEvent,
  PromiseOrValue,
} from "../../../common";

export interface MockFlashLoanReceiverInterface extends utils.Interface {
  functions: {
    "ADDRESSES_PROVIDER()": FunctionFragment;
    "LENDING_POOL()": FunctionFragment;
    "amountToApprove()": FunctionFragment;
    "executeOperation(address[],uint256[],uint256[],address,bytes)": FunctionFragment;
    "setAmountToApprove(uint256)": FunctionFragment;
    "setFailExecutionTransfer(bool)": FunctionFragment;
    "setSimulateEOA(bool)": FunctionFragment;
    "simulateEOA()": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "ADDRESSES_PROVIDER"
      | "LENDING_POOL"
      | "amountToApprove"
      | "executeOperation"
      | "setAmountToApprove"
      | "setFailExecutionTransfer"
      | "setSimulateEOA"
      | "simulateEOA"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "ADDRESSES_PROVIDER",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "LENDING_POOL",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "amountToApprove",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "executeOperation",
    values: [
      PromiseOrValue<string>[],
      PromiseOrValue<BigNumberish>[],
      PromiseOrValue<BigNumberish>[],
      PromiseOrValue<string>,
      PromiseOrValue<BytesLike>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "setAmountToApprove",
    values: [PromiseOrValue<BigNumberish>]
  ): string;
  encodeFunctionData(
    functionFragment: "setFailExecutionTransfer",
    values: [PromiseOrValue<boolean>]
  ): string;
  encodeFunctionData(
    functionFragment: "setSimulateEOA",
    values: [PromiseOrValue<boolean>]
  ): string;
  encodeFunctionData(
    functionFragment: "simulateEOA",
    values?: undefined
  ): string;

  decodeFunctionResult(
    functionFragment: "ADDRESSES_PROVIDER",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "LENDING_POOL",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "amountToApprove",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "executeOperation",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setAmountToApprove",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setFailExecutionTransfer",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setSimulateEOA",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "simulateEOA",
    data: BytesLike
  ): Result;

  events: {
    "ExecutedWithFail(address[],uint256[],uint256[])": EventFragment;
    "ExecutedWithSuccess(address[],uint256[],uint256[])": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "ExecutedWithFail"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "ExecutedWithSuccess"): EventFragment;
}

export interface ExecutedWithFailEventObject {
  _assets: string[];
  _amounts: BigNumber[];
  _premiums: BigNumber[];
}
export type ExecutedWithFailEvent = TypedEvent<
  [string[], BigNumber[], BigNumber[]],
  ExecutedWithFailEventObject
>;

export type ExecutedWithFailEventFilter =
  TypedEventFilter<ExecutedWithFailEvent>;

export interface ExecutedWithSuccessEventObject {
  _assets: string[];
  _amounts: BigNumber[];
  _premiums: BigNumber[];
}
export type ExecutedWithSuccessEvent = TypedEvent<
  [string[], BigNumber[], BigNumber[]],
  ExecutedWithSuccessEventObject
>;

export type ExecutedWithSuccessEventFilter =
  TypedEventFilter<ExecutedWithSuccessEvent>;

export interface MockFlashLoanReceiver extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: MockFlashLoanReceiverInterface;

  queryFilter<TEvent extends TypedEvent>(
    event: TypedEventFilter<TEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TEvent>>;

  listeners<TEvent extends TypedEvent>(
    eventFilter?: TypedEventFilter<TEvent>
  ): Array<TypedListener<TEvent>>;
  listeners(eventName?: string): Array<Listener>;
  removeAllListeners<TEvent extends TypedEvent>(
    eventFilter: TypedEventFilter<TEvent>
  ): this;
  removeAllListeners(eventName?: string): this;
  off: OnEvent<this>;
  on: OnEvent<this>;
  once: OnEvent<this>;
  removeListener: OnEvent<this>;

  functions: {
    ADDRESSES_PROVIDER(overrides?: CallOverrides): Promise<[string]>;

    LENDING_POOL(overrides?: CallOverrides): Promise<[string]>;

    amountToApprove(overrides?: CallOverrides): Promise<[BigNumber]>;

    executeOperation(
      assets: PromiseOrValue<string>[],
      amounts: PromiseOrValue<BigNumberish>[],
      premiums: PromiseOrValue<BigNumberish>[],
      initiator: PromiseOrValue<string>,
      params: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    setAmountToApprove(
      amountToApprove: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    setFailExecutionTransfer(
      fail: PromiseOrValue<boolean>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    setSimulateEOA(
      flag: PromiseOrValue<boolean>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    simulateEOA(overrides?: CallOverrides): Promise<[boolean]>;
  };

  ADDRESSES_PROVIDER(overrides?: CallOverrides): Promise<string>;

  LENDING_POOL(overrides?: CallOverrides): Promise<string>;

  amountToApprove(overrides?: CallOverrides): Promise<BigNumber>;

  executeOperation(
    assets: PromiseOrValue<string>[],
    amounts: PromiseOrValue<BigNumberish>[],
    premiums: PromiseOrValue<BigNumberish>[],
    initiator: PromiseOrValue<string>,
    params: PromiseOrValue<BytesLike>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  setAmountToApprove(
    amountToApprove: PromiseOrValue<BigNumberish>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  setFailExecutionTransfer(
    fail: PromiseOrValue<boolean>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  setSimulateEOA(
    flag: PromiseOrValue<boolean>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  simulateEOA(overrides?: CallOverrides): Promise<boolean>;

  callStatic: {
    ADDRESSES_PROVIDER(overrides?: CallOverrides): Promise<string>;

    LENDING_POOL(overrides?: CallOverrides): Promise<string>;

    amountToApprove(overrides?: CallOverrides): Promise<BigNumber>;

    executeOperation(
      assets: PromiseOrValue<string>[],
      amounts: PromiseOrValue<BigNumberish>[],
      premiums: PromiseOrValue<BigNumberish>[],
      initiator: PromiseOrValue<string>,
      params: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<boolean>;

    setAmountToApprove(
      amountToApprove: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<void>;

    setFailExecutionTransfer(
      fail: PromiseOrValue<boolean>,
      overrides?: CallOverrides
    ): Promise<void>;

    setSimulateEOA(
      flag: PromiseOrValue<boolean>,
      overrides?: CallOverrides
    ): Promise<void>;

    simulateEOA(overrides?: CallOverrides): Promise<boolean>;
  };

  filters: {
    "ExecutedWithFail(address[],uint256[],uint256[])"(
      _assets?: null,
      _amounts?: null,
      _premiums?: null
    ): ExecutedWithFailEventFilter;
    ExecutedWithFail(
      _assets?: null,
      _amounts?: null,
      _premiums?: null
    ): ExecutedWithFailEventFilter;

    "ExecutedWithSuccess(address[],uint256[],uint256[])"(
      _assets?: null,
      _amounts?: null,
      _premiums?: null
    ): ExecutedWithSuccessEventFilter;
    ExecutedWithSuccess(
      _assets?: null,
      _amounts?: null,
      _premiums?: null
    ): ExecutedWithSuccessEventFilter;
  };

  estimateGas: {
    ADDRESSES_PROVIDER(overrides?: CallOverrides): Promise<BigNumber>;

    LENDING_POOL(overrides?: CallOverrides): Promise<BigNumber>;

    amountToApprove(overrides?: CallOverrides): Promise<BigNumber>;

    executeOperation(
      assets: PromiseOrValue<string>[],
      amounts: PromiseOrValue<BigNumberish>[],
      premiums: PromiseOrValue<BigNumberish>[],
      initiator: PromiseOrValue<string>,
      params: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    setAmountToApprove(
      amountToApprove: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    setFailExecutionTransfer(
      fail: PromiseOrValue<boolean>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    setSimulateEOA(
      flag: PromiseOrValue<boolean>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    simulateEOA(overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    ADDRESSES_PROVIDER(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    LENDING_POOL(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    amountToApprove(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    executeOperation(
      assets: PromiseOrValue<string>[],
      amounts: PromiseOrValue<BigNumberish>[],
      premiums: PromiseOrValue<BigNumberish>[],
      initiator: PromiseOrValue<string>,
      params: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    setAmountToApprove(
      amountToApprove: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    setFailExecutionTransfer(
      fail: PromiseOrValue<boolean>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    setSimulateEOA(
      flag: PromiseOrValue<boolean>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    simulateEOA(overrides?: CallOverrides): Promise<PopulatedTransaction>;
  };
}