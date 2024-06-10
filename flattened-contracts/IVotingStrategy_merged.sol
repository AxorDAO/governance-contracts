pragma solidity 0.7.5;
pragma abicoder v2;


// SPDX-License-Identifier: AGPL-3.0
interface IVotingStrategy {
  function getVotingPowerAt(address user, uint256 blockNumber) external view returns (uint256);
}