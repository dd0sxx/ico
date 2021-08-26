pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TomatoToken is ERC20, Ownable {

    address payable public treasury;
    address payable public tomatoLP;
    uint constant MAX_SUPPLY = 500000000000000000000000;
    bool public tax;

    constructor(address payable treasuryAddress) ERC20("Tomato", "TMT") {
        setTreasury(treasuryAddress);
        mint(treasury, 350000 * 10**decimals());
        mint(tomatoLP, 150000 * 10**decimals());
        tax = true;
    }

    function mint(address to, uint amount) public onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, 'minting would surpass max supply');
        _mint(to, amount);
    }

    function transfer (address recipient, uint256 amount) public virtual override returns (bool){
        require (amount > 0, 'amount must be greater than 0');
        if (tax) {
            uint taxAmount  = (amount * 2) / 100;
            uint newAmount = amount - taxAmount;
            _transfer(msg.sender, recipient, newAmount);
            _transfer(msg.sender, treasury, taxAmount);
        } else {
            _transfer(msg.sender, recipient, amount);
        }
        return true;
    }

    function setTreasury (address payable treasuryAddress) public onlyOwner {
        require (treasuryAddress != address(0), 'treasury cannot be address(0)');
        treasury = treasuryAddress;
    }

    function toggleTax (bool state) external onlyOwner {
        tax = state;
    }

}