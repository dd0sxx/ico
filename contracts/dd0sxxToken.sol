pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract dd0sxxToken is ERC20, Ownable {

    constructor() ERC20("dd0sxx", "D0X") {
        _mint(msg.sender, 500000);
    }

}