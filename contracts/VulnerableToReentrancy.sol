pragma solidity ^0.6.10;


contract VulnerableToReentrancy {
    mapping(address => uint) public balances;
    
    function deposit() public payable {
        balances[msg.sender] += msg.value;        
    }
    
    function withdraw(uint _amount) public {
        require(balances[msg.sender] >= _amount);
        
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failure to send Eth");
        
        balances[msg.sender] -= _amount;
    }
    
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}


// in solidity 0.8, underflows and overflows are prevented. Reentrancy would only work if the withdraw function withdrew the entire balance
// example:

// function withdraw() public {
//         uint bal = balances[msg.sender];
//         require(bal > 0);

//         (bool sent, ) = msg.sender.call{value: bal}("");
//         require(sent, "Failed to send Ether");

//         balances[msg.sender] = 0;
//     }