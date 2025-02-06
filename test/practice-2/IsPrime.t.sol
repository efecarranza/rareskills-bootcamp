// SPDX-License-Identifier: No-License

pragma solidity 0.8.27;

import {Test} from "forge-std/Test.sol";
import {MyERC721Enumerable} from "src/practice-2/primes/MyERC721Enumerable.sol";
import {IsPrime} from "src/practice-2/primes/IsPrime.sol";

contract IsPrimeTest is Test {
    IsPrime isPrime;
    MyERC721Enumerable erc721;

    address public immutable userOne = makeAddr("user-one");
    address public immutable userTwo = makeAddr("user-two");

    function setUp() public {
        erc721 = new MyERC721Enumerable();
        isPrime = new IsPrime(address(erc721));

        deal(userOne, 100 ether);
        deal(userTwo, 100 ether);
    }

    function test_returnsPrimeNumber() public {
        vm.prank(userOne, userOne);
        erc721.mint{value: 0.01 ether}();

        vm.prank(userTwo, userTwo);
        erc721.mint{value: 0.01 ether}();

        uint256[] memory results = isPrime.tokensOfOwner(userTwo);

        assertEq(results.length, 1);
        assertEq(results[0], 2);
    }

    function test_returnsEmptyArray() public {
        vm.prank(userOne, userOne);
        erc721.mint{value: 0.01 ether}();

        uint256[] memory results = isPrime.tokensOfOwner(userOne);

        assertEq(results.length, 1);
        assertEq(results[0], 0);
    }
}
