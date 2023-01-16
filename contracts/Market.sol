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
    // This mapping stores farmers who ahve produce on the Market
    mapping(address=> bool) public farmerList;

    constructor() public {
        produceImplementation = address(new Produce());
    }
 
    function addProduce( 
        uint256 _name,
        uint256 _price,
        uint256 _minimumOrder,
        uint256 _maximumOrder,
        bytes32 _amount) external returns (address produceContract) {
            address newProduceClone = Clones.clone(produceImplementation);
            Produce(newProduceClone).initilize(
                 msg.sender,
                 _name,
                 _price,
                 _minimumOrder,
                 _maximumOrder,
                 _amount
            );
            produceAddresses.push(address(newProduceClone));
            produceList[address(newProduceClone)] = true;
            farmerList[msg.sender] = true;
    }

    function removeProduce(address produceAddress) public {
        require(produceList[produceAddress], "This produce is not listed on the Market");
        require(Produce(produceAddress).owner == msg.sender, "Only produce owner can remove produce from Market");
        produceList[produceAddress] = false;
    }

    function getProduceList() public returns (address[] calldata){
        // we want to put a limit on the number of addresses in the contract
        address[] memory names = new address[](produceAddresses.length);
        for (uint i = 0; i<produceAddresses.length; ++i ) {
            if (produceList[produceAddresses[i]]) {
                names.push(produceAddresses[i]);
            }
        }
        return names;
    }

}