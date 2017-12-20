HelloWorld = artifacts.require('HelloWorld');

module.exports = function () {
    instance = HelloWorld.at(HelloWorld.address);
	instance.greet().then(console.log);
}
