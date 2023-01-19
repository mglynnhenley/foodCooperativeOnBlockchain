// SPDX-License-Identifier: UNLICENSD
pragma solidity ^0.8.0;
import "./GroupOrder.sol";
import "./Ballot.sol";

contract GroupOrderWithVoting is GroupOrder {

     enum State {
        OPEN,
        ORDER_PENDING,
        REJECTED,
        ORDER_SENT,
        ORDER_DISTRIBUTED,
        VOTING,
        CLOSED
    }

    bool public wasProductDeliveredToMembers ;
    uint public ballotLengthInDays = 10;
    event votingOpen(uint time);
    address public ballot;

    //STATE==ORDER_SENT
    function openVoting() {
        require(state = State.ORDER_DISTRIBUTED);
        ballot = new Ballot(ballotLengthInDays);
        emit votingOpen(block.timestamp);
        state = State.VOTING;
    }

    function wasTheProduceDelivered() {
        require(state == State.VOTING);
        wasProductDeliveredToMembers = ballot.wasTheProduceDelivered();
        state == State.CLOSED;
    }

}