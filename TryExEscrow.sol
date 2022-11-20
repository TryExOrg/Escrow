// SPDX-License-Identifier: MIT

//THIS IS A SAMPLE REPRESENTATION OF A PROSPECTIVE ESCROW CONTRACT NOT TO BE USED IN PRODUCTION
//FUNCTIONS PROVIDED ARE FOR EXPLANATORY PURPOSE AS DEFINED BELOW
//Function trueSignature: Return signer information (Signed by User who has deposited funds in Escrow)
//Function redeem is to allow for Recipient CEX to claim the signed amount of the User, remaining funds are sent back to User
//Function extend is to allow the user to extend the duration of the contract in order to continue engaging with the CEX
//Function claim timeout is to allow the user to claim the unused/unclaimed funds at the end of the tenure 

pragma solidity 0.8.0;

contract TryExEscrow {
    address payable public sender;      
    address payable public recipient;   
    uint256 public expiration;          


    constructor (address payable _recipient, uint256 duration) public payable {
        sender = msg.sender;
        recipient = _recipient;
        expiration = now + duration;
    }

    function trueSignature(uint256 amount, bytes memory signature) internal view returns (bool){
        bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));
        return recoverSigner(message, signature) == sender;
    }

    function redeem(uint256 amount, bytes memory signature) public {
        require(msg.sender == recipient);
        require(trueSignature(amount, signature));
        recipient.transfer(amount);
        selfdestruct(sender);
    }

    function extend(uint256 newExpiration) public {
        require(msg.sender == sender);
        require(newExpiration > expiration);
        expiration = newExpiration;
    }


    function claimTimeout() public {
        require(now >= expiration);
        selfdestruct(sender);
    }
}
