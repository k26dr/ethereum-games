pragma solidity ^0.4.18;

contract PredictionMarket {
    enum OrderType { Buy, Sell }
    enum Result { Open, Yes, No }

    struct Order {
        address user;
        OrderType orderType;
        uint amount;
        uint price;
    }

    uint public constant TX_FEE_NUMERATOR = 1;
    uint public constant TX_FEE_DENOMINATOR = 500;

    address public owner;
    Result public result;
    uint public deadline;
    uint public counter;
    uint public collateral;
    mapping(uint => Order) public orders;
    mapping(address => uint) public shares;
    mapping(address => uint) public balances;

    event OrderPlaced(uint orderId, address user, OrderType orderType, uint amount, uint price);
    event TradeMatched(uint orderId, address user, uint amount);
    event OrderCanceled(uint orderId);
    event Payout(address user, uint amount);

    function PredictionMarket (uint duration) public payable {
        require(msg.value > 0);

        owner = msg.sender;
        deadline =  now + duration;
        shares[msg.sender] = msg.value / 100;
        collateral = msg.value;
    }

    function orderBuy (uint price) public payable {
        require(now < deadline);
        require(msg.value > 0);
        require(price >= 0);
        require(price <= 100);
        uint amount = msg.value / price;

        counter++;
        orders[counter] = Order(msg.sender, OrderType.Buy, amount, price);
        OrderPlaced(counter, msg.sender, OrderType.Buy, amount, price);
    }

    function orderSell (uint price, uint amount) public {
        require(now < deadline);
        require(shares[msg.sender] >= amount);
        require(price >= 0);
        require(price <= 100);

        shares[msg.sender] -= amount;

        counter++;
        orders[counter] = Order(msg.sender, OrderType.Sell, amount, price);
        OrderPlaced(counter, msg.sender, OrderType.Sell, amount, price);
    }

    function tradeBuy (uint orderId) public payable {
        Order storage order = orders[orderId];

        require(now < deadline);
        require(order.user != msg.sender); 
        require(order.orderType == OrderType.Sell);
        require(order.amount > 0);
        require(msg.value > 0);
        require(msg.value <= order.amount * order.price);

        uint amount = msg.value / order.price;
        uint fee = (amount * order.price) * TX_FEE_NUMERATOR / TX_FEE_DENOMINATOR;
        uint feeShares = amount * TX_FEE_NUMERATOR / TX_FEE_DENOMINATOR;

        shares[msg.sender] += (amount - feeShares);
        shares[owner] += feeShares;

        balances[order.user] += (amount * order.price) - fee;
        balances[owner] += fee;

        order.amount -= amount;
        if (order.amount == 0) 
            delete orders[orderId];

        TradeMatched(orderId, msg.sender, amount);
    }

    function tradeSell (uint orderId, uint amount) public {
        Order storage order = orders[orderId];

        require(now < deadline);
        require(order.user != msg.sender); 
        require(order.orderType == OrderType.Buy);
        require(order.amount > 0);
        require(amount <= order.amount);
        require(shares[msg.sender] >= amount);

        uint fee = (amount * order.price) * TX_FEE_NUMERATOR / TX_FEE_DENOMINATOR;
        uint feeShares = amount * TX_FEE_NUMERATOR / TX_FEE_DENOMINATOR;

        shares[msg.sender] -= amount;
        shares[order.user] += (amount - feeShares);
        shares[owner] += feeShares;

        balances[msg.sender] += (amount * order.price) - fee;
        balances[owner] += fee;

        order.amount -= amount;
        if (order.amount == 0) 
            delete orders[orderId];

        TradeMatched(orderId, msg.sender, amount);
    }

    function cancelOrder (uint orderId) public {
        Order storage order = orders[orderId];

        require(order.user == msg.sender);

        if (order.orderType == OrderType.Buy)
            balances[msg.sender] += order.amount * order.price;
        else
            shares[msg.sender] += order.amount;

        delete orders[orderId];
        OrderCanceled(orderId);
    }

    function resolve (bool _result) public {
        require(now > deadline);
        require(msg.sender == owner);
        require(result == Result.Open);

        result = _result ? Result.Yes : Result.No;
        if (result == Result.No)
            balances[owner] += collateral;
    }

    function withdraw () public {
        uint payout = balances[msg.sender];
        balances[msg.sender] = 0;

        if (result == Result.Yes) {
            payout += shares[msg.sender] * 100;
            shares[msg.sender] = 0;
        }

        msg.sender.transfer(payout);
        Payout(msg.sender, payout);
    }

}
