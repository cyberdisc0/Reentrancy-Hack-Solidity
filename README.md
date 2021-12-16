# Reentrancy Hack Soliditity

This is an example of a basic reentrancy hack in solidity. There are 3 contracts provided: a contract that is vulnerable to reentrancy, a contract to execute the reentrancy hack, and a contract that prevents the reentrancy hack.


The vulnerable contract allows deposits and withdrawals, while keeping track of the balances of addresses that have made deposits. When the deposit function is called, the balance of the address making the call will be updated to include this amount. When the withdrawal function is called, the vulnerable contract will check that the balance of the address making the call is sufficient for the withdrawal, send the withdrawal amount, then update the balance of that address.

The vulnerability comes from updating the balance of the withdrawer after sending assets. An attacking contract can contain a call to withdraw within its fallback function. If the attacker calls the withdrawal function after making a deposit, assets will be sent to the attacker’s contract, triggering the attacker’s fallback function before updating their balance in the vulnerable contract. This will allow an additional withdrawal from the vulnerable contract before the balance of the attacker is updated, triggering the attacker’s fallback function again;  effectively reentering the vulnerable contract before the withdrawal function fully executes (hence the name reentrancy hack). This process will continue until the vulnerable contract does not have enough funds to withdraw the amount being requested by the attacker. Simply put, once an attacker makes a deposit into the vulnerable contract, they can withdraw everything in the vulnerable contract, including funds they did not deposit. 

I have provided two solutions to prevent reentrancy in this case: updating balances before sending assets, and adding a modifier to the withdrawal function that does not allow the function to be called again until it has fully executed. 

The attacker’s success hinges on the fallback function calling withdraw before the balance is updated. Updating the balance before sending assets causes the attacker’s fallback function to call withdraw with an updated balance, preventing the attacker from withdrawing more than they deposited. 

The modifier will include a boolean stated variable that is initially set to false. The modifier will require the boolean be equal to false, set the boolean to true, run the function, then set the boolean back to false. The first time the attack contract calls the withdraw function, the boolean gets set to true, then assets are sent. The attacker fallback function is then trigged, calling the withdraw function again. At this point, the withdrawal function has not been fully executed, so the boolean has not been changed back to false. Thus, the require statement of the modifier is not met, and the second withdrawal fails.


## A Few Clarifications
When looking at the code, “1 ether” in the attack function is an arbitrary amount, just trying to keep it simple in this example. The attacker may deposit whatever amount they have the funds for, but the max amount the attacker may withdraw per call is equal to the attacker’s balance/amount deposited. Otherwise the require statement in the withdraw function will not be met.

“1 ether “ in the if statement in the fallback function is also arbitrary - it should be equal to the amount being withdrawn in the following line of code. It is simply to check that there is enough in the vulnerable contract to withdraw before calling the withdraw function with that amount. To maximize the withdrawal amount per call, the withdrawal amount should be equal to the amount deposited by the attacker. The withdrawal amount may not exceed the amount deposited, otherwise the require statement in the withdraw function will not be met. Additional if statements can be included in the attacker’s fallback function to withdraw smaller amounts once the balance of the vulnerable contract is below the attacker’s deposited amount. To keep this example as simple as possible, additional if statements have not been included.


## Version Update
In solidity 0.8, uint overflows and underflows are prevented, reverting the transaction. When the attacker is done withdrawing, and their balance is being updated, the transaction will be reverted once their balance underflows. This attack would only work in 0.8 if the withdraw function withdrew the sender’s entire balance.
