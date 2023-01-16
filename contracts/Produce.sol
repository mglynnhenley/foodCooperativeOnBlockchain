// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./Market.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Produce is Ownable{
    address public farmer;
    address[] private orders;
    uint256 public limitOnPendingOrders;

    ProduceInformation public produceInformation;
    struct ProduceInformation{
        uint256 name;
        uint256 price;
        uint256 orderSize;
        bytes32 amount;
    }


    function initilize(
        address _farmer,
        uint256 _name,
        uint256 _price,
        uint256 _orderSize,
        bytes32 _amount,
        uint256 _limitOnPendingOrders
    ) external {
        _transferOwnership(_farmer);
        limitOnPendingOrders = _limitOnPendingOrders;
        produceInformation = ProduceInformation(
            {
            name: _name,
            price: _price,
            orderSize: _orderSize,
            amount: _amount
        }
        );
    }

    /// Place an order an order of the produce
    function placeOrder() external payable {
        require(
            msg.sender != owner(),
            "farmer cannot place order for their own produce"
        );
        require(
            msg.value == produceInformation.orderSize * produceInformation.price,
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
