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

    /// Owner of the food proposal contract can submit order to Market if minimum order requirement is met
    /// @dev can only be called by the owner of the GroupOrder, this function also changes the state to closed
    function submitOrder() external onlyOwner {
        require(state == State.OPEN);
        require(
            portionsAgreed == produce.orderSize()
        );
        state = State.ORDERPENDING;
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

    function rejectOrder() external {
        require(
            msg.sender == produce.farmer(),
            "Only the farmer of the produce can reject the order"
        );
        state = State.REJECTED;
    }

    function notifyOrderSent() external {
        require(state == State.ORDER_
        PENDING);
        require(
            msg.sender == produce.farmer(),
            "Only the farmer of the produce can notify that the order has been sent"
        );
        state = State.ORDER_SENT;
    }

    function notifyOrderWithGroupLeader() external {
        require(state == State.ORDER_SENT);
        require(
            msg.sender == produce.deliverer(),
            "Only the deliverer of the produce can notify that the order has been delivered"
        );
        state = State.ORDER_WITH_GROUP_LEADER;
        payable(produce.farmer()).transfer(portionsAgreed*produce.price());
    }

    function withdrawFunds() external {
        require(state == State.REJECTED, "order has not been rejected");
        require(orders[msg.sender] > 0, "customer has no outstanding balance to refund");
        uint amount = orders[msg.sender];
        orders[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
