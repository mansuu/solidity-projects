// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {util} from "./util.sol";

contract TodoList{

    struct Todo{
        uint256 todoId;
        bytes32 note;
        address owner;
        bool isCompleted;
        uint256 creationTimestamp;
        uint256 completionTimeStamp;
        
    }

    uint  constant maxNoOfTodos = 100;

    mapping(address => Todo[maxNoOfTodos]) todos;

    mapping (address => uint256) lastTodoIds;

    modifier _onlyOwner(address _owner){
        require(msg.sender == _owner);
        _;
    }

    function addTodo(string memory _content) public returns (Todo memory){
        
        Todo memory note = Todo(lastTodoIds[msg.sender], util.convertTobytes32(_content), msg.sender, false, block.timestamp, 0);
        todos[msg.sender][lastTodoIds[msg.sender]] = note;
        if(lastTodoIds[msg.sender] >= maxNoOfTodos){
            lastTodoIds[msg.sender] = 0;
        }
        else{
             lastTodoIds[msg.sender]++;
        }
        return note;
    }

    function listAllTheTodos() public view returns (string[] memory , bool[] memory, uint256[] memory){
        string[] memory notes = new string[](lastTodoIds[msg.sender]);
        bool[] memory completed = new bool[](lastTodoIds[msg.sender]);
        uint256[] memory creationDates = new uint256[](lastTodoIds[msg.sender]);
       //object[] data = new Object[](lastTodoIds[msg.sender]-1);
        for (uint256 index = 0; index <= lastTodoIds[msg.sender]-1; index++) 
        {   
            Todo memory todo = todos[msg.sender][index];
            
            notes[index] = util.convertToString(todo.note);
            completed[index] = todo.isCompleted;
            creationDates[index] = todo.creationTimestamp;
            //return  todo;
        }
        
        //return (notes:notes, completed : completed, creationDates : creationDates);
        return (notes, completed, creationDates);
    }

    function markTodoAsCompleted(uint256 _todoId) public _onlyOwner(todos[msg.sender][_todoId].owner){
        
        require(_todoId <= maxNoOfTodos);
        require(!todos[msg.sender][_todoId].isCompleted);
        todos[msg.sender][_todoId].isCompleted = true;
        todos[msg.sender][_todoId].completionTimeStamp = block.timestamp;

    }
}