pragma solidity ^0.4.18; 

contract SimpleLottery {
    enum State { Ticketing, Drawing, Complete }

    address[] tickets;
    address winner;
    State state;
    uint ticketingCloses;

    // duration is the length of the ticketing period
    // in seconds
    function SimpleLottery (uint duration) public {
        state = State.Ticketing;
        ticketingCloses = now + duration;
    }

    function buy () payable public {
        require(msg.value == 1e16); // 0.01 ether
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
