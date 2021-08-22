pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./TomatoToken.sol";
import "./ICO.sol";

contract Treasury is Ownable {

    TomatoToken tomatoToken;
    ICO ico;
    address payable private icoAddress;
    uint public treasuryBalance;

    function setTokenContract (address tokenContract) external onlyOwner {
        require(tokenContract != address(0), "cannot be address(0)");
        tomatoToken = TomatoToken(tokenContract);
    }

    function setICOContract (address payable icoContract) external onlyOwner {
        require(icoContract != address(0), "cannot be address(0)");
        ico = ICO(icoContract);
        icoAddress = icoContract;
    }

    function claimTreasuryTax () external onlyOwner {
        (uint amount) = tomatoToken.withdrawTreasury();
        treasuryBalance += amount;
    }

    function send (address to, uint amount) external onlyOwner {
        bool status = _send(to, amount);
        require(status == true, "transfer failed");
    }

    function _send (address to, uint amount) internal returns (bool) {
        bool status = tomatoToken.transfer(to, amount);
        return status;
    }

    function icoDistribute (address to, uint amount) external {
        require (msg.sender == icoAddress, "msg.sender is not the ico contract");
        bool status = _send(to, amount);
        require(status == true, "transfer failed");
    }

    // @notice: this function serves as a backup incase ether is sent to this contract  
    function sendEther (address to, uint amount) external onlyOwner {
        require(amount > 0, 'amount cannot be 0');
        require(to != address(0), 'address(0) cannot be recipient');
        (bool status,) = to.call{value: amount}("");
        require(status == true, 'transfer failed');
    }

    receive () external payable {

    }

}