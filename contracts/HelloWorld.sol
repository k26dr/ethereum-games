pragma solidity ^0.4.15; // specifies minimum Solidity version to compiler

contract HelloWorld {
    address owner;
    string greeting = "Hello World";

    // Constructor function
    // Runs only once, when contract is deployed
    // Cannot be invoked after contract deployment
    function HelloWorld () public {
        owner = msg.sender;
    }

    function greet () constant public returns (string) {
        return greeting;    
    }

    function kill () public {
        require(owner == msg.sender);
        selfdestruct(owner);
    }
}
