// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0 .0;
import "./Produce.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract Market {
    event ProduceAddedToMarket(address produce, address farmer);
    event ProduceDeletedFromMarket(address produce);

    //This is the immutable definition of produce in this market
    address immutable produceImplementation;

    // This mapping stores avaliable produce
    mapping(address=> bool) produceList;
    // This mapping stores farmers who have produce on the Market
    // This is what would be changed to add an implemented reputation part thing 
    mapping(address=> bool) farmerList;

    constructor() {
        produceImplementation = address(new Produce());
    }
 
    function addProduce( 
        bytes32 _produceHash,
        uint256 _price,
        uint256 _orderSize
        ) external {
            address newProduceClone = Clones.clone(produceImplementation);
            Produce(newProduceClone).initilize(
                 msg.sender,
                 _produceHash,
                 _price,
                 _orderSize
            );
            produceList[address(newProduceClone)] = true;
            farmerList[msg.sender] = true;
            emit ProduceAddedToMarket(address(newProduceClone), msg.sender);
    }

    function removeProduce() public {
        require(produceList[msg.sender], "This produce is not listed on the Market");
        produceList[msg.sender] = false;
        emit ProduceDeletedFromMarket(msg.sender);
    }


}