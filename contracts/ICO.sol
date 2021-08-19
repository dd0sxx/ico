pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ICO is Ownable {

    mapping (address => bool) whitelist;
    uint constant goal = 30000 ether;
    phases phase;

    enum phases {
        seed,
        general,
        open
    }

    function changePhase () public onlyOwner {
        if (phase == phases.seed) {
            phase = phases.general;
        } else if (phase == phases.general) {
            phase = phases.open;
        } else {
            revert("ICO is in phase open");
        }
    }

    function addToWhitelist (address[] memory privateInvestors) public onlyOwner {
        uint i;
        for (i = 0; i < privateInvestors.length; i++) {
            whitelist[privateInvestors[i]] = true;
        }
    }



}