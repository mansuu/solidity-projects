// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage{
    uint256 public favNumber;

    struct People{
        uint256 favNumber;
        string name;
    }

    People[] public people;
    mapping (string => uint256) nameTofavNumber;

    function store(uint256 _favNumber) public virtual {
        favNumber = _favNumber;
    }

    function retrievefavNumber() public view returns(uint256){
        return favNumber;
    }
 
    function addPerson(string memory _name, uint256 _favNumber) public {
        people.push(People(_favNumber, _name));
        nameTofavNumber[_name] = _favNumber;
    }



}