var fs = require('fs');

var password = fs.readFileSync('password', 'ascii');

// Many text editors will automatically add an endline character 
// at the end of a file. This removes that character
password = password.split('\n')[0]

module.exports = function (web3, network) {
    if (network != "development") {
        web3.personal.unlockAccount(web3.eth.accounts[0], password);
    }
}
