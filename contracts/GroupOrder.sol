// SPDX-License-Identifier: UNLICENSD
pragma solidity ^0.8.0;
import "./Produce.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GroupOrder is Ownable {

    Produce public produce;
    uint public portionsAgreed; 

    enum State {
        OPEN,
        ORDER_PENDING,
        REJECTED,
        ORDER_SENT,
        ORDER_WITH_GROUP_LEADER,
        ORDER_DISTRIBUTED
    }
    State private state;

    mapping(address => uint) orders;
    address[] orderList;

    constructor(address produce_) {
        produce = Produce(produce_);
        state = State.OPEN;
    }

    // STATE==OPEN

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

    function submitOrder() external onlyOwner {
        require(state == State.OPEN);
        require(
            portionsAgreed == produce.orderSize()
        );
        state = State.ORDERPENDING;
        produce.placeOrder();
    }

    // STATE==REJECTED

    function withdrawFunds() external {
        require(state == State.REJECTED, "order has not been rejected");
        require(orders[msg.sender] > 0, "customer has no outstanding balance to refund");
        uint amount = orders[msg.sender];
        orders[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    // STATE==ORDER_PENDING

    function rejectOrder() external {
        require(state == State.ORDER_PENDING);
        require(
            msg.sender == produce.farmer(),
            "Only the farmer of the produce can reject the order"
        );
        state = State.REJECTED;
    }

    function notifyOrderSent() external {
        require(state == State.ORDER_PENDING);
        require(
            msg.sender == produce.farmer(),
            "Only the farmer of the produce can notify that the order has been sent"
        );
        state = State.ORDER_SENT;
    }

    // STATE==ORDER_SENT

    function notifyOrderWithGroupLeader() external {
        require(state == State.ORDER_SENT);
        require(
            msg.sender == produce.deliverer(),
            "Only the deliverer of the produce can notify that the order has been delivered"
        );
        state = State.ORDER_WITH_GROUP_LEADER;
        payable(produce.farmer()).transfer(portionsAgreed*produce.price());
    }

    function notifyOrderDistributed() onlyOwner {
            require(state == State.ORDER_WITH_GROUP_LEADER);
            state == State.ORDER_DISTRIBUTED;
    }

}
