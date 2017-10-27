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
//contract TrustFund {
//    address[3] public children;
//
//    function TrustFund (address[3] _children) {
//        children = _children;
//    }
//
//    function updateAddress(uint child, address newAddress) {
//        require(msg.sender == children[child]);
//        children[child] = newAddress;
//    }
//
//    function disperse () {
//        uint balance = address(this).balance;
//        children[0].send(balance / 2);
//        children[1].send(balance / 4);
//        children[2].send(balance / 4);
//    }
//
//    function () payable {}
//}
//
//contract SaltyChild {}

contract Welfare {
    address[] recipients;

    function register () {
        recipients.push(msg.sender);
    }

    function disperse () {
        uint balance = address(this).balance;
        uint amount = balance / recipients.length;
        for (uint i=0; i < recipients.length; i++) {
            recipients[i].send(amount);
        }
    }

    function () payable {}
}
    
