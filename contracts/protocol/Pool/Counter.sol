// SPDX-License-Identifier: none
pragma solidity ^0.8.10;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ICounter} from '../../interfaces/ICounter.sol';
import {ICounterAddressesProvider} from '../../interfaces/ICounterAddressesProvider.sol';
import {IPToken} from '../../interfaces/IPToken.sol';
import {CounterStorage} from './CounterStorage.sol';

import {ReserveConfiguration} from '../libraries/configuration/ReserveConfiguration.sol';
import {UserConfiguration} from '../libraries/configuration/UserConfiguration.sol';

import {Errors} from '../libraries/helpers/Errors.sol';
import {ReserveLogic} from '../libraries/logic/ReserveLogic.sol';
// import {GenericLogic} from '../libraries/logic/GenericLogic.sol';
import {ValidationLogic} from '../libraries/logic/ValidationLogic.sol';

import {DataTypes} from '../libraries/types/DataTypes.sol';

/**
 * @title Prestare Counter contract
 * @dev Main point of interaction with an Prestare protocol's market
 * - Users can:
 *   # Deposit
 *   # Withdraw
 *   # Borrow
 *   # Repay
 *   # Liquidate positions
 *   # Execute Flash Loans
 * - To be covered by a proxy contract, owned by the CounterAddressesProvider of the specific market
 * - All admin functions are callable by the CounterConfigurator contract defined also in the
 *   CounterAddressesProvider
 * @author Prestare
 **/

contract Counter is ICounter, CounterStorage {
  using ReserveLogic for DataTypes.ReserveData;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;

  ICounterAddressesProvider public immutable _addressesProvider;

  modifier whenNotPaused() {
    _whenNotPaused();
    _;
  }

  modifier onlyLendingPoolConfigurator() {
    _onlyLendingPoolConfigurator();
    _;
  }

  function _whenNotPaused() internal view {
    require(!_paused, Errors.LP_IS_PAUSED);
  }

  function _onlyLendingPoolConfigurator() internal view {
    require(
      _addressesProvider.getCounterConfigurator() == msg.sender,
      Errors.LP_CALLER_NOT_LENDING_POOL_CONFIGURATOR
    );
  }

  /**
   * @dev Constructor.
   * @param provider The address of the PoolAddressesProvider contract
   */
  constructor(ICounterAddressesProvider provider) {
    _addressesProvider = provider;
  }

  /**
   * @dev Function is invoked by the proxy contract when the Counter contract is added to the
   * CounterAddressesProvider of the market.
   * - Caching the address of the CounterAddressesProvider in order to reduce gas consumption
   *   on subsequent operations
   * @param provider The address of the CounterAddressesProvider
   **/
  function initialize(ICounterAddressesProvider provider) public {
    _flashLoanPremiumTotal = 9;
    _maxNumberOfReserves = 128;
  }

  /**
   * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
   * - E.g. User deposits 100 USDC and gets in return 100 aUSDC
   * @param asset The address of the underlying asset to deposit
   * @param amount The amount to be deposited
   * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user
   *   wants to receive them on his own wallet, or a different address if the beneficiary of aTokens
   *   is a different wallet
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the action is executed directly by the user, without any middle-man
   **/
  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external override whenNotPaused {
    DataTypes.ReserveData storage reserve = _reserves[asset];

    ValidationLogic.validateDeposit(reserve, amount);

    address pToken = reserve.aTokenAddress;

    reserve.updateState();
    reserve.updateInterestRates(asset, pToken, amount, 0);

    IERC20(asset).transferFrom(msg.sender, pToken, amount);

    bool isFirstDeposit = IPToken(pToken).mint(onBehalfOf, amount, reserve.liquidityIndex);

    if (isFirstDeposit) {
      _usersConfig[onBehalfOf].setUsingAsCollateral(reserve.id, true);
      emit ReserveUsedAsCollateralEnabled(asset, onBehalfOf);
    }

    emit Deposit(asset, msg.sender, onBehalfOf, amount, referralCode);
  }

}

