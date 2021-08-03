// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "../MerkleDistributor.sol";
import "../../lib/ds-test/src/test.sol";

contract MerkleDistributorTest is DSTest {
   MerkleDistributor distributor;
   bytes32 merkleRoot = "";
   bytes32 token = "0x321c2fe4446c7c963dc41dd58879af648838f98d";

   function setUp() public {
      distributor = new MerkleDistributor(merkleRoot, token);
   }

   function invariant_values() {
      assertEq(distributor.merkleRoot(), merkleRoot);
      assertEq(distributor.token(), token);
   }

   function test_claim() public {}

   function testFail_basic_sanity() public {
      assertTrue(false);
   }

   function test_basic_sanity() public {
      assertTrue(true);
   }
}
