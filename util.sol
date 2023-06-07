// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library util{

    function convertTobytes32(string memory _input) public pure returns (bytes32 ){
        return bytes32(abi.encodePacked(_input));
    }
    
    function convertToString(bytes32 _input) public pure  returns (string memory){
        string memory stringOutput = string(abi.encodePacked(_input));
        return  stringOutput;
    }
}