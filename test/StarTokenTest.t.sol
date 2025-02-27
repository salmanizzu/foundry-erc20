// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {DeployStarToken} from "../script/DeployStarToken.s.sol";
import {StarToken} from "../src/StarToken.sol";

contract StarTokenTest is Test {
    StarToken public starToken;
    DeployStarToken public deployer;

    address alex = makeAddr("alex");
    address beth = makeAddr("beth");

    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant INITIAL_ALLOWANCE = 50 ether;

    function setUp() public {
        deployer = new DeployStarToken();
        starToken = deployer.run();

        vm.prank(msg.sender);
        starToken.transfer(alex, STARTING_BALANCE);
    }

    // ------------- INITIAL TESTS -------------

    function testAlexBalance() public view {
        assertEq(STARTING_BALANCE, starToken.balanceOf(alex));
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        vm.prank(alex);
        starToken.approve(beth, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(beth);
        starToken.transferFrom(alex, beth, transferAmount);

        assertEq(starToken.balanceOf(beth), transferAmount);
        assertEq(starToken.balanceOf(alex), STARTING_BALANCE - transferAmount);
    }

    // ------------- TRANSFER TESTS -------------

    function testTransferSuccess() public {
        uint256 transferAmount = 10 ether;

        vm.prank(alex);
        starToken.transfer(beth, transferAmount);

        assertEq(starToken.balanceOf(alex), STARTING_BALANCE - transferAmount);
        assertEq(starToken.balanceOf(beth), transferAmount);
    }

    function testTransferFailsIfInsufficientBalance() public {
        uint256 transferAmount = STARTING_BALANCE + 1;

        vm.prank(alex);
        vm.expectRevert();
        starToken.transfer(beth, transferAmount);
    }

    function testTransferZeroAmount() public {
        vm.prank(alex);
        bool success = starToken.transfer(beth, 0);
        assertTrue(success);
    }

    // ------------- ALLOWANCE & TRANSFERFROM TESTS -------------

    function testApproveWorks() public {
        vm.prank(alex);
        starToken.approve(beth, INITIAL_ALLOWANCE);

        assertEq(starToken.allowance(alex, beth), INITIAL_ALLOWANCE);
    }

    function testTransferFromWithAllowance() public {
        vm.prank(alex);
        starToken.approve(beth, INITIAL_ALLOWANCE);

        uint256 transferAmount = 20 ether;

        vm.prank(beth);
        starToken.transferFrom(alex, beth, transferAmount);

        assertEq(starToken.balanceOf(alex), STARTING_BALANCE - transferAmount);
        assertEq(starToken.balanceOf(beth), transferAmount);
        assertEq(starToken.allowance(alex, beth), INITIAL_ALLOWANCE - transferAmount);
    }

    function testTransferFromFailsWithoutAllowance() public {
        uint256 transferAmount = 10 ether;

        vm.prank(beth);
        vm.expectRevert();
        starToken.transferFrom(alex, beth, transferAmount);
    }

    function testTransferFromFailsIfExceedingAllowance() public {
        vm.prank(alex);
        starToken.approve(beth, INITIAL_ALLOWANCE);

        uint256 transferAmount = INITIAL_ALLOWANCE + 1;

        vm.prank(beth);
        vm.expectRevert();
        starToken.transferFrom(alex, beth, transferAmount);
    }
}
