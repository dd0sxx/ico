pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TomatoToken is ERC20, Ownable {

    address payable treasury;
    uint treasuryBalance;
    bool tax;

    constructor(address payable treasuryAddress) ERC20("Tomato", "TMT") {
        setTreasury(treasuryAddress);
        _mint(treasury, 500000); //max supply
        tax = true;
    }

    function transfer (address recipient, uint256 amount) public virtual override returns (bool){
        require (amount > 0, 'amount must be greater than 0');
        if (tax) {
            uint taxAmount  = (amount / 100) * 2;
            uint newAmount = amount - taxAmount;
            treasuryBalance += taxAmount;
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

    function setTax (bool state) public onlyOwner {
        tax = state;
    }

    function withdrawTreasury () public  {
        require (msg.sender == treasury, "address is not treasury");
        //replace this with erc20 transfer (not eth call)
        // (bool status, ) = treasury.call{value: treasuryBalance}("");
        require(status == true, "transfer failed");

    }



}