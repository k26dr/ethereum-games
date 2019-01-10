// Modifications are required to run this test.
// In contracts/Lotteries.sol make the following modifications. 
// replace the line:
    // uint public constant ROUND_LENGTH = 3 days;
// with: 
    // uint public constant ROUND_LENGTH = 15 seconds;
// 
// Reducing the round lengths makes it possible to run an end to end
// test in a reasonable time

Powerball = artifacts.require('Powerball');

contract('Powerball', function (accounts) {
    var lottery = Powerball.at(Powerball.address);

    it("should buy a ticket", function () {
        var numbers = [[1,2,3,4,5,6]];
        return lottery.buy(numbers, { from: accounts[0], value: 2e15 });
    });

    it("should fail to buy a ticket with duplicate numbers", function () {
        var numbers = [[1,2,3,3,4,6]];
        return new Promise(function (resolve, reject) {
            lottery.buy(numbers, { from: accounts[0], value: 2e15 })
                .then(reject)
                .catch(resolve);
        });
    });

    it("should buy 500 tickets from 10 accounts", function () {
        var buys = []
        for (var i=0; i < 50; i++) {
            var numbers = [];
            for (var j=0; j < 10; j++) {
                numbers.push(generateRandomNumbers());
            }
            var tx = lottery.buy(numbers, { from: accounts[i%10], value: 2e16 })
            buys.push(tx);
        } 
        return Promise.all(buys)
    });

    it("should wait 15 seconds", function () {
        return new Promise(function (resolve, reject) {
            setTimeout(resolve, 15000);
        });
    });

    it("should buy 500 tickets for 2nd round", function () {
        var buys = []
        for (var i=0; i < 50; i++) {
            var numbers = [];
            for (var j=0; j < 10; j++) {
                numbers.push(generateRandomNumbers());
            }
            var tx = lottery.buy(numbers, { from: accounts[i%10], value: 2e16 })
            buys.push(tx);
        } 
        return Promise.all(buys)
    });

    it("should draw numbers", function () {
        return lottery.drawNumbers(1, { from: accounts[0] })
    });

    it("should claim prizes", function () {
        var claims = []
        for (var i=0; i < 10; i++) {
            var tx = lottery.claim(1, { from: accounts[i] });     
            claims.push(tx);
        }
        return Promise.all(claims)
    });

});

function generateRandomNumbers () {
    var numbers = []
    var i=0;
    while (i < 5) {
        var num = Math.ceil(Math.random() * 69);
        if (numbers.includes(num))
            continue;
        numbers.push(num);
        i++;
    }
    numbers.push(Math.ceil(Math.random() * 26));
    return numbers;
}
