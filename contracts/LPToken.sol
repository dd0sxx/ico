pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPToken is ERC20 {

    address payable tomatoLP;

    constructor(address payable tomatoLPAddress) ERC20("TMTOxETH_LP_TOKEN", "TXE") {
        tomatoLP = tomatoLPAddress;
    }

    function mint(address to, uint liquidity) public {
        require(msg.sender == tomatoLP, 'sender must be tomatoLP contract');
        _mint(to, liquidity);
    }    

}