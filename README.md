#LP Safe Guard
Designed to be used as a means to trustlessly get a group of depositors to pledge adding liquidity to an LP pool. Once the threshold is met the 



##Contract Features
Accept the deposit of two tokens into the contract their ERC20 token address tokenA and tokenB
The contract needs to keep a record of which addresses have deposited tokenA and tokenB and the amounts deposited by each users
When depositors send tokenA and tokenB to the contract they need to do this according to a ratio of tokenA to tokenB
This ratio will be defined as a constructor arg and will take the form of tokenA_amount and tokenB_amount
The token_ratio will be calculated using the tokenA_amount and tokenB_amount at the time of the deposit being made 
A total_tokenA_threshold amount will be set as a constructor argument 
Users will be able to reclaim both their tokens from the contract up until 14days after the total_tokenA_threshold amount is met, after which they will not be able to reclaim 
If a user does not deposit tokenA and tokenB in the correct ratio amounts the tokens will not be counted towards the total_tokenA_threshold until the required amount is deposited of both tokens.
If the user never deposits the correct ratio of both tokens they can reclaim both their tokens from the contract
The contract will record the total amounts of tokenA and tokenB deposited by all users that have met the required ratio amounts



## Breakdown of what each function in the contract does:

1. **Constructor**: This function is called when the contract is deployed. It initializes the contract with the addresses of tokenA, tokenB, and the LP token, the amounts for the tokenA to tokenB ratio, the total tokenA threshold, and the address of the liquidity pool.

2. **Deposit**: This function allows a user to deposit tokenA and tokenB into the contract. The deposited amounts are added to the user's current deposited amounts in the `depositors` mapping. If the user deposits tokens in the correct ratio, the deposited amounts are also added to the total deposited amounts. If the total deposit of tokenA reaches the threshold, the deadline for reclaiming tokens is set to 14 days from the current time.

3. **Reclaim**: This function allows a user to reclaim their tokens from the contract. It checks if the current time is before the deadline, then transfers the user's deposited amounts of tokenA and tokenB back to the user, and resets the user's deposited amounts in the `depositors` mapping.

4. **DepositToLiquidityPool**: This function deposits the total amounts of tokenA and tokenB that have been deposited by all users (who have met the required ratio amounts) into a liquidity pool. It calculates the total amounts of tokenA and tokenB to be deposited to the liquidity pool for each depositor by summing up all the amounts they have deposited. If a user has made multiple deposits, there will be only a single LP deposit for the total amount of tokens they have deposited.

5. **ClaimLP**: This function allows a depositor to claim their LP tokens. It first checks if the depositor has any LP tokens to claim, then resets the depositor's LP tokens to zero, and finally transfers the LP tokens to the depositor.

Please note that this is a simplified explanation and the actual implementation will depend on the specific liquidity pool you are using. Also, these functions do not handle any tokens deposited that did not meet the required ratio. You might need to add additional logic to handle these tokens. As always, please make sure to have this contract reviewed by a Solidity expert before deploying it to the mainnet. Smart contracts are immutable once deployed, and any bugs or vulnerabilities could result in loss of funds. It's also crucial to thoroughly test any smart contract before deploying it on the mainnet.