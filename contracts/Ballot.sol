pragma solidity ^0.8.0; 
import "@openzeppelin/contracts/access/Ownable.sol";
import "./GroupOrder.sol";

contract Ballot {

    enum Stage {
        OPEN,
        CLOSED
    }

    Stage public stage;
    uint public ballotLengthInDays;
    uint public creationTime = block.timestamp;
    uint public endTime;
    uint private votesFor;
    uint private votesAgainst;
    address public groupOrder;
    mapping(address => bool) voted;

    

    constructor(address groupOrder, uint ballotLengthInDays) {
        stage = Stage.OPEN;
        votesCast = 0;
        endTime = creationTime + ballotLengthInDays;
    }

    // Stage == stage.OPEN
    function castVote(bool produceArrived) public {
        require(stage == Stage.OPEN);
        require(block.timestamp<endTime, "voting already ended");
        require(!voted[address], "Member has already voted");
        require(groupOrder.orders[msg.sender]>0, "only Members who have placed order with the groupOrder can vote");

        if(produceArrived){
            votesFor+=1;
            }
        else {
            votesAgainst+=1;
            }
        voted[address] = true;
    }

    function votingEnd() external {
        require(stage == Stage.OPEN);
        require(block.timestamp>endTime, "voting not ended yet");
        stage = Stage.CLOSED;
        return (votesFor, votesAgainst);
    }

    function wasTheProduceDelivered() external view returns (bool) {
        require(stage = Stage.CLOSED);
        return votesFor>votesAgainst;
    }

} 