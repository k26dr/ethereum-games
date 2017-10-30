var fs = require('fs');
var HackableRoulette = artifacts.require("./HackableRoulette.sol");
var ReentrancyAttack = artifacts.require("./ReentrancyAttack.sol");

module.exports = function(deployer, network) {

    // unlock account for geth
    if (network == "rinkeby" || network == "mainnet") {
        var password = fs.readFileSync("password", "utf8")
                         .split('\n')[0];
        web3.personal.unlockAccount(web3.eth.accounts[0], password)
    }

    var accounts = web3.eth.accounts;
    deployer.deploy(HackableRoulette).then(instance => 
        deployer.deploy(ReentrancyAttack, HackableRoulette.address));
};
