pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./TomatoToken";

contract ICO is Ownable {

    TomatoToken tomatoToken;
    mapping (address => uint) balances;
    mapping (address => bool) whitelist;
    address tomatoTokenAdress;
    uint totalFunds;
    bool paused;
    phases phase;

    enum phases {
        seed,
        general,
        open
    }

    constructor (address tokenContract) {
        phase = phases.seed;
        tomatoToken = tokenContract;
    }

    function changePhase () external onlyOwner {
        if (phase == phases.seed) {
            phase = phases.general;
        } else if (phase == phases.general) {
            phase = phases.open;
        } else {
            revert("ICO is in phase open");
        }
    }

    function togglePause (bool state) public onlyOwner {
        paused = state;
    }

    function addToWhitelist (address[] memory privateInvestors) external onlyOwner {
        require(phase == phases.seed, "whitelist is irrelevant after seed phase");
        uint i;
        for (i = 0; i < privateInvestors.length; i++) {
            whitelist[privateInvestors[i]] = true;
        }
    }

    function claimTomatoTokens () public {
        require(phase == phases.open, "cannot withdraw until phase open");
        require(balances[msg.sender] > 0, "no balance on this address");

    }

    function claimTreasury () public onlyOwner{
        tomatoToken(tomatoTokenAdress).withdrawTreasury();
    }

    function recieve () external payable {
        require (msg.value > 0.01 ether, "not enough ether");
        require (paused == false, "ICO is paused");

        if (phase == phases.seed) {
            require(totalFunds + msg.value <= 15000 ether, "seed phase goal cannot be surpassed");
            require(whitelist[msg.sender] == true, "address not whitelisted for seed sale");
            require(balances[msg.sender] + msg.value <= 1500 ether, "amount would be more than 1500 ether contributed");
            totalFunds += msg.value;
            balances[msg.sender] += msg.value;
        }

        if (phase == phases.general) {
            require(totalFunds + msg.value <= 30000 ether, "30000 ether contributed cannot be surpassed");
            require(balances[msg.sender] + msg.value <= 1000 ether, "amount would be more than 1000 ether contributed");
            totalFunds += msg.value;
            balances[msg.sender] += msg.value;
        }

        if (phase == phases.open) {
            require(totalFunds + msg.value <= 30000 ether, "30000 ether contributed cannot be surpassed");
            totalFunds += msg.value;
            balances[msg.sender] += msg.value;
        }
    }


}