var fs = require('fs');
var SimpleLottery = artifacts.require("SimpleLottery");

module.exports = function(deployer, network) {

    // unlock account for geth
    if (network == "rinkeby" || network == "mainnet") {
        var password = fs.readFileSync("password", "utf8")
                         .split('\n')[0];
        web3.personal.unlockAccount(web3.eth.accounts[0], password);
    }

    var duration = 3600 * 24 * 3; // 3 days
    deployer.deploy(SimpleLottery, duration);
};
