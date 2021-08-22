pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TomatoToken is ERC20, Ownable {

    address payable public treasury;
    uint public treasuryTaxBalance;
    uint constant MAX_SUPPLY = 500000000000000000000000;
    bool public tax;

    constructor(address payable treasuryAddress) ERC20("Tomato", "TMT") {
        setTreasury(treasuryAddress);
        mint(treasury, 500000 * 10**decimals()); // max supply
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
            treasuryTaxBalance += taxAmount;
            _transfer(msg.sender, recipient, newAmount);
        } else {
            _transfer(msg.sender, recipient, amount);
        }
        return true;
    }

    function setTreasury (address payable treasuryAddress) public onlyOwner {
        require (treasuryAddress != address(0), 'treasury cannot be address(0)');
        treasury = treasuryAddress;
    }

    function toggleTax (bool state) public onlyOwner {
        tax = state;
    }

    function withdrawTreasury () public returns (uint) {
        require (msg.sender == treasury, "msg.sender is not treasury");
        uint balance = treasuryTaxBalance;
        bool status = transfer(treasury, balance);
        require(status == true, "transfer failed");
        treasuryTaxBalance = 0;
        return balance;
    }



}