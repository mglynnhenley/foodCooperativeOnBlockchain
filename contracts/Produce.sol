// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./Market.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Produce is Ownable{
    event OrderQueued(address groupOrder);

    address public farmer;
    address public market;
    bytes32 public produceHash;
    uint256 public price;
    uint256 public orderSize;

    mapping(address=> bool) public orderList;

    enum State {
        UNINITIALIZED,
        OPEN,
        CLOSED
    }
    State private state;

    constructor() {
        state = State.UNINITIALIZED;
    }

    function initilize(
        address _farmer,
        bytes32 _produceHash,
        uint256 _price,
        uint256 _orderSize
    ) external {
        require(state==State.UNINITIALIZED, "This produce has already been initilized");
        _transferOwnership(_farmer);
        market = msg.sender;
        produceHash = _produceHash;
        price = _price;
        orderSize = _orderSize;
        state = State.OPEN;
    }

    /// Place an order an order of the produce
    function placeOrder() external {
        require(state == State.OPEN, "produce is not open for ordering");
        require(
            msg.sender != owner(),
            "farmer cannot place order for their own produce"
        );
        require(!orderList[msg.sender],  "order has already been placed");
        orderList[msg.sender] = true;
        emit OrderQueued(msg.sender);
    }

    function removeOrder() external {
        require(orderList[msg.sender], "no order has been placed");
        orderList[msg.sender] = false;
    }

    function closeProduce() external onlyOwner {
        require(state == State.OPEN, "produce is already closed");
        state = State.CLOSED;
        Market(market).removeProduce();
    }


}
