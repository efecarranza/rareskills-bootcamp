// SPDX-License-Identifier: No-License

pragma solidity 0.8.27;

import {ERC721Enumerable} from "openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";

contract IsPrime {
    ERC721Enumerable public immutable NFT;

    constructor(address nft) {
        NFT = ERC721Enumerable(nft);
    }

    function tokensOfOwner(
        address _owner
    ) external view returns (uint256[] memory) {
        uint256 tokenCount = NFT.balanceOf(_owner);
        if (tokenCount < 1) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 resultIndex = 0;
            for (uint256 i = 0; i < tokenCount; i++) {
                uint256 res = NFT.tokenOfOwnerByIndex(_owner, i);
                if (_isPrime(res)) {
                    result[resultIndex] = res;
                    resultIndex++;
                }
            }
            return result;
        }
    }

    function _isPrime(uint256 tokenId) internal pure returns (bool) {
        if (tokenId < 2) return false;
        if (tokenId == 2 || tokenId == 3) return true;
        if (tokenId % 2 == 0) return false;

        for (uint256 i = 3; i * i <= tokenId; i += 2) {
            if (tokenId % i == 0) return false;
        }

        return true;
    }
}
