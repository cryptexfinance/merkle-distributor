// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "openzeppelin/token/ERC20/ERC20.sol";

contract Ctx is ERC20 {
   constructor(uint256 initialSupply) ERC20("Cryptex", "Ctx") {
      _mint(msg.sender, initialSupply);
   }
}
