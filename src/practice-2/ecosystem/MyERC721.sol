// SPDX-License-Identifier: No-License

pragma solidity 0.8.27;

import {BitMaps} from "openzeppelin/utils/structs/BitMaps.sol";
import {ERC721Royalty, ERC721} from "openzeppelin/token/ERC721/extensions/ERC721Royalty.sol";
import {MerkleProof} from "openzeppelin/utils/cryptography/MerkleProof.sol";
import {Ownable2Step, Ownable} from "openzeppelin/access/Ownable2Step.sol";

contract MyERC721 is ERC721Royalty, Ownable2Step {
    using BitMaps for BitMaps.BitMap;

    event PublicSaleStarted();
    event RootUpdated();

    error AlreadyClaimed();
    error FailedWithdrawal();
    error InvalidAmount();
    error InvalidProof();
    error NoBots();
    error PublicSaleNotStarted();
    error SupplyReached();

    uint256 public constant MAX_SUPPLY = 1_001;
    uint256 public constant MAX_PRESALE_TICKETS = 100;
    uint256 public constant COST = 0.01 ether;
    uint256 public constant PRESALE_COST = 0.008 ether;

    BitMaps.BitMap private bitmap;
    uint256 private tokenSupply = 1;
    bytes32 private root;
    bool public publicSale;

    constructor() ERC721("MyERC721", "MYERC721") Ownable(msg.sender) {
        _setDefaultRoyalty(msg.sender, 2500);
    }

    /// @notice Public sale of the NFT
    function mint() external payable {
        require(publicSale, PublicSaleNotStarted());
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

    /// @notice Pre-sale of the NFT
    function presale(
        uint256 ticket,
        bytes32[] calldata proof
    ) external payable {
        if (isClaimed(ticket)) revert AlreadyClaimed();

        uint256 _supply = tokenSupply;
        require(_supply < MAX_SUPPLY, SupplyReached());
        require(msg.value == PRESALE_COST, InvalidAmount());

        bytes32 leaf = keccak256(abi.encodePacked(ticket, msg.sender));
        if (!MerkleProof.verify(proof, root, leaf)) revert InvalidProof();

        bitmap.set(ticket);
        _mint(msg.sender, _supply);
        unchecked {
            _supply++;
        }
        tokenSupply = _supply;
    }

    function updateRoot(bytes32 _newRoot) external onlyOwner {
        root = _newRoot;
        emit RootUpdated();
    }

    function withdraw() external onlyOwner {
        (bool ok, ) = owner().call{value: address(this).balance}("");
        if (!ok) revert FailedWithdrawal();
    }

    function startPublicSale() external onlyOwner {
        publicSale = true;
        emit PublicSaleStarted();
    }

    function isClaimed(uint256 ticket) public view returns (bool) {
        return bitmap.get(ticket);
    }

    function tokenURI(
        uint256 _tokenId
    ) public pure override returns (string memory) {
        return "pinata.com/mynft.json";
    }

    function totalSupply() external view returns (uint256) {
        return tokenSupply - 1; // Starts at 1 for gas-savings on first mint
    }
}
