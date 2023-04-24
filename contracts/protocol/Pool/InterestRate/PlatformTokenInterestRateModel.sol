// SPDX-License-Identifier: none
pragma solidity ^0.8.10;

import {IBaseRateModel} from '../../../interfaces/IBaseRateModel.sol';
import {WadRayMath} from '../../libraries/math/WadRayMath.sol';
import {PercentageMath} from '../../libraries/math/PercentageMath.sol';
import {ICounterAddressesProvider} from '../../../interfaces/ICounterAddressesProvider.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ILendingPool} from '../../../interfaces/aaveInterface/ILendingPool.sol';
import {Errors} from '../../libraries/helpers/Errors.sol';
import {ReserveConfiguration} from '../../libraries/configuration/ReserveConfiguration.sol';
import {DataTypes} from '../../libraries/types/DataTypes.sol';

import "hardhat/console.sol";

/**
 * @title DefaultReserveInterestRateStrategy contract
 * @notice Implements the calculation of the interest rates depending on the reserve state
 * @dev The model of interest rate is based on 2 slopes, one before the `OPTIMAL_UTILIZATION_RATE`
 * point of utilization and another from that one to 100%
 **/
contract PlatformTokenInterestRateModel is IBaseRateModel {
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using WadRayMath for uint256;
  using PercentageMath for uint256;
  ILendingPool internal _pool = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
  mapping(address => uint256) internal p2pSupplyIndex; // Current index from supply peer-to-peer unit to underlying (in ray).
  mapping(address => uint256) internal p2pBorrowIndex; // Current index from borrow peer-to-peer unit to underlying (in ray).
  mapping(address => PoolIndexes) internal poolIndexes; // Last pool index stored. paToken => Poolindexes
  mapping(address => Market) internal markets; // underlying => Market (like ausdt => (usdt, paUsdt))
  /// STRUCTS ///

  struct Market {
        address underlyingToken; // The address of the market's underlying token.
        address pToken;
  //       uint16 reserveFactor; // Proportion of the additional interest earned being matched peer-to-peer on Morpho compared to being on the pool. It is sent to the DAO for each market. The default value is 0. In basis point (100% = 10 000).
  //       uint16 p2pIndexCursor; // Position of the peer-to-peer rate in the pool's spread. Determine the weights of the weighted arithmetic average in the indexes computations ((1 - p2pIndexCursor) * r^S + p2pIndexCursor * r^B) (in basis point).
  }

  struct GrowthFactors {
      uint256 poolSupplyGrowthFactor; // The pool supply index growth factor (in ray).
      uint256 poolBorrowGrowthFactor; // The pool borrow index growth factor (in ray).
      uint256 p2pSupplyGrowthFactor; // Peer-to-peer supply index growth factor (in ray).
      uint256 p2pBorrowGrowthFactor; // Peer-to-peer borrow index growth factor (in ray).
  }

  struct P2PIndexComputeParams {
      uint256 poolGrowthFactor; // The pool index growth factor (in ray).
      uint256 p2pGrowthFactor; // Morpho's peer-to-peer median index growth factor (in ray).
      uint256 lastPoolIndex; // The last stored pool index (in ray).
      uint256 lastP2PIndex; // The last stored peer-to-peer index (in ray).
      // uint256 p2pDelta; // The peer-to-peer delta for the given market (in pool unit).
      // uint256 p2pAmount; // The peer-to-peer amount for the given market (in peer-to-peer unit).
  }
  struct P2PRateComputeParams {
      uint256 poolSupplyRatePerYear; // The pool supply rate per year (in ray).
      uint256 poolBorrowRatePerYear; // The pool borrow rate per year (in ray).
      uint256 poolIndex; // The last stored pool index (in ray).
      uint256 p2pIndex; // The last stored peer-to-peer index (in ray).
      // uint256 p2pDelta; // The peer-to-peer delta for the given market (in pool unit).
      // uint256 p2pAmount; // The peer-to-peer amount for the given market (in peer-to-peer unit).
      uint256 p2pIndexCursor; // The index cursor of the given market (in bps).
      uint256 reserveFactor; // The reserve factor of the given market (in bps).
  }

  /**
   * @notice Emitted when the peer-to-peer indexes of a market are updated.
   * @param _poolToken The address of the market updated.
   * @param _p2pSupplyIndex The updated supply index from peer-to-peer unit to underlying.
   * @param _p2pBorrowIndex The updated borrow index from peer-to-peer unit to underlying.
   * @param _poolSupplyIndex The updated pool supply index.
   * @param _poolBorrowIndex The updated pool borrow index.
   */
  event P2PIndexesUpdated(
      address indexed _poolToken,
      uint256 _p2pSupplyIndex,
      uint256 _p2pBorrowIndex,
      uint256 _poolSupplyIndex,
      uint256 _poolBorrowIndex
  );


  /**
   * @dev This constant represents the excess utilization rate above the optimal. It's always equal to
   * 1-optimal utilization rate. Added as a constant here for gas optimizations.
   * Expressed in ray
   **/

  uint256 public EXCESS_UTILIZATION_RATE;

  ICounterAddressesProvider public immutable addressesProvider;

  // uint256 internal pSupplyIndex;
  // uint256 internal opBorrowIndex;
  // PoolIndexes internal poolIndex;
  
  constructor(
    ICounterAddressesProvider provider
  ) public {
    addressesProvider = provider;
  }

  function createMarket(
      address _underlyingToken,
      address platformToken,
      address _pToken,
      uint16 _p2pIndexCursor
  ) external {
      require(_underlyingToken != address(0), Errors.ZERO_ADDRESS);
      // require(_pool.getConfiguration(_underlyingToken).getActive(), Errors.VL_NO_ACTIVE_RESERVE);
      p2pSupplyIndex[_pToken] = WadRayMath.RAY;
      p2pBorrowIndex[_pToken] = WadRayMath.RAY;
      PoolIndexes storage poolIndexes = poolIndexes[_pToken];
      poolIndexes.lastUpdateTimestamp = uint32(block.timestamp);
      poolIndexes.poolSupplyIndex = uint112(_pool.getReserveNormalizedIncome(_underlyingToken));
      console.log("poolSupplyIndex is",poolIndexes.poolSupplyIndex);
      poolIndexes.poolBorrowIndex = uint112(
          _pool.getReserveNormalizedVariableDebt(_underlyingToken)
      );
      console.log("poolBorrowIndex is",poolIndexes.poolBorrowIndex);

      markets[platformToken] = Market({
        underlyingToken: _underlyingToken,
        pToken: _pToken
      });
  }
  
  struct IRindex {
      uint256 newPoolSupplyIndex;
      uint256 newPoolBorrowIndex;
      uint256 newP2PSupplyIndex;
      uint256 newP2PBorrowIndex;
  }

  function getReserveIRIndex(address pToken) external view returns (
      uint256 nowP2PSupplyIndex,
      uint256 nowP2PBorrowIndex,
      uint112 poolSupplyIndex,
      uint112 poolBorrowIndex
    ) {
      PoolIndexes memory marketPoolIndexs = poolIndexes[pToken];
      nowP2PSupplyIndex = p2pSupplyIndex[pToken];
      nowP2PBorrowIndex = p2pBorrowIndex[pToken];
      poolSupplyIndex = marketPoolIndexs.poolSupplyIndex;
      poolBorrowIndex = marketPoolIndexs.poolBorrowIndex;
  }

  /**
   * @dev Calculates the interest rates depending on the reserve's state and configurations
   * @param reserve The address of the reserve
   * @param liquidityAdded The liquidity added during the operation
   * @param liquidityTaken The liquidity taken during the operation
   * @param totalVariableDebt The total borrowed from the reserve at a variable rate
   * @param reserveFactor The reserve portion of the interest that goes to the treasury of the market
   * @return The liquidity rate,  borrow rate
   **/
  function calculateInterestRates(
    address reserve,
    address pToken,
    uint256 liquidityAdded,
    uint256 liquidityTaken,
    uint256 totalVariableDebt,
    uint256 reserveFactor
  )
    external
    override
    returns (
      uint256,
      uint256
    )
  {
    // uint256 availableLiquidity = IERC20(reserve).balanceOf(pToken);
    // //avoid stack too deep
    // // console.log("calculateInterestRates - availableLiquidity is ", availableLiquidity);
    // // console.log("calculateInterestRates - liquidityAdded is ", liquidityAdded);
    // // console.log("calculateInterestRates - liquidityTaken is ", liquidityTaken);

    // availableLiquidity = availableLiquidity + liquidityAdded - liquidityTaken;
    return
      calculateInterestRates(
        reserve,
        0,
        0,
        reserveFactor
      );
  }

  struct CalcInterestRatesLocalVars {
    uint256 totalDebt;
    uint256 currentVariableBorrowRate;
    uint256 currentLiquidityRate;
    uint256 utilizationRate;
  }

  struct PoolIndexes {
      uint32 lastUpdateTimestamp; // The last time the local pool and peer-to-peer indexes were updated.
      uint112 poolSupplyIndex; // Last pool supply index. 
      uint112 poolBorrowIndex; // Last pool borrow index. 
  }

  struct Params {
      uint256 lastP2PSupplyIndex; // The peer-to-peer supply index at last update.
      uint256 lastP2PBorrowIndex; // The peer-to-peer borrow index at last update.
      uint256 poolSupplyIndex; // The current pool supply index.
      uint256 poolBorrowIndex; // The current pool borrow index.
      PoolIndexes lastPoolIndexes; // The pool indexes at last update.
      uint256 reserveFactor; // The reserve factor percentage (10 000 = 100%).
      uint256 p2pIndexCursor; // The peer-to-peer index cursor (10 000 = 100%).
      // Types.Delta delta; // The deltas and peer-to-peer amounts.
  }

  /**
   * @dev Calculates the interest rates depending on the reserve's state and configurations.
   * NOTE This function is kept for compatibility with the previous DefaultInterestRateStrategy interface.
   * New protocol implementation uses the new calculateInterestRates() interface
   * @param reserve The address of the reserve
   * @param availableLiquidity The liquidity available in the corresponding pToken
   * @param totalVariableDebt The total borrowed from the reserve at a variable rate
   * @param reserveFactor The reserve portion of the interest that goes to the treasury of the market
   * @return The liquidity rate, the variable borrow rate
   **/
  function calculateInterestRates(
    address reserve,
    uint256 availableLiquidity,
    uint256 totalVariableDebt,
    uint256 reserveFactor
  )
    public
    override
    returns (
      uint256,
      uint256
    )
  {
    console.log("PlatformTokenInterestRateModel calculateInterestRates - reserve:", reserve);
    address pToken = markets[reserve].pToken;
    console.log("PlatformTokenInterestRateModel calculateInterestRates - pToken:", pToken);
    PoolIndexes storage marketPoolIndexes = poolIndexes[pToken];
    address underlying = markets[reserve].underlyingToken;
    IRindex memory vars;
    (vars.newPoolSupplyIndex, vars.newPoolBorrowIndex) = _getPoolIndexes(underlying);
    console.log("calculateInterestRates - newPoolSupplyIndex:", vars.newPoolSupplyIndex);
    console.log("calculateInterestRates - newPoolBorrowIndex:", vars.newPoolBorrowIndex);

    uint256 p2pIndexCursor = PercentageMath.HALF_PERCENTAGE_FACTOR;
    (vars.newP2PSupplyIndex, vars.newP2PBorrowIndex) = _computeP2PIndexes(
        Params({
          lastP2PSupplyIndex: p2pSupplyIndex[pToken],
          lastP2PBorrowIndex: p2pBorrowIndex[pToken],
          poolSupplyIndex: vars.newPoolSupplyIndex,
          poolBorrowIndex: vars.newPoolBorrowIndex,
          lastPoolIndexes: marketPoolIndexes,
          reserveFactor: reserveFactor,
          p2pIndexCursor: p2pIndexCursor
        })
    );
    p2pSupplyIndex[pToken] = vars.newP2PSupplyIndex;

    console.log("gas: ", gasleft());
    console.log("calculateInterestRates - newP2PSupplyIndex:", vars.newP2PSupplyIndex);
    console.log("gas: ", gasleft());
    console.log("calculateInterestRates - newP2PBorrowIndex:", vars.newP2PBorrowIndex);
    console.log("finish");
    // p2pSupplyIndex[pToken] = vars.newP2PSupplyIndex;
    console.log("calculateInterestRates - p2pSupplyIndex:", p2pSupplyIndex[pToken]);
    console.log("gas: ", gasleft());
    // p2pBorrowIndex[pToken] = vars.newP2PBorrowIndex;
    console.log("calculateInterestRates - p2pBorrowIndex:", p2pBorrowIndex[pToken]);

    marketPoolIndexes.lastUpdateTimestamp = uint32(block.timestamp);
    marketPoolIndexes.poolSupplyIndex = uint112(vars.newPoolSupplyIndex);
    // console.log("calculateInterestRates - poolSupplyIndex:", marketPoolIndexes.poolSupplyIndex);
    marketPoolIndexes.poolBorrowIndex = uint112(vars.newPoolBorrowIndex);
    // console.log("calculateInterestRates - poolBorrowIndex:", marketPoolIndexes.poolBorrowIndex);
    console.log("set finish....");
    emit P2PIndexesUpdated(
            pToken,
            vars.newP2PSupplyIndex,
            vars.newP2PBorrowIndex,
            vars.newPoolSupplyIndex,
            vars.newPoolBorrowIndex
        );
    return (vars.newP2PSupplyIndex, vars.newP2PBorrowIndex);
  }


  /**
   * @param _underlyingToken The address of the underlying token.
   * @return poolSupplyIndex The pool supply index.
   * @return poolBorrowIndex The pool borrow index.
   */
  function _getPoolIndexes(address _underlyingToken)
    internal
    view
    returns (uint256 poolSupplyIndex, uint256 poolBorrowIndex)
  {
    poolSupplyIndex = _pool.getReserveNormalizedIncome(_underlyingToken);
    poolBorrowIndex = _pool.getReserveNormalizedVariableDebt(_underlyingToken);
    console.log("_getPoolIndexes poolSupplyIndex: ", poolSupplyIndex);
    console.log("_getPoolIndexes poolBorrowIndex: ", poolBorrowIndex);

  }

  /**
   * @notice Computes and returns new peer-to-peer indexes.
   * @param _params Computation parameters.
   * @return newP2PSupplyIndex The updated p2pSupplyIndex.
   * @return newP2PBorrowIndex The updated p2pBorrowIndex.
   */
  function _computeP2PIndexes(Params memory _params)
    internal
    view
    returns (uint256 newP2PSupplyIndex, uint256 newP2PBorrowIndex)
  {
    console.log("");
    console.log("_computeP2PIndexes...");
    GrowthFactors memory growthFactors = computeGrowthFactors(
        _params.poolSupplyIndex,
        _params.poolBorrowIndex,
        _params.lastPoolIndexes,
        _params.p2pIndexCursor,
        _params.reserveFactor
    );

    newP2PSupplyIndex = computeP2PIndex(
        P2PIndexComputeParams({
            poolGrowthFactor: growthFactors.poolSupplyGrowthFactor,
            p2pGrowthFactor: growthFactors.p2pSupplyGrowthFactor,
            lastPoolIndex: _params.lastPoolIndexes.poolSupplyIndex,
            lastP2PIndex: _params.lastP2PSupplyIndex
            // p2pDelta: _params.delta.p2pSupplyDelta,
            // p2pAmount: _params.delta.p2pSupplyAmount
        })
    );
    newP2PBorrowIndex = computeP2PIndex(
        P2PIndexComputeParams({
            poolGrowthFactor: growthFactors.poolBorrowGrowthFactor,
            p2pGrowthFactor: growthFactors.p2pBorrowGrowthFactor,
            lastPoolIndex: _params.lastPoolIndexes.poolBorrowIndex,
            lastP2PIndex: _params.lastP2PBorrowIndex
            // p2pDelta: _params.delta.p2pBorrowDelta,
            // p2pAmount: _params.delta.p2pBorrowAmount
        })
    );
    console.log("finish _computeP2PIndexes");
  }
  /**
   * @notice Computes and returns the new supply/borrow growth factors associated to the given market's pool & peer-to-peer indexes.
   * @param _newPoolSupplyIndex The current pool supply index.
   * @param _newPoolBorrowIndex The current pool borrow index.
   * @param _lastPoolIndexes The last stored pool indexes.
   * @param _p2pIndexCursor The peer-to-peer index cursor for the given market.
   * @param _reserveFactor The reserve factor of the given market.
   * @return growthFactors The market's indexes growth factors (in ray).
   */ 
  function computeGrowthFactors(
        uint256 _newPoolSupplyIndex,
        uint256 _newPoolBorrowIndex,
        PoolIndexes memory _lastPoolIndexes,
        uint256 _p2pIndexCursor,
        uint256 _reserveFactor
  ) internal view returns (GrowthFactors memory growthFactors) {
      console.log("");
      console.log("computeGrowthFactors...");
      growthFactors.poolSupplyGrowthFactor = _newPoolSupplyIndex.rayDiv(
          _lastPoolIndexes.poolSupplyIndex
      );
      growthFactors.poolBorrowGrowthFactor = _newPoolBorrowIndex.rayDiv(
          _lastPoolIndexes.poolBorrowIndex
      );

      if (growthFactors.poolSupplyGrowthFactor <= growthFactors.poolBorrowGrowthFactor) {
          uint256 p2pGrowthFactor = PercentageMath.weightedAvg(
            growthFactors.poolSupplyGrowthFactor,
            growthFactors.poolBorrowGrowthFactor,
            _p2pIndexCursor
          );

          growthFactors.p2pSupplyGrowthFactor =
              p2pGrowthFactor -
              (p2pGrowthFactor - growthFactors.poolSupplyGrowthFactor).percentMul(_reserveFactor);
          growthFactors.p2pBorrowGrowthFactor =
              p2pGrowthFactor +
              (growthFactors.poolBorrowGrowthFactor - p2pGrowthFactor).percentMul(_reserveFactor);
      } else {
            // The case poolSupplyGrowthFactor > poolBorrowGrowthFactor happens because someone has done a flashloan on Aave, or because the interests
            // generated by the stable rate borrowing are high (making the supply rate higher than the variable borrow rate). In this case the peer-to-peer
            // growth factors are set to the pool borrow growth factor.
          growthFactors.p2pSupplyGrowthFactor = growthFactors.poolBorrowGrowthFactor;
          growthFactors.p2pBorrowGrowthFactor = growthFactors.poolBorrowGrowthFactor;
      }
      console.log("finish computeGrowthFactors");
  }
  /**
   * @notice Computes and returns the new peer-to-peer supply/borrow index of a market given its parameters.
   * @param _params The computation parameters.
   * @return newP2PIndex The updated peer-to-peer index (in ray).
   */
  function computeP2PIndex(P2PIndexComputeParams memory _params)
    internal
    view
    returns (uint256 newP2PIndex)
  {
    // if (_params.p2pAmount == 0 || _params.p2pDelta == 0) {
    //   newP2PIndex = _params.lastP2PIndex.rayMul(_params.p2pGrowthFactor);
    // } else {
    //     // uint256 shareOfTheDelta = Math.min(
    //     //     _params.p2pDelta.rayMul(_params.lastPoolIndex).rayDiv(
    //     //     _params.p2pAmount.rayMul(_params.lastP2PIndex)
    //     //     ), // Using ray division of an amount in underlying decimals by an amount in underlying decimals yields a value in ray.
    //     //     WadRayMath.RAY // To avoid shareOfTheDelta > 1 with rounding errors.
    //     // ); // In ray.
    //     uint256 shareOfTheDelta = WadRayMath.halfRAY;
    //     newP2PIndex = _params.lastP2PIndex.rayMul(
    //         (WadRayMath.RAY - shareOfTheDelta).rayMul(_params.p2pGrowthFactor) +
    //           shareOfTheDelta.rayMul(_params.poolGrowthFactor)
    //     );
    // }
    console.log("computeP2PIndex...");
    uint256 shareOfTheDelta = WadRayMath.halfRAY;
    newP2PIndex = _params.lastP2PIndex.rayMul(
        (WadRayMath.RAY - shareOfTheDelta).rayMul(_params.p2pGrowthFactor) +
        shareOfTheDelta.rayMul(_params.poolGrowthFactor)
    );
  }

  // /**
  //  * @notice Computes and returns the peer-to-peer supply rate per year of a market given its parameters.
  //  * @param _params The computation parameters.
  //  * @return p2pSupplyRate The peer-to-peer supply rate per year (in ray).
  //  */
  // function computeP2PSupplyRatePerYear(P2PRateComputeParams memory _params)
  //   internal
  //   pure
  //   returns (uint256 p2pSupplyRate)
  // {
  //   if (_params.poolSupplyRatePerYear > _params.poolBorrowRatePerYear) {
  //     p2pSupplyRate = _params.poolBorrowRatePerYear; // The p2pSupplyRate is set to the poolBorrowRatePerYear because there is no rate spread.
  //   } else {
  //     uint256 p2pRate = PercentageMath.weightedAvg(
  //               _params.poolSupplyRatePerYear,
  //               _params.poolBorrowRatePerYear,
  //               _params.p2pIndexCursor
  //           );

  //     p2pSupplyRate =
  //         p2pRate -
  //         (p2pRate - _params.poolSupplyRatePerYear).percentMul(_params.reserveFactor);
  //   }
  //   if (_params.p2pDelta > 0 && _params.p2pAmount > 0) {
  //       uint256 shareOfTheDelta = Math.min(
  //           _params.p2pDelta.rayMul(_params.poolIndex).rayDiv(
  //               _params.p2pAmount.rayMul(_params.p2pIndex)
  //           ), // Using ray division of an amount in underlying decimals by an amount in underlying decimals yields a value in ray.
  //           WadRayMath.RAY // To avoid shareOfTheDelta > 1 with rounding errors.
  //         ); // In ray.

  //       p2pSupplyRate =
  //           p2pSupplyRate.rayMul(WadRayMath.RAY - shareOfTheDelta) +
  //           _params.poolSupplyRatePerYear.rayMul(shareOfTheDelta);
  //   }
  // }

  // /**
  //  * @notice Computes and returns the peer-to-peer borrow rate per year of a market given its parameters.
  //  * @param _params The computation parameters.
  //  * @return p2pBorrowRate The peer-to-peer borrow rate per year (in ray).
  //  */
  // function computeP2PBorrowRatePerYear(P2PRateComputeParams memory _params)
  //   internal
  //   pure
  //   returns (uint256 p2pBorrowRate)
  // {
  //   if (_params.poolSupplyRatePerYear > _params.poolBorrowRatePerYear) {
  //     p2pBorrowRate = _params.poolBorrowRatePerYear; // The p2pBorrowRate is set to the poolBorrowRatePerYear because there is no rate spread.
  //   } else {
  //       uint256 p2pRate = PercentageMath.weightedAvg(
  //           _params.poolSupplyRatePerYear,
  //           _params.poolBorrowRatePerYear,
  //           _params.p2pIndexCursor
  //       );

  //       p2pBorrowRate =
  //           p2pRate +
  //           (_params.poolBorrowRatePerYear - p2pRate).percentMul(_params.reserveFactor);
  //   }
    
  //   if (_params.p2pDelta > 0 && _params.p2pAmount > 0) {
  //       uint256 shareOfTheDelta = Math.min(
  //             _params.p2pDelta.rayMul(_params.poolIndex).rayDiv(
  //                 _params.p2pAmount.rayMul(_params.p2pIndex)
  //             ), // Using ray division of an amount in underlying decimals by an amount in underlying decimals yields a value in ray.
  //             WadRayMath.RAY // To avoid shareOfTheDelta > 1 with rounding errors.
  //       ); // In ray.

  //       p2pBorrowRate =
  //           p2pBorrowRate.rayMul(WadRayMath.RAY - shareOfTheDelta) +
  //           _params.poolBorrowRatePerYear.rayMul(shareOfTheDelta);
  //   }
  // }
}
