var fs = require('fs');
var RecurringLottery = artifacts.require("RecurringLottery");

module.exports = function(deployer, network) {

    // unlock account for geth
    if (network == "rinkeby" || network == "mainnet") {
        var password = fs.readFileSync("password", "utf8")
                         .split('\n')[0];
        web3.personal.unlockAccount(web3.eth.accounts[0], password);
    }

    // duration is in blocks. 1 day = ~5500 blocks
    var duration = 5500 * 7; // 7 days
    deployer.deploy(RecurringLottery, duration);
};
