// SPDX-License-Identifier: UNLICENSD
pragma solidity ^0.8.0;
import "./Produce.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GroupOrder {
    event Log(string message); // change this when you put reasons in

    Produce public produce;
    uint256 public portionsAgreed;
    uint256 public portionsPerPerson;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public constant minimumTimeLimit = 25 * (3 * 10**6); // 25 hours or 1500 minutes in milliseconds
    bytes32 public groupOrderHash; // This is a hash of the details of the group order provided off chain such as delivery location and pick up instructions 

    enum State {
        OPEN,
        PENDING,
        REJECTED,
        SENT
    }
    State public state;

    mapping(address => bool) orders;
    address[] public orderList;

    constructor(address produce_, uint256 timeLimit_) {
        require(timeLimit_ > minimumTimeLimit, "time limit not high enough");
        produce = Produce(produce_);
        startTime = block.timestamp;
        endTime = startTime + timeLimit_;
        state = State.OPEN;
    }

    /// anyone can submit the order if the portions agreed has reached the max size
    // if there is not enough space then users are going to have to keep trying
    function submitOrder() external {
        require(state == State.OPEN);
        require(portionsAgreed == produce.orderSize());
        try produce.placeOrder() {
                    state = State.PENDING;
                } catch Error(string memory reason) {
                    emit Log(reason);
                }
    }

    /// Function for User to pledge individual order to the group order
    /// One person gets one order to ensure equal economic participation
    /// @dev returns boolean flag variable representing whether the order has been sent
    function placeOrder()
        external
        payable
        returns (bool orderplaced)
    {
        require(state == State.OPEN);
        require(produce.orderSize() - 1 <= portionsAgreed);
        require(produce.price() == msg.value);
        if (block.timestamp > endTime) {
            state = State.REJECTED;
        } else {
            orderList.push(msg.sender);
            orders[msg.sender] = true;
            portionsAgreed += 1;
            // The order will be placed as soon as the required order size is met
            if (portionsAgreed == produce.orderSize()) {
                try produce.placeOrder() {
                    state = State.PENDING;
                } catch Error(string memory reason) {
                    emit Log(reason);
                }
            }
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
    function acceptOrder() external {
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
            orders[msg.sender],
            "customer has no outstanding balance to refund"
        );
        orders[msg.sender] = false;
        payable(msg.sender).transfer(produce.price());
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
