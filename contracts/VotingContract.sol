// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Election
 * @author Nayna Siddharth, Shomini Sen, Srinath Rangan, Srikar Munukutla, Isabella Otterson, Sofia Bourche
 * @dev A smart contract to be used for school elections
 */
contract Election {

    /** 
     * @dev Voter struct that is created for each student voter. Holds the boolean and a hash of the student's ID.
     */
    struct Voter {
        bool voted;  // If true, that person already voted
        bytes32 idHash; // Hashed value of the student's id
    }
    
    /** 
     * @dev Candidate struct created for each candidate running for student office. Holds the candidate name and the number of votes they currently hold.
     */
    struct Candidate {
        uint256 name;   // Candidate name
        uint voteCount; // Number of votes the candidate has received
        bool exists;
    }

    mapping(bytes32 => Voter) public voters; // Mapping of people who have already voted

    mapping(uint256 => Candidate) public candidates; //Mapping of the candidates running
    uint256[] public candidate_names; 

    uint256 endTime; //When the election will end.

    /** 
     * @dev Create a new ballot for a student election
     * @param votingDuration The length of time that we would like the keep the voting open for.
     */
    constructor(uint256 votingDuration ) {

        endTime = votingDuration + block.timestamp; //Store the time at when the election ends. 
    }

    /**
     * @dev The student with the given voterId votes for the candidate passed in.
     * @param voterId is the student ID of the voter. Assumed that this is an integer
     * @param candidateName the name of the candidate that the voter would like to vote for.
     */
    function vote(uint voterId, bytes32 candidateName) public {

        //Check to make sure that the time for this election has not expired yet. If it has, call the voting end functions
        require(block.timestamp < endTime, "Voting for this election has expired");
        
        //Calculate the hash of the voter's student ID.
        bytes32 hashedVoterID = keccak256(abi.encodePacked(voterId));

        //Check to make sure that a voter with this ID has not already voted by seeing if they exist in our mapping of voters.
        // require(!voters[hashedVoterID].voted, "Already voted.");

        //Create a voter object for the voter with the given voterId. Put it in storage.
        Voter memory currentVoter = Voter({
            idHash: hashedVoterID,
            voted: false
        });
        currentVoter.voted = true;
        //Add the voter with this student id to our lists of voters, so that we can make sure they aren't voting multiple times.
        //Future improvement would be to give each voter multiple votes, and only add them to our list of voters once they have 0 votes left.
        voters[hashedVoterID] = currentVoter;

        uint256 name = uint256(candidateName);

        //If the candidate being voted for doesn't already exist, create a candidate object for them and push them to our list of vandidates.
        if (candidates[name].exists == false ) {
            candidates[name] = Candidate({
                name: name,
                voteCount: 0,
                exists: true
            });
            // candidates.push(Candidate({
            //     name: name,
            //     voteCount: 0,
            //     exists: true
            // }));
            candidate_names.push(name);
        }
        //Increase the number of votes for the given candidate by 1.
        candidates[name].voteCount = candidates[name].voteCount + 1;

    }

    /** 
     * @dev Return the name of the winning candidate by seeing which candidate has the most votes
     * @return winningCandidate_ Name of the winner
     */
    function winningCandidate(bool time) public view
            returns (bytes32 winningCandidate_)
    {
        if (time) {
            require(block.timestamp>=endTime, "There is no winner, since voting has not ended yet");
        }
        uint maxVoteCount = 0;
        bool tie_occured = false;
        string memory tie;
        for (uint i = 0; i < candidate_names.length; i++) {
            if (candidates[candidate_names[i]].voteCount > maxVoteCount) {
                maxVoteCount = candidates[candidate_names[i]].voteCount;
                winningCandidate_ = bytes32(candidates[candidate_names[i]].name);
                tie_occured = false;
            }
            else if (candidates[candidate_names[i]].voteCount == maxVoteCount) {
                tie = string.concat(string(abi.encodePacked(winningCandidate_)), string(abi.encodePacked((bytes32(candidates[candidate_names[i]].name)))));
                tie_occured = true;
            }
        }
        require(!tie_occured, string.concat("Tie between: ", tie));
    }
}