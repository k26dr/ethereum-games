pragma solidity ^0.4.18; 

contract SimpleLottery {
    uint public constant TICKET_PRICE = 1e16; // 0.01 ether

    address[] public tickets;
    address public winner;
    uint public ticketingCloses;

    function SimpleLottery (uint duration) public {
        ticketingCloses = now + duration;
    }

    function buy () public payable {
        require(msg.value == TICKET_PRICE); 
        require(now < ticketingCloses);

        tickets.push(msg.sender);
    }

    function drawWinner () public {
        require(now > ticketingCloses + 5 minutes);
        require(winner == address(0));

        bytes32 rand = keccak256(
            block.blockhash(block.number-1)
        );
        winner = tickets[uint(rand) % tickets.length];
    }


    function withdraw () public {
        require(msg.sender == winner);
        msg.sender.transfer(this.balance);
    }

    function () payable public {
        buy();
    }
}



// ======================================================================
 


contract RecurringLottery {
    struct Round {
        uint endBlock;
        uint drawBlock;
        Entry[] entries;
        uint totalQuantity;
        address winner;
    }
    struct Entry {
        address buyer;
        uint quantity;
    }

    uint constant public TICKET_PRICE = 1e15;

    mapping(uint => Round) public rounds;
    uint public round;
    uint public duration;
    mapping (address => uint) public balances;

    // duration is in blocks. 1 day = ~5500 blocks
    function RecurringLottery (uint _duration) public {
        duration = _duration;
        round = 1;
        rounds[round].endBlock = block.number + duration;
        rounds[round].drawBlock = block.number + duration + 5;
    }

    function buy () payable public {
        require(msg.value % TICKET_PRICE == 0);

        if (block.number > rounds[round].endBlock) {
            round += 1;
            rounds[round].endBlock = block.number + duration;
            rounds[round].drawBlock = block.number + duration + 5;
        }

        uint quantity = msg.value / TICKET_PRICE;
        Entry memory entry = Entry(msg.sender, quantity);
        rounds[round].entries.push(entry);
        rounds[round].totalQuantity += quantity;
    }

    function drawWinner (uint roundNumber) public {
        Round storage drawing = rounds[roundNumber];
        require(drawing.winner ==  address(0));
        require(block.number > drawing.drawBlock);
        require(drawing.entries.length > 0);

        // pick winner
        bytes32 rand = keccak256(
            block.blockhash(drawing.drawBlock)
        );
        uint counter = uint(rand) % drawing.totalQuantity;
        for (uint i=0; i < drawing.entries.length; i++) {
            uint quantity = drawing.entries[i].quantity;
            if (quantity > counter) {
                drawing.winner = drawing.entries[i].buyer;
                break;
            }
            else
                counter -= quantity;
        }
        
        balances[drawing.winner] += TICKET_PRICE * drawing.totalQuantity;
    }

    function withdraw () public {
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function deleteRound (uint _round) public {
        require(block.number > rounds[_round].drawBlock + 100);
        require(rounds[_round].winner != address(0));
        delete rounds[_round];
    }

    function () payable public {
        buy();
    }
}


// ======================================================================


contract RNGLottery {
    uint constant public TICKET_PRICE = 1e16;

    address[] public tickets;
    address public winner;
    bytes32 public seed;
    mapping(address => bytes32) public commitments;

    uint public ticketDeadline;
    uint public revealDeadline;

    function RNGLottery (uint duration, uint revealDuration) public {
        ticketDeadline = block.number + duration;
        revealDeadline = ticketDeadline + revealDuration;
    }
    
    function createCommitment(address user, uint N) 
      public pure returns (bytes32 commitment) {
        return keccak256(user, N);
    }

    function buy (bytes32 commitment) payable public {
        require(msg.value == TICKET_PRICE); 
        require(block.number <= ticketDeadline);

        commitments[msg.sender] = commitment;
    }

    function reveal (uint N) public {
        require(block.number > ticketDeadline);
        require(block.number <= revealDeadline);

        bytes32 hash = createCommitment(msg.sender, N);
        require(hash == commitments[msg.sender]);

        seed = keccak256(seed, N);
        tickets.push(msg.sender);
    }

    function drawWinner () public {
        require(block.number > revealDeadline);
        require(winner == address(0));

        uint randIndex = uint(seed) % tickets.length;
        winner = tickets[randIndex];
    }

    function withdraw () public {
        require(msg.sender == winner);
        msg.sender.transfer(this.balance);
    }
}


// ======================================================================


contract Powerball {
    struct Round {
        uint endTime;
        uint drawBlock;
        uint[6] winningNumbers;
        mapping(address => uint[6][]) tickets;
    }

    uint public constant TICKET_PRICE = 2e15;
    uint public constant MAX_NUMBER = 69;
    uint public constant MAX_POWERBALL_NUMBER = 26;
    uint public constant ROUND_LENGTH = 3 days;

    uint public round;
    mapping(uint => Round) public rounds;

    function Powerball () public {
        round = 1;
        rounds[round].endTime = now + ROUND_LENGTH;
    }

    function buy (uint[6][] numbers) payable public {
        require(numbers.length * TICKET_PRICE == msg.value);

        for (uint i=0; i < numbers.length; i++) {
            for (uint j=0; j < 6; j++)
                require(numbers[i][j] > 0);
            for (j=0; j < 5; j++)
                require(numbers[i][j] <= MAX_NUMBER);
            require(numbers[i][5] <= MAX_POWERBALL_NUMBER);
        }

        // check for round expiry
        if (now > rounds[round].endTime) {
            rounds[round].drawBlock = block.number + 5;
            round += 1;
            rounds[round].endTime = now + ROUND_LENGTH;
        }

        for (i=0; i < numbers.length; i++)
            rounds[round].tickets[msg.sender].push(numbers[i]);
    }

    function drawNumbers (uint _round) public {
        uint drawBlock = rounds[_round].drawBlock;
        require(now > rounds[_round].endTime);
        require(block.number >= drawBlock);
        require(rounds[_round].winningNumbers[0] == 0);

        for (uint i=0; i < 5; i++) {
            bytes32 rand = keccak256(block.blockhash(drawBlock), i);
            uint numberDraw = uint(rand) % MAX_NUMBER + 1;
            rounds[_round].winningNumbers[i] = numberDraw;
        }
        rand = keccak256(block.blockhash(drawBlock), uint(5));
        uint powerballDraw = uint(rand) % MAX_POWERBALL_NUMBER + 1;
        rounds[_round].winningNumbers[5] = powerballDraw;
    }

    function claim (uint _round) public {
        require(rounds[_round].tickets[msg.sender].length > 0);
        require(rounds[_round].winningNumbers[0] != 0);

        uint[6][] storage myNumbers = rounds[_round].tickets[msg.sender];
        uint[6] storage winningNumbers = rounds[_round].winningNumbers;

        uint payout = 0;
        for (uint i=0; i < myNumbers.length; i++) {
            uint numberMatches = 0;
            for (uint j=0; j < 5; j++) {
                for (uint k=0; k < 5; k++) {
                    if (myNumbers[i][j] == winningNumbers[k])
                        numberMatches += 1;
                }
            }
            bool powerballMatches = (myNumbers[i][5] == winningNumbers[5]);

            // win conditions
            if (numberMatches == 5 && powerballMatches) {
                payout = this.balance;
                break;
            }
            else if (numberMatches == 5)
                payout += 1000 ether;
            else if (numberMatches == 4 && powerballMatches)
                payout += 50 ether;
            else if (numberMatches == 4)
                payout += 1e17; // .1 ether
            else if (numberMatches == 3 && powerballMatches)
                payout += 1e17; // .1 ether
            else if (numberMatches == 3)
                payout += 7e15; // .007 ether
            else if (numberMatches == 2 && powerballMatches)
                payout += 7e15; // .007 ether
            else if (powerballMatches)
                payout += 4e15; // .004 ether
        }

        msg.sender.transfer(payout);
        delete rounds[_round].tickets[msg.sender];
    }

    function ticketsFor(uint _round, address user) public view 
      returns (uint[6][] tickets) {
        return rounds[_round].tickets[user];
    }

    function winningNumbersFor(uint _round) public view
      returns (uint[6] winningNumbers) {
        return rounds[_round].winningNumbers;
    }
}
