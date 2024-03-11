// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.7.5;
pragma abicoder v2;

import { IERC20 } from '../interfaces/IERC20.sol';
import { SafetyModuleV1 } from '../safety/v1/SafetyModuleV1.sol';

contract MockSafetyModuleSubclass is SafetyModuleV1 {
  constructor(
    IERC20 stakedToken,
    IERC20 rewardsToken,
    address rewardsTreasury,
    uint256 distributionStart,
    uint256 distributionEnd
  )
    SafetyModuleV1(
      stakedToken,
      rewardsToken,
      rewardsTreasury,
      distributionStart,
      distributionEnd
    )
  {}

  function mockTransferFromZero(
    address recipient,
    uint256 amount
  )
    external
  {
    _transfer(address(0), recipient, amount);
  }

  function mockApproveFromZero(
    address spender,
    uint256 amount
  )
    external
  {
    _approve(address(0), spender, amount);
  }
}
