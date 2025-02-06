// SPDX-License-Identifier: No-License

pragma solidity 0.8.27;

import {ERC721Enumerable, ERC721} from "openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable2Step, Ownable} from "openzeppelin/access/Ownable2Step.sol";

contract MyERC721Enumerable is ERC721Enumerable, Ownable2Step {
    event PublicSaleStarted();
    event RootUpdated();

    error FailedWithdrawal();
    error InvalidAmount();
    error NoBots();
    error SupplyReached();

    uint256 public constant MAX_SUPPLY = 101;
    uint256 public constant COST = 0.01 ether;
    uint256 public constant PRESALE_COST = 0.008 ether;

    uint256 private tokenSupply = 1;

    constructor() ERC721("MyERC721", "MYERC721") Ownable(msg.sender) {}

    /// @notice Public sale of the NFT
    function mint() external payable {
        uint256 _supply = tokenSupply;
        require(_supply < MAX_SUPPLY, SupplyReached());
        require(msg.sender == tx.origin, NoBots());
        require(msg.value == COST, InvalidAmount());

        _mint(msg.sender, _supply);
        unchecked {
            _supply++;
        }
        tokenSupply = _supply;
    }

    function withdraw() external onlyOwner {
        (bool ok, ) = owner().call{value: address(this).balance}("");
        if (!ok) revert FailedWithdrawal();
    }

    function tokenURI(
        uint256 _tokenId
    ) public pure override returns (string memory) {
        return "pinata.com/mynft.json";
    }
}
