HelloWorld = artifacts.require('./HelloWorld.sol');

module.exports = function () {
    HelloWorld.deployed().then(function (instance) {
        instance.greet().then(console.log);
    });
}


