// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function transfer(address, uint) external returns (bool);

    function transferFrom(
        address,
        address,
        uint
    ) external returns (bool);
}

    /** 
    * @title CrowdFunding
    * @author Nayna Siddharth, Shomini Sen, Srinath Rangan, Srikar Munukutla, Isabella Otterson, Sofia Bourche
    * @dev Smart contract used for management of crowdfunding for school clubs. 
    */

contract CrowdFund {
    struct Campaign {
        address[4] approvedWithdrawers;
        uint currNumWithdrawers;
        address creator;
        uint goal;
        uint pledged;
        uint256 startAt;
        uint256 endAt;
        bool claimed;
        bool active;
    }

    IERC20 public immutable token;
    uint public count;
    uint public maxDuration;

    //Public mapping of campaign IDs to campaign structs. 
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    event CreateCampaign(
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );
    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint id, address indexed caller, uint amount);
    event AddManager(uint id, address indexed newManager);

    constructor(address _token, uint _maxDuration) {
        token = IERC20(_token);
        maxDuration = _maxDuration;
    }

    function createCampaign(address creatorId, uint _goal, uint32 startTime_, uint32 endTime_) external {
        //Checks for the timestamps to make sure they are valid.
        require(startTime_ >= block.timestamp,"Start time is less than current time.");
        require(endTime_ > startTime_ ,"End time is less than Start time");
        require(endTime_ <= block.timestamp + maxDuration, "End time exceeds the maximum Duration allowed for a campaign");

        //hash the ID of the campaign creator
        
        bytes32 hash = keccak256(abi.encodePacked(creatorId));
        address hashedCampaignCreatorId = address(uint160(uint256(hash)));

        campaigns[count] = Campaign({
            creator: hashedCampaignCreatorId,
            goal: _goal,
            pledged: 0,
            startAt: startTime_,
            endAt: endTime_,
            claimed: false,
            active: true,
            currNumWithdrawers: 0,
            approvedWithdrawers: [address(0),address(0),address(0),address(0)]
        });

        campaigns[count].approvedWithdrawers[0] = creatorId;
        campaigns[count].currNumWithdrawers += 1;

        emit CreateCampaign(msg.sender,_goal, startTime_ , endTime_);
    }

    function cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        address campaignCreator = campaign.creator;
        require(campaignCreator == msg.sender, "You did not create this Campaign");
        require(block.timestamp < campaign.startAt, "Campaign has already started");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "Campaign has not Started yet");
        require(block.timestamp <= campaign.endAt, "Campaign has already ended");
        require(_amount > 0, "Donation amount must be greater than zero");
        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        address currentWithdrawer = campaign.creator;
        for (uint i = 0; i < campaign.approvedWithdrawers.length; i++) {
            if (msg.sender == campaign.approvedWithdrawers[i]) {
                currentWithdrawer = campaign.approvedWithdrawers[i];
            }
        }
        
        require(msg.sender == currentWithdrawer, "You did not create this Campaign");
        require(block.timestamp > campaign.endAt, "Campaign has not ended");
        require(campaign.pledged >= campaign.goal, "Campaign did not succed");
        require(!campaign.claimed, "claimed");

        campaign.claimed = true;
        token.transfer(currentWithdrawer, campaign.pledged);

        emit Claim(_id);
    }

    function refund(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged < campaign.goal, "You cannot Withdraw, Campaign has succeeded");

        uint bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }

    function addManager(uint _id, address newManager) {
        Campaign memory campaign = campaigns[_id];
        require(campaign.currNumWithdrawers < 4, "Campaign has the maximum number of withdrawers")
        require(block.timestamp >= campaign.startAt, "Campaign has not Started yet");
        require(block.timestamp <= campaign.endAt, "Campaign has already ended");
        campaign.approvedWithdrawers[campaign.currNumWithdrawers] = newManager;
        campaign.currNumWithdrawers + 1;

        emit AddManager(_id, newManager);
    }

}