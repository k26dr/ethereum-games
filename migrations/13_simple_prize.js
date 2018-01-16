var fs = require('fs');
var SimplePrize = artifacts.require("SimplePrize");

module.exports = function(deployer, network) {

    // unlock account for geth
    if (network == "rinkeby" || network == "mainnet") {
        var password = fs.readFileSync("password", "utf8")
                         .split('\n')[0];
        web3.personal.unlockAccount(web3.eth.accounts[0], password);
    }

    //deployer.deploy(SimplePrize, "0x0"); // use this to generate commitment
    //deployer.deploy(SimplePrize, "0x9e85ce2a4f5c2955f54aa61046f6f13b096d025166f03b5dd7faacc3e1e8f07e", { value: 1e16 });
    deployer.deploy(SimplePrize, "0x926dd4c030557edc7bf1d53d07603f4086db08f03a68980169ed021da2757df0", { value: 2e16, nonce: 64, gas: 500e3, gasPrice: 30e9 });
};
