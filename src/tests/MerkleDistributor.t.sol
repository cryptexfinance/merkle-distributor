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
      0xf3e2ea4c235de14ee793f105dbb1f54a4be38543c2996f3ea8a163363961d109;
   address account1 = 0x0186Ac54Ba042Ed538f42a7b38BF15A22aE77b54;
   bytes32[] merkleProof1 = [
      bytes32(
         0x0d95bd07c647d4aba5ad5248d6ea86f689e0a85432ee3d3b549cc94801edb786
      ),
      bytes32(
         0xfcd53d74b98e933c02b3b3cf6b988f82c461a03e0cd3d35e5f632136997c1358
      ),
      bytes32(
         0x3d41e1190be9037773adad53ded577e7443778f5563e9dd79eee2dcd4f5db7b5
      ),
      bytes32(
         0x65539c5aac2bfb5dc477ccfdaf0ad8033945178bc4dae4ca8b86a0bc06bbecfd
      ),
      bytes32(
         0x7e5906b6b64e87a73a9791b39be31bc91fce0cc3a94f310c76026871757d08e5
      ),
      bytes32(
         0x8c980c8d7fef83dfd3e19c972ee3d28826cbbeb7f8107f31e56e16e805d600db
      ),
      bytes32(
         0x48e61261fdc7da92e379cbe77533b11d5c49750d04b208798f6d7774a8de265d
      ),
      bytes32(
         0xf3f0cc06e84f018ce89e529119dfe5d3435ff03d8d72cf85ccc94945cda29596
      )
   ];
   address account2 = 0x02Fd85e93f38660623F0E3228a319A0Dafab8901;
   bytes32[] merkleProof2 = [
      bytes32(
         0xd5f83ff4c6a8aeac795e6eb5299f189d1b3607c97d2437d8429b33ad8daa95ec
      ),
      bytes32(
         0xcaa3f5d0507f2afd15a0ceeb98651a72787d45010683f4904d2320e37649ca27
      ),
      bytes32(
         0x868f547c5f517c4a7431baf4f2c63a9eee71159a37b7228b7ca503e8420b69bd
      ),
      bytes32(
         0x0dfa4119ebd28170dc436f4b1e0ec0292cf402eb443713cd0e66b8bec9b717bb
      ),
      bytes32(
         0xc818964e0b2b91dcaa9806e807da3cb7fd7ecc97daced9830ea2e8515a6500ff
      ),
      bytes32(
         0x49378176c3d375977f0cfea5ea21c593ae4ccf0dca8144bd77119ead42bb060c
      ),
      bytes32(
         0x047fe3d4474b8e980fc72bca8f3e338b722c49b5124a4d4948d30d2313cc1a8b
      ),
      bytes32(
         0xf3f0cc06e84f018ce89e529119dfe5d3435ff03d8d72cf85ccc94945cda29596
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
      assertEq(distributor.timeout(), 4 weeks);
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
