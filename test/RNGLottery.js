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

    it("should buy 10 tickets", function () {
        var buys = []
        for (var i=0; i < 10; i++) {
            var seed = i;
            var commitment = web3.sha3(accounts[i], seed);
            var tx = lottery.buy(commitment, { from: accounts[i], value: 1e16 })
            buys.push(tx);
        } 
        return Promise.all(buys);
    });

    it("should reveal a ticket", function () {
        var seed = 17839384;
        return lottery.reveal(seed, { from: accounts[0] })
    });

    //it("should reveal 10 tickets", function () {
    //    var reveals = []
    //    for (var i=0; i < 10; i++) {
    //        var seed = i;
    //        var tx = lottery.reveal(seed, { from: accounts[i] })
    //        reveals.push(tx);
    //    } 
    //    return Promise.all(reveals);
    //});

    //it("should draw a winner", function () {
    //    
    //});
});
