pragma solidity ^0.5.0;

interface BallotInterface {
             function getEciMember() external returns(address[] memory);
        }
contract IndividualUserContract{

    
        string name;
        uint256 age;
        string gender;
        string userAddress;
        string voteGivenTo;
        address[] permToAccessContract;
        mapping (address => uint)  internal accessExpiry;
        address public owner;
        

        BallotInterface ballotContract;
        constructor (string memory _name, uint256 _age, string memory _gender, string memory _address, address _ballotAddress) public{
            name  = _name;
            age  =  _age;
            gender = _gender;
            userAddress = _address; 
            
            ballotContract = BallotInterface(_ballotAddress);
            owner = msg.sender;
        
        
        }
        
 //set the value of voteGivenTo as a copy after casting vote      
        function setVoteGivenTo(string memory _candidate) public {
            voteGivenTo = _candidate;
        }
        
//get the name of candidate to whom user has voted
        
        function getVoteGivenTo() public view returns(string memory) {
            return voteGivenTo;
        }
 
 //get the details of user
        function getUser() public ifOwner ifAuthMember  returns (string memory, uint256, string memory, string memory) {
            return (name,age,gender,userAddress);
        }

//set address of other user in permission list to access contract.
        function giveAccess(address _accessAddress, uint _expiryDate) internal returns (bool){
            permToAccessContract.push(_accessAddress);
            accessExpiry[_accessAddress] =  _expiryDate;
            return true;
        }

//check if the quried person belongs to ECI list or permToAccessContract list        
        function checkPermission() internal returns (bool){
            address[] memory tmp;
            tmp = ballotContract.getEciMember();
            for (uint i=0 ; i < tmp.length ; i++)
            {if (msg.sender == tmp[i] || msg.sender == permToAccessContract[i])
                return true;
            }
            return false;
        }
        
    
        modifier ifOwner() {
             require(msg.sender == owner);
                _;
        }
        
        modifier ifAuthMember() {
             require(checkPermission());
                _;
        }
    
}
