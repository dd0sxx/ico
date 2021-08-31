// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import './LPToken.sol';


contract TomatoLP is Ownable {
    /// @dev devide token amount by FEE
    LPToken lpToken;
    address payable constant WETH = payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); //WETH address on mainnet
    address TMTO;
    address treasury;
    uint constant FEE = 100;
    uint public balanceTMTO;
    uint public balanceWETH;
    bool initialized;
    bool locked;

    constructor(address treasuryAddress) {
        require(treasuryAddress != address(0));
        treasury = treasuryAddress;
    }

    modifier lock () {
        require(locked == false);
        _;
    }

    function lockContract (bool state) external onlyOwner {
        locked = state;
    }

    function setTMTOAddress (address TMTOAddress) external onlyOwner {
        require(TMTOAddress != address(0));
        TMTO = TMTOAddress;
    }

    function setLPTokenAddress (address payable LPTokenAdress) external onlyOwner {
        require(LPTokenAdress != address(0));
        lpToken = LPToken(LPTokenAdress);
    }

    function wrapEther (uint amount) external onlyOwner {
        (bool success,) = WETH.call{value: amount}("");
        require(success == true, 'weth conversion failed');
        sync();
    }

    // function approve () external {
    //     IERC20(TMTO).approve(address(this), IERC20(TMTO).balanceOf(msg.sender));
    //     IERC20(WETH).approve(address(this), IERC20(TMTO).balanceOf(msg.sender));
    // }

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
    function getTotalSupply() public view returns (uint) {
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

    function calcSwap (uint deposit, uint k, address to) view public returns (uint) {
        uint output;
        deposit -= (deposit / FEE);

        if (to == WETH) {
            output = balanceTMTO * k;
        } else if (to == TMTO) {
            output = balanceWETH * k;
        } else {
            revert('to address needs to be WETH or TMTO');
        }
        if (((deposit * 10) / 100) > output) {
            revert('more than 10% slippage on swap');
        }
        return output;
    }

   function initialize (uint amount0, uint amount1) public onlyOwner {
       sync();
       uint liquidity = calcLPTokens(amount0, amount1);
       initialized = true;
       lpToken.mint(address(this), liquidity);
   }

    /// @notice will mint LP tokens and deposit liquidity
   function provideLiquidity (uint amount0, uint amount1) public lock {
        require(IERC20(TMTO).balanceOf(msg.sender) >= amount0, 'not enough TMTO');
        require(IERC20(WETH).balanceOf(msg.sender) >= amount1, 'not enough WETH');
        // make sure they deposit an even ratio

        bool status1 = IERC20(TMTO).transferFrom(msg.sender, address(this), amount0);
        bool status2 = IERC20(WETH).transferFrom(msg.sender, address(this), amount1);
        require(status1 == true && status2 == true, 'transfer failed');

        sync();

        uint liquidity = calcLPTokens(amount0, amount1);

        lpToken.mint(msg.sender, liquidity);
   }

    /// @notice will burn LP tokens and return liquidity
   function withdrawLiquidity (uint amount) public lock {
        sync();
        uint totalSupply = getTotalSupply();
        uint amount0 = (balanceTMTO * amount) / totalSupply ;
        uint amount1 = (balanceWETH * amount) / totalSupply ;
        lpToken.burn(msg.sender, amount);

        bool status1 = IERC20(TMTO).transfer(msg.sender, amount0);
        bool status2 = IERC20(WETH).transfer(msg.sender, amount1);
        require(status1 == true && status2 == true, 'transfer failed');

        sync();
   }

   /// @notice swap TMTO for ETH
   /// @dev amount0 or amount1 will be 0. 
   /// @param amount0 = amount of TMTO coins
   /// @param amount1= amount of WETH
   /// @param to = address of coin which the trader wants to swap to
   function swap (uint amount0, uint amount1, address to) public lock {
        require(amount0 > 0 || amount1 > 0, 'insufficient amount');

        sync();
        uint k = balanceTMTO * balanceWETH;
        require(amount0 < balanceTMTO && amount1 < balanceWETH, 'insufficient liquidity');
        require(to != WETH && to != TMTO, 'invalid to address');

        uint deposit;

        if (amount0 > 0) {
            deposit = amount0;
            bool status = IERC20(TMTO).transferFrom(msg.sender, address(this), amount0);
            require(status== true, 'transfer failed');
        }
        else if (amount1 > 0) {
            deposit = amount1;
            bool status = IERC20(WETH).transferFrom(msg.sender, address(this), amount1);
            require(status== true, 'transfer failed');
        }

        sync();
        uint output = calcSwap(deposit, k, to);

        bool result = IERC20(to).transfer(msg.sender, output);
        require(result== true, 'transfer failed');
   }

    receive () external payable {}


        


}