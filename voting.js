(() => {
  // Candidates for testing ["0x48696d616e736875000000000000000000000000000000000000000000000000", "0x596f67656e647261000000000000000000000000000000000000000000000000"]
  if (typeof web3 !== "undefined") {
    web3 = new Web3(web3.currentProvider);
  } else {
    web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));
  }
  const myAddress = "0xD514D486Adb352a2f42CF0B5fBCD35f3D52B5c56";
  const contractAddress = "0x711C1e646564EF4F22E54B8DC1A6a764970f7147";
  const contractInstance = new web3.eth.Contract(
    [
      {
        "constant": false,
        "inputs": [
          {
            "name": "candidate",
            "type": "bytes32"
          }
        ],
        "name": "voteForCandidate",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "name": "_candidateNames",
            "type": "bytes32[]"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "constructor"
      },
      {
        "constant": true,
        "inputs": [
          {
            "name": "",
            "type": "uint256"
          }
        ],
        "name": "candidateList",
        "outputs": [
          {
            "name": "",
            "type": "bytes32"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "declareTheWinner",
        "outputs": [
          {
            "name": "",
            "type": "bytes32"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "getCandidateList",
        "outputs": [
          {
            "name": "",
            "type": "bytes32[]"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [
          {
            "name": "candidate",
            "type": "bytes32"
          }
        ],
        "name": "totalVotesFor",
        "outputs": [
          {
            "name": "",
            "type": "uint8"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [
          {
            "name": "candidate",
            "type": "bytes32"
          }
        ],
        "name": "validCandidate",
        "outputs": [
          {
            "name": "",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [
          {
            "name": "",
            "type": "bytes32"
          }
        ],
        "name": "votesReceived",
        "outputs": [
          {
            "name": "",
            "type": "uint8"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      }
    ],
    contractAddress
  );

  const tableElem = document.getElementById("table-body");
  const candidateOptions = document.getElementById("candidate-options");
  const voteForm = document.getElementById("vote-form");

  // Get and display the winner name on the screen
  function announceTheWinner() {
    contractInstance.methods
          .declareTheWinner()
          .call()
          .then(function (winner) {
            document.getElementById("winner-name").innerText = "Winner is " + web3.utils.toAscii(winner);

            announceTheWinner();
          });
  }

  function handleVoteForCandidate(evt) {
    evt.preventDefault();
    const candidate = new FormData(evt.target).get("candidate");
    contractInstance.methods
      .voteForCandidate(candidate)
      .send({ from: myAddress, gas: 300000 })
      .on("transactionHash", function (result) {
        // Vote is given now get the total votes and update the UI
        contractInstance.methods
          .totalVotesFor(candidate)
          .call()
          .then(function (votes) {
            document.getElementById("vote-" + candidate).innerText = votes;

            announceTheWinner();
          });
      });
  }

  voteForm.addEventListener("submit", handleVoteForCandidate, false);

  function populateCandidates() {
    contractInstance.methods
      .getCandidateList()
      .call()
      .then(function (candidateList) {
        candidateList.forEach((candidate) => {
          const candidateName = web3.utils.toAscii(candidate);
          contractInstance.methods
            .totalVotesFor(candidate)
            .call()
            .then(function (votes) {
              // Creates a row element.
              const rowElem = document.createElement("tr"); // Creates a cell element for the name.
              const nameCell = document.createElement("td");
              nameCell.innerText = candidateName;
              rowElem.appendChild(nameCell);
              // Creates a cell element for the votes.
              const voteCell = document.createElement("td");
              voteCell.id = "vote-" + candidate;
              voteCell.innerText = votes;
              rowElem.appendChild(voteCell);
              // Adds the new row to the voting table.
              tableElem.appendChild(rowElem);
              // Creates an option for each candidate
              const candidateOption = document.createElement("option");
              candidateOption.value = candidate;
              candidateOption.innerText = candidateName;
              candidateOptions.appendChild(candidateOption);
            });
        });
      });
  }
  populateCandidates();
})();
