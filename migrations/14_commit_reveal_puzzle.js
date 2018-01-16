var fs = require('fs');
var CommitRevealPuzzle = artifacts.require("CommitRevealPuzzle");

module.exports = function(deployer, network) {

    // unlock account for geth
    if (network == "rinkeby" || network == "mainnet") {
        var password = fs.readFileSync("password", "utf8")
                         .split('\n')[0];
        web3.personal.unlockAccount(web3.eth.accounts[0], password);
    }

    //deployer.deploy(CommitRevealPuzzle, "0x0"); // use this to generate commitment
    deployer.deploy(CommitRevealPuzzle, "0xba4fc57b188ade935d02f819f9b4d93c149cdb7108efd027e5c037e93148b678", { value: 1e16 });
};
