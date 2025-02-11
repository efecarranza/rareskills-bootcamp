// SPDX-License-Identifier: No-License

pragma solidity 0.8.27;

import {Test} from "forge-std/Test.sol";
import {Overmint1} from "src/practice-2/overmint/Overmint1.sol";
import {Overmint1Attacker} from "src/practice-2/overmint/Overmint1Attacker.sol";

contract IsPrimeTest is Test {
    Overmint1Attacker attacker;
    Overmint1 overmint;

    address public immutable userOne = makeAddr("user-one");
    address public immutable userTwo = makeAddr("user-two");

    function setUp() public {
        overmint = new Overmint1();
        attacker = new Overmint1Attacker(address(overmint));

        deal(userOne, 100 ether);
        deal(userTwo, 100 ether);
    }

    function test_success() public {
        vm.prank(address(attacker));
        overmint.mint();

        assertTrue(overmint.success(address(attacker)));
    }
}
