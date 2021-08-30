pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPToken is ERC20 {

    address payable tomatoLP;

    constructor(address payable tomatoLPAddress) ERC20("TMTOxETH_LP_TOKEN", "TXE") {
        tomatoLP = tomatoLPAddress;
    }

    function approve () public {
        _approve(tomatoLP, msg.sender, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function mint(address to, uint liquidity) public {
        require(msg.sender == tomatoLP, 'sender must be tomatoLP contract');
        _mint(to, liquidity);
    }    

    function burn(address sender, uint amount) public {
        require(msg.sender == tomatoLP, 'sender must be tomatoLP contract');
        require(balanceOf(sender) >= amount, 'sender does not have enough LP tokens');
        _burn(sender, amount);
    }

}