// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DepositContract {
    ERC20 public tokenA = ERC20(0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39); // Currently Set to HEX Replace with the tokenA address
    ERC20 public tokenB = ERC20(0x5A9780Bfe63f3ec57f01b087cD65BD656C9034A8); // Currently Set to COM Replace with the tokenB address
    ERC20 public lpToken = ERC20(0x5aDbcC7885311Fc621B3Ac59D685b355Ae4507F5); // Replace with the LP token address
    uint256 public tokenA_amount = 99; // Set to desired tokenA amount to set ratio
    uint256 public tokenB_amount = 1; // Set to desired tokenB amount to set ratio
    uint256 public total_tokenA_threshold = 700000000; //Currently Set to 7Mil Hex, set as required
    uint256 public total_tokenA_deposited;
    uint256 public total_tokenB_deposited;
    uint256 public deadline;
    address public liquidityPool = 0x5aDbcC7885311Fc621B3Ac59D685b355Ae4507F5; //Current set to HEX/COM LP pool on pulseX, set as required for desired pool

    struct Depositor {
        uint256 tokenA_deposited;
        uint256 tokenB_deposited;
        uint256 lp_tokens; // The amount of LP tokens the depositor is entitled to
    }

    mapping(address => Depositor) public depositors;
    address[] public depositorAddresses; // New array to store depositor addresses

    function deposit(uint256 _tokenA_amount, uint256 _tokenB_amount) public {
        require(
            tokenA.transferFrom(msg.sender, address(this), _tokenA_amount),
            "Transfer of tokenA failed"
        );
        require(
            tokenB.transferFrom(msg.sender, address(this), _tokenB_amount),
            "Transfer of tokenB failed"
        );

        if (
            depositors[msg.sender].tokenA_deposited == 0 &&
            depositors[msg.sender].tokenB_deposited == 0
        ) {
            depositorAddresses.push(msg.sender); // Add new depositor address to the array
        }

        depositors[msg.sender].tokenA_deposited += _tokenA_amount;
        depositors[msg.sender].tokenB_deposited += _tokenB_amount;

        if (_tokenA_amount / _tokenB_amount == tokenA_amount / tokenB_amount) {
            total_tokenA_deposited += _tokenA_amount;
            total_tokenB_deposited += _tokenB_amount;

            if (
                total_tokenA_deposited >= total_tokenA_threshold &&
                deadline == 0
            ) {
                deadline = block.timestamp + 14 days;
            }
        }
    }

    function reclaim() public {
        require(block.timestamp <= deadline, "Reclaim period has ended");
        require(
            tokenA.transfer(
                msg.sender,
                depositors[msg.sender].tokenA_deposited
            ),
            "Transfer of tokenA failed"
        );
        require(
            tokenB.transfer(
                msg.sender,
                depositors[msg.sender].tokenB_deposited
            ),
            "Transfer of tokenB failed"
        );

        depositors[msg.sender].tokenA_deposited = 0;
        depositors[msg.sender].tokenB_deposited = 0;
    }

    function depositToLiquidityPool() public {
        require(
            block.timestamp > deadline,
            "Cannot deposit to liquidity pool until after the deadline"
        );
        require(
            total_tokenA_deposited >= total_tokenA_threshold,
            "Threshold not met"
        );

        // Iterate over the depositorAddresses array
        for (uint i = 0; i < depositorAddresses.length; i++) {
            address depositor = depositorAddresses[i];

            // Calculate the amounts to be deposited to the liquidity pool
            uint256 tokenA_to_deposit = depositors[depositor].tokenA_deposited;
            uint256 tokenB_to_deposit = depositors[depositor].tokenB_deposited;

            // Check if the depositor has deposited the correct ratio of tokens
            if (
                tokenA_to_deposit / tokenB_to_deposit ==
                tokenA_amount / tokenB_amount
            ) {
                // Reset the depositor's deposited amounts
                depositors[depositor].tokenA_deposited = 0;
                depositors[depositor].tokenB_deposited = 0;

                // Approve the liquidity pool to withdraw the tokens
                require(
                    tokenA.approve(liquidityPool, tokenA_to_deposit),
                    "Approval of tokenA failed"
                );
                require(
                    tokenB.approve(liquidityPool, tokenB_to_deposit),
                    "Approval of tokenB failed"
                );

                // Call the addLiquidity function of the liquidity pool
                (bool success, ) = liquidityPool.call(
                    abi.encodeWithSignature(
                        "addLiquidity(address,address,uint256,uint256)",
                        address(tokenA),
                        address(tokenB),
                        tokenA_to_deposit,
                        tokenB_to_deposit
                    )
                );
                require(success, "Adding liquidity failed");

                // Assume the addLiquidity function returns the amount of LP tokens minted
                // Update the depositor's LP tokens
                depositors[depositor].lp_tokens += bytesToUint(msg.data); // LP tokens are tracked by amount
            }
        }
    }

    function claimLP() public {
        uint256 lp_tokens = depositors[msg.sender].lp_tokens;
        require(lp_tokens > 0, "No LP tokens to claim");

        // Reset the depositor's LP tokens
        depositors[msg.sender].lp_tokens = 0;

        // Transfer the LP tokens to the depositor
        require(
            lpToken.transfer(msg.sender, lp_tokens),
            "Transfer of LP tokens failed"
        );
    }

    function bytesToUint(bytes memory b) private pure returns (uint256) {
        uint256 number;
        for (uint i = 0; i < b.length; i++) {
            number = number + uint8(b[i]) * (2 ** (8 * (b.length - (i + 1))));
        }
        return number;
    }
}
