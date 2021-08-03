// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleDistributor {
   address public immutable override token;
   bytes32 public immutable override merkleRoot;
   // This is a packed array of booleans.
   mapping(uint256 => uint256) private claimedBitMap;

   constructor(address token_, bytes32 merkleRoot_) public {
      token = token_;
      merkleRoot = merkleRoot_;
   }
}
