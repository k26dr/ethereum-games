var Migrations = artifacts.require("./Migrations.sol");

module.exports = function(deployer, network) {
    require('./unlock_account.js')(web3, network);
    deployer.deploy(Migrations);
};
