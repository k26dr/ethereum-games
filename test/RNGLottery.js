// Running this test requires some modifications to the migration
// The last 3 lines of migrations/11_rng_lottery.js should look
// exactly like follows:
// 
// var duration = 12; 
// var revealDuration = 12; 
// deployer.deploy(RNGLottery, duration);

RNGLottery = artifacts.require('RNGLottery');

contract('RNGLottery', function (accounts) {
    var lottery = RNGLottery.at(RNGLottery.address);

    it("should buy a ticket", function () {
        var seed = 17839384;
        var account = accounts[0];
        return lottery.createCommitment(accounts[0], seed)
            .then(commitment => lottery.buy(commitment, 
              { from: accounts[0], value: 1e16 }))
    });

    it("should buy 8 tickets", function () {
        var buys = [];
        for (var i=1; i<9; i++) {
            var seed = i;
            var buy = lottery.createCommitment(accounts[i], seed)
                .then(c => lottery.buy(c, { from: accounts[i], value: 1e16 }))
            buys.push(buy);
        }

        return Promise.all(buys);
    });

    it("should reveal a ticket", function () {
        var seed = 17839384;
        return lottery.reveal(seed, { from: accounts[0] });
    });

    it("should reveal 8 tickets", function () {
        var reveals = []
        for (var i=1; i < 9; i++) {
            var seed = i;
            var tx = lottery.reveal(i, { from: accounts[i] })
            reveals.push(tx);
        } 
        return Promise.all(reveals);
    });

    it("should draw a winner", function () {
        return lottery.drawWinner();
    });

    it("should withdraw winnings", function () {
        lottery.winner(winner => lottery.withdraw({ from: winner }));
    });
});
