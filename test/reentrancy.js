const HackableRoulette = artifacts.require('HackableRoulette');
const ReentrancyAttack = artifacts.require('ReentrancyAttack');

contract('AttackSequence', function (accounts) {
    var roulette = HackableRoulette.at(HackableRoulette.address);
    var attacker = ReentrancyAttack.at(ReentrancyAttack.address);

    it("attacker should point to roulette", function () {
        return attacker.roulette()
            .then(addr => assert.equal(addr, roulette.address));
    });

    it("should place multiple bets from each account", function () {
        var bets = []
        accounts.forEach(function (account) {
            for (var i=0; i < 2; i++)
                bets.push(roulette.betRed({ from: account, value: 1e18 }));
        });
        
        return Promise.all(bets)
            .then(() => web3.eth.getBalance(roulette.address))
            .then(bal => assert.isAtLeast(bal, 1e18));
    });

    it("attacker should drain contract", function () {
        return attacker.hack({ from: accounts[0], value: 1e17, gas: 4e6 })
            .then(() => web3.eth.getBalance(attacker.address))
            .then(bal => assert.isAtLeast(bal, 2e18))
            .then(() => web3.eth.getBalance(roulette.address))
            .then(bal => assert.isBelow(bal, 3e17))
    });

});
