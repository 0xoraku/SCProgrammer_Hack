// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {EtherStore} from "../src/Reentrancy.sol";
import {Attack} from "../src/Reentrancy.sol";
import {ReEntrancyGuard} from "../src/Reentrancy.sol";
import {ReEntrancyGuardAttack} from "../src/Reentrancy.sol";

contract ReentrancyTest is Test {
    EtherStore public etherStore;
    Attack public attack;
    ReEntrancyGuard public reEntrancyGuard;
    ReEntrancyGuardAttack public reEntrancyGuardAttack;
    

    function setUp() public {
        etherStore = new EtherStore();
        attack = new Attack(address(etherStore));
        reEntrancyGuard = new ReEntrancyGuard();
        reEntrancyGuardAttack = new ReEntrancyGuardAttack(address(reEntrancyGuard));
    }

    function testAttack() public {
        uint originalBalance = 5 ether;
        vm.deal(address(etherStore), 5 ether);
        console2.log("Before attacking etherStore balance: %s", etherStore.getBalance() / 1e18); //5

        attack.attack{value: 1 ether}();
        console2.log("After attacking etherStore balance: %s", etherStore.getBalance() / 1e18); //0
        console2.log("attack balance: %s", attack.getBalance() / 1e18); //6
        assertEq(etherStore.getBalance(), 0);
        assertEq(attack.getBalance(), originalBalance + 1 ether);
    }

    function testReEntrancyGuardAttack() public {
        vm.deal(address(reEntrancyGuard), 5 ether);
        vm.expectRevert(bytes("Failed to send Ether"));//"No re-entrancy" ->Failed to send Ether 
        reEntrancyGuardAttack.attack{value: 1 ether}();

    }

    function testFail() public {
        revert("This test always fails");
    }
}