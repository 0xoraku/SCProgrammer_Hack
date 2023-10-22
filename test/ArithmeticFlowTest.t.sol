// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;
pragma abicoder v2;

import {Test, console2} from "forge-std/Test.sol";
import {TimeLock, Attack, ProtectedTimeLock, ProtectedTimeLockAttack} from "../src/ArithmeticFlow.sol";

contract TimeLockTest is Test {
    TimeLock public timeLock;
    Attack public attack;
    ProtectedTimeLock public protectedTimeLock;
    ProtectedTimeLockAttack public protectedTimeLockAttack;
    
    function setUp() public {
        timeLock = new TimeLock();
        attack = new Attack(timeLock);
        protectedTimeLock = new ProtectedTimeLock();
        protectedTimeLockAttack = new ProtectedTimeLockAttack(protectedTimeLock);
    }

    ///////////////////
    //対策前のテスト
    ///////////////////

    //一般ユーザーが１週間以内に引き出そうとしても引き出せない
    function test_withdrawal_fails_if_within_a_week() public {
        vm.deal(address(timeLock), 5 ether);
        address user = makeAddr("user");
        vm.deal(address(user), 1 ether);
        vm.startPrank(user);
        timeLock.deposit{value: 1 ether}();
        vm.expectRevert(bytes("Lock time not expired"));
        timeLock.withdraw();
    }

    //攻撃コントラクトが１週間以内に引き出せてしまうことを確認する
    function test_attack_can_withdraw_within_a_week() public {
        vm.deal(address(timeLock), 5 ether);
        attack.attack{value: 1 ether}();
        assertEq(address(attack).balance, 1 ether);
    }


    ///////////////////
    //対策後のテスト
    ///////////////////
    //攻撃コントラクトが１週間以内に引き出せないことを確認する
    function test_attack_cannot_withdraw_within_a_week() public {
        vm.deal(address(protectedTimeLock), 5 ether);
        vm.expectRevert("SafeMath: addition overflow");
        protectedTimeLockAttack.attack{value: 1 ether}();
    }

}
