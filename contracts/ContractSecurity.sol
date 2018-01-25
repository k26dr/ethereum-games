pragma solidity ^0.4.18; // specifies minimum Solidity version to compiler

contract NotSoPrivateData {
    uint public money = 16;
    uint public constant lives = 100;
    string private password = "twiddledee";
}

// DO NOT USE CONTRACT: BAD CODE
contract Payout {
    address receiver = address(15); // dummy address

    function modifyAndPayout () public {
        uint balance = address(this).balance;
        receiver.transfer(balance);
    }
}

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

contract Welfare {
    address[] recipients;

    function register () public {
        recipients.push(msg.sender);
    }

    function disperse () public {
        uint balance = address(this).balance;
        uint amount = balance / recipients.length;
        for (uint i=0; i < recipients.length; i++) {
            recipients[i].send(amount);
        }
    }

    function () payable public {}
}

contract Roulette {
    mapping(address => uint) public balances;

    function betRed () payable public {
        bool winner = (randomNumber() % 2 == 0);
        if (winner)
            balances[msg.sender] += msg.value * 2;
    }

    function randomNumber() public returns (uint) {
        // we will implement this in a later section
        // for now it returns 0 by default
    }

    function withdraw () public {
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}

contract RouletteTwo {
    function betRed () payable public {
        bool winner = (randomNumber() % 2 == 0);
        if (winner)
            msg.sender.transfer(msg.value * 2);
    }

    function randomNumber() public returns (uint) {
        // we will implement this in a later section
        // for now imagine it returns a number from
        // 0-36
    }
}

contract WelfareTwo {
    address[] recipients;
    uint totalFunding;
    mapping(address => uint) withdrawn;

    function register () public {
        recipients.push(msg.sender);
    }

    function () payable public {
        totalFunding += msg.value; 
    }

    function withdraw () public {
        uint withdrawnSoFar = withdrawn[msg.sender];
        uint allocation = totalFunding / recipients.length;
        require(allocation > withdrawnSoFar);

        uint amount = allocation - withdrawnSoFar;
        withdrawn[msg.sender] = allocation;
        msg.sender.transfer(amount);
    }
}

contract Marriage {
    address wife = address(0); // dummy address
    address husband = address(1); // dummy address
    mapping (address => uint) balances;

    function withdraw () public {
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function () payable public {
        balances[wife] += msg.value / 2;
        balances[husband] += msg.value / 2;
    }
}

contract ERC20 {
  uint public totalSupply;

  function balanceOf(address who) public view returns (uint);
  function allowance(address owner, address spender) public view returns (uint);

  function transfer(address to, uint value) public returns (bool ok);
  function transferFrom(address from, address to, uint value) public returns (bool ok);
  function approve(address spender, uint value) public returns (bool ok);

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract TokenSale {
    enum State { Active, Suspended }

    address public owner;
    ERC20 public token;
    State public state;

    function TokenSale(address tokenContractAddress) public {
        owner = msg.sender;
        token = ERC20(tokenContractAddress);
        state = State.Active;
    }

    // 1:1 exchange of ETH for token
    function buy() payable public {
        require(state == State.Active);
        token.transfer(msg.sender, msg.value);
    }

    function suspend () public {
        require(msg.sender == owner);
        state = State.Suspended;
    }

    function activate () public {
        require(msg.sender == owner);
        state = State.Active;
    }

    function withdraw() public {
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }
}

contract Random {
    function example () public view returns (uint) {
        uint seed = 0x7543def;
        return range(seed, 100);
    }

    function range (uint seed, uint max) public view returns (uint) {
        return random(seed) % max;
    }

    function random(uint seed) public view returns (uint) {
        return uint(
            keccak256(block.blockhash(block.number-1), seed)
        );
    }
}

contract C {
    // (2**256 - 1) + 1 = 0
    function overflow() public returns (uint256 _overflow) {
        uint256 max = 2**256 - 1;
        return max + 1;
    }

    function mult () public returns (int8) {
        int8 b = 64;
        b *= 3;
        return b;
    }

    // 0 - 1 = 2**256 - 1
    function underflow() public returns (uint256 _underflow) {
        uint256 min = 0;
        return min - 1;
    }
}

contract Stock {
    function balanceOf (address owner) public view returns (uint) {
        return 0; 
    }
    function transfer(address to, uint amount) public {}
}

contract MarriageInvestment {
    address wife = address(0); // dummy address
    address husband = address(1); // dummy address
    Stock GOOG = Stock(address(2)); // dummy contract

    function split () public {
        uint amount = GOOG.balanceOf(address(this));
        uint each = amount / 2;
        uint remainder = amount % 2;
        GOOG.transfer(husband, each + remainder);
        GOOG.transfer(wife, each);
    }
}

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
