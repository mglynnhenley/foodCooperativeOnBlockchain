// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0 .0;
import "./Produce.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract Market {
    //This is the immutable definition of produce in this market
    address immutable produceImplementation;

    //This is an array of all current and past produce listed on the market 
    address[] produceAddresses;

    // This mapping stores avaliable produce
    mapping(address=> bool) produceList;
    // This mapping stores farmers who have produce on the Market
    mapping(address=> bool) public farmerList;

    constructor() {
        produceImplementation = address(new ProduceWithNoLeader());
    }
 
    function addProduce( 
        uint256 _name,
        uint256 _price,
        uint256 _orderSize,
        bytes32 _amount,
        uint256 _limitOnPendingOrders
        ) external returns (address produceContract) {
            address newProduceClone = Clones.clone(produceImplementation);
            Produce(newProduceClone).initilize(
                 msg.sender,
                 _name,
                 _price,
                 _orderSize,
                 _amount,
                 _limitOnPendingOrders
            );
            produceAddresses.push(address(newProduceClone));
            produceList[address(newProduceClone)] = true;
            farmerList[msg.sender] = true;
            return produceContract;
    }

    function removeProduce(address produceAddress) public {
        require(produceList[produceAddress], "This produce is not listed on the Market");
        require(Produce(produceAddress).owner()== msg.sender, "Only produce owner can remove produce from Market");
        produceList[produceAddress] = false;
    }


}