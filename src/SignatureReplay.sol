// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol";
import {ECDSA} from "./interactions/ECDSA.sol";

//脆弱性のあるコード
contract MultiSigWallet {
    using ECDSA for bytes32;

    address[2] public owners;

    constructor(address[2] memory _owners) payable {
        owners = _owners;
    }

    function deposit() external payable {}

    function transfer(address _to, uint _amount, bytes[2] memory _sigs) external {
        bytes32 txHash = getTxHash(_to, _amount);
        require(_checkSigs(_sigs, txHash), "invalid sig");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function getTxHash(address _to, uint _amount) public view returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount));
    }

    function _checkSigs(
        bytes[2] memory _sigs,
        bytes32 _txHash
    ) private view returns (bool) {
        bytes32 ethSignedHash = _txHash.toEthSignedMessageHash();

        for (uint i = 0; i < _sigs.length; i++) {
            address signer = ethSignedHash.recover(_sigs[i]);
            bool valid = signer == owners[i];

            if (!valid) {
                return false;
            }
        }

        return true;
    }
}

// 1. スマートコントラクトには、各ユーザーの現在のnonceを追跡するマッピングを含めます。
// 2. ユーザーがトランザクションに署名する際、そのトランザクションには特定のnonceが含まれている必要があります。これは、通常、そのユーザーの現在のnonceに1加算したものです。
// 3. トランザクションがコントラクトに送信されると、コントラクトはそのトランザクションの署名が正しいこと、および提供されたnonceが期待される値（保存されている現在のnonce + 1）であることを確認します。
// 4. トランザクションが正当であると確認されると、コントラクトは内部のnonceを更新（+1する）し、トランザクションを実行します。
//nonceをつけ、replay attackを防ぐコード
contract ProtectedMultiSigWallet {
    using ECDSA for bytes32;

    address[2] public owners;
    mapping(bytes32 => bool) public executed;

    constructor(address[2] memory _owners) payable {
        owners = _owners;
    }

    function deposit() external payable {}

    function transfer(
        address _to,
        uint _amount,
        uint _nonce,
        bytes[2] memory _sigs
    ) external {
        bytes32 txHash = getTxHash(_to, _amount, _nonce);
        require(!executed[txHash], "tx executed");
        require(_checkSigs(_sigs, txHash), "invalid sig");

        executed[txHash] = true;

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function getTxHash(
        address _to,
        uint _amount,
        uint _nonce
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), _to, _amount, _nonce));
    }

    function _checkSigs(
        bytes[2] memory _sigs,
        bytes32 _txHash
    ) private view returns (bool) {
        bytes32 ethSignedHash = _txHash.toEthSignedMessageHash();

        for (uint i = 0; i < _sigs.length; i++) {
            address signer = ethSignedHash.recover(_sigs[i]);
            bool valid = signer == owners[i];

            if (!valid) {
                return false;
            }
        }

        return true;
    }
}