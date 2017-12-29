pragma solidity ^0.4.18;

contract SimplePrize {
    bytes32 public constant salt = 0x055bcf14957f08824ae0a0278964f914c8ebeec1cc43d515b9f55ad8416cac55;

    bytes32 public commitment;

    function SimplePrize(bytes32 _commitment) public payable {
        commitment = _commitment;   
    }

    function createCommitment(uint answer) 
      public pure returns (bytes32) {
        return keccak256(salt, answer);
    }

    function guess (uint answer) public {
        require(createCommitment(answer) == commitment);
        msg.sender.transfer(this.balance);
    }

    function () public payable {}
}
