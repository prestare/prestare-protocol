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
} from "../../common";

export interface IStableDebtTokenInterface extends utils.Interface {
  functions: {
    "burn(address,uint256)": FunctionFragment;
    "getAverageStableRate()": FunctionFragment;
    "getIncentivesController()": FunctionFragment;
    "getSupplyData()": FunctionFragment;
    "getTotalSupplyAndAvgRate()": FunctionFragment;
    "getTotalSupplyLastUpdated()": FunctionFragment;
    "getUserLastUpdated(address)": FunctionFragment;
    "getUserStableRate(address)": FunctionFragment;
    "initialize(address,address,address,uint8,string,string,bytes)": FunctionFragment;
    "mint(address,address,uint256,uint256)": FunctionFragment;
    "principalBalanceOf(address)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "burn"
      | "getAverageStableRate"
      | "getIncentivesController"
      | "getSupplyData"
      | "getTotalSupplyAndAvgRate"
      | "getTotalSupplyLastUpdated"
      | "getUserLastUpdated"
      | "getUserStableRate"
      | "initialize"
      | "mint"
      | "principalBalanceOf"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "burn",
    values: [PromiseOrValue<string>, PromiseOrValue<BigNumberish>]
  ): string;
  encodeFunctionData(
    functionFragment: "getAverageStableRate",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getIncentivesController",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getSupplyData",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getTotalSupplyAndAvgRate",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getTotalSupplyLastUpdated",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getUserLastUpdated",
    values: [PromiseOrValue<string>]
  ): string;
  encodeFunctionData(
    functionFragment: "getUserStableRate",
    values: [PromiseOrValue<string>]
  ): string;
  encodeFunctionData(
    functionFragment: "initialize",
    values: [
      PromiseOrValue<string>,
      PromiseOrValue<string>,
      PromiseOrValue<string>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<string>,
      PromiseOrValue<string>,
      PromiseOrValue<BytesLike>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "mint",
    values: [
      PromiseOrValue<string>,
      PromiseOrValue<string>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "principalBalanceOf",
    values: [PromiseOrValue<string>]
  ): string;

  decodeFunctionResult(functionFragment: "burn", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "getAverageStableRate",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getIncentivesController",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getSupplyData",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getTotalSupplyAndAvgRate",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getTotalSupplyLastUpdated",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getUserLastUpdated",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getUserStableRate",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "initialize", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "mint", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "principalBalanceOf",
    data: BytesLike
  ): Result;

  events: {
    "Burn(address,uint256,uint256,uint256,uint256,uint256)": EventFragment;
    "Initialized(address,address,address,uint8,string,string,bytes)": EventFragment;
    "Mint(address,address,uint256,uint256,uint256,uint256,uint256,uint256)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "Burn"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "Initialized"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "Mint"): EventFragment;
}

export interface BurnEventObject {
  user: string;
  amount: BigNumber;
  currentBalance: BigNumber;
  balanceIncrease: BigNumber;
  avgStableRate: BigNumber;
  newTotalSupply: BigNumber;
}
export type BurnEvent = TypedEvent<
  [string, BigNumber, BigNumber, BigNumber, BigNumber, BigNumber],
  BurnEventObject
>;

export type BurnEventFilter = TypedEventFilter<BurnEvent>;

export interface InitializedEventObject {
  underlyingAsset: string;
  pool: string;
  incentivesController: string;
  debtTokenDecimals: number;
  debtTokenName: string;
  debtTokenSymbol: string;
  params: string;
}
export type InitializedEvent = TypedEvent<
  [string, string, string, number, string, string, string],
  InitializedEventObject
>;

export type InitializedEventFilter = TypedEventFilter<InitializedEvent>;

export interface MintEventObject {
  user: string;
  onBehalfOf: string;
  amount: BigNumber;
  currentBalance: BigNumber;
  balanceIncrease: BigNumber;
  newRate: BigNumber;
  avgStableRate: BigNumber;
  newTotalSupply: BigNumber;
}
export type MintEvent = TypedEvent<
  [
    string,
    string,
    BigNumber,
    BigNumber,
    BigNumber,
    BigNumber,
    BigNumber,
    BigNumber
  ],
  MintEventObject
>;

export type MintEventFilter = TypedEventFilter<MintEvent>;

export interface IStableDebtToken extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IStableDebtTokenInterface;

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
    burn(
      user: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    getAverageStableRate(overrides?: CallOverrides): Promise<[BigNumber]>;

    getIncentivesController(overrides?: CallOverrides): Promise<[string]>;

    getSupplyData(
      overrides?: CallOverrides
    ): Promise<[BigNumber, BigNumber, BigNumber, number]>;

    getTotalSupplyAndAvgRate(
      overrides?: CallOverrides
    ): Promise<[BigNumber, BigNumber]>;

    getTotalSupplyLastUpdated(overrides?: CallOverrides): Promise<[number]>;

    getUserLastUpdated(
      user: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<[number]>;

    getUserStableRate(
      user: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    initialize(
      pool: PromiseOrValue<string>,
      underlyingAsset: PromiseOrValue<string>,
      incentivesController: PromiseOrValue<string>,
      debtTokenDecimals: PromiseOrValue<BigNumberish>,
      debtTokenName: PromiseOrValue<string>,
      debtTokenSymbol: PromiseOrValue<string>,
      params: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    mint(
      user: PromiseOrValue<string>,
      onBehalfOf: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      rate: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    principalBalanceOf(
      user: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;
  };

  burn(
    user: PromiseOrValue<string>,
    amount: PromiseOrValue<BigNumberish>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  getAverageStableRate(overrides?: CallOverrides): Promise<BigNumber>;

  getIncentivesController(overrides?: CallOverrides): Promise<string>;

  getSupplyData(
    overrides?: CallOverrides
  ): Promise<[BigNumber, BigNumber, BigNumber, number]>;

  getTotalSupplyAndAvgRate(
    overrides?: CallOverrides
  ): Promise<[BigNumber, BigNumber]>;

  getTotalSupplyLastUpdated(overrides?: CallOverrides): Promise<number>;

  getUserLastUpdated(
    user: PromiseOrValue<string>,
    overrides?: CallOverrides
  ): Promise<number>;

  getUserStableRate(
    user: PromiseOrValue<string>,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  initialize(
    pool: PromiseOrValue<string>,
    underlyingAsset: PromiseOrValue<string>,
    incentivesController: PromiseOrValue<string>,
    debtTokenDecimals: PromiseOrValue<BigNumberish>,
    debtTokenName: PromiseOrValue<string>,
    debtTokenSymbol: PromiseOrValue<string>,
    params: PromiseOrValue<BytesLike>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  mint(
    user: PromiseOrValue<string>,
    onBehalfOf: PromiseOrValue<string>,
    amount: PromiseOrValue<BigNumberish>,
    rate: PromiseOrValue<BigNumberish>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  principalBalanceOf(
    user: PromiseOrValue<string>,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  callStatic: {
    burn(
      user: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<void>;

    getAverageStableRate(overrides?: CallOverrides): Promise<BigNumber>;

    getIncentivesController(overrides?: CallOverrides): Promise<string>;

    getSupplyData(
      overrides?: CallOverrides
    ): Promise<[BigNumber, BigNumber, BigNumber, number]>;

    getTotalSupplyAndAvgRate(
      overrides?: CallOverrides
    ): Promise<[BigNumber, BigNumber]>;

    getTotalSupplyLastUpdated(overrides?: CallOverrides): Promise<number>;

    getUserLastUpdated(
      user: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<number>;

    getUserStableRate(
      user: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    initialize(
      pool: PromiseOrValue<string>,
      underlyingAsset: PromiseOrValue<string>,
      incentivesController: PromiseOrValue<string>,
      debtTokenDecimals: PromiseOrValue<BigNumberish>,
      debtTokenName: PromiseOrValue<string>,
      debtTokenSymbol: PromiseOrValue<string>,
      params: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<void>;

    mint(
      user: PromiseOrValue<string>,
      onBehalfOf: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      rate: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<boolean>;

    principalBalanceOf(
      user: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;
  };

  filters: {
    "Burn(address,uint256,uint256,uint256,uint256,uint256)"(
      user?: PromiseOrValue<string> | null,
      amount?: null,
      currentBalance?: null,
      balanceIncrease?: null,
      avgStableRate?: null,
      newTotalSupply?: null
    ): BurnEventFilter;
    Burn(
      user?: PromiseOrValue<string> | null,
      amount?: null,
      currentBalance?: null,
      balanceIncrease?: null,
      avgStableRate?: null,
      newTotalSupply?: null
    ): BurnEventFilter;

    "Initialized(address,address,address,uint8,string,string,bytes)"(
      underlyingAsset?: PromiseOrValue<string> | null,
      pool?: PromiseOrValue<string> | null,
      incentivesController?: null,
      debtTokenDecimals?: null,
      debtTokenName?: null,
      debtTokenSymbol?: null,
      params?: null
    ): InitializedEventFilter;
    Initialized(
      underlyingAsset?: PromiseOrValue<string> | null,
      pool?: PromiseOrValue<string> | null,
      incentivesController?: null,
      debtTokenDecimals?: null,
      debtTokenName?: null,
      debtTokenSymbol?: null,
      params?: null
    ): InitializedEventFilter;

    "Mint(address,address,uint256,uint256,uint256,uint256,uint256,uint256)"(
      user?: PromiseOrValue<string> | null,
      onBehalfOf?: PromiseOrValue<string> | null,
      amount?: null,
      currentBalance?: null,
      balanceIncrease?: null,
      newRate?: null,
      avgStableRate?: null,
      newTotalSupply?: null
    ): MintEventFilter;
    Mint(
      user?: PromiseOrValue<string> | null,
      onBehalfOf?: PromiseOrValue<string> | null,
      amount?: null,
      currentBalance?: null,
      balanceIncrease?: null,
      newRate?: null,
      avgStableRate?: null,
      newTotalSupply?: null
    ): MintEventFilter;
  };

  estimateGas: {
    burn(
      user: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    getAverageStableRate(overrides?: CallOverrides): Promise<BigNumber>;

    getIncentivesController(overrides?: CallOverrides): Promise<BigNumber>;

    getSupplyData(overrides?: CallOverrides): Promise<BigNumber>;

    getTotalSupplyAndAvgRate(overrides?: CallOverrides): Promise<BigNumber>;

    getTotalSupplyLastUpdated(overrides?: CallOverrides): Promise<BigNumber>;

    getUserLastUpdated(
      user: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getUserStableRate(
      user: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    initialize(
      pool: PromiseOrValue<string>,
      underlyingAsset: PromiseOrValue<string>,
      incentivesController: PromiseOrValue<string>,
      debtTokenDecimals: PromiseOrValue<BigNumberish>,
      debtTokenName: PromiseOrValue<string>,
      debtTokenSymbol: PromiseOrValue<string>,
      params: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    mint(
      user: PromiseOrValue<string>,
      onBehalfOf: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      rate: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    principalBalanceOf(
      user: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    burn(
      user: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    getAverageStableRate(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getIncentivesController(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getSupplyData(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getTotalSupplyAndAvgRate(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getTotalSupplyLastUpdated(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getUserLastUpdated(
      user: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getUserStableRate(
      user: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    initialize(
      pool: PromiseOrValue<string>,
      underlyingAsset: PromiseOrValue<string>,
      incentivesController: PromiseOrValue<string>,
      debtTokenDecimals: PromiseOrValue<BigNumberish>,
      debtTokenName: PromiseOrValue<string>,
      debtTokenSymbol: PromiseOrValue<string>,
      params: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    mint(
      user: PromiseOrValue<string>,
      onBehalfOf: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      rate: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    principalBalanceOf(
      user: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;
  };
}