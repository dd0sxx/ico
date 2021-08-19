pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TomatoToken is ERC20, Ownable {

    address payable treasury;

    constructor(address treasuryAddress) ERC20("Tomato", "TMT") {
        _mint(msg.sender, 500000);
        setTreasury(treasuryAddress)
    }

    function transfer(
        address sender,
        address recipient,
        uint256 amount
    ) public {

    }

    function setTreasury (address treasuryAddress) public {
        require (treasuryAddress != address(0), 'treasury cannot be address(0)');
        treasury = treasuryAddress;
    }

}