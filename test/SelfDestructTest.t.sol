// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {EtherGame, Attack, ProtectedEtherGame, ProtectedEtherGameAttack} from "../src/SelfDestruct.sol";

contract EtherGameTest is Test {
    EtherGame public etherGame;
    Attack public attack;
    ProtectedEtherGame public protectedEtherGame;
    ProtectedEtherGameAttack public protectedEtherGameAttack;
    

    function setUp() public {
        etherGame = new EtherGame();
        attack = new Attack(etherGame);
        protectedEtherGame = new ProtectedEtherGame();
        protectedEtherGameAttack = new ProtectedEtherGameAttack(protectedEtherGame);
    }

    //selfdestructでEtherGameのbalanceを7にし、勝者なしとする
    function testAttack() public {
        address Alice = makeAddr("Alice");
        address Bob = makeAddr("Bob");
        hoax(Alice, 1 ether);
        etherGame.deposit{value: 1 ether}();
        console2.log("etherGame balance: %s", address(etherGame).balance / 1e18); //1
        hoax(address(attack), 6 ether);
        attack.attack{value: 6 ether}();
        console2.log("etherGame balance: %s", address(etherGame).balance / 1e18); //7
        hoax(Bob, 1 ether);
        vm.expectRevert(bytes("Game is over"));
        etherGame.deposit{value: 1 ether}(); //既に7 etherなので失敗する
        vm.expectRevert(bytes("Not winner"));
        etherGame.claimReward(); //勝者なし
    }

    //balanceがaddress(this).balanceを参照してないことを確認
    function test_state_of_balance_protected() public {
        address Alice = makeAddr("Alice");
        address Bob = makeAddr("Bob");
        hoax(Alice, 1 ether);
        protectedEtherGame.deposit{value: 1 ether}();
        console2.log("Before attack: protectedEtherGame balance: %s", protectedEtherGame.getBalance() / 1e18); //1
        hoax(address(protectedEtherGameAttack), 6 ether);
        protectedEtherGameAttack.attack{value: 6 ether}();
        console2.log("After attack: protectedEtherGame balance: %s", protectedEtherGame.getBalance() / 1e18); //1
        assertEq(protectedEtherGame.getBalance(), 1 ether);
        hoax(Bob, 1 ether);
        protectedEtherGame.deposit{value: 1 ether}();
        console2.log("After Bob deposit: protectedEtherGame balance: %s", protectedEtherGame.getBalance() / 1e18); //2
    }

}