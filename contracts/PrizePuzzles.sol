pragma solidity ^0.4.18;

contract SimplePrize {
    bytes32 public constant salt = bytes32(987463829);
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

contract CommitRevealPuzzle {
    uint public constant GUESS_DURATION_BLOCKS = 5; // 3 days
    uint public constant REVEAL_DURATION_BLOCKS = 5; // 1 day

    address public creator;
    uint public guessDeadline;
    uint public revealDeadline;
    uint public totalPrize;
    mapping(address => bytes32) public commitments;
    address[] public winners;
    mapping(address => bool) public claimed;
    
    function CommitRevealPuzzle(bytes32 _commitment) public payable {
        creator = msg.sender;
        commitments[creator] = _commitment;
        guessDeadline = block.number + GUESS_DURATION_BLOCKS;
        revealDeadline = guessDeadline + REVEAL_DURATION_BLOCKS;
        totalPrize += msg.value;
    }

    function createCommitment(address user, uint answer) 
      public pure returns (bytes32) {
        return keccak256(user, answer);
    }

    function guess(bytes32 _commitment) public {
        require(block.number < guessDeadline);
        require(msg.sender != creator);
        commitments[msg.sender] = _commitment;
    }

    function reveal(uint answer) public {
        require(block.number > guessDeadline);
        require(block.number < revealDeadline);
        require(createCommitment(msg.sender, answer) == commitments[msg.sender]);
        require(createCommitment(creator, answer) == commitments[creator]);
        require(!isWinner(msg.sender));
        winners.push(msg.sender);
    }

    function claim () public {
        require(block.number > revealDeadline);
        require(claimed[msg.sender] == false);
        require(isWinner(msg.sender));

        uint payout = totalPrize / winners.length;
        claimed[msg.sender] = true;
        msg.sender.transfer(payout);
    }

    function isWinner (address user) public view returns (bool) {
        bool winner = false;
        for (uint i=0; i < winners.length; i++) {
            if (winners[i] == user) {
                winner = true;
                break;
            }
        }
        return winner;
    }

    function () public payable {
        totalPrize += msg.value;
    }
}
