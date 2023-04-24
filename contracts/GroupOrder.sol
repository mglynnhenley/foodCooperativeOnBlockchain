// SPDX-License-Identifier: UNLICENSD
pragma solidity ^0.8.0;
import "./Produce.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GroupOrder {
    event OrderStateUpdate(State state);
    event OrderFailed(string reason);

    Produce public produce;
    uint256 public portionsAgreed;
    uint256 public portionsPerPerson;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public constant minimumTimeLimit = 25 * (3 * 10**6); // 25 hours or 1500 minutes in milliseconds
    bytes32 public groupOrderHash; // This is a hash of the details of the group order provided off chain such as delivery location and pick up instructions 
    uint256 public requiredVotesToReject;

    // State variable for counting votes to reject the order 
    uint256 public votesToReject = 0;

    enum State {
        OPEN,
        PENDING,
        REJECTED,
        SENT
    }
    State public state;

    mapping(address => bool) orders;

    constructor(address produce_, uint256 timeLimit_, uint256 requiredVotesToReject_) {
        require(timeLimit_ > minimumTimeLimit, "time limit not high enough");
        produce = Produce(produce_);
        requiredVotesToReject = requiredVotesToReject_;
        startTime = block.timestamp;
        endTime = startTime + timeLimit_;
        state = State.OPEN;
    }

    // State: OPEN Functions

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
        emit OrderStateUpdate(state);
    }

    /// One person gets one order to ensure equal economic participation
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
            emit OrderStateUpdate(state);
        } else {
            orders[msg.sender] = true;
            portionsAgreed += 1;
            // The order will be placed as soon as the required order size is met
            if (portionsAgreed == produce.orderSize()) {
                try produce.placeOrder() {
                    state = State.PENDING;
                    emit OrderStateUpdate(state);
                } catch Error(string memory reason) {
                    emit OrderFailed(reason);
                }
            }
            return orders[msg.sender];
        }
    }

    // State: PENDING Functions

    //Function for Farmer to reject Order
    function rejectOrder() external {
        require(state == State.PENDING);
        require(
            msg.sender == produce.farmer(),
            "Only the farmer of the produce can reject the order"
        );
        state = State.REJECTED;
        emit OrderStateUpdate(state);
    }

    // Function for farmer to notify the order is sent
    function acceptOrder() external {
        require(state == State.PENDING);
        require(
            msg.sender == produce.farmer(),
            "Only the farmer of the produce can notify that the order has been accepted"
        );
        state = State.SENT;
        produce.removeOrder();
        emit OrderStateUpdate(state);
        payable(produce.farmer()).transfer(portionsAgreed * produce.price());
    }

    //Function for gropu order members to 
    function voteToCancel() external {
        require(state == State.PENDING, "members can only vote to reject pending orders");
        require(orders[msg.sender], "only members of this group order may vote to reject the order");
        votesToReject += 1;
        if (votesToReject > requiredVotesToReject) {
            state = State.REJECTED;
            produce.removeOrder();
            emit OrderStateUpdate(state);
        }
    }

    // State: REJECTED Functions

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

}
