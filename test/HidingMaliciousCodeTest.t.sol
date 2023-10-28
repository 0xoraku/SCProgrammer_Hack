//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Foo, Bar, Mal} from "../src/HidingMaliciousCode.sol";

contract HidingMaliciousCodeTest is Test {
    event Log(string message);

    Foo public foo;
    Bar public bar;
    Mal public mal;


    function setUp() public {
        // mal = new Mal();
        // foo = new Foo(address(mal));
        // bar = new Bar();
    }

    function test_foo_call_bar() public {
        address alice = makeAddr("Alice");
        address eve = makeAddr("Eve");
        vm.startPrank(eve);
        mal = new Mal();
        foo = new Foo(address(mal));
        vm.stopPrank();
        vm.prank(alice);
        vm.expectEmit(true, false, false, false);
        //Bar was calledではない！
        emit Log("Mal was called");
        foo.callBar();
    }
}