pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./TomatoToken.sol";
import "./ICO.sol";

contract Treasury is Ownable {

    TomatoToken tomatoToken;
    ICO ico;
    address payable private icoAddress;
    uint public treasuryBalance;

    function setTokenContract (address tokenContract) public onlyOwner {
        tomatoToken = TomatoToken(tokenContract);
    }

    function setICOContract (address payable icoContract) public onlyOwner {
        ico = ICO(icoContract);
        icoAddress = icoContract;
    }

    function claimTreasuryTax () public onlyOwner {
        tomatoToken.withdrawTreasury();
    }

    function send (address to, uint amount) public onlyOwner {
        bool status = _send(to, amount);
        require(status == true, "transfer failed");
    }

    function _send (address to, uint amount) internal returns (bool) {
        bool status = tomatoToken.transfer(to, amount);
        return status;
    }

    function icoDistribute (address to, uint amount) public {
        require (msg.sender == icoAddress, "msg.sender is not the ico contract");
        bool status = _send(to, amount);
        require(status == true, "transfer failed");
    }



    receive () external payable {

    }

}