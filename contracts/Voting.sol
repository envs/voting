pragma solidity ^0.5.0;

contract Voting {
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;  
        uint votedCandidateId;   
    }
    
    struct Candidate {
        string description;   
        uint voteCount; 
    }
    
    enum WorkflowStatus {
        RegisteringVoters, 
        CandidatesRegistrationStarted,
        CandidatesRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    // States
    
    WorkflowStatus public workflowStatus;
    address public admin;
    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    uint private winningCandidateId;

    // Modifiers
    
    modifier onlyAdmin() {
       require(msg.sender == admin, "the caller of this function must be the administrator");
       _;
    }
    
    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].isRegistered, 
           "the caller of this function must be a registered voter");
       _;
    }
    
    modifier onlyDuringVotersRegistration() {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, 
           "this function can be called only before candidates registration has started");
       _;
    }
    
    modifier onlyDuringCandidatesRegistration() {
        require(workflowStatus == WorkflowStatus.CandidatesRegistrationStarted, 
           "this function can be called only during candidates registration");
       _;
    }
    
    modifier onlyAfterCandidatesRegistration() {
        require(workflowStatus == WorkflowStatus.CandidatesRegistrationEnded,  
           "this function can be called only after candidates registration has ended");
       _;
    }
    
    modifier onlyDuringVotingSession() {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, 
           "this function can be called only during the voting session");
       _;
    }
    
    modifier onlyAfterVotingSession() {
        require(workflowStatus == WorkflowStatus.VotingSessionEnded,  
           "this function can be called only after the voting session has ended");
       _;
    }
    
    modifier onlyAfterVotesTallied() {
        require(workflowStatus == WorkflowStatus.VotesTallied,  
           "this function can be called only after votes have been tallied");
       _;
    }

    // Events
    
	event VoterRegisteredEvent (
		address voterAddress
	); 
	
	event CandidatesRegistrationStartedEvent ();
	
	event CandidatesRegistrationEndedEvent ();
	
	event CandidateRegisteredEvent(
	    uint candidateId
	);
	
	event VotingSessionStartedEvent ();
	
	event VotingSessionEndedEvent ();
	
	event VotedEvent (
	    address voter,
	    uint candidateId
	);
	
	event VotesTalliedEvent ();
	
	event WorkflowStatusChangeEvent (
        WorkflowStatus previousStatus,
        WorkflowStatus newStatus
    );
    
    constructor() public {
        admin = msg.sender;
        workflowStatus = WorkflowStatus.RegisteringVoters;
    }

    // Functions
    
    function registerVoter(address _voterAddress) 
        public onlyAdmin onlyDuringVotersRegistration {
        
        require(!voters[_voterAddress].isRegistered, "voter is already registered");
        
        voters[_voterAddress].isRegistered = true;
        voters[_voterAddress].hasVoted = false;
        voters[_voterAddress].votedCandidateId = 0;
        
        emit VoterRegisteredEvent(_voterAddress);
    }
    
    function startCandidatesRegistration() 
        public onlyAdmin onlyDuringVotersRegistration {
        workflowStatus = WorkflowStatus.CandidatesRegistrationStarted;
        
        emit CandidatesRegistrationStartedEvent();
        emit WorkflowStatusChangeEvent(
            WorkflowStatus.RegisteringVoters, workflowStatus);
    }
    
    function endCandidatesRegistration() 
        public onlyAdmin onlyDuringCandidatesRegistration {
        workflowStatus = WorkflowStatus.CandidatesRegistrationEnded;
        
        emit CandidatesRegistrationEndedEvent();
        emit WorkflowStatusChangeEvent(
            WorkflowStatus.CandidatesRegistrationStarted, workflowStatus);
    }
    
    function registerCandidate(string memory candidateDescription) 
        public onlyRegisteredVoter onlyDuringCandidatesRegistration {
        candidates.push(Candidate({
            description: candidateDescription,
            voteCount: 0
        }));
        
        emit CandidateRegisteredEvent(candidates.length - 1);
    }
    
	function getCandidatesNumber() public view
	    returns (uint) {
	    return candidates.length;
	}
	
	function getCandidateDescription(uint index) public view 
	    returns (string memory) {
	    return candidates[index].description;
	}    

    function startVotingSession() 
        public onlyAdmin onlyAfterCandidatesRegistration {
        workflowStatus = WorkflowStatus.VotingSessionStarted;
        
        emit VotingSessionStartedEvent();
        emit WorkflowStatusChangeEvent(
            WorkflowStatus.CandidatesRegistrationEnded, workflowStatus);
    }
    
    function endVotingSession() 
        public onlyAdmin onlyDuringVotingSession {
        workflowStatus = WorkflowStatus.VotingSessionEnded;
        
        emit VotingSessionEndedEvent();
        emit WorkflowStatusChangeEvent(
            WorkflowStatus.VotingSessionStarted, workflowStatus);        
    }
    
    function vote(uint candidateId) onlyRegisteredVoter onlyDuringVotingSession public {
        require(!voters[msg.sender].hasVoted, "the caller has already voted");
        
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = candidateId;
        
        candidates[candidateId].voteCount += 1;
        
        emit VotedEvent(msg.sender, candidateId);
    }
    
    function tallyVotes() onlyAdmin onlyAfterVotingSession public {
        uint winningVoteCount = 0;
        uint winningCandidateIndex = 0;
        
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateIndex = i;
            }
        }
        
        winningCandidateId = winningCandidateIndex;
        workflowStatus = WorkflowStatus.VotesTallied;
        
        emit VotesTalliedEvent();
        emit WorkflowStatusChangeEvent(
            WorkflowStatus.VotingSessionEnded, workflowStatus);     
    }
    
    function getWinningCandidateId() onlyAfterVotesTallied public view
       returns (uint) {
        return winningCandidateId;
    }
    
    function getWinningCadidateDescription() onlyAfterVotesTallied public view
       returns (string memory) {
        return candidates[winningCandidateId].description;
    }  
    
    function getWinningCandidateVoteCounts() onlyAfterVotesTallied public view
       returns (uint) {
        return candidates[winningCandidateId].voteCount;
    }   
    
    function isRegisteredVoter(address _voterAddress) public view
	   returns (bool) {
	   return voters[_voterAddress].isRegistered;
	}
	
	function isAdmin(address _address) public view 
	    returns (bool) {
	    return _address == admin;
	}	
	
	function getWorkflowStatus() public view
	    returns (WorkflowStatus) {
	    return workflowStatus;       
	}
}