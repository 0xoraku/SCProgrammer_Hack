//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Bank, HoneyPot, Logger,Attack} from "../src/Honeypot.sol";

contract HoneyPotTest is Test {
    Bank public bank;
    HoneyPot public honeyPot;
    Attack public attack;
    Logger public logger;
    address alice = makeAddr("Alice");
    address eve = makeAddr("Eve");

    function setUp() public {
        vm.startPrank(alice);
        honeyPot = new HoneyPot();
        bank = new Bank(address(honeyPot));
        deal(address(bank), 2 ether);
        vm.stopPrank();
    }

    //eveがreentrancy攻撃をしても、honeypotのlog関数が呼ばれて、
    //最後にrevertする。
    function test_eve_cannot_withdraw() public {
        vm.startPrank(eve);
        attack = new Attack(bank);
        deal(address(attack), 1 ether);
        vm.expectRevert(bytes("Failed to send Ether"));
        attack.attack();
        vm.stopPrank();
    }

}