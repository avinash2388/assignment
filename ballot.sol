pragma solidity ^0.5.0;

interface VoterListInterface {
    function checkVoter(address _voter) external returns (bool);
    function isRegistered() external returns (bool);
    function getAllVoters() external returns (address[] memory);
    function getContractAdd(address _voterAdd) external view returns (address);
}
interface IndividualUserInterface {
    function getVoteGivenTo() external view returns(string memory);
    
   
}


//Note : I could have used bytes32 instead of string at most places for less Gas Consumption, but for now to avoid some type conversions i have used string 

contract Ballot{

  
    string[] internal  candidateList = ["CA","CB","CC"];
    uint startTime;
    address[] public  eciList ;
    mapping (string => uint256) internal votesReceived;
    mapping (address => string) internal votedCandidate;
    mapping (address => bool) ifVoted;
    
    VoterListInterface voterListContract;
    IndividualUserInterface userContract;
    
    constructor (address _voterListAdd) public {
        voterListContract = VoterListInterface(_voterListAdd);
        
    }

//start the voting time   
    function startVoting() internal {
        require(ifAuthorized());
        startTime= now;
    }
    
//add the new member to ECI list
    function addEciMember(address _eciMember) internal {
             eciList.push(_eciMember);
             
    }
 
//get the list of all ECI members   
    function getEciMember() public returns (address[] memory) {
             return eciList;
             
    }

//return the name of candidate to whom the queried user has voted    
    function getMyVote() public view returns (string memory){
        return votedCandidate[msg.sender];
        
    }
    
    
//assuming this will be called in loop for length of candidateList from javascript side and print details   
    function getResults(uint256 _i) public ifEnd view returns (string memory, uint256){
        return (candidateList[_i],votesReceived[candidateList[_i]]);
        
    }
    
//set the value of votedCandidate & votesReceived, also write a copy of voteGivenTo at the usercontract address .
//i was getting some syntax error here while doing "".call" call to write the voteGivenTo at the storage of usercontract .
    function castVote(address _vIndCon, string memory  _candidate) public ifEligibe {
        require(validateCandidate(_candidate));
        votesReceived[_candidate] += 1;
        votedCandidate[msg.sender]= _candidate;
        ifVoted[msg.sender] = true;
    
        
        _vIndCon.call(keccak256(abi.encodePacked("setVoteGivenTo(_candidate)")));
        
    }
    
//return the name of candidate  to whom the user has casted the vote  
  
    function getUserVote(address _voter) internal onlyEciMember  returns (string memory, bool){
        
        if (ifVoted[_voter]){
        return (votedCandidate[_voter], true);}
        else{return ("Not voted yet",false);}
        
    }

//assuming this will be called in loop for length of voterList  from javascript side and print details 
    function getVoteMap(uint256 _i) internal onlyEciMember  returns (address, string memory){
         address[] memory voter = voterListContract.getAllVoters();
         return (voter[_i], votedCandidate[voter[_i]]);
         
        
    }

//check the combined count from each contract against the votesReceived for each candidate from ballot contract for any discrepency

    function getConsolidate() internal onlyEciMember  returns (bool){
        for (uint i =0 ; i < candidateList.length; i++ ){
            
            uint256 sumCount = getSummation(i);
            if (sumCount != votesReceived[candidateList[i]]){
                revert();
            }
            
            else return true;
        }
        
    }

//get combined count of all votes for each candidate from each user contract 
    function getSummation(uint256 _i) internal  returns (uint256){
        uint256 count = 0;
        address[] memory tmp1 = voterListContract.getAllVoters();
        for (uint j = 0; j < tmp1.length; j++ ){
            address tmp2 =  voterListContract.getContractAdd(tmp1[j]);
            
            userContract = IndividualUserInterface(tmp2);
            string memory candName = userContract.getVoteGivenTo();
        
            if (keccak256(bytes(candName)) == keccak256(bytes(candidateList[_i]))){
             count++;
            }
            
        }
    }

//check if candidate name is present in candidateList before casting voting  
    function validateCandidate(string memory _candidate) internal view returns (bool) {
        for(uint i = 0; i < candidateList.length; i++) {
              if (keccak256(bytes(candidateList[i]))  == keccak256(bytes(_candidate))) {
              return true;
              }
        }
        return false;
        
    }    
    
    
    function ifAuthorized() internal returns (bool){
            for (uint i=0 ; i < eciList.length ; i++)
            {if (msg.sender == eciList[i] )
                return true;
            }
            return false;
    }
    
    modifier ifEnd() {
             require(now > startTime + 1 days);
                _;
    }
        
    modifier onlyEciMember() {
             require(ifAuthorized());
                _;
    }
    
    modifier ifEligibe() {
             require(voterListContract.isRegistered());
                _;
    }
    
}


