pragma solidity ^0.5.0;

interface IndividualInterface {
        
    function getUser() external returns (string memory, uint256, string memory, string memory);
}

contract VoterList{

    
    address[] voterList;
    mapping (address => address) internal citizenToContractAddress;
    
    IndividualInterface individualContract;


//add new voter to voterList   
    function addVoter(address _voter, address _voterIndContract) public {
             voterList.push(_voter);
             citizenToContractAddress[_voter] = _voterIndContract;
    }
    
//check if the voter address is present in the voter list 
    function isRegistered() view public returns (bool) {
            for (uint i = 0; i < voterList.length; i++){
                if(voterList[i] == msg.sender){
                    return true;
                }
                return false;
            }
    }
 
//get the list of address of all voters   
    function getAllVoters() internal view returns (address[] memory){
        
        return voterList;
    }
    
//get the contract address of given voter
    function getContractAdd(address _voterAdd) internal view returns (address){
        
        return citizenToContractAddress[_voterAdd];
    }
    
//get the user details of voter from usercontract
    
    function getUserDetails(address _indContractAdd) internal returns (string memory, uint256, string memory, string memory){
        individualContract = IndividualInterface(_indContractAdd);
        return individualContract.getUser();
    }
    
    
    
        
}
