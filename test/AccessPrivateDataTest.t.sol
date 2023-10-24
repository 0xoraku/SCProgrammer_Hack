// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {Vault} from "../src/AccessPrivateData.sol";

contract VaultTest is Test {
    Vault public vault;
    

    function setUp() public {
        vault = new Vault(bytes32("123"));
    }

    function test_get_slot_value() public view {
        for(uint i = 0; i< 8; i++) {
            bytes32 slotValue = vault.getSlotValue(i);
            console2.log("slot %s: ", i);
            console2.logBytes32(slotValue);
        }
    }

    function test_reveal_password() public view {
        bytes32 password = vault.getSlotValue(2);
        console2.logBytes32(password); //0x3132330000000000000000000000000000000000000000000000000000000000
        bytes memory myBytes = abi.encodePacked(password);
        string memory myString = string(myBytes);
        console2.log("password: %s", myString); //password: 123
    }
}

/**
slot初期値
count
owner
isTrue
u16
password
data
users
idToUser
Logs:
  slot 0: 
  0x000000000000000000000000000000000000000000000000000000000000007b
  slot 1: 
  0x000000000000000000001f017fa9385be102ac3eac297483dd6233d62b3e1496
  slot 2: 
  0x3132330000000000000000000000000000000000000000000000000000000000
  slot 3: 
  0x0000000000000000000000000000000000000000000000000000000000000000
  slot 4: 
  0x0000000000000000000000000000000000000000000000000000000000000000
  slot 5: 
  0x0000000000000000000000000000000000000000000000000000000000000000
  slot 6: 
  0x0000000000000000000000000000000000000000000000000000000000000000
  slot 7: 
  0x0000000000000000000000000000000000000000000000000000000000000000

*/


/**
forge inspect Vault storageLayout
でstorageの構成を調べられる。
"storage": [
    {
      "astId": 43353,
      "contract": "src/AccessPrivateData.sol:Vault",
      "label": "count",
      "offset": 0,
      "slot": "0",
      "type": "t_uint256"
    },
    {
      "astId": 43357,
      "contract": "src/AccessPrivateData.sol:Vault",
      "label": "owner",
      "offset": 0,
      "slot": "1",
      "type": "t_address"
    },
    {
      "astId": 43360,
      "contract": "src/AccessPrivateData.sol:Vault",
      "label": "isTrue",
      "offset": 20,
      "slot": "1",
      "type": "t_bool"
    },
    {
      "astId": 43363,
      "contract": "src/AccessPrivateData.sol:Vault",
      "label": "u16",
      "offset": 21,
      "slot": "1",
      "type": "t_uint16"
    },
    {
      "astId": 43365,
      "contract": "src/AccessPrivateData.sol:Vault",
      "label": "password",
      "offset": 0,
      "slot": "2",
      "type": "t_bytes32"
    },
    {
      "astId": 43372,
      "contract": "src/AccessPrivateData.sol:Vault",
      "label": "data",
      "offset": 0,
      "slot": "3",
      "type": "t_array(t_bytes32)3_storage"
    },
    {
      "astId": 43381,
      "contract": "src/AccessPrivateData.sol:Vault",
      "label": "users",
      "offset": 0,
      "slot": "6",
      "type": "t_array(t_struct(User)43377_storage)dyn_storage"
    },
    {
      "astId": 43386,
      "contract": "src/AccessPrivateData.sol:Vault",
      "label": "idToUser",
      "offset": 0,
      "slot": "7",
      "type": "t_mapping(t_uint256,t_struct(User)43377_storage)"
    }
  ]

 */