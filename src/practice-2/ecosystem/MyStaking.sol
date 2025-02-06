// SPDX-License-Identifier: No-License

pragma solidity 0.8.27;

import {MyERC20} from "./MyERC20.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "openzeppelin/interfaces/IERC721Receiver.sol";
import {Ownable2Step, Ownable} from "openzeppelin/access/Ownable2Step.sol";

contract MyStaking is IERC721Receiver, Ownable2Step {
    event Staked(uint256 id, address owner);

    error Unauthorized();

    struct Position {
        address owner;
        uint256 timestamp;
        uint256 lastRewardTimestamp;
    }

    uint256 public constant REWARDS_PER_DAY = 10 ether;
    IERC721 public immutable nft;
    IERC20 public immutable rewardToken;

    mapping(uint256 id => Position position) public positions;

    constructor(address _nft) Ownable(msg.sender) {
        address _rewardToken = address(new MyERC20(1_000_000_000 ether));
        nft = IERC721(_nft);
        rewardToken = IERC20(_rewardToken);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external returns (bytes4) {
        require(msg.sender == address(nft), Unauthorized());

        Position memory pos = Position({
            owner: from,
            timestamp: block.timestamp,
            lastRewardTimestamp: block.timestamp
        });

        positions[id] = pos;
        emit Staked(id, from);
    }

    function claim(uint256 id) public {
        Position memory pos = positions[id];
        uint256 amount = claimableAmount(id);

        rewardToken.transfer(pos.owner, amount);
    }

    function withdraw(uint256 id) external {
        Position memory pos = positions[id];

        require(msg.sender == pos.owner, Unauthorized());

        delete positions[id];
        uint256 amount = claimableAmount(id);
        rewardToken.transfer(pos.owner, amount);
        nft.transferFrom(address(this), msg.sender, id);
    }

    function claimableAmount(uint256 id) public view returns (uint256) {
        Position memory pos = positions[id];
        return
            ((block.timestamp - pos.lastRewardTimestamp) * REWARDS_PER_DAY) /
            1 days;
    }
}
