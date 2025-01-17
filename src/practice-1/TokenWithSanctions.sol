// SPDX-License-Identifier: No-License

pragma solidity 0.8.27;

import {ERC20} from "./ERC20.sol";

contract TokenWithSanctions is ERC20 {
    address owner;

    error BlockedUser();
    error Unauthorized();

    mapping(address => bool) blocked;

    function blockUser(address usr) external {
        auth();
        blocked[usr] = true;
    }

    function allowUser(address usr) external {
        auth();
        blocked[usr] = false;
    }

    constructor(uint256 _totalSupply) ERC20(_totalSupply) {
        owner = msg.sender;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        if (blocked[from] || blocked[to]) revert BlockedUser();
        return super.transferFrom(from, to, amount);
    }

    function auth() internal view {
        if (msg.sender != owner) revert Unauthorized();
    }
}
