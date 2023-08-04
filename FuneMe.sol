// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

//Custom error
error NotOwner();

contract FuneMe{

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18;

    address[] public funders;
    mapping (address => uint256) addressToAmount;

    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    modifier onlyOwner{
       if(msg.sender != i_owner )
       { 
           revert NotOwner();
       }
       _;
    }

    function fund() public payable{

       require(msg.value.getConversionRate() >= MINIMUM_USD, "Did not send enough"); 
       funders.push(msg.sender);
       addressToAmount[msg.sender] = msg.value;

    }

    function withdraw() public onlyOwner{

        for(uint256 index = 0; index < funders.length ; index++){
            address funder = funders[index];
            addressToAmount[funder] = 0;
        }

        //reset the funders array
        funders = new address[](0);

        //send the ether
        //transfer --- throws error if fails
        //Send -- returns bool
        //Call -- returns bool, most reecommended way
        (bool success, bytes memory data) = payable(msg.sender).call{value : address(this).balance}("");
        require(success, "Withdrwal failed");
    }

    

}