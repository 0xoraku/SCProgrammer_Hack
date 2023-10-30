//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Target, FailedAttack, Hack} from "../src/BypassContractSizeCheck.sol";

contract BypassContractSizeCheckTest is Test {
    Target public target;
    FailedAttack public failedAttack;
    Hack public hack;

    function setUp() public {
        target = new Target();
        failedAttack = new FailedAttack();
        hack = new Hack(address(target));
    }

    //FailedAttackのコントラクトでは、isContractがtrue
    //なので、revertされる
    function test_failed_attack_failed() public {
        // This will fail
        vm.expectRevert(bytes("no contract allowed"));
        failedAttack.pwn(address(target));
    }

    //Hackのコントラクトでは、isContractがfalseにできる
    function test_hack_success() public {
        assertEq(hack.isContract(), false);
        //isContractがfalseなので、revertされない
        assertEq(target.pwned(), true);
    }

    
}