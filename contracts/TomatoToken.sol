pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TomatoToken is ERC20, Ownable {

    address payable treasury;
    uint treasuryBalance;

    constructor(address payable treasuryAddress) ERC20("Tomato", "TMT") {
        setTreasury(treasuryAddress);
        _mint(treasury, 50000); //initial 10% to the treasury
    }

    function transfer(
        address sender,
        address recipient,
        uint256 amount
    ) public {
        uint tax  = (amount / 100) * 2;
        uint newAmount = amount - tax;
        treasuryBalance += tax;
        _transfer(sender, recipient, newAmount);
    }

    function setTreasury (address payable treasuryAddress) public onlyOwner{
        require (treasuryAddress != address(0), 'treasury cannot be address(0)');
        treasury = treasuryAddress;
    }

}