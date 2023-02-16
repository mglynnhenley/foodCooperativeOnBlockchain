// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./Market.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ProduceWithNoLeader is Ownable{
    address public farmer;
    address public market;
    address[] private orders;
    uint256 public limitOnPendingOrders;

    uint256 public name;
    uint256 public price;
    uint256 public orderSize;
    bytes32 public amount;

    enum State {
        UNINITIALIZED,
        PRODUCESET
    }
    State private state;

    constructor() {
        state = State.UNINITIALIZED;
    }

    function initilize(
        address _farmer,
        uint256 _name,
        uint256 _price,
        uint256 _orderSize,
        bytes32 _amount,
        uint256 _limitOnPendingOrders
    ) external {
        require(state==State.UNINITIALIZED, "This produce has already been initilized");
        _transferOwnership(_farmer);
        market = msg.sender;
        limitOnPendingOrders = _limitOnPendingOrders;
        name = _name;
        price = _price;
        orderSize = _orderSize;
        amount = _amount;
        state = State.PRODUCESET;
    }

    /// Place an order an order of the produce
    function placeOrder() external payable {
        require(
            msg.sender != owner(),
            "farmer cannot place order for their own produce"
        );
        require(
            msg.value == orderSize * price,
            "order must be of correct size and price"
        );
        require(orders.length < limitOnPendingOrders);
        orders.push(msg.sender);
    }

    /// This allows farmers to take a single produceOrder
    function takeOrder() external onlyOwner returns (address order) {
        require(orders.length > 0, "No orders to take");
        address orderToTake = orders[orders.length - 1];
        orders.pop();
        return orderToTake;
    } 

}
