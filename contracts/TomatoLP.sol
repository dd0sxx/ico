pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import './LPToken.sol';


contract TomatoLP is Ownable {
    /// @dev devide token amount by FEE
    LPToken lpToken;
    address payable LPTokenAdress;
    address constant WETH = 0xECF8F87f810EcF450940c9f60066b4a7a501d6A7;
    uint constant FEE = 100;
    uint public balanceTMTO;
    uint public balanceETH;
    bool initialized;


    /// @notice uniswap's sqrt function (not original)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function getTotalSupply() internal returns (uint) {
        return lpToken.totalSupply();
    }

    function calcLPTokens (uint amount0, uint amount1) public returns (uint) {
        uint liquidity;
        if (initialized == false) {
            liquidity = sqrt(amount0 * amount1); //- MINIMUM_LIQUIDITY
        } else {
            uint x = amount0 * getTotalSupply() / balanceTMTO;
            uint y = amount1 * getTotalSupply() / balanceETH;
            x > y ? liquidity = y : liquidity = x;
        }
        return liquidity;
    }

    }


    /// @notice will mint LP tokens and deposit liquidity
   function provideLiquidity (uint amount0, uint amount2) public {

   }

    /// @notice will burn LP tokens and return liquidity
   function withdrawLiquidity (uint amount) public {

   }

   /// @notice swap TMTO for ETH
   function swap () public {
       // 1% fee
   }

}