//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MultiSigWallet, ProtectedMultiSigWallet} from "../src/SignatureReplay.sol";
import {ECDSA} from "../src/interactions/ECDSA.sol";

contract MultiSigWalletTest is Test {
    using ECDSA for bytes32;
    MultiSigWallet public multiSigWallet;
    ProtectedMultiSigWallet public protectedMultiSigWallet;
    address[2] public owners;
    address public alice;
    address public eve;
    uint256 public alicePk;
    uint256 public evePk;
    

    function setUp() public {
        (alice, alicePk) = makeAddrAndKey("alice");
        (eve, evePk) = makeAddrAndKey("eve");
        owners[0] = alice;
        owners[1] = eve;
        multiSigWallet = new MultiSigWallet(owners);
        protectedMultiSigWallet = new ProtectedMultiSigWallet(owners);
        
    }

    //EveがMultiSigWalletのコントラクトに対して、
    //aliceの署名を何度も利用することで、必要以上にaliceの残高を奪う
    function test_multiple_sign_by_eve() public {
        deal(address(multiSigWallet),5 ether);
        //aliceの署名作成
        bytes32 digest = keccak256(abi.encodePacked(eve, uint256(100))).toEthSignedMessageHash();
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(alicePk, digest);
        bytes memory aliceSignature = abi.encodePacked(r1, s1, v1);
        console.logBytes(aliceSignature); // 0x41569414382cd24146f3db68318760d259800aed312eacca73e3f66ddc0cf32c1f973125c8dbe43f8b49f99a0a8c0e828959e352e89a596384963bcebbd96a2e1c
        //eveの署名作成
        // bytes32 digestEve = keccak256(abi.encodePacked(eve, uint256(100))).toEthSignedMessageHash();
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(evePk, digest);
        bytes memory eveSignature = abi.encodePacked(r2, s2, v2);
        // console.logBytes(eveSignature);
        //aliceの署名を利用して、aliceの残高を奪う
        console.log("eve's balance: ", address(eve).balance);//0
        multiSigWallet.transfer(eve, 100, [aliceSignature, eveSignature]);
        console.log("eve's balance 1st : ", address(eve).balance);//100
        // console.log("contractbalance: ", address(multiSigWallet).balance);//4999999999999999900
        multiSigWallet.transfer(eve, 100, [aliceSignature, eveSignature]);
        console.log("eve's balance 2nd : ", address(eve).balance);//200
        assertEq(address(eve).balance, 200);
    }

    //nonceによって、aliceの署名値が変わるので、
    //eveはaliceの署名を何度も利用することができない
    function test_cannot_use_signature_multiple_times() public {
        deal(address(protectedMultiSigWallet),5 ether);
        //aliceの署名作成
        bytes32 digest = keccak256(abi.encodePacked(address(protectedMultiSigWallet), eve, uint256(100), uint(0))).toEthSignedMessageHash();
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(alicePk, digest);
        bytes memory aliceSignature = abi.encodePacked(r1, s1, v1);
        console.logBytes(aliceSignature); //0xc6f3d12fb052ecd2a8b6e4f61d453182d0605218aa890e04641170468568723d3dd13d108c227258dd37aa62841b1479cee72b12b5af94517fc00d75b27107d71b
        //eveの署名作成
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(evePk, digest);
        bytes memory eveSignature = abi.encodePacked(r2, s2, v2);

        console.log("eve's balance: ", address(eve).balance);//0
        protectedMultiSigWallet.transfer(eve, 100, 0, [aliceSignature, eveSignature]);
        console.log("eve's balance 1st : ", address(eve).balance);//100
        vm.expectRevert();
        //１度使われた署名は使えない
        protectedMultiSigWallet.transfer(eve, 100, 0,[aliceSignature, eveSignature]);// "tx executed"
        //nonceを増やしたら、aliceの署名値が変わるので、invalid sigになる
        // protectedMultiSigWallet.transfer(eve, 100, 1,[aliceSignature, eveSignature]); //"invalid sig"
    }
}

/*
// owners
0xe19aea93F6C1dBef6A3776848bE099A7c3253ac8
0xfa854FE5339843b3e9Bfd8554B38BD042A42e340

// to
0xe10422cc61030C8B3dBCD36c7e7e8EC3B527E0Ac
// amount
100
// nonce
0
// tx hash
0x12a095462ebfca27dc4d99feef885bfe58344fb6bb42c3c52a7c0d6836d11448

// signatures
0x120f8ed8f2fa55498f2ef0a22f26e39b9b51ed29cc93fe0ef3ed1756f58fad0c6eb5a1d6f3671f8d5163639fdc40bb8720de6d8f2523077ad6d1138a60923b801c
0xa240a487de1eb5bb971e920cb0677a47ddc6421e38f7b048f8aa88266b2c884a10455a52dc76a203a1a9a953418469f9eec2c59e87201bbc8db0e4d9796935cb1b
*/