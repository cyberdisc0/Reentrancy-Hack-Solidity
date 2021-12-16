pragma solidity ^0.6.10;

contract PreventReentrancyClone {
    bool internal locked;
    mapping(address => uint) public balances;

    modifier noReentrancy() {
        require(!locked, "no re-entrancy");
        locked = true;
        _;
        locked = false;
    }
    
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
    
    function withdraw(uint _amount) public noReentrancy {
        require(balances[msg.sender] >= _amount);

        balances[msg.sender] -= _amount;
        
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failure to send Eth");
        
        
    }
    
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}





contract AttackPreventReentrancy {
    PreventReentrancyClone public preventReentrancy;
    
    constructor(address _preventReentrancy) public {
        preventReentrancy = PreventReentrancyClone(_preventReentrancy);
    }
    
    fallback() external payable {
        if (address(preventReentrancy).balance >= 1 ether) {
            preventReentrancy.withdraw(1 ether);
        }  
    }
    
    function attack() external payable {
        preventReentrancy.deposit{value: 1 ether}();
        preventReentrancy.withdraw(1 ether); 
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}
