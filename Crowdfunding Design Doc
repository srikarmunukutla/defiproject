# Crowdfunding Smart Contract Design Document

## Data Structures:

### Campaign Struct:
- Hashed SID of club creator
- List of hashed SIDs of club execs
- Int containing the monetary goal
- Int containing the start date of the campaign
- Int containing the end date of the campaign
- Int containing deadline to claim funds (60 days after end date)
- Boolean indicating whether the funds have been claimed yet or not
- Boolean indicating whether this campaign is currently active or inactive

### pledgedAmount mapping/dictionary:
- This is a mapping of a mapping. First, mapping the address of a transaction to the amount of that transaction as key-value pairs. Next, mapping the campaign ID (as the key) to this transaction mapping (as the value).

### Campaigns mapping/dictionary:
- Mapping (hash table in Solidity) that maps the ID of a campaign (key) to the corresponding struct of that campaign (value).

## Algorithms:

### createCampaign(int goal, int start, int end)
- Initialize crowdfunding campaign # Crowdfunding Smart Contract Design Document

### Campaign Struct:
- Hashed SID of club creator
- List of hashed SIDs of club execs
- Int containing the monetary goal
- Int containing the start date of the campaign
- Int containing the end date of the campaign
- Int containing deadline to claim funds (60 days after end date)
- Boolean indicating whether the funds have been claimed yet or not
- Boolean indicating whether this campaign is currently active or inactive

### pledgedAmount mapping/dictionary:
- This is a mapping of a mapping. First, mapping the address of a transaction to the amount of that transaction as key-value pairs. Next, mapping the campaign ID (as the key) to this transaction mapping (as the value).

### Campaigns mapping/dictionary:
- Mapping (hash table in Solidity) that maps the ID of a campaign (key) to the corresponding struct of that campaign (value).

## Algorithms:

### createCampaign(int goal, int start, int end)
- Initialize crowdfunding campaign 
- Initialize list of up to 4 managers within the club that have access to withdraw from the campaign

### donate(campaign id, amount)
- Check if campaign started
- Check if campaign ended
- Pledge the specified amount

### withdraw(campaign id, studentID)
- Check that student has the ability to withdraw from the specified campaign
- If after goal deadline & goal reached & not after claimed deadline, then distribute tokens from campaign to student, otherwise block

### refund(campaign id)
- Check to see if conditions have been met in order for valid refund (campaign hasn’t ended or campaign has succeeded)
- Use pledgedAmount map to transfer correct amount of tokens back to person requesting refund 

### addManager(studentID)
- Adds a student to the list of execs in a club so that they can also withdraw money from the campaign; limit of 4 managers

### cancel(campaign id)
- Cancel the campaign by removing the campaign from campaigns, and this is done by setting the active boolean to false

### viewCampaign(campaign id)
- Function that returns how much has been raised so far for a campaign so the public/anyone can check and see

## Assumptions: 
- Assume that all student IDs involved are valid
- Only students can create and donate to campaigns
- If a campaign is canceled/does not reach goal, each individual donor must request their refund, they will not automatically be refunded
- No need to hash IDs because for crowdfunding we can keep transactions public

## Modifications:
- [TODO] have a list of donor IDs in the campaign struct
- Function: addManager(student ID) adds a student to the list of execs in a club so that they can also withdraw money from the campaign; limit of 4 leaders
- Change pledge wording to donate
- Function that returns how much has been raised so far for a campaign so the public/anyone can check and see
- Initialize list of up to 4 managers within the club that have access to withdraw from the campaign

### donate(campaign id, amount)
- Check if campaign started
- Check if campaign ended
- Pledge the specified amount

### withdraw(campaign id, studentID)
- Check that student has the ability to withdraw from the specified campaign
- If after goal deadline & goal reached & not after claimed deadline, then distribute tokens from campaign to student, otherwise block

### refund(campaign id)
- Check to see if conditions have been met in order for valid refund (campaign hasn’t ended or campaign has succeeded)
- Use pledgedAmount map to transfer correct amount of tokens back to person requesting refund 

### addManager(studentID)
- Adds a student to the list of execs in a club so that they can also withdraw money from the campaign; limit of 4 managers

### cancel(campaign id)
- Cancel the campaign by removing the campaign from campaigns, and this is done by setting the active boolean to false

### viewCampaign(campaign id)
- Function that returns how much has been raised so far for a campaign so the public/anyone can check and see

## Assumptions: 
- Assume that all student IDs involved are valid
- Only students can create and donate to campaigns
- If a campaign is canceled/does not reach goal, each individual donor must request their refund, they will not automatically be refunded
- No need to hash IDs because for crowdfunding we can keep transactions public

## Modifications:
- [TODO] have a list of donor IDs in the campaign struct
- Function: addManager(student ID) adds a student to the list of execs in a club so that they can also withdraw money from the campaign; limit of 4 leaders
- Change pledge wording to donate
- Function that returns how much has been raised so far for a campaign so the public/anyone can check and see
