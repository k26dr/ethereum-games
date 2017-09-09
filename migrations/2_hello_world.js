var fs = require('fs');

var HelloWorld = artifacts.require("./HelloWorld.sol");

module.exports = function(deployer, network) {
    if (network == "rinkeby" || network == "mainnet") {
        var password = fs.readFileSync("password");
        web3.personal.unlockAccount(web3.eth.accounts[0], password)
    }
    deployer.deploy(HelloWorld);
};
