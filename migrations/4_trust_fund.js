var fs = require('fs');
var TrustFund = artifacts.require("./TrustFund.sol");
var SaltyChild = artifacts.require("./SaltyChild.sol");

module.exports = function(deployer, network) {

    // unlock account for geth
    if (network == "rinkeby" || network == "mainnet") {
        var password = fs.readFileSync("password", "utf8")
                         .split('\n')[0];
        web3.personal.unlockAccount(web3.eth.accounts[0], password)
    }

    var accounts = web3.eth.accounts;
    var addresses = [accounts[2], accounts[3], accounts[4]];
    deployer.deploy(TrustFund, addresses);
    deployer.deploy(SaltyChild);
};
