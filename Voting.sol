pragma solidity ^0.4.6;

contract Voting {

mapping (bytes32 => uint8) public votesReceived;

// Saving candidate names in bytes32 for optimization
bytes32[] public candidateList;

constructor(bytes32[] _candidateNames) public {
    candidateList = _candidateNames; 
}

// This function returns the list of candidates.
function getCandidateList() public view  returns (bytes32[] memory) {
    return candidateList; 
    }

function validCandidate(bytes32 candidate) public view returns (bool) { 
    for(uint index = 0; index < candidateList.length; index++) 
    {
        if (candidateList[index] == candidate) {
             return true;
        }
    } 
    return false;
}

//Returns total votes received by a candidate
function totalVotesFor(bytes32 candidate) public view returns (uint8) { 
    require(validCandidate(candidate), "The candidate, you are looking for is not a valid candidate");
        return votesReceived[candidate];
}

//Vote a candidate
function voteForCandidate(bytes32 candidate) public {
    require(validCandidate(candidate));
    votesReceived[candidate] += 1; 
    }

function declareTheWinner() public view returns (bytes32){
    bytes32  winner  ;
    uint8  winningVote = 0;
      for(uint index = 0; index < candidateList.length; index++) 
    {
       bytes32 candidate = candidateList[index];
       uint8 votes = votesReceived[candidate];
       if(votes > winningVote){
           winningVote = votes;
           winner = candidate;
       }
    } 
    return winner;
}


}