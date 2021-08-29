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

    // TODO: add an approve function

    /// @notice returns supply of LP tokwns 
    function getTotalSupply() internal view returns (uint) {
        return lpToken.totalSupply();
    }

    /// @notice syncs the total balances of TMTO & WETH on this contract
    function sync() internal {
        balanceTMTO = IERC20(TMTO).balanceOf(address(this));
        balanceWETH = IERC20(WETH).balanceOf(address(this));
    }

    /// @dev handles token calc for init and normal deposits
    function calcLPTokens (uint amount0, uint amount1) public view returns (uint) {
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

    function calcSwap (uint deposit, address to) view public returns (uint) {
        uint output;
        deposit -= (deposit / FEE);

        if (to == WETH) {
            output = deposit / 5;
        } else if (to == TMTO) {
            output = deposit * 5;
        } else {
            revert('to address needs to be WETH or TMTO');
        }
        return output;
    }

    /// @notice will mint LP tokens and deposit liquidity
   function provideLiquidity (uint amount0, uint amount1) public {
        require(IERC20(TMTO).balanceOf(msg.sender) >= amount0, 'not enough TMTO');
        require(IERC20(WETH).balanceOf(msg.sender) >= amount1, 'not enough WETH');

        IERC20(TMTO).transferFrom(msg.sender, address(this), amount0);
        IERC20(WETH).transferFrom(msg.sender, address(this), amount1);

        sync();

        uint liquidity = calcLPTokens(amount0, amount1);

        lpToken.mint(msg.sender, liquidity);
   }

    /// @notice will burn LP tokens and return liquidity
   function withdrawLiquidity (uint amount) public {
        sync();

        uint amount0 = (amount  / getTotalSupply()) * balanceTMTO;
        uint amount1 = (amount  / getTotalSupply()) * balanceWETH;

        lpToken.burn(msg.sender, amount);

        IERC20(TMTO).transfer(msg.sender, amount0);
        IERC20(WETH).transfer(msg.sender, amount1);

        sync();
   }

   /// @notice swap TMTO for ETH
   /// @dev amount0 or amount1 will be 0. 
   /// @param amount0 = amount of TMTO coins
   /// @param amount1= amount of WETH
   /// @param to = address of coin which the trader wants to swap to
   function swap (uint amount0, uint amount1, address to) public {
        require(amount0 > 0 || amount1 > 0, 'insufficient amount');

        sync();

        require(amount0 < balanceTMTO && amount1 < balanceWETH, 'insufficient liquidity');
        require(to != WETH && to != TMTO, 'invalid to address');

        uint deposit;

        if (amount0 > 0) {
            deposit = amount0;
            IERC20(TMTO).transferFrom(msg.sender, address(this), amount0);
        }
        else if (amount1 > 0) {
            deposit = amount1;
            IERC20(WETH).transferFrom(msg.sender, address(this), amount1);
        }

        sync();

        uint output = calcSwap(deposit, to);

        IERC20(to).transfer(msg.sender, output);
        
        sync();
   }

        


        


}