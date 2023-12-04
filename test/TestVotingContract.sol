import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/VotingContract.sol";
import "truffle/Console.sol";

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract TestVotingContract {

    /**
    Checks to see if a a winner is correctly determined.
    */
    function testCheckWinner () public {
        uint256 votingDuration = 1 hours;
        Election electionTest = new Election(votingDuration);
        electionTest.vote(1, bytes32("Bird"));
        electionTest.vote(2, bytes32("Magic"));
        electionTest.vote(3, bytes32("Jordan"));
        electionTest.vote(4, bytes32("Thomas"));
        electionTest.vote(5, bytes32("Thomas"));
        electionTest.vote(6, bytes32("Hakeem"));
        electionTest.vote(7, bytes32("Jordan"));
        electionTest.vote(8, bytes32("Magic"));
        electionTest.vote(9, bytes32("Jordan"));
        electionTest.vote(10, bytes32("Bird"));
        electionTest.vote(11, bytes32("Bird"));
        electionTest.vote(12, bytes32("Bird"));
        electionTest.vote(13, bytes32("Bird"));
        Assert.equal(electionTest.winningCandidate(false), bytes32("Bird"), "Bird should be the winner name");
    }

    /**
    Checks to see if a tie is correctly called.
    */
    function testCheckTie () public {
        uint256 votingDuration = 1 hours;
        Election electionTest2 = new Election(votingDuration);
        electionTest2.vote(1, bytes32("Jordan"));
        electionTest2.vote(2, bytes32("LeBron"));
        electionTest2.vote(3, bytes32("Jordan"));
        electionTest2.vote(4, bytes32("LeBron"));

        bool success;
        bytes memory revertReason;
        (success, revertReason) = address(electionTest2).call(abi.encodeWithSignature("winningCandidate(bool)", false));

        Assert.isFalse(success, "Tie Occured");
    }

    /**
    Throw-away test to see if time error throws properly, */
    function testTimeHinderance () public {
        uint256 votingDuration = 1 seconds;
        Election electionTest3 = new Election(votingDuration);
        electionTest3.vote(1, bytes32("Kobe"));
        electionTest3.vote(2, bytes32("Russel"));

        bool success;
        bytes memory revertReason;
        (success, revertReason) = address(electionTest3).call(abi.encodeWithSignature("winningCandidate(bool)", true));

        Assert.isFalse(success, "Someone voted before time ended.");
    }

    /**
    Tests to catch requirement if a candidate has already voted. 
    */
    function testAlreadyVoted () public {
        uint256 votingDuration = 1 seconds;
        Election electionTest4 = new Election(votingDuration);
        electionTest4.vote(22, bytes32("Duncan"));
        electionTest4.vote(22, bytes32("Neal"));

        bool success;
        bytes memory revertReason;
        (success, revertReason) = address(electionTest4).call(abi.encodeWithSignature("vote(uint, bytes32)", 22, bytes32("Neal")));

        Assert.isFalse(success, "Already voted!.");
    }

}