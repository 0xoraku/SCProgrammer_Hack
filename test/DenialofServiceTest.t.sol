//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {KingOfEther, Attack, ProtectedKingOfEther, ProtectedKingOfEtherAttack} from "../src/DenialofService.sol";

contract KingOfEtherTest is Test {
    KingOfEther public kingOfEther;
    Attack public attack;
    ProtectedKingOfEther public protectedKingOfEther;
    ProtectedKingOfEtherAttack public protectedKingOfEtherAttack;

    function setUp() public {
        kingOfEther = new KingOfEther();
        attack = new Attack(kingOfEther);
        protectedKingOfEther = new ProtectedKingOfEther();
        protectedKingOfEtherAttack = new ProtectedKingOfEtherAttack(protectedKingOfEther);
    }

    //EveがAttackコントラクトのattack関数を呼び出すことで、
    //Attack contract addressがKingになることを確認
    function test_attack_can_become_the_king() public {
        address alice = makeAddr("Alice");
        address eve = makeAddr("Eve");

        hoax(alice, 1 ether);
        kingOfEther.claimThrone{value: 1 ether}();
        console.log("Alice address is: ", address(alice));
        console.log("current king is: ", kingOfEther.king());
        hoax(eve, 2 ether);
        attack.attack{value: 2 ether}();
        console.log("attack contract address is: ", address(attack));
        console.log("current king is: ", kingOfEther.king());
        assertEq(kingOfEther.king(), address(attack));
    }

    //EveがAttack後、attack contractが送金を拒否するので
    //誰もKingになれないことを確認
    function test_no_one_can_become_the_king_after_the_attack() public {
        address alice = makeAddr("Alice");
        address bob = makeAddr("Bob");
        address eve = makeAddr("Eve");

        hoax(alice, 1 ether);
        kingOfEther.claimThrone{value: 1 ether}();
        hoax(eve, 2 ether);
        attack.attack{value: 2 ether}();
        hoax(bob, 3 ether);
        vm.expectRevert(bytes("Failed to send Ether"));
        kingOfEther.claimThrone{value: 3 ether}();
    }

    //EveがProtectedKingOfEtherAttackコントラクト
    //のattack関数を呼び出した後も、誰かがKingになれることを確認
    function test_anyone_can_become_the_king_after_the_attack_on_the_protectedContract() public {
        address alice = makeAddr("Alice");
        address bob = makeAddr("Bob");
        address eve = makeAddr("Eve");
        console.log("Alice address is: ", address(alice));
        console.log("Bob address is: ", address(bob));

        hoax(alice, 1 ether);
        protectedKingOfEther.claimThrone{value: 1 ether}();
        console.log("current king is: ", protectedKingOfEther.king());
        hoax(eve, 2 ether);
        protectedKingOfEtherAttack.attack{value: 2 ether}();
        console.log("current king is: ", protectedKingOfEther.king());
        hoax(bob, 3 ether);
        protectedKingOfEther.claimThrone{value: 3 ether}();
        console.log("current king is: ", protectedKingOfEther.king());
        assertEq(protectedKingOfEther.king(), address(bob));
    }

    //AliceがBobがkingになった後、出金できることを確認
    function test_withdraw() public {
        address alice = makeAddr("Alice");
        address bob = makeAddr("Bob");
        hoax(alice, 1 ether);
        protectedKingOfEther.claimThrone{value: 1 ether}();
        console.log("alice balance is: ", address(alice).balance);
        hoax(bob, 2 ether);
        protectedKingOfEther.claimThrone{value: 2 ether}();
        vm.prank(alice);
        protectedKingOfEther.withdraw();
        console.log("alice balance is: ", address(alice).balance);
        assertEq(address(alice).balance, 1 ether);
    }

    //Aliceがkingの時には、出金できないことを確認
    function test_withdraw_fail() public {
        address alice = makeAddr("Alice");
        hoax(alice, 1 ether);
        protectedKingOfEther.claimThrone{value: 1 ether}();
        vm.expectRevert(bytes("Failed to send Ether")); //Current king cannot withdraw -> Failed to send Ether
        protectedKingOfEther.withdraw();
    }

}