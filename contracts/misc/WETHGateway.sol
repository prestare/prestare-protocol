// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Ownable} from '../CRT/openzeppelin/Ownable.sol';

import {IWETH} from '../interfaces/IWETH.sol';
import {IWETHGateway} from '../interfaces/IWETHGateway.sol';
import {ICounter} from '../interfaces/ICounter.sol';
import {IPToken} from '../interfaces/IPToken.sol';
import {ReserveConfiguration} from '../protocol/libraries/configuration/ReserveConfiguration.sol';
import {UserConfiguration} from '../protocol/libraries/configuration/UserConfiguration.sol';
import {Helpers} from '../protocol/libraries/helpers/Helpers.sol';
import {DataTypes} from '../protocol/libraries/types/DataTypes.sol';
import "hardhat/console.sol";
contract WETHGateway is IWETHGateway, Ownable {
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;

  IWETH internal immutable WETH;

  /**
   * @dev Sets the WETH address and the CounterAddressesProvider address. Infinite approves Counter.
   * @param weth Address of the Wrapped Ether contract
   **/
  constructor(address weth) {
    WETH = IWETH(weth);
  }

  function authorizeCounter(address counter) external onlyOwner {
    console.log("authorizeCounter");
    bool result = WETH.approve(counter, type(uint256).max);
  }

  /**
   * @dev deposits WETH into the reserve, using native ETH. A corresponding amount of the overlying asset (pTokens)
   * is minted.
   * @param counter address of the targeted underlying Counter
   * @param riskTier The risk tier of WETH user want to deposit
   * @param onBehalfOf address of the user who will receive the pTokens representing the deposit
   * @param referralCode integrators are assigned a referral code and can potentially receive rewards.
   **/
  function depositETH(
    address counter,
    uint8 riskTier,
    address onBehalfOf,
    uint16 referralCode
  ) external payable override {
    WETH.deposit{value: msg.value}();
    ICounter(counter).deposit(address(WETH), riskTier, msg.value, onBehalfOf, referralCode);
  }

  /**
   * @dev withdraws the WETH _reserves of msg.sender.
   * @param counter address of the targeted underlying Counter
   * @param riskTier The risk tier of WETH user want to deposit
   * @param amount amount of aWETH to withdraw and receive native ETH
   * @param to address of the user who will receive native ETH
   */
  function withdrawETH(
    address counter,
    uint8 riskTier,
    uint256 amount,
    address to
  ) external override {
    IPToken pWETH = IPToken(ICounter(counter).getReserveData(address(WETH), riskTier).pTokenAddress);
    uint256 userBalance = pWETH.balanceOf(msg.sender);
    uint256 amountToWithdraw = amount;

    // if amount is equal to uint(-1), the user wants to redeem everything
    if (amount == type(uint256).max) {
      amountToWithdraw = userBalance;
    }
    pWETH.transferFrom(msg.sender, address(this), amountToWithdraw);
    ICounter(counter).withdraw(address(WETH), riskTier, amountToWithdraw, address(this));
    WETH.withdraw(amountToWithdraw);
    _safeTransferETH(to, amountToWithdraw);
  }

  /**
   * @dev repays a borrow on the WETH reserve, for the specified amount (or for the whole amount, if uint256(-1) is specified).
   * @param counter address of the targeted underlying Counter
   * @param riskTier The risk tier of WETH user want to deposit
   * @param amount the amount to repay, or uint256(-1) if the user wants to repay everything
   * @param rateMode the rate mode to repay
   * @param onBehalfOf the address for which msg.sender is repaying
   */
  function repayETH(
    address counter,
    uint8 riskTier,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external payable override {
    uint256 variableDebt =
      Helpers.getUserCurrentDebtMemory(
        onBehalfOf,
        ICounter(counter).getReserveData(address(WETH), riskTier)
      );

    uint256 paybackAmount = variableDebt;

    if (amount < paybackAmount) {
      paybackAmount = amount;
    }
    require(msg.value >= paybackAmount, 'msg.value is less than repayment amount');
    WETH.deposit{value: paybackAmount}();
    ICounter(counter).repay(address(WETH), riskTier, msg.value, rateMode, onBehalfOf);

    // refund remaining dust eth
    if (msg.value > paybackAmount) _safeTransferETH(msg.sender, msg.value - paybackAmount);
  }

  /**
   * @dev borrow WETH, unwraps to ETH and send both the ETH and DebtTokens to msg.sender, via `approveDelegation` and onBehalf argument in `Counter.borrow`.
   * @param counter address of the targeted underlying Counter
   * @param riskTier The risk tier of WETH user want to deposit
   * @param amount the amount of ETH to borrow
   * @param interesRateMode the interest rate mode
   * @param referralCode integrators are assigned a referral code and can potentially receive rewards
   */
  function borrowETH(
    address counter,
    uint8 riskTier,
    uint256 amount,
    uint256 interesRateMode,
    uint16 referralCode,
    bool crtenable
  ) external override {
    ICounter(counter).borrow(
      address(WETH),
      riskTier,
      amount,
      interesRateMode,
      referralCode,
      msg.sender,
      crtenable
    );
    WETH.withdraw(amount);
    _safeTransferETH(msg.sender, amount);
  }

  /**
   * @dev transfer ETH to an address, revert if it fails.
   * @param to recipient of the transfer
   * @param value the amount to send
   */
  function _safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, 'ETH_TRANSFER_FAILED');
  }

  /**
   * @dev transfer ERC20 from the utility contract, for ERC20 recovery in case of stuck tokens due
   * direct transfers to the contract address.
   * @param token token to transfer
   * @param to recipient of the transfer
   * @param amount amount to send
   */
  function emergencyTokenTransfer(
    address token,
    address to,
    uint256 amount
  ) external onlyOwner {
    IERC20(token).transfer(to, amount);
  }

  /**
   * @dev transfer native Ether from the utility contract, for native Ether recovery in case of stuck Ether
   * due selfdestructs or transfer ether to pre-computated contract address before deployment.
   * @param to recipient of the transfer
   * @param amount amount to send
   */
  function emergencyEtherTransfer(address to, uint256 amount) external onlyOwner {
    _safeTransferETH(to, amount);
  }

  /**
   * @dev Get WETH address used by WETHGateway
   */
  function getWETHAddress() external view returns (address) {
    return address(WETH);
  }

  /**
   * @dev Only WETH contract is allowed to transfer ETH here. Prevent other addresses to send Ether to this contract.
   */
  receive() external payable {
    require(msg.sender == address(WETH), 'Receive not allowed');
  }

  /**
   * @dev Revert fallback calls
   */
  fallback() external payable {
    revert('Fallback not allowed');
  }
}
