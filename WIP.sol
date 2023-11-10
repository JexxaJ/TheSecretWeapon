// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DepositContract {
    ERC20 public tokenA;
    ERC20 public tokenB;
    ERC20 public lpToken; // The LP token
    uint256 public tokenA_amount;
    uint256 public tokenB_amount;
    uint256 public total_tokenA_threshold;
    uint256 public total_tokenA_deposited;
    uint256 public total_tokenB_deposited;
    uint256 public deadline;
    address public liquidityPool;

    struct Depositor {
        uint256 tokenA_deposited;
        uint256 tokenB_deposited;
        uint256 lp_tokens; // The amount of LP tokens the depositor is entitled to
    }

    mapping(address => Depositor) public depositors;

    constructor(
        address _tokenA,
        address _tokenB,
        address _lpToken,
        uint256 _tokenA_amount,
        uint256 _tokenB_amount,
        uint256 _total_tokenA_threshold,
        address _liquidityPool
    ) {
        tokenA = ERC20(_tokenA);
        tokenB = ERC20(_tokenB);
        lpToken = ERC20(_lpToken); // Initialize the LP token
        tokenA_amount = _tokenA_amount;
        tokenB_amount = _tokenB_amount;
        total_tokenA_threshold = _total_tokenA_threshold;
        liquidityPool = _liquidityPool;
    }

    function deposit(uint256 _tokenA_amount, uint256 _tokenB_amount) public {
        require(
            tokenA.transferFrom(msg.sender, address(this), _tokenA_amount),
            "Transfer of tokenA failed"
        );
        require(
            tokenB.transferFrom(msg.sender, address(this), _tokenB_amount),
            "Transfer of tokenB failed"
        );

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

        // Approve the liquidity pool to withdraw the tokens
        require(
            tokenA.approve(liquidityPool, total_tokenA_deposited),
            "Approval of tokenA failed"
        );
        require(
            tokenB.approve(liquidityPool, total_tokenB_deposited),
            "Approval of tokenB failed"
        );

        // Call the addLiquidity function of the liquidity pool
        (bool success, ) = liquidityPool.call(
            abi.encodeWithSignature(
                "addLiquidity(address,address,uint256,uint256)",
                address(tokenA),
                address(tokenB),
                total_tokenA_deposited,
                total_tokenB_deposited
            )
        );
        require(success, "Adding liquidity failed");

        // Assume the addLiquidity function returns the amount of LP tokens minted
        // Update the total LP tokens
        uint256 total_lp_tokens = msg.data; // LP tokens are tracked by amount

        // Iterate over the depositors mapping and assign LP tokens based on their percentage of the total deposit
        for (uint i = 0; i < depositors.length; i++) {
            address depositor = depositors[i];

            // Calculate the percentage of the total deposit that this depositor contributed
            uint256 percentage = depositors[depositor].tokenA_deposited /
                total_tokenA_deposited;

            // Assign LP tokens to the depositor based on their percentage of the total deposit
            depositors[depositor].lp_tokens += total_lp_tokens * percentage;
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
}
