const Election = artifacts.require("./Election.sol");

contract("Election", function (accounts) {
    let electionInstance;

    // Test case for contract deployment
    it("initializes with no candidates", function () {
        return Election.deployed().then(function (instance) {
            return instance.candidates.length;
        }).then(function (count) {
            assert.equal(count, 0);
        });
    });

    // Test case for voting functionality
    it("allows a voter to cast a vote", function () {
        return Election.deployed().then(function (instance) {
            electionInstance = instance;
            candidateName = web3.utils.asciiToHex("Candidate 1");
            return electionInstance.vote(12345, candidateName, { from: accounts[0] });
        }).then(function (receipt) {
            assert.equal(receipt.logs.length, 1, "an event was triggered");
            assert.equal(receipt.logs[0].event, "VotedEvent", "the event type is correct");
            return electionInstance.voters(accounts[0]);
        }).then(function (voted) {
            assert(voted, "the voter was marked as voted");
            return electionInstance.candidates(candidateName);
        }).then(function (candidate) {
            assert.equal(candidate.voteCount, 1, "increments the candidate's vote count");
        });
    });

    // Test case for checking the winning candidate
    it("declares the correct winner", function () {
        return Election.deployed().then(function (instance) {
            return instance.winningCandidate();
        }).then(function (winner) {
            assert.equal(web3.utils.hexToAscii(winner).replace(/\0/g, ''), "Candidate 1");
        });
    });
});
