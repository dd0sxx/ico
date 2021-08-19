pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TomatoToken is ERC20, Ownable {

    constructor() ERC20("Tomato", "TMT") {
        _mint(msg.sender, 500000);
    }

}