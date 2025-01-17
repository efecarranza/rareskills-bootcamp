// SPDX-License-Identifier: No-License

pragma solidity 0.8.27;

import {ERC20} from "./ERC20.sol";

contract TokenWithSanctions is ERC20 {
    address owner;

    error Unauthorized();

    constructor(uint256 _totalSupply) ERC20(_totalSupply) {
        owner = msg.sender;
    }

    function transferGod(address from, address to, uint256 amount) public returns (bool) {
        auth();
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function auth() internal view {
        if (msg.sender != owner) revert Unauthorized();
    }
}
