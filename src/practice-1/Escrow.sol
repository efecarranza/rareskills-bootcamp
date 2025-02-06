// SPDX-License-Identifier: No-License

pragma solidity 0.8.27;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";

contract Escrow {
    using SafeERC20 for IERC20;

    struct Deposit {
        address token;
        address withdrawer;
        bool withdrawn;
        uint256 timestamp;
        uint256 amount;
    }

    error Unauthorized();
    error Wait();

    uint128 internal receiptId;
    mapping(address depositor => mapping(uint256 receiptId => Deposit receipt)) public escrowed;

    function deposit(address token, address withdrawer, uint256 amount) external {
        escrowed[msg.sender][receiptId] = Deposit({
            token: token,
            withdrawer: withdrawer,
            withdrawn: false,
            timestamp: block.timestamp + 3 days,
            amount: amount
        });

        IERC20(token).transferFrom(msg.sender, address(this), amount);
        receiptId++;
    }

    function withdraw(address creator, uint256 _receiptId) external {
        Deposit memory deposit = escrowed[creator][_receiptId];
        if (msg.sender != deposit.withdrawer) revert Unauthorized();
        if (block.timestamp < deposit.timestamp) revert Wait();

        uint256 toWithdraw = deposit.amount;

        deposit.amount = 0;
        deposit.withdrawn = true;
        deposit.withdrawer = address(0);

        escrowed[creator][_receiptId] = deposit;

        IERC20(deposit.token).transfer(msg.sender, toWithdraw);
    }
}
