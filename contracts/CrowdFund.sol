// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Transfer function for tokens.
interface IERC20 {
    function transfer(address, uint) external returns (bool);

    function transferFrom(address, address, uint) external returns (bool);
}

contract CrowdFunding {
    event Launch(
        address indexed creatorID,
        uint goal,
        uint32 startTime,
        uint32 endTime
    );
    event CancelCampaign(address studentID, address campaignID);
    event PledgeAmount(uint indexed id, address indexed caller, uint amount);
    event ClaimCampaign(address campaignID, address studentID);
    event RefundCampaign(address campaignID, address indexed caller, uint amount);
    event AddManager(address campaignID, address indexed studentID);

    struct Campaign {
        // Address of the creator of the campaign-- hashed studentID
        address creator;
        // The goal amount trying to be raised
        uint goal;
        // Current amount that has been raised
        uint pledged;
        // When the campaign starts
        uint32 startTime;
        // When the campaign ends
        uint32 endTime;
        // Boolean indicating if funds have already been claimed
        bool claimed;
        //The current number of withdrawers allowed. Can't go above 4
        uint currNumWithdrawers;
        //Student IDs of the approved withdrawers
        address[4] approvedWithdrawers;

    }

    IERC20 public immutable token;
    //Maximum duration of a campaign
    uint public maxDuration;
    // Keeps track of current num of campaigns
    // Count is used to generate an ID for a campaign, that campaign creators use to access their campaigns.
    uint public count;
    // Mapping from campaign ID given to creators, to campaign ID
    mapping(address => uint) public campaignAddress;
    // Mapping from campaign ID to campaign
    mapping(uint => Campaign) public campaigns;
    // Mapping from campaign id => pledger => amount pledged
    mapping(address => mapping(address => uint)) public pledgeMapping;

    constructor(address _token, uint maxDuration_) {
        token = IERC20(_token);
        maxDuration = maxDuration_;
    }

    /**
    * @dev Launch a campaign.
    * @param studentID The ID of the student launching the campaign
    * @param goalAmount The amount the campaign is trying to raise
    * @param startTime The time that the campaign starts at
    * @param endTime The time that the campaign ends.
    */
    function launch(uint studentID, uint goalAmount, uint32 startTime, uint32 endTime) external returns (address) {
        require(startTime >= block.timestamp, "Start time is less than current time.");
        require(endTime >= startTime, "Start time is greater than the end time");
        require(endTime <= block.timestamp + maxDuration, "The campaign is not allowed to run for that long.");
        
        //Hash of the student ID of the campaign creator 
        bytes32 creatorHash = keccak256(abi.encodePacked(studentID));
        address hashedCampaignCreatorId = address(uint160(uint256(creatorHash)));

        //Campaign address returned to the campaign creator
        bytes32 campaignHash = keccak256(abi.encodePacked(count));
        address hashedCampaignID = address(uint160(uint256(campaignHash)));
        
        campaigns[count] = Campaign({
            creator: hashedCampaignCreatorId,
            goal: goalAmount,
            pledged: 0,
            startTime: startTime,
            endTime: endTime,
            claimed: false,
            currNumWithdrawers: 0,
            approvedWithdrawers:  [address(0), address(0), address(0), address(0)]
        });

        campaigns[count].approvedWithdrawers[0] = hashedCampaignCreatorId;
        campaigns[count].currNumWithdrawers += 1;
        
        //add the mapping of the campaign ID to the count 
        campaignAddress[hashedCampaignID] = count;
        count += 1;

        emit Launch(msg.sender, goalAmount, startTime, endTime);

        return hashedCampaignID;
    }

    /**
    * @dev Function to cancel a campaign
    * @param studentID ID of the student trying to cancel the campaign (must be an approved withdrawer)
    * @param campaignID The ID of the campaign itself.
    */

    function cancelCampaign(address studentID, address campaignID) external {
        uint campaignNum = campaignAddress[campaignID];
        Campaign memory campaign = campaigns[campaignNum];
        
        bytes32 studentHash = keccak256(abi.encodePacked(studentID));
        address studentAddress = address(uint160(uint256(studentHash)));

        bool allowedCreator = false;
        for (uint256 i = 0; i < 4; i++) {
            if (campaign.approvedWithdrawers[i] == studentAddress) {
                allowedCreator = true;
            }
        }
        require(allowedCreator == true, "You are not allowed to cancel this campaign");
        require(block.timestamp < campaign.endTime, "The campaign has already started");

        delete campaigns[campaignNum];
        emit CancelCampaign(studentAddress, campaignID);
    }

    /**
    * @dev Function for a donor to donate to a campaign
    * @param campaignID The ID of the campaign that is being donated to 
    * @param amount Amount that the donor would like to donate
    */
    function pledgeAmount(address campaignID, uint amount) external {
        //Retrieve the campaign number from the given campaignID
        uint campaignNum = campaignAddress[campaignID];
        //Retreieve the campaign object from the campaignNum
        Campaign storage campaign = campaigns[campaignNum];
        require(block.timestamp >= campaign.startTime, "This campaign has not started yet, wait to donate");
        require(block.timestamp <= campaign.endTime, "This campaign has ended.");

        //Increase the amount pledged to a campaign by an amount
        campaign.pledged += amount;
        //Keep track of the amount that a certain person donated to a campaign (for refunds)
        pledgeMapping[campaignID][msg.sender] += amount;
        //Transfer the token (money) from sender to campaign
        token.transferFrom(msg.sender, campaignID, amount);

        emit PledgeAmount(campaignNum, msg.sender, amount);
    }

    /**
    * @dev Function that allows a student to claim the funds of their campaign
    * @param studentID ID of the student trying to claim a campaign fund
    * @param campaignID ID of the campaign trying to be claimed
    */
    function claim(address campaignID, address studentID) external {
        //Retrieve the campaign from a campaignID
        uint campaignNum = campaignAddress[campaignID];
        Campaign storage campaign = campaigns[campaignNum];
        //get the hashed address of the student ID
        bytes32 studentHash = keccak256(abi.encodePacked(studentID));
        address studentAddress = address(uint160(uint256(studentHash)));

        bool allowed = false;
        for(uint256 i = 0; i < 4; i++) {
            if (campaign.approvedWithdrawers[i] == studentAddress) {
                allowed = true;
            }
        }
        require(allowed == true, "You are not an approved withdrawer of this event");
        require(block.timestamp > campaign.endTime, "Please wait for the campaign to finish before withdrawing funds.");
        require(campaign.pledged >= campaign.goal, "The goal was not met, so unfortunately funds cannot be claimed. ");
        require(!campaign.claimed, "The funds for this campaign have already been claimed.");

        campaign.claimed = true;
        token.transfer(campaign.creator, campaign.pledged);

        emit ClaimCampaign(campaignID, studentID);
    }

    /**
    * @dev If the campaing doesn't meet it's goal, fund get returned to donors. Donors must request a refund
    * @param campaignID ID of the campaing to retrieve refunds from
    */
    function refund(address campaignID) external {
        uint campaignNum = campaignAddress[campaignID];
        Campaign storage campaign = campaigns[campaignNum];
        require(block.timestamp > campaign.endTime, "This campaign has not ended yet, so we cannot return your funds.");
        require(campaign.pledged < campaign.goal, "The funds cannot be returned, as the goal for the campaign was met.");

        uint bal = pledgeMapping[campaignID][msg.sender];
        pledgeMapping[campaignID][msg.sender] = 0;
        token.transfer(msg.sender, bal);

        emit RefundCampaign(campaignID, msg.sender, bal);
    }

    /**
    * @dev Add an approved withdrawer of a campaign
    * @param campaignID ID of the campaing to add an approved withdrawer from
    * @param studentID ID of the student to be added as an approved withdrawer
    */
    function addManager(address campaignID, address studentID) external{
        uint campaignNum = campaignAddress[campaignID];
        Campaign storage campaign = campaigns[campaignNum];
        require(campaign.currNumWithdrawers < 4, "Campaign has the maximum number of withdrawers");
        require(block.timestamp >= campaign.startTime, "Campaign has not Started yet");
        require(block.timestamp <= campaign.endTime, "Campaign has already ended");

        bytes32 idEncoded = keccak256(abi.encodePacked(studentID));
        address hashedStudentID = address(uint160(uint256(idEncoded)));
        campaign.approvedWithdrawers[campaign.currNumWithdrawers] = hashedStudentID;
        campaign.currNumWithdrawers + 1;

        emit AddManager(campaignID, hashedStudentID);
    }
}