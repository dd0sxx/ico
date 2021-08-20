pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./TomatoToken.sol";
import "./ICO.sol";

contract Treasury is Ownable {

    TomatoToken tomatoToken;
    ICO ico;
    uint public treasuryBalance;

    function setTokenContract (address tokenContract) public onlyOwner {
        tomatoToken = TomatoToken(tokenContract);
    }

    function setICOContract (address payable icoContract) public onlyOwner {
        ico = ICO(icoContract);
    }

    function claimTreasuryTax () public onlyOwner {
        tomatoToken.withdrawTreasury();
    }

    function send (address to, uint amount) public onlyOwner {
        // TODO
    }

    receive () external payable {

    }

}