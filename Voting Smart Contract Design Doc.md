# Voting Smart Contract Design Doc

## Data Structures

### Voter Struct:
- Boolean with whether or not user has voted
- Hash of the student’s student ID

### Candidate Struct
- String containing candidate name
- Integer holding the number of votes a candidate has accumulated

### Dictionaries:
- One that maps hash of the student’s student ID to the voter struct
- One that maps candidate name to candidate struct

### End time
- Contains the time that the election ends

## Algorithms:

### Constructor
- When a ballot is created, the duration of the election is passed in. We calculate the end time of the election and store it as a global variable.

### Vote (voterID, candidateID)
- Takes in the student ID of the voter and the name of the candidate. 
- Check that voting hasn’t ended yet.
- If the candidate passed in doesn’t exist, we create a candidate struct for them and add it to the dictionary of candidate structs
- Make sure that the voter passed in has not voted yet, and if they haven’t, create a voter struct for them.
- Add the new voter to the dictionary of voter structs
- Increase the candidate's number of votes by 1.

### Winner()
- Make sure that voting has ended
- Iterate through the mapping of candidates and return the candidate with the maximum number of votes.

## Assumptions:
- Assume scope that if a voter has been created, they have the ability to vote. In a future implementation, we could obtain access to all the eligible student IDs at a school, and ensure that the ID passed in exists as an eligible voter. 
- We are working under the assumption that there are write-in candidates, rather than a list of pre-approved candidates, so any candidate that gets voted for and has a struct created for them is assumed to be an eligible candidate. 
- Possible future enhancement: Allowing voters to have multiple votes, so that they can vote for multiple candidates if they please (i.e. 3 votes for candidate A, 1 vote for candidate B, etc).
