pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPToken is ERC20, Ownable {

    address payable public tomatoLP;
    uint public balanceTMTO;
    uint public balanceETH;
    bool initialized;

    constructor(address payable treasuryAddress) ERC20("TMTOxETH_LP_TOKEN", "TXE") {

    }

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

    function initialize (uint amount0, uint amount1) public onlyOwner {
       uint liquidity = sqrt(amount0 * amount1); //- MINIMUM_LIQUIDITY
       _mint(_msgSender(), liquidity);
    }

    function mint(address to, uint amount0, uint amount1) public onlyOwner {
        // TODO
        require(initialized == true, 'pool does not exist yet');
        uint liquidity;
        uint x = amount0 * totalSupply() / balanceTMTO;
        uint y = amount1 * totalSupply() / balanceETH;
        x > y ? liquidity = y : liquidity = x;
        _mint(to, liquidity);
    }    

}