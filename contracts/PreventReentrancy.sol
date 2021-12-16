pragma solidity ^0.6.10;

contract PreventReentrancy {
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