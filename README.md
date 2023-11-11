# Warning this has not been tested or audited
This is a working example to build upon only.

## LP Safe Guard
Designed to be used as a means to trustlessly get a group of depositors to pledge adding liquidity to an LP pool.
The contract facilitates the process of depositing tokens into a liquidity pool. 

## Summary of contract functionality:


- **Purpose**: The contract is designed to facilitate the process of depositing tokens into a liquidity pool.

- **Token Deposit**: Users can deposit two types of tokens (tokenA and tokenB) into the contract. Each deposit needs to meet a certain ratio of tokenA to tokenB, which is set at the deployment of the contract.

- **Deadline and Threshold**: After a certain deadline has passed and if a certain threshold of tokenA deposits has been met, the contract deposits the total amounts of tokenA and tokenB that have been deposited by all users into a liquidity pool.

- **LP Token Calculation**: The contract then calculates the amount of Liquidity Provider (LP) tokens each depositor is entitled to based on their percentage of the total amount of tokens deposited.

- **LP Token Claim**: Users can claim their LP tokens from the contract, which then transfers the LP tokens to the user.


## Function Documentation**:

Breakdown of each function in the contract:

1. **deposit**: This function allows a user to deposit a specified amount of `tokenA` and `tokenB` into the contract. It checks if the ratio of `tokenA` to `tokenB` deposited by the user matches a predefined ratio. If it does, the total deposited amounts of `tokenA` and `tokenB` are updated. If the total deposited amount of `tokenA` reaches a certain threshold, a deadline for deposits is set.

2. **reclaim**: This function allows a user to reclaim their tokens before the deadline. It transfers the deposited tokens back to the user and resets their deposited amounts in the contract.

3. **depositToLiquidityPool**: After the deadline has passed, this function can be called. It iterates over all depositors and checks if they have deposited the correct ratio of tokens. If they have, the function resets the depositor's deposited amounts, approves the liquidity pool to withdraw the tokens, and calls the `addLiquidity` function of the liquidity pool.

4. **claimLP**: This function allows users to claim their LP tokens. It checks if the user has any LP tokens to claim, resets their LP tokens in the contract, and transfers the LP tokens to the user.

5. **bytesToUint**: This is a helper function that converts bytes to an unsigned integer. This function is used to convert the data returned by the `addLiquidity` function (assumed to be the amount of LP tokens minted) into a format that can be added to the depositor's LP tokens.

This contract provides a way for users to deposit tokens into a liquidity pool and claim LP tokens, while ensuring that the ratio of tokens deposited matches a predefined ratio.😊