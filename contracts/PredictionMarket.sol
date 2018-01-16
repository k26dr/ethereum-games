contract PredictionMarket {
    enum OrderType { Buy, Sell }
    enum Result { Open, Yes, No }

    struct Order {
        address user;
        OrderType type;
        uint amount;
        uint price;
        bool claimed;
    }

    uint public constant TX_FEE_NUMERATOR = 1;
    uint public constant TX_FEE_DENOMINATOR = 500;

    address owner;
    Result result;
    uint price;
    uint deadline;
    uint counter;
    uint fees;
    mapping(uint => Order) orders;
    mapping(address => uint) shares;

    event OrderPlaced(uint orderId, address user, OrderType orderType, uint amount, uint price);
    event TradeMatched(uint orderId, address user);

    function PredictionMarket (uint duration) public payable {
        require(msg.value > 0);

        owner = msg.sender;
        deadline =  now + duration;
        uint totalShares = msg.value / 100;
        shares[msg.sender] = totalShares;
    }

    function order (OrderType orderType, uint amount, uint price) public payable {
        require(now < deadline);

        if (orderType == OrderType.Buy) {
            require(msg.value == amount * price);
        }
        else
            require(shares[msg.sender] >= amount);
        counter++;
        orders[counter] = Order(msg.sender, orderType, amount, price, false);
        OrderPlaced(counter, msg.sender, orderType, amount, price);
    }

    function trade (uint orderId) public payable {
        require(now < deadline);

        Order order = orders[orderId];
        uint feeShares = order.amount * TX_FEE_NUMERATOR / TX_FEE_DENOMINATOR;
        uint fee = feeShares * price;
        uint amount = order.amount - feeShares;
        fees += fee;
        
        if (orderType == OrderType.Buy) {
            require(msg.value == order.amount * price);
            shares[order.user] += amount;
            shares[msg.sender] -= order.amount;
        }
        else {
            require(shares[msg.sender] >= amount);
            shares[msg.sender] += amount;
            shares[order.user] -= order.amount;
        }
    }

    function resolve (bool _result) public {
        require(now > deadline);
        require(msg.sender == owner);
        require(result == Result.Open);
        result = _result ? Result.Yes : Result.No;
    }

    function claim () public {
        require(result == Result.Yes);
        require(shares[msg.sender] > 0);
        uint payout = shares[msg.sender] * 100;
        shares[msg.sender] = 0;
        msg.sender.transfer(payout);
    }

    function claimOwner () {
        require(msg.sender == owner);
        if (result == Result.Yes) {
            owner.transfer(fees);
            fees = 0;
        }
        else
            owner.transfer(this.balance);
    }
}
