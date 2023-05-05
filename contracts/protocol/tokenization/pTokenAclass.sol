// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.10;

// import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
// import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
// import {ICounter} from '../../interfaces/ICounter.sol';
// import {IPToken} from '../../interfaces/IPToken.sol';
// import {WadRayMath} from '../libraries/math/WadRayMath.sol';
// import {Errors} from '../libraries/helpers/Errors.sol';

// import {IncentivizedERC20} from './IncentivizedERC20.sol';
// import "hardhat/console.sol";

// /**
//  * @title Prestare ERC20 A tier pToken
//  * @dev Implementation of the interest bearing token for the Prestare protocol
//  */
// contract pTokenAclass is
//   IncentivizedERC20('PTOKEN_IMPL', 'PTOKEN_IMPL', 0),
//   IPToken
// {
//   using WadRayMath for uint256;
//   using SafeERC20 for IERC20;

//   bytes public constant EIP712_REVISION = bytes('1');
//   bytes32 internal constant EIP712_DOMAIN =
//     keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)');
//   bytes32 public constant PERMIT_TYPEHASH =
//     keccak256('Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)');

//   uint256 public constant PTOKEN_REVISION = 0x1;

//   /// @dev owner => next valid nonce to submit with permit()
//   mapping(address => uint256) public _nonces;

//   bytes32 public DOMAIN_SEPARATOR;

//   ICounter internal _counter;
//   address internal _treasury;
//   address internal _underlyingAsset;
  
//   mapping (address => uint256) _APool;
//   mapping (address => uint256) _BPool;
//   mapping (address => uint256) _CPool;
//   uint8 internal _assetTier;
//   modifier onlyCounter {
//     require(_msgSender() == address(_counter), Errors.CT_CALLER_MUST_BE_Counter);
//     _;
//   }

//   /**
//    * @dev Initializes the A tier pToken
//    * @param counter The address of the Counter where this pToken will be used
//    * @param treasury The address of the treasury, receiving the fees on this pToken
//    * @param underlyingAsset The address of the underlying asset of this pToken (E.g. WETH for aWETH)
//    * @param assetTier The asset Tier of the underlying asset
//    * @param pTokenDecimals The decimals of the pToken, same as the underlying asset's
//    * @param pTokenName The name of the pToken
//    * @param pTokenSymbol The symbol of the pToken
//    */
//   function initialize(
//     ICounter counter,
//     address treasury,
//     address underlyingAsset,
//     uint8 assetTier,
//     uint8 pTokenDecimals,
//     string calldata pTokenName,
//     string calldata pTokenSymbol,
//     bytes calldata params
//   ) external {
//     uint256 chainId;

//     //solium-disable-next-line
//     assembly {
//       chainId := chainid()
//     }

//     DOMAIN_SEPARATOR = keccak256(
//       abi.encode(
//         EIP712_DOMAIN,
//         keccak256(bytes(pTokenName)),
//         keccak256(EIP712_REVISION),
//         chainId,
//         address(this)
//       )
//     );

//     _setName(pTokenName);
//     _setSymbol(pTokenSymbol);
//     _setDecimals(pTokenDecimals);

//     _counter = counter;
//     _treasury = treasury;
//     _underlyingAsset = underlyingAsset;
//     _assetTier = assetTier;
//   }

//   /**
//    * @dev Mints `amount` pTokens to `user`
//    * - Only callable by the Counter, as extra state updates there need to be managed
//    * @param user The address receiving the minted tokens
//    * @param amount The amount of tokens getting minted
//    * @param index The new liquidity index of the reserve
//    * @return `true` if the the previous balance of the user was 0
//    */
//   function mint(
//     address user,
//     uint256 amount,
//     uint256 index,
//     uint8 assetTier
//   ) external override onlyCounter returns (bool) {
//     uint256 previousBalance = super.balanceOf(user);

//     uint256 amountScaled = amount.rayDiv(index);
//     require(assetTier >= _assetTier && assetTier <= 3, Errors.WRONG_TARGET_ASSET_TIER);
//     require(amountScaled != 0, Errors.CT_INVALID_MINT_AMOUNT);
//     _mint(user, amountScaled);
//     if (assetTier == 1) {
//         _APool[user] += amountScaled;
//     } else if (assetTier == 2) {
//         _BPool[user] += amountScaled;
//     } else if (assetTier == 3) {
//         _CPool[user] += amountScaled;
//     }
//     emit Transfer(address(0), user, amount);
//     emit Mint(user, amount, index);
//     // console.log("previousBalance is: ", previousBalance);
//     return previousBalance == 0;
//   }
// }
