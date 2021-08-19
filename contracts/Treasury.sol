pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./TomatoToken.sol";

contract Treasury is Ownable {

    TomatoToken tomatoToken;

    function setTokenContract (address tokenContract) public onlyOwner {
        tomatoToken = TomatoToken(tokenContract);
    }

    function claimTreasury () public onlyOwner {
        tomatoToken.withdrawTreasury();
    }

}