// SPDX-License-Identifier: UNLICENSD
pragma solidity ^0.8.0;
import "./Produce.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GroupOrder {

    Produce public produce;
    uint public portionsAgreed; 

    enum State {
        OPEN,
        ORDER_PENDING,
        REJECTED,
        ORDER_SENT
    }
    State private state;

    mapping(address => uint) orders;
    address[] orderList;

    constructor(address produce_) {
        produce = Produce(produce_);
        state = State.OPEN;
    }

    /// anyone can submit the order if the portions agreed has reached the max size
    function submitOrder() external {
        require(state == State.OPEN);
        require(
            portionsAgreed == produce.orderSize()
        );
        state = State.ORDER_PENDING;
        produce.placeOrder();
    }

    /// Function for User to pledge individual order to the group order
    /// @param numberOfPortions number of portions required for order
    /// @dev returns boolean flag variable representing whether the order has been sent
    function placeOrder(
        uint256 numberOfPortions
    ) external payable returns (uint portions) {
        require(state == State.OPEN);
        require(produce.orderSize() - numberOfPortions >= numberOfPortions);
        require(numberOfPortions * produce.price() == msg.value);

        orderList.push(msg.sender);
        orders[msg.sender] += portions;
        portionsAgreed += portions;
        return orders[msg.sender];
    }

//Function for Farmer to reject Order 
    function rejectOrder() external {
        require(
            msg.sender == produce.farmer(),
            "Only the farmer of the produce can reject the order"
        );
        state = State.REJECTED;
    }

// Function for farmer to notify the order is sent
// In the version without voting this will be enough to transfer the funds to the farmer
    function notifyOrderSent() external {
        require(state == State.ORDER_PENDING);
        require(
            msg.sender == produce.farmer(),
            "Only the farmer of the produce can notify that the order has been sent"
        );
        state = State.ORDER_SENT;
        payable(produce.farmer()).transfer(portionsAgreed*produce.price());
    }

//Function for members of the order to withdraw funds if order is rejected
    function withdrawFunds() external {
        require(state == State.REJECTED, "order has not been rejected");
        require(orders[msg.sender] > 0, "customer has no outstanding balance to refund");
        uint amount = orders[msg.sender];
        orders[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
