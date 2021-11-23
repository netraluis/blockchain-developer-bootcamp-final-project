// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/security/PullPayment.sol";

contract Prueba is PullPayment {
  function probando(address dest, uint256 amount) public {
    _asyncTransfer( dest, amount);
  }
}