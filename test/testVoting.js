const Voting = artifacts.require("./Voting.sol");

contract('Voting', function(accounts) {	
  contract('Voting.endCandidateRegistration - onlyAdmin modifier ', function(accounts) {
	it("The voting administrator should be able to end the candidate registration session only after it has started", async function() {
	
		let votingInstance = await Voting.deployed();
	  	let votingAdmin = await votingInstance.admin();

	  	let nonVotingAdmin = web3.eth.accounts[1];
	  			
		try {
		
			await votingInstance.endCandidatesRegistration();
			assert.isTrue(false);
		}
		catch(e) {
			//assert
			assert.isTrue(votingAdmin != nonVotingAdmin);
			assert.equal(e, "Error: Returned error: VM Exception while processing transaction: revert this function can be called only during candidates registration -- Reason given: this function can be called only during candidates registration.");
		}
	});					
  });
	
  contract('Voting.endCandidateRegistration - onlyDuringCandidatesRegistration modifier', function(accounts) {
	it("An account that is not the voting administrator must not be able to end the candidate registration session", async function() {
		
		let votingInstance = await Voting.deployed();
		let votingAdmin = await votingInstance.admin();	
							
		try {
			
			await votingInstance.endCandidatesRegistration();
			assert.isTrue(false);
		}
		catch(e) {
			//assert
			assert.equal(e, "Error: Returned error: VM Exception while processing transaction: revert this function can be called only during candidates registration -- Reason given: this function can be called only during candidates registration.");
		}
	});					
  });
	
  contract('Voting.endCandidateRegistration - successful', function(accounts) {
	it("An account that is not the voting administrator must not be able to end the candidate registration session", async function() {
	  
	  let votingInstance = await Voting.deployed();
	  let votingAdmin = await votingInstance.admin();

	  await votingInstance.startCandidatesRegistration({from: votingAdmin});
	  let workflowStatus = await votingInstance.getWorkflowStatus();
	  let expectedWorkflowStatus = 1;
			
	  assert.equal(workflowStatus.valueOf(), expectedWorkflowStatus, "The current workflow status does not correspond to candidate registration session started"); 			
						
	  await votingInstance.endCandidatesRegistration({from: votingAdmin});
	  let newWorkflowStatus = await votingInstance.getWorkflowStatus();
	  let newExpectedWorkflowStatus = 2;
			
	  //assert
	  assert.equal(newWorkflowStatus.valueOf(), newExpectedWorkflowStatus, "The current workflow status does not correspond to candidate registration session ended"); 

	  });					
	});

	// Only a Admin can register voters
	contract('Voting.isAdmin', function(accounts) {
		it("Should be able to check if entity registering voters is Admin", async function() {
			let votingInstance = await Voting.deployed();
			let votingAdmin = await votingInstance.admin();
			let nonVotingAdmin = web3.eth.accounts[1];
					
			await votingInstance.registerVoter(votingAdmin);
			const registeredVoter = await votingInstance.isAdmin(votingAdmin, {from: votingAdmin})
			assert.equal(registeredVoter, true, "should be labeled Admin");
		});					
	});

});







/*
const assert = require('assert')
const operations = require('./operations.js')

it('should correctly calculate the sum of 1 and 3', () => {
  assert.equal(operations.add(1, 3), 4)
})

it('should correctly calculates the sum of -1 and -1', () => {
  assert.equal(operations.add(-1, -1), -2)
})

it('should correctly calculate the difference of 33 and 3', () => {
  assert.equal(operations.subtract(33, 3), 30)
})

it('should correctly calculate the product of 12 and 12', () => {
  assert.equal(operations.multiply(12,12), 144)
})

it('should correctly calculate the quotient of 10 and 2', () => {
  assert.equal(operations.divide(10,2), 5)
})

it('should correctly calculate the modulus of 10 and 2', () => {
  assert.equal(operations.mod(10,2), 0)
})


it('indicates failure when a string is used instead of a number', () => {
  assert.equal(operations.validateNumbers('sammy', 5), false)
})

it('indicates failure when two strings are used instead of a numbers', () => {
  assert.equal(operations.validateNumbers('sammy', 'sammy'), false)
})

it('successfully runs when two numbers are used', () => {
  assert.equal(operations.validateNumbers(5, 5), true)
})
*/