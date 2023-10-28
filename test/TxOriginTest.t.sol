//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//foundryのtx.originはdefaultの値がある。

import {Test, console} from "forge-std/Test.sol";
import {Wallet, Attack, ProtectedWallet, ProtectedWalletAttack} from "../src/TxOrigin.sol";

contract WalletTest is Test {
    Wallet public wallet;
    Attack public attack;
    ProtectedWallet public protectedWallet;
    ProtectedWalletAttack public protectedWalletAttack;
    address constant TXORIGIN = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

    function setUp() public {
        // wallet = new Wallet();
        attack = new Attack(wallet);
        protectedWallet = new ProtectedWallet();
        protectedWalletAttack = new ProtectedWalletAttack(protectedWallet);
    }

    //msg.sender,t.xoriginの値が同じaliceの場合、
    //eveはフィッシングしてもaliceの代わりに引き出せないことを確認
    function test_eve_cannot_withdraw() public {
        address payable alice = payable(makeAddr("Alice"));
        address payable eve = payable(makeAddr("Eve"));
        vm.prank(alice, alice);
        // vm.prank(address(this),TXORIGIN);
        wallet = new Wallet();
        console.log("owner is: ", wallet.owner());
        vm.deal(address(wallet), 10 ether);
        vm.prank(alice, alice);
        wallet.transfer(alice, 1);
        console.log("Alice's balance is: ", address(alice).balance);
        vm.startPrank(eve);
        attack = new Attack(wallet);
        vm.expectRevert(bytes("Not owner"));
        attack.attack();
    }

    //tx.originの値がalice,msg.senderがattackの場合、
    //aliceの代わりにattackが引き出せることを確認
    function test_attack_can_withdraw() public {
        address payable alice = payable(makeAddr("Alice"));
        address payable eve = payable(makeAddr("Eve"));
        console.log("Alice's address is: ", address(alice));
        console.log("Eve's address is: ", address(eve));
        vm.prank(alice, alice);
        wallet = new Wallet();
        assertEq(wallet.owner(), address(alice));
        vm.deal(address(wallet), 5 ether);
        vm.prank(eve);
        attack = new Attack(wallet);
        assertEq(attack.owner(), address(eve));
        //フィッシングでaliceを騙す
        vm.prank(alice, alice);
        attack.attack();
        //attackのOwnerであるeveが引き出せることを確認
        assertEq(eve.balance / 1e18, 5 ether / 1e18);
    }

}