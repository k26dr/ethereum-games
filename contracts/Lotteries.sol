pragma solidity ^0.4.18; 

contract SimpleLottery {
    enum State { Ticketing, Drawing, Complete }

    uint public constant TICKET_PRICE = 1e16;

    address[] tickets;
    address winner;
    State state;

    uint ticketingCloses;
    uint drawingBlock;

    function SimpleLottery (uint duration) public {
        state = State.Ticketing;
        ticketingCloses = now + duration;
    }

    function buy () payable public {
        require(msg.value == 1e16); // 0.01 ether
        require(state == State.Ticketing);
        require(now < ticketingCloses);

        tickets.push(msg.sender);
    }

    function closeTicketing () public {
        require(state == State.Ticketing);

        if (now > ticketingCloses) {
            state = State.Drawing;
            drawingBlock = block.number + 2;
        }
    }

    function drawWinner () public {
        require(state == State.Drawing);
        require(block.number >= drawingBlock);

        bytes32 rand = keccak256(block.blockhash(block.number-1));
        uint randint = uint(rand);
        winner = tickets[randint % tickets.length];

        state = State.Complete;
    }

    function withdraw () public {
        require(state == State.Complete);
        require(msg.sender == winner);
        msg.sender.transfer(this.balance);
    }
}



contract RecurringLottery {
    enum State { Ticketing, Drawing, Complete }

    uint constant public TICKET_PRICE = 1e16;

    address[] tickets;
    State public state;
    uint public ticketingCloses;
    uint public round;
    uint duration;
    mapping (address => uint) public balances;

    // duration is the length of the ticketing period
    // in seconds
    function RecurringLottery (uint _duration) public {
        state = State.Ticketing;
        duration = _duration;
        ticketingCloses = now + duration;
        round = 1;
    }

    function buy () payable public {
        require(msg.value == TICKET_PRICE);
        require(state == State.Ticketing);

        if (now > ticketingCloses)
            state = State.Drawing;
        else 
            tickets.push(msg.sender);
    }

    function drawWinner () public {
        require(state == State.Drawing);

        bytes32 rand = keccak256(block.blockhash(block.number-1));
        uint randint = uint(rand);

        address winner = tickets[randint % tickets.length];
        balances[winner] += TICKET_PRICE * tickets.length;

        // reset lottery
        state = State.Ticketing;
        ticketingCloses = now + duration;
        tickets.length = 0;
        round += 1;
    }

    function withdraw () public {
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}

contract RNGLottery {
    enum State { Ticketing, Revealing, Drawing, Complete }

    uint constant public TICKET_PRICE = 2e15;

    address[] public tickets;
    address public winner;
    State public state;
    bytes32 public seed;
    mapping(address => bytes32) commitments;

    uint public ticketingCloses;
    uint public drawingBlock;

    // duration is the length of the ticketing period
    // in seconds
    function RNGLottery (uint duration) public {
        state = State.Ticketing;
        ticketingCloses = now + duration;
    }

    function buy (bytes32 commitment) payable public {
        require(msg.value == TICKET_PRICE); 
        require(state == State.Ticketing);
        require(now < ticketingCloses);

        commitments[msg.sender] = commitment;
    }

    function reveal (uint N) public {
        bytes32 hash = keccak256(msg.sender, N);
        require(hash == commitments[msg.sender]);

        seed = keccak256(seed, N);
        tickets.push(msg.sender);
    }

    function drawWinner () public {
        require(state == State.Drawing);

        uint randIndex = uint(seed) % tickets.length;
        winner = tickets[randIndex];

        state = State.Complete;
    }

    function withdraw () public {
        require(state == State.Complete);
        require(msg.sender == winner);
        msg.sender.transfer(this.balance);
    }
}

contract Powerball {
    struct Round {
        uint endTime;
        uint drawBlock;
        uint[6] winningNumbers;
    }

    uint public constant TICKET_PRICE = 2e15;
    uint public constant MAX_NUMBER = 69;
    uint public constant MAX_POWERBALL_NUMBER = 26;

    uint public round;
    mapping(uint => mapping(address => uint[6][])) tickets;
    mapping(uint => Round) public rounds;

    function Powerball () public {
        round = 1;
        rounds[round].endTime = now + 3 days;
    }

    function buy (uint[6] numbers) payable public {
        require(msg.value == TICKET_PRICE);
        for (uint i=0; i < 5; i++)
            require(numbers[i] > 0);
        for (i=0; i < 5; i++)
            require(numbers[i] <= MAX_NUMBER);
        require(numbers[5] <= MAX_POWERBALL_NUMBER);

        // check for round expiry
        if (now > rounds[round].endTime) {
            rounds[round].drawBlock = block.number + 5;
            round += 1;
            rounds[round].endTime = now + 3 days;
        }

        tickets[round][msg.sender].push(numbers);
    }

    function drawNumbers (uint _round) public {
        uint drawBlock = rounds[_round].drawBlock;
        require(block.number >= drawBlock);
        require(rounds[_round].winningNumbers[0] == 0);

        for (uint i=0; i < 5; i++) {
            bytes32 rand = keccak256(block.blockhash(drawBlock), i);
            uint numberDraw = uint(rand) % MAX_NUMBER + 1;
            rounds[_round].winningNumbers[i] = numberDraw;
        }
        rand = keccak256(block.blockhash(drawBlock), 5);
        uint powerballDraw = uint(rand) % MAX_POWERBALL_NUMBER + 1;
        rounds[_round].winningNumbers[5] = powerballDraw;
    }

    function claim (uint _round) public {
        uint[6][] storage myNumbers = tickets[_round][msg.sender];
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
                payout += this.balance;
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
                payout += 4e15; // .004 ether
            else if (powerballMatches)
                payout += 4e15; // .004 ether
        }

        msg.sender.transfer(payout);
    }
}
