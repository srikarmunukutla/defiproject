# Crowdfunding Smart Contract Design Document

## Data Structures/Variables

### Campaign Struct
- `creator`: Hashed SID of club campaign creator
- `goal`: Unsigned Int containing the monetary goal
- `pledged`: Unsigned Int containing current amount that has been raised
- `startTime`: Unsigned Int containing the start date of the campaign
- `endTime`: Unsigned Int containing the end date of the campaign
- `claimed`: Boolean indicating whether the funds have been claimed yet or not
- `currNumWithdrawers`: Unsigned int containing the amount of approved withdrawers (max 4)
- `approvedWithdrawers`: List of hashed SID
- `token`: We use an ERC-20 token for transferring funds from a donor to a campaign. We do this because ERC-20 Ethereum tokens provide consistency and security. 
- `maxDuration`: Maximum duration of a campaign
- `campaignAddress mapping`: This is a mapping that maps a campaignID to a number, which is our count variable. The campaignID is visible to anyone who wants to donate to a campaign, and is the value returned to a campaign creator upon creation. The count variable is used for internal purposes. 
- `Count`: Count is the number of campaigns we currently have in our system.
- `campaignAddress mapping`: The campaignAddress maps a number to a campaign struct. The number is received from the campaignAddress mapping
- `pledgeMapping mapping/dictionary`: This maps the address of a campaign, to the person pledging money, to the amount that they pledged. This is primarily used for refunds.

## Algorithms

### Launch(address studentID, int goal, int start, int end)
- Initialize crowdfunding campaign 
- Takes in the student ID of the person creating the campaign, the campaign goal, start and end time.

### CancelCampaign(campaign id)
- Cancel the campaign by removing the campaign from campaign
- Make sure that the person cancelling the campaign is allowed to.

### PledgeAmount(campaign id, amount)
- Check if campaign started
- Check if campaign ended
- Pledge the specified amount

### ClaimCampaign(campaign id, studentID)
- Check that student has the ability to withdraw from the specified campaign
- If after goal deadline && goal reached && not after claimed deadline, then distribute tokens from campaign to student, otherwise block

### RefundCampaign(campaign id)
- Check to see if conditions have been met in order for valid refund (campaign hasn’t ended or campaign has succeeded)
- Use pledgedMapping nested map to transfer correct amount of tokens back to person requesting refund 

### AddManager(studentID)
- Adds a student to the list of execs in a club so that they can also withdraw money from the campaign; limit of 4 managers

## Assumptions
- Assume that all student IDs involved are valid.
- Only students can create and donate to campaigns.
- If a campaign is canceled/does not reach goal, each individual donor must request their refund, they will not automatically be refunded.
- No need to hash IDs because for crowdfunding we can keep transactions public.
