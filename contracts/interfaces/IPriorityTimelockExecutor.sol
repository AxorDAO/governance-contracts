// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.7.5;
pragma abicoder v2;

import { IAxorGovernor } from './IAxorGovernor.sol';
import { IExecutorWithTimelock } from './IExecutorWithTimelock.sol';

interface IPriorityTimelockExecutor is
  IExecutorWithTimelock
{
  /**
   * @dev Emitted when a priority controller is added or removed.
   *
   * @param  account               The address added or removed.
   * @param  isPriorityController  Whether the account is now a priority controller.
   */
  event PriorityControllerUpdated(
    address account,
    bool isPriorityController
  );

  /**
   * @dev Emitted when a new priority period is set.
   *
   * @param  priorityPeriod  New priority period.
   **/
  event NewPriorityPeriod(
    uint256 priorityPeriod
  );

  /**
   * @dev Emitted when an action is locked or unlocked for execution by a priority controller.
   *
   * @param  actionHash              Hash of the action.
   * @param  isUnlockedForExecution  Whether the proposal is executable during the priority period.
   */
  event UpdatedActionPriorityStatus(
    bytes32 actionHash,
    bool isUnlockedForExecution
  );
}
