// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./Market.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Produce is Ownable{
    address public farmer;
    address[] private orders;
    uint256 public limitOnPendingOrders;

    // This is the information for the produce contract 
    uint256 public name;
    uint256 public pricePerPortion;
    uint256 public portionsPerOrder;
    bytes32 public amountPerPortion;


    function initilize(
        address _farmer,
        uint256 _name,
        uint256 _pricePerPortion,
        uint256 _portionsPerOrder,
        bytes32 _amountPerPortion,
        uint256 _limitOnPendingOrders
    ) external {
        _transferOwnership(_farmer);
        name = _name;
        pricePerPortion = _pricePerPortion;
        portionsPerOrder = _portionsPerOrder;
        amountPerPortion = _amountPerPortion;
        limitOnPendingOrders = _limitOnPendingOrders;
        }

    /// Place an order an order of the produce
    function placeOrder() external payable {
        require(
            msg.sender != owner(),
            "farmer cannot place order for their own produce"
        );
        require(
            msg.value == portionsPerOrder * pricePerPortion,
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