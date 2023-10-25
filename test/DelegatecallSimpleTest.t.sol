//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {HackMe, Lib, Attack} from "../src/DelegatecallSimple.sol";

contract DelegatecallSimpleTest is Test {
    HackMe public hackMe;
    Lib public lib;
    Attack public attack;

    function setUp() public {
        lib = new Lib();
        hackMe = new HackMe(lib);
        attack = new Attack(address(hackMe));
    }

    //EveがAttackを使ってHackMeのownerを変更する
    //この際、新しいownerはAttackのアドレスになる.(eveではない)
    function test_attack() public {
        console2.log("hackMe contract owner: %s", hackMe.owner());
        console2.log("attack contract address: %s", address(attack));
        address eve = makeAddr("Eve");
        console2.log("Eve's address: %s", address(eve));
        vm.prank(eve);
        attack.attack();
        console2.log("hackMe contract owner: %s", hackMe.owner());
        assertEq(hackMe.owner(), address(attack));
    }

}
