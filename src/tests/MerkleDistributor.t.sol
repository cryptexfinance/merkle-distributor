// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.6;

import "../MerkleDistributor.sol";
import "../mocks/Ctx.sol";
import "ds-test/test.sol";
import "ds-test/hevm.sol";

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

   function doWithdrawn(MerkleDistributor dist) public returns (bool) {
      dist.endAirdrop();
      return true;
   }
}

contract MerkleDistributorTest is DSTest {
   MerkleDistributor distributor;
   Ctx token;
   User user1;
   Hevm hevm;

   address treasury = 0xa54074b2cc0e96a43048d4a68472F7F046aC0DA8;
   bytes32 merkleRoot =
      0x7cb4c259a57584fa8dbcf791cbcfe4b775e1b9aad918cfe2f0b7220d22bf7f84;
   address account1 = 0x1FdD5814d3d23fBF93849B530c825eAd5f83D63f;
   bytes32[] merkleProof1 = [
      bytes32(
         0xc981948a9e5913fae75b920010feef51e488c21b8b6194bf19154c3160f860b5
      ),
      bytes32(
         0x614c79ec9fc36857d7d56355335a2e6a552059cd309a540bf9d2a1500ea4a90e
      ),
      bytes32(
         0xcddf56f5cb27d946efcc7988c5520a24e219f0b10d6d8370f395a643fe51ab2c
      ),
      bytes32(
         0xc00b04023b8f4c27b568bfdd29efaf223f519d5c8266bd2dd47b021d27e2bfb5
      ),
      bytes32(
         0x6fc7dfa5adc4bf28739a464e646ca32a77ff49943eed06f9be5e92cabfbd90af
      ),
      bytes32(
         0xb910bb330ad5be1b0dae32daf283e9510a951530b9d94e9688fb81a74dc0e999
      ),
      bytes32(
         0x394a45ebafd54ac2de62e6aabe3f347eeb77f827d6012f3e5f5677624111f13b
      ),
      bytes32(
         0xeba6587c99653ffcbecb9a46fafd71d6bbd106aae746051e5226bc748cef96c1
      )
   ];
   address account2 = 0x76927E2CCAb0084BD19cEe74F78B63134b9d181E;
   bytes32[] merkleProof2 = [
      bytes32(
         0xc7a19c791a34139e40d5c7103a29686c24d3f39fd8daa7bf6425474cdcf7b6ef
      ),
      bytes32(
         0xdc440cf833902884f12587d2118ddb26bd0df73fb2f50779a889d9d78573b6b6
      ),
      bytes32(
         0xcddf56f5cb27d946efcc7988c5520a24e219f0b10d6d8370f395a643fe51ab2c
      ),
      bytes32(
         0xc00b04023b8f4c27b568bfdd29efaf223f519d5c8266bd2dd47b021d27e2bfb5
      ),
      bytes32(
         0x6fc7dfa5adc4bf28739a464e646ca32a77ff49943eed06f9be5e92cabfbd90af
      ),
      bytes32(
         0xb910bb330ad5be1b0dae32daf283e9510a951530b9d94e9688fb81a74dc0e999
      ),
      bytes32(
         0x394a45ebafd54ac2de62e6aabe3f347eeb77f827d6012f3e5f5677624111f13b
      ),
      bytes32(
         0xeba6587c99653ffcbecb9a46fafd71d6bbd106aae746051e5226bc748cef96c1
      )
   ];

   function setUp() public {
      hevm = Hevm(HEVM_ADDRESS);
      token = new Ctx(10_000_000 ether);
      user1 = new User();
      distributor = new MerkleDistributor(address(token), merkleRoot, treasury);
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
      user1.doClaim(distributor, 1, account2, 50 ether, merkleProof2);
      assertEq(token.balanceOf(account2), 50 ether);
      assertEq(
         token.balanceOf(address(distributor)),
         (10_000 ether - 50 ether)
      );
      assertTrue(distributor.isClaimed(1));
   }

   function testFail_alreadyClaimed() public {
      token.transfer(address(distributor), 10_000 ether);
      distributor.claim(0, account1, 50 ether, merkleProof1);
      user1.doClaim(distributor, 0, account1, 50 ether, merkleProof1);
   }

   function testFail_endAirdrop() public {
      token.transfer(address(distributor), 10_000 ether);
      distributor.endAirdrop();
   }

   function test_endAirdrop() public {
      assertEq(token.balanceOf(treasury), 0);
      token.transfer(address(distributor), 10_000 ether);
      hevm.warp(4 weeks + 1 seconds);
      distributor.endAirdrop();
      assertEq(token.balanceOf(address(distributor)), 0);
      assertEq(token.balanceOf(treasury), 10_000 ether);
   }
}
