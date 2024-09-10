// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract VotingSystem {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool hasVoted;
        uint votedFor;
    }

    address public admin;
    bool public votingEnded;

    mapping(address => Voter) public voters;
    mapping(uint => Candidate) public candidates;
    uint public candidateCount;

    event Voted(address voter, uint candidateId);
    event VotingEnded(uint winnerId, string winnerName);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier hasNotVoted() {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        _;
    }

    modifier isVotingActive() {
        require(!votingEnded, "Voting has ended");
        _;
    }

    constructor() {
        admin = msg.sender;
        votingEnded = false;
    }

    function addCandidate(string memory name) public onlyAdmin {
        candidateCount++;
        candidates[candidateCount] = Candidate(candidateCount, name, 0);
    }

    function vote(uint candidateId) public hasNotVoted isVotingActive {
        require(candidateId > 0 && candidateId <= candidateCount, "Invalid candidate");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedFor = candidateId;

        candidates[candidateId].voteCount++;

        emit Voted(msg.sender, candidateId);
    }

    function endVoting() public onlyAdmin isVotingActive {
        votingEnded = true;
        uint winnerId = 0;
        uint highestVotes = 0;

        for (uint i = 1; i <= candidateCount; i++) {
            if (candidates[i].voteCount > highestVotes) {
                highestVotes = candidates[i].voteCount;
                winnerId = i;
            }
        }

        emit VotingEnded(winnerId, candidates[winnerId].name);
    }
}
