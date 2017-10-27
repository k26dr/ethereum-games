pragma solidity ^0.4.15; // specifies minimum Solidity version to compiler

contract NotSoPrivateData {
    uint public money = 16;
    uint public constant lives = 100;
    string private password = "twiddledee";
}
