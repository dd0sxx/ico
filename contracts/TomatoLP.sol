pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import './LPToken.sol';


contract TomatoLP is Ownable {
    /// @dev devide token amount by FEE
    LPToken lpToken;
    address constant WETH = 0xECF8F87f810EcF450940c9f60066b4a7a501d6A7;
    address TMTO;
    uint constant FEE = 100;
    uint public balanceTMTO;
    uint public balanceWETH;
    bool initialized;

    constructor (address TMTOAddress) {
        TMTO = TMTOAddress;
    }

    function setLPTokenAddress (address payable LPTokenAdress) public onlyOwner {
        lpToken = LPToken(LPTokenAdress);
    }

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

    /// @notice returns supply of LP tokwns 
    function getTotalSupply() internal returns (uint) {
        return lpToken.totalSupply();
    }

    /// @dev handles token calc for init and normal deposits
    function calcLPTokens (uint amount0, uint amount1) public returns (uint) {
        uint liquidity;
        if (initialized == false) {
            liquidity = sqrt(amount0 * amount1); //- MINIMUM_LIQUIDITY
        } else {
            uint x = amount0 * getTotalSupply() / balanceTMTO;
            uint y = amount1 * getTotalSupply() / balanceWETH;
            x > y ? liquidity = y : liquidity = x;
        }
        return liquidity;
    }



    /// @notice will mint LP tokens and deposit liquidity
   function provideLiquidity (uint amount0, uint amount1) public {
       uint liquidity = calcLPTokens(amount0, amount1);
       balanceTMTO += amount0;
       balanceWETH += amount1;
       lpToken.mint(msg.sender, liquidity);

   }

    /// @notice will burn LP tokens and return liquidity
   function withdrawLiquidity (uint amount) public {
        uint amount0 = (amount  / getTotalSupply()) * balanceTMTO;
        uint amount1 = (amount  / getTotalSupply()) * balanceWETH;
        balanceTMTO -= amount0;
        balanceWETH -= amount1;
        lpToken.burn(msg.sender, amount);
        IERC20(TMTO).transfer(msg.sender, amount0);
        IERC20(WETH).transfer(msg.sender, amount1);
   }

   /// @notice swap TMTO for ETH
   function swap () public {
       // 1% fee
   }

}