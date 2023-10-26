//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {GuessTheRandomNumber, Attack} from "../src/Randomness.sol";

contract GuessTheRandomNumberTest is Test {
    GuessTheRandomNumber public guessTheRandomNumber;
    Attack public attack;
    
    function setUp() public {
        guessTheRandomNumber = new GuessTheRandomNumber();
        attack = new Attack();
    }

    function test_attack_can_guess_the_number() public {
        deal(address(guessTheRandomNumber), 1 ether);
        address eve = makeAddr("Eve");
        vm.prank(eve);
        attack.attack(guessTheRandomNumber);
        assertEq(address(attack).balance, 1 ether);
    }
}