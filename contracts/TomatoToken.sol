pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TomatoToken is ERC20, Ownable {

    address payable public treasury;
    uint public treasuryTaxBalance;
    bool public tax;

    constructor(address payable treasuryAddress) ERC20("Tomato", "TMT") {
        setTreasury(treasuryAddress);
        _mint(treasury, 50000); // 10% of max supply
        tax = true;
    }

    function transfer (address recipient, uint256 amount) public virtual override returns (bool){
        require (amount > 0, 'amount must be greater than 0');
        if (tax) {
            uint taxAmount  = (amount / 100) * 2;
            uint newAmount = amount - taxAmount;
            treasuryTaxBalance += taxAmount;
            _transfer(_msgSender(), recipient, newAmount);
        } else {
            _transfer(_msgSender(), recipient, amount);
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

    function withdrawTreasury () public  {
        require (msg.sender == treasury, "msg.sender is not treasury");
        bool status = transfer(treasury, treasuryTaxBalance);
        require(status == true, "transfer failed");
    }



}