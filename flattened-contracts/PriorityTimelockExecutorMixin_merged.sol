pragma solidity 0.7.5;
pragma abicoder v2;


library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, 'SafeMath: modulo by zero');
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

interface IExecutorWithTimelock {
  /**
   * @dev emitted when a new pending admin is set
   * @param newPendingAdmin address of the new pending admin
   **/
  event NewPendingAdmin(address newPendingAdmin);

  /**
   * @dev emitted when a new admin is set
   * @param newAdmin address of the new admin
   **/
  event NewAdmin(address newAdmin);

  /**
   * @dev emitted when a new delay (between queueing and execution) is set
   * @param delay new delay
   **/
  event NewDelay(uint256 delay);

  /**
   * @dev emitted when a new (trans)action is Queued.
   * @param actionHash hash of the action
   * @param target address of the targeted contract
   * @param value wei value of the transaction
   * @param signature function signature of the transaction
   * @param data function arguments of the transaction or callData if signature empty
   * @param executionTime time at which to execute the transaction
   * @param withDelegatecall boolean, true = transaction delegatecalls the target, else calls the target
   **/
  event QueuedAction(
    bytes32 actionHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 executionTime,
    bool withDelegatecall
  );

  /**
   * @dev emitted when an action is Cancelled
   * @param actionHash hash of the action
   * @param target address of the targeted contract
   * @param value wei value of the transaction
   * @param signature function signature of the transaction
   * @param data function arguments of the transaction or callData if signature empty
   * @param executionTime time at which to execute the transaction
   * @param withDelegatecall boolean, true = transaction delegatecalls the target, else calls the target
   **/
  event CancelledAction(
    bytes32 actionHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 executionTime,
    bool withDelegatecall
  );

  /**
   * @dev emitted when an action is Cancelled
   * @param actionHash hash of the action
   * @param target address of the targeted contract
   * @param value wei value of the transaction
   * @param signature function signature of the transaction
   * @param data function arguments of the transaction or callData if signature empty
   * @param executionTime time at which to execute the transaction
   * @param withDelegatecall boolean, true = transaction delegatecalls the target, else calls the target
   * @param resultData the actual callData used on the target
   **/
  event ExecutedAction(
    bytes32 actionHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 executionTime,
    bool withDelegatecall,
    bytes resultData
  );

  /**
   * @dev Getter of the current admin address (should be governance)
   * @return The address of the current admin
   **/
  function getAdmin() external view returns (address);

  /**
   * @dev Getter of the current pending admin address
   * @return The address of the pending admin
   **/
  function getPendingAdmin() external view returns (address);

  /**
   * @dev Getter of the delay between queuing and execution
   * @return The delay in seconds
   **/
  function getDelay() external view returns (uint256);

  /**
   * @dev Returns whether an action (via actionHash) is queued
   * @param actionHash hash of the action to be checked
   * keccak256(abi.encode(target, value, signature, data, executionTime, withDelegatecall))
   * @return true if underlying action of actionHash is queued
   **/
  function isActionQueued(bytes32 actionHash) external view returns (bool);

  /**
   * @dev Checks whether a proposal is over its grace period
   * @param governance Governance contract
   * @param proposalId Id of the proposal against which to test
   * @return true of proposal is over grace period
   **/
  function isProposalOverGracePeriod(IAxorGovernor governance, uint256 proposalId)
    external
    view
    returns (bool);

  /**
   * @dev Getter of grace period constant
   * @return grace period in seconds
   **/
  function GRACE_PERIOD() external view returns (uint256);

  /**
   * @dev Getter of minimum delay constant
   * @return minimum delay in seconds
   **/
  function MINIMUM_DELAY() external view returns (uint256);

  /**
   * @dev Getter of maximum delay constant
   * @return maximum delay in seconds
   **/
  function MAXIMUM_DELAY() external view returns (uint256);

  /**
   * @dev Function, called by Governance, that queue a transaction, returns action hash
   * @param target smart contract target
   * @param value wei value of the transaction
   * @param signature function signature of the transaction
   * @param data function arguments of the transaction or callData if signature empty
   * @param executionTime time at which to execute the transaction
   * @param withDelegatecall boolean, true = transaction delegatecalls the target, else calls the target
   **/
  function queueTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) external returns (bytes32);

  /**
   * @dev Function, called by Governance, that executes a transaction, returns the callData executed
   * @param target smart contract target
   * @param value wei value of the transaction
   * @param signature function signature of the transaction
   * @param data function arguments of the transaction or callData if signature empty
   * @param executionTime time at which to execute the transaction
   * @param withDelegatecall boolean, true = transaction delegatecalls the target, else calls the target
   **/
  function executeTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) external payable returns (bytes memory);

  /**
   * @dev Function, called by Governance, that cancels a transaction, returns action hash
   * @param target smart contract target
   * @param value wei value of the transaction
   * @param signature function signature of the transaction
   * @param data function arguments of the transaction or callData if signature empty
   * @param executionTime time at which to execute the transaction
   * @param withDelegatecall boolean, true = transaction delegatecalls the target, else calls the target
   **/
  function cancelTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) external returns (bytes32);
}

interface IAxorGovernor {

  enum ProposalState {
    Pending,
    Canceled,
    Active,
    Failed,
    Succeeded,
    Queued,
    Expired,
    Executed
  }

  struct Vote {
    bool support;
    uint248 votingPower;
  }

  struct Proposal {
    uint256 id;
    address creator;
    IExecutorWithTimelock executor;
    address[] targets;
    uint256[] values;
    string[] signatures;
    bytes[] calldatas;
    bool[] withDelegatecalls;
    uint256 startBlock;
    uint256 endBlock;
    uint256 executionTime;
    uint256 forVotes;
    uint256 againstVotes;
    bool executed;
    bool canceled;
    address strategy;
    bytes32 ipfsHash;
    mapping(address => Vote) votes;
  }

  struct ProposalWithoutVotes {
    uint256 id;
    address creator;
    IExecutorWithTimelock executor;
    address[] targets;
    uint256[] values;
    string[] signatures;
    bytes[] calldatas;
    bool[] withDelegatecalls;
    uint256 startBlock;
    uint256 endBlock;
    uint256 executionTime;
    uint256 forVotes;
    uint256 againstVotes;
    bool executed;
    bool canceled;
    address strategy;
    bytes32 ipfsHash;
  }

  /**
   * @dev emitted when a new proposal is created
   * @param id Id of the proposal
   * @param creator address of the creator
   * @param executor The ExecutorWithTimelock contract that will execute the proposal
   * @param targets list of contracts called by proposal's associated transactions
   * @param values list of value in wei for each propoposal's associated transaction
   * @param signatures list of function signatures (can be empty) to be used when created the callData
   * @param calldatas list of calldatas: if associated signature empty, calldata ready, else calldata is arguments
   * @param withDelegatecalls boolean, true = transaction delegatecalls the taget, else calls the target
   * @param startBlock block number when vote starts
   * @param endBlock block number when vote ends
   * @param strategy address of the governanceStrategy contract
   * @param ipfsHash IPFS hash of the proposal
   **/
  event ProposalCreated(
    uint256 id,
    address indexed creator,
    IExecutorWithTimelock indexed executor,
    address[] targets,
    uint256[] values,
    string[] signatures,
    bytes[] calldatas,
    bool[] withDelegatecalls,
    uint256 startBlock,
    uint256 endBlock,
    address strategy,
    bytes32 ipfsHash
  );

  /**
   * @dev emitted when a proposal is canceled
   * @param id Id of the proposal
   **/
  event ProposalCanceled(uint256 id);

  /**
   * @dev emitted when a proposal is queued
   * @param id Id of the proposal
   * @param executionTime time when proposal underlying transactions can be executed
   * @param initiatorQueueing address of the initiator of the queuing transaction
   **/
  event ProposalQueued(uint256 id, uint256 executionTime, address indexed initiatorQueueing);
  /**
   * @dev emitted when a proposal is executed
   * @param id Id of the proposal
   * @param initiatorExecution address of the initiator of the execution transaction
   **/
  event ProposalExecuted(uint256 id, address indexed initiatorExecution);
  /**
   * @dev emitted when a vote is registered
   * @param id Id of the proposal
   * @param voter address of the voter
   * @param support boolean, true = vote for, false = vote against
   * @param votingPower Power of the voter/vote
   **/
  event VoteEmitted(uint256 id, address indexed voter, bool support, uint256 votingPower);

  event GovernanceStrategyChanged(address indexed newStrategy, address indexed initiatorChange);

  event VotingDelayChanged(uint256 newVotingDelay, address indexed initiatorChange);

  event ExecutorAuthorized(address executor);

  event ExecutorUnauthorized(address executor);

  /**
   * @dev Creates a Proposal (needs Proposition Power of creator > Threshold)
   * @param executor The ExecutorWithTimelock contract that will execute the proposal
   * @param targets list of contracts called by proposal's associated transactions
   * @param values list of value in wei for each propoposal's associated transaction
   * @param signatures list of function signatures (can be empty) to be used when created the callData
   * @param calldatas list of calldatas: if associated signature empty, calldata ready, else calldata is arguments
   * @param withDelegatecalls if true, transaction delegatecalls the taget, else calls the target
   * @param ipfsHash IPFS hash of the proposal
   **/
  function create(
    IExecutorWithTimelock executor,
    address[] memory targets,
    uint256[] memory values,
    string[] memory signatures,
    bytes[] memory calldatas,
    bool[] memory withDelegatecalls,
    bytes32 ipfsHash
  ) external returns (uint256);

  /**
   * @dev Cancels a Proposal, when proposal is Pending/Active and threshold no longer reached
   * @param proposalId id of the proposal
   **/
  function cancel(uint256 proposalId) external;

  /**
   * @dev Queue the proposal (If Proposal Succeeded)
   * @param proposalId id of the proposal to queue
   **/
  function queue(uint256 proposalId) external;

  /**
   * @dev Execute the proposal (If Proposal Queued)
   * @param proposalId id of the proposal to execute
   **/
  function execute(uint256 proposalId) external payable;

  /**
   * @dev Function allowing msg.sender to vote for/against a proposal
   * @param proposalId id of the proposal
   * @param support boolean, true = vote for, false = vote against
   **/
  function submitVote(uint256 proposalId, bool support) external;

  /**
   * @dev Function to register the vote of user that has voted offchain via signature
   * @param proposalId id of the proposal
   * @param support boolean, true = vote for, false = vote against
   * @param v v part of the voter signature
   * @param r r part of the voter signature
   * @param s s part of the voter signature
   **/
  function submitVoteBySignature(
    uint256 proposalId,
    bool support,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  /**
   * @dev Set new GovernanceStrategy
   * Note: owner should be a timelocked executor, so needs to make a proposal
   * @param governanceStrategy new Address of the GovernanceStrategy contract
   **/
  function setGovernanceStrategy(address governanceStrategy) external;

  /**
   * @dev Set new Voting Delay (delay before a newly created proposal can be voted on)
   * Note: owner should be a timelocked executor, so needs to make a proposal
   * @param votingDelay new voting delay in seconds
   **/
  function setVotingDelay(uint256 votingDelay) external;

  /**
   * @dev Add new addresses to the list of authorized executors
   * @param executors list of new addresses to be authorized executors
   **/
  function authorizeExecutors(address[] memory executors) external;

  /**
   * @dev Remove addresses to the list of authorized executors
   * @param executors list of addresses to be removed as authorized executors
   **/
  function unauthorizeExecutors(address[] memory executors) external;

  /**
   * @dev Getter of the current GovernanceStrategy address
   * @return The address of the current GovernanceStrategy contracts
   **/
  function getGovernanceStrategy() external view returns (address);

  /**
   * @dev Getter of the current Voting Delay (delay before a created proposal can be voted on)
   * Different from the voting duration
   * @return The voting delay in seconds
   **/
  function getVotingDelay() external view returns (uint256);

  /**
   * @dev Returns whether an address is an authorized executor
   * @param executor address to evaluate as authorized executor
   * @return true if authorized
   **/
  function isExecutorAuthorized(address executor) external view returns (bool);

  /**
   * @dev Getter of the proposal count (the current number of proposals ever created)
   * @return the proposal count
   **/
  function getProposalsCount() external view returns (uint256);

  /**
   * @dev Getter of a proposal by id
   * @param proposalId id of the proposal to get
   * @return the proposal as ProposalWithoutVotes memory object
   **/
  function getProposalById(uint256 proposalId) external view returns (ProposalWithoutVotes memory);

  /**
   * @dev Getter of the Vote of a voter about a proposal
   * Note: Vote is a struct: ({bool support, uint248 votingPower})
   * @param proposalId id of the proposal
   * @param voter address of the voter
   * @return The associated Vote memory object
   **/
  function getVoteOnProposal(uint256 proposalId, address voter) external view returns (Vote memory);

  /**
   * @dev Get the current state of a proposal
   * @param proposalId id of the proposal
   * @return The current state if the proposal
   **/
  function getProposalState(uint256 proposalId) external view returns (ProposalState);
}

interface IPriorityTimelockExecutor is
  IExecutorWithTimelock {
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

// SPDX-License-Identifier: AGPL-3.0
/**
 * @title PriorityTimelockExecutorMixin
 * @author Axor
 *
 * @notice Time-locked executor contract mixin, inherited by the PriorityExecutor contract.
 *
 *  This contract adds the priority period and priority controller features to the
 *  ExecutorWithTimelockMixin contract.
 *
 *  Each governance proposal contains information about one or more proposed transactions. This
 *  contract is responsible for queueing, executing, and/or canceling the transactions of
 *  successful proposals. Once a transaction is queued, it can be executed after the delay has
 *  elapsed, as long as the grace period has not expired.
 */
contract PriorityTimelockExecutorMixin is
  IPriorityTimelockExecutor {
  using SafeMath for uint256;

  // ============ Constants ============

  /// @notice Period of time after `_delay` in which a proposal can be executed, in seconds.
  uint256 public immutable override GRACE_PERIOD;

  /// @notice Minimum allowed `_delay`, inclusive, in seconds.
  uint256 public immutable override MINIMUM_DELAY;

  /// @notice Maximum allowed `_delay`, inclusive, in seconds.
  uint256 public immutable override MAXIMUM_DELAY;

  // ============ Storage ============

  /// @dev The address which may queue, executed, and cancel transactions. This should be set to
  ///  the governor contract address.
  address internal _admin;

  /// @dev Pending admin, which must call acceptAdmin() in order to become the admin.
  address internal _pendingAdmin;

  /// @dev Addresses which may unlock proposals for execution during the priority period.
  mapping(address => bool) private _isPriorityController;

  /// @dev Minimum time between queueing and execution of a proposal, in seconds.
  uint256 internal _delay;

  /// @dev Time at end of the delay period during which priority controllers may unlock
  ///  transactions for early execution, in seconds.
  uint256 private _priorityPeriod;

  mapping(bytes32 => bool) private _queuedTransactions;
  mapping(bytes32 => bool) private _priorityUnlockedTransactions;

  // ============ Constructor ============

  /**
   * @notice Constructor.
   *
   * @param  admin               The address which may queue, executed, and cancel transactions.
   *                             THis should be set to the governor contract address.
   * @param  delay               Minimum time between queueing and execution of a proposal, seconds.
   * @param  gracePeriod         Period of time after `_delay` in which a proposal can be executed,
   *                             in seconds.
   * @param  minimumDelay        Minimum allowed `_delay`, inclusive, in seconds.
   * @param  maximumDelay        Maximum allowed `_delay`, inclusive, in seconds.
   * @param  priorityPeriod      Time at end of the delay period during which priority controllers
   *                             may unlock transactions for early execution, in seconds.
   * @param  priorityController  Addresses which may unlock proposals for execution during the
   *                             priority period.
   */
  constructor(
    address admin,
    uint256 delay,
    uint256 gracePeriod,
    uint256 minimumDelay,
    uint256 maximumDelay,
    uint256 priorityPeriod,
    address priorityController
  ) {
    require(
      delay >= minimumDelay,
      'DELAY_SHORTER_THAN_MINIMUM'
    );
    require(
      delay <= maximumDelay,
      'DELAY_LONGER_THAN_MAXIMUM'
    );
    _validatePriorityPeriod(delay, priorityPeriod);
    _delay = delay;
    _priorityPeriod = priorityPeriod;
    _admin = admin;

    GRACE_PERIOD = gracePeriod;
    MINIMUM_DELAY = minimumDelay;
    MAXIMUM_DELAY = maximumDelay;

    emit NewDelay(delay);
    emit NewPriorityPeriod(priorityPeriod);
    emit NewAdmin(admin);

    _updatePriorityController(priorityController, true);
  }

  // ============ Modifiers ============

  modifier onlyAdmin() {
    require(
      msg.sender == _admin,
      'ONLY_BY_ADMIN'
    );
    _;
  }

  modifier onlyTimelock() {
    require(
      msg.sender == address(this),
      'ONLY_BY_THIS_TIMELOCK'
    );
    _;
  }

  modifier onlyPendingAdmin() {
    require(
      msg.sender == _pendingAdmin,
      'ONLY_BY_PENDING_ADMIN'
    );
    _;
  }

  modifier onlyPriorityController() {
    require(
      _isPriorityController[msg.sender],
      'ONLY_BY_PRIORITY_CONTROLLER'
    );
    _;
  }

  // ============ External and Public Functions ============

  /**
   * @notice Set the delay.
   *
   * @param  delay  Minimum time between queueing and execution of a proposal.
   */
  function setDelay(
    uint256 delay
  )
    public
    onlyTimelock
  {
    _validateDelay(delay);
    _validatePriorityPeriod(delay, _priorityPeriod);
    _delay = delay;
    emit NewDelay(delay);
  }

  /**
   * @notice Set the priority period.
   *
   * @param  priorityPeriod  Time at end of the delay period during which priority controllers may
   *                         unlock transactions for early execution, in seconds.
   */
  function setPriorityPeriod(
    uint256 priorityPeriod
  )
    public
    onlyTimelock
  {
    _validatePriorityPeriod(_delay, priorityPeriod);
    _priorityPeriod = priorityPeriod;
    emit NewPriorityPeriod(priorityPeriod);
  }

  /**
   * @notice Callable by a pending admin to become the admin.
   */
  function acceptAdmin()
    public
    onlyPendingAdmin
  {
    _admin = msg.sender;
    _pendingAdmin = address(0);
    emit NewAdmin(msg.sender);
  }

  /**
   * @notice Set the new pending admin. Can only be called by this executor (i.e. via a proposal).
   *
   * @param  newPendingAdmin  Address of the new admin.
   */
  function setPendingAdmin(
    address newPendingAdmin
  )
    public
    onlyTimelock
  {
    _pendingAdmin = newPendingAdmin;
    emit NewPendingAdmin(newPendingAdmin);
  }

  /**
   * @dev Add or remove a priority controller.
   */
  function updatePriorityController(
    address account,
    bool isPriorityController
  )
    public
    onlyTimelock
  {
    _updatePriorityController(account, isPriorityController);
  }

  /**
   * @notice Called by the admin (i.e. governor) to enqueue a transaction. Returns the action hash.
   *
   * @param  target            Smart contract target of the transaction.
   * @param  value             Value to send with the transaction, in wei.
   * @param  signature         Function signature of the transaction (optional).
   * @param  data              Function arguments of the transaction, or the full calldata if
   *                           the `signature` param is empty.
   * @param  executionTime     Time at which the transaction should become executable.
   * @param  withDelegatecall  Boolean `true` if delegatecall should be used instead of call.
   *
   * @return The action hash of the enqueued transaction.
   */
  function queueTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  )
    public
    override
    onlyAdmin
    returns (bytes32)
  {
    require(
      executionTime >= block.timestamp.add(_delay),
      'EXECUTION_TIME_UNDERESTIMATED'
    );

    bytes32 actionHash = keccak256(
      abi.encode(target, value, signature, data, executionTime, withDelegatecall)
    );
    _queuedTransactions[actionHash] = true;

    emit QueuedAction(actionHash, target, value, signature, data, executionTime, withDelegatecall);
    return actionHash;
  }

  /**
   * @notice Called by the admin (i.e. governor) to cancel a transaction. Returns the action hash.
   *
   * @param  target            Smart contract target of the transaction.
   * @param  value             Value to send with the transaction, in wei.
   * @param  signature         Function signature of the transaction (optional).
   * @param  data              Function arguments of the transaction, or the full calldata if
   *                           the `signature` param is empty.
   * @param  executionTime     Time at which the transaction should become executable.
   * @param  withDelegatecall  Boolean `true` if delegatecall should be used instead of call.
   *
   * @return The action hash of the canceled transaction.
   */
  function cancelTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  )
    public
    override
    onlyAdmin
    returns (bytes32)
  {
    bytes32 actionHash = keccak256(
      abi.encode(target, value, signature, data, executionTime, withDelegatecall)
    );
    _queuedTransactions[actionHash] = false;

    emit CancelledAction(
      actionHash,
      target,
      value,
      signature,
      data,
      executionTime,
      withDelegatecall
    );
    return actionHash;
  }

  /**
   * @dev Called by the admin (i.e. governor) to execute a transaction. Returns the result.
   *
   * @param  target            Smart contract target of the transaction.
   * @param  value             Value to send with the transaction, in wei.
   * @param  signature         Function signature of the transaction (optional).
   * @param  data              Function arguments of the transaction, or the full calldata if
   *                           the `signature` param is empty.
   * @param  executionTime     Time at which the transaction should become executable.
   * @param  withDelegatecall  Boolean `true` if delegatecall should be used instead of call.
   *
   * @return The result of the transaction call.
   */
  function executeTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  )
    public
    payable
    override
    onlyAdmin
    returns (bytes memory)
  {
    bytes32 actionHash = keccak256(abi.encode(
      target,
      value,
      signature,
      data,
      executionTime,
      withDelegatecall
    ));
    require(
      _queuedTransactions[actionHash],
      'ACTION_NOT_QUEUED'
    );
    require(
      block.timestamp <= executionTime.add(GRACE_PERIOD),
      'GRACE_PERIOD_FINISHED'
    );

    // Require that either:
    //  - The timelock elapsed; OR
    //  - The transaction was unlocked by a priority controller, and we are in the priority
    //    execution window.
    if (_priorityUnlockedTransactions[actionHash]) {
      require(
        block.timestamp >= executionTime.sub(_priorityPeriod),
        'NOT_IN_PRIORITY_WINDOW'
      );
    } else {
      require(
        block.timestamp >= executionTime,
        'TIMELOCK_NOT_FINISHED'
      );
    }

    _queuedTransactions[actionHash] = false;

    bytes memory callData;

    if (bytes(signature).length == 0) {
      callData = data;
    } else {
      callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
    }

    bool success;
    bytes memory resultData;
    if (withDelegatecall) {
      require(
        msg.value >= value,
        'NOT_ENOUGH_MSG_VALUE'
      );
      (success, resultData) = target.delegatecall(callData);
    } else {
      (success, resultData) = target.call{value: value}(callData);
    }

    require(
      success,
      'FAILED_ACTION_EXECUTION'
    );

    emit ExecutedAction(
      actionHash,
      target,
      value,
      signature,
      data,
      executionTime,
      withDelegatecall,
      resultData
    );

    return resultData;
  }

  /**
   * @notice Function, called by a priority controller, to lock or unlock a proposal for execution
   *  during the priority period.
   *
   * @param  actionHash              Hash of the action.
   * @param  isUnlockedForExecution  Whether the proposal is executable during the priority period.
   */
  function setTransactionPriorityStatus(
    bytes32 actionHash,
    bool isUnlockedForExecution
  )
    public
    onlyPriorityController
  {
    require(
      _queuedTransactions[actionHash],
      'ACTION_NOT_QUEUED'
    );
    _priorityUnlockedTransactions[actionHash] = isUnlockedForExecution;
    emit UpdatedActionPriorityStatus(actionHash, isUnlockedForExecution);
  }

  /**
   * @notice Get the current admin address (should be the governor contract).
   *
   * @return The address of the current admin.
   */
  function getAdmin()
    external
    view
    override
    returns (address)
  {
    return _admin;
  }

  /**
   * @notice Get the current pending admin address.
   *
   * @return The address of the pending admin.
   */
  function getPendingAdmin()
    external
    view
    override
    returns (address)
  {
    return _pendingAdmin;
  }

  /**
   * @notice Get the minimum time between queueing and execution of a proposal.
   *
   * @return The delay, in seconds.
   */
  function getDelay()
    external
    view
    override
    returns (uint256)
  {
    return _delay;
  }

  /**
   * @notice Get the priority period, which is the period of time before the end of the timelock
   *  delay during which a transaction can be unlocked for early execution by a priority controller.
   *
   * @return The priority period in seconds.
   */
  function getPriorityPeriod()
    external
    view
    returns (uint256)
  {
    return _priorityPeriod;
  }

  /**
   * @notice Check whether an address is a priority controller.
   *
   * @param  account  Address to check.
   *
   * @return Boolean `true` if `account` is a priority controller, otherwise `false`.
   */
  function isPriorityController(
    address account
  )
    external
    view
    returns (bool)
  {
    return _isPriorityController[account];
  }

  /**
   * @notice Check whether a given action is queued.
   *
   * @param  actionHash  Hash of the action to be checked. Calculated as keccak256(abi.encode(
   *                     target, value, signature, data, executionTime, withDelegatecall)).
   *
   * @return Boolean `true` if the underlying action of `actionHash` is queued, otherwise `false`.
   */
  function isActionQueued(
    bytes32 actionHash
  )
    external
    view
    override
    returns (bool)
  {
    return _queuedTransactions[actionHash];
  }

  /**
   * @notice Check whether an action is unlocked for early execution during the priority period.
   *
   * @param  actionHash  Hash of the action to be checked. Calculated as keccak256(abi.encode(
   *                     target, value, signature, data, executionTime, withDelegatecall)).
   *
   * @return Boolean `true` if the underlying action of `actionHash` is unlocked, otherwise `false`.
   */
  function hasPriorityStatus(
    bytes32 actionHash
  )
    external
    view
    returns (bool)
  {
    return _priorityUnlockedTransactions[actionHash];
  }


  /**
   * @notice Check whether a proposal has exceeded its grace period.
   *
   * @param  governor    The governor contract.
   * @param  proposalId  ID of the proposal to check.
   *
   * @return Boolean `true` if proposal has exceeded its grace period, otherwise `false`.
   */
  function isProposalOverGracePeriod(
    IAxorGovernor governor,
    uint256 proposalId
  )
    external
    view
    override
    returns (bool)
  {
    IAxorGovernor.ProposalWithoutVotes memory proposal = governor.getProposalById(proposalId);

    return block.timestamp > proposal.executionTime.add(GRACE_PERIOD);
  }

  // ============ Internal Functions ============

  function _updatePriorityController(
    address account,
    bool isPriorityController
  )
    internal
  {
    _isPriorityController[account] = isPriorityController;
    emit PriorityControllerUpdated(account, isPriorityController);
  }

  function _validateDelay(
    uint256 delay
  )
    internal
    view
  {
    require(
      delay >= MINIMUM_DELAY,
      'DELAY_SHORTER_THAN_MINIMUM'
    );
    require(
      delay <= MAXIMUM_DELAY,
      'DELAY_LONGER_THAN_MAXIMUM'
    );
  }

  function _validatePriorityPeriod(
    uint256 delay,
    uint256 priorityPeriod
  )
    internal
    view
  {
    require(
      priorityPeriod <= delay,
      'PRIORITY_PERIOD_LONGER_THAN_DELAY'
    );
  }

  // ============ Receive Function ============

  receive()
    external
    payable
  {}
}