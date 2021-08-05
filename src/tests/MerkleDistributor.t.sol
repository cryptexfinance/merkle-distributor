// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.6;

import "../MerkleDistributor.sol";
import "../mocks/Ctx.sol";
import "ds-test/test.sol";

contract User {
   function doClaim(
      MerkleDistributor dist,
      uint256 index,
      address account,
      uint256 amount,
      bytes32[] memory merkleProof
   ) public returns (bool) {
      dist.claim(index, account, amount, merkleProof);
      return true;
   }
}

contract MerkleDistributorTest is DSTest {
   MerkleDistributor distributor;
   Ctx token;
   User user1;

   bytes32 merkleRoot =
      0xc3ac5fe0d8a8ce5f00939535eaf787781aa1b6452c8135d1b586ba453e0cdd08;
   address account1 = 0x097A3a6cE1D77a11Bda1AC40C08fDF9F6202103F;
   bytes32[] merkleProof1 = [
      bytes32(
         0x8ecc3ce8e823c7e7c24b0f71d3490a76a44680fe757a94e79550aba324920abe
      ),
      bytes32(
         0xd6f35d491811ec65b24916024828090dfb543e9557175e505e574e42eba17c56
      ),
      bytes32(
         0xe9d707c8df5e140a60827aa5a03438b1ca128dd5544a1c87831de9ff079aff50
      ),
      bytes32(
         0x5a1688427676a0e036b4ac7398b487d2f93460648f98d563251af38a3c2d516b
      ),
      bytes32(
         0xe3ff1a8f3847535eb97982790eab2ba7db25c8938790320fe5688a2c23cbc470
      ),
      bytes32(
         0x1c8e04a6d1325be4f1d46ffc390a7dd4e8174aab168d0460828ead4dd565bb71
      )
   ];
   address account2 = 0xFa6863A6507c94ed52e9276F8A72479924E77a36;
   bytes32[] merkleProof2 = [
      bytes32(
         0xddaf9711f68a616823e1c8e6bd03541db5d6ad9a9661d69f91064666adb7663a
      ),
      bytes32(
         0x446c16a1d7898ec72e06aaa2ed93345d64b3c5e1e0e642a25a52df7262dee4e2
      ),
      bytes32(
         0x23e327a76aa767c256278ef84f0bdcfddb91b59de4a01bab17b134fbc5290903
      ),
      bytes32(
         0x03a60593c88d940f93c4e7d6d416945b656243b8503ae832d84da2c8dca01d52
      ),
      bytes32(
         0xe3ff1a8f3847535eb97982790eab2ba7db25c8938790320fe5688a2c23cbc470
      ),
      bytes32(
         0x1c8e04a6d1325be4f1d46ffc390a7dd4e8174aab168d0460828ead4dd565bb71
      )
   ];

   function setUp() public {
      token = new Ctx(10_000_000 ether);
      user1 = new User();
      distributor = new MerkleDistributor(address(token), merkleRoot);
   }

   function invariants_values() public {
      assertEq(distributor.merkleRoot(), merkleRoot);
      assertEq(distributor.token(), address(token));
   }

   function testFail_invalidProof() public {
      bytes32[] memory invalidMerkleProof;
      token.transfer(address(distributor), 10_000 ether);
      distributor.claim(0, account1, 50 ether, invalidMerkleProof);
   }

   function testFail_noBalance() public {
      distributor.claim(0, account1, 50 ether, merkleProof1);
   }

   function test_claim() public {
      token.transfer(address(distributor), 10_000 ether);
      assert(distributor.isClaimed(0) == false);
      assertEq(token.balanceOf(account1), 0);
      distributor.claim(0, account1, 50 ether, merkleProof1);
      assertEq(token.balanceOf(account1), 50 ether);
      assertEq(
         token.balanceOf(address(distributor)),
         (10_000 ether - 50 ether)
      );
      assertTrue(distributor.isClaimed(0));
   }

   function test_claimFrom() public {
      token.transfer(address(distributor), 10_000 ether);
      assert(distributor.isClaimed(1) == false);
      assertEq(token.balanceOf(account2), 0);
      user1.doClaim(distributor, 1, account2, 100 ether, merkleProof2);
      assertEq(token.balanceOf(account2), 100 ether);
      assertEq(
         token.balanceOf(address(distributor)),
         (10_000 ether - 100 ether)
      );
      assertTrue(distributor.isClaimed(1));
   }

   function testFail_alreadyClaimed() public {
      token.transfer(address(distributor), 10_000 ether);
      distributor.claim(0, account1, 50 ether, merkleProof1);
      user1.doClaim(distributor, 0, account1, 50 ether, merkleProof1);
   }

   function testFail_timeNotPassed() public {}
}
