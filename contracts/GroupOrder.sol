// SPDX-License-Identifier: UNLICENSD
pragma solidity ^0.8.0;
import "./Produce.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GroupOrder {
    Produce public produce;
    uint256 public portionsAgreed;
    uint256 public startTime;
    uint256 public endTime;

    enum State {
        OPEN,
        PENDING,
        REJECTED,
        SENT
    }
    State public state;

    mapping(address => uint256) orders;
    address[] public orderList;

    constructor(address produce_, uint256 timeLimit_) {
        // We probably don't want our orders to be open for any time
        // In particular lets put a lower limit of 25 minutes 
        require(timeLimit_ > 1500);
        produce = Produce(produce_);
        startTime = block.timestamp;
        endTime = startTime + timeLimit_;
        state = State.OPEN;
    }

    /// anyone can submit the order if the portions agreed has reached the max size
    function submitOrder() external {
        require(state == State.OPEN);
        require(portionsAgreed == produce.orderSize());
        state = State.PENDING;
        produce.placeOrder();
    }

    /// Function for User to pledge individual order to the group order
    /// @param numberOfPortions number of portions required for order
    /// @dev returns boolean flag variable representing whether the order has been sent
    function placeOrder(uint256 numberOfPortions)
        external
        payable
        returns (uint256 portions)
    {
        require(state == State.OPEN);
        require(produce.orderSize() - numberOfPortions >= numberOfPortions);
        require(numberOfPortions * produce.price() == msg.value);
        if (block.timestamp > endTime) {
            state = State.REJECTED;
        } else {
            orderList.push(msg.sender);
            orders[msg.sender] += portions;
            portionsAgreed += portions;
            return orders[msg.sender];
        }
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
        require(state == State.PENDING);
        require(
            msg.sender == produce.farmer(),
            "Only the farmer of the produce can notify that the order has been sent"
        );
        state = State.SENT;
        payable(produce.farmer()).transfer(portionsAgreed * produce.price());
    }

    //Function for members of the order to withdraw funds if order is rejected
    function withdrawFunds() external {
        require(state == State.REJECTED, "order has not been rejected");
        require(
            orders[msg.sender] > 0,
            "customer has no outstanding balance to refund"
        );
        uint256 amount = orders[msg.sender];
        orders[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    // function for the timeout of the GroupOrder
    function timeOutGroupOrder() external {
        require(
            state == State.OPEN,
            "The order state is not open, so can not be timed out"
        );
        require(
            block.timestamp > endTime,
            "The group order has not yet timed out"
        );
        state = State.REJECTED;
    }
}
