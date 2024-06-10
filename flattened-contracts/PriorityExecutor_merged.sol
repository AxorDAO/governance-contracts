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

interface IGovernanceStrategy {

  /**
   * @dev Returns the Proposition Power of a user at a specific block number.
   * @param user Address of the user.
   * @param blockNumber Blocknumber at which to fetch Proposition Power
   * @return Power number
   **/
  function getPropositionPowerAt(address user, uint256 blockNumber) external view returns (uint256);

  /**
   * @dev Returns the total supply of Outstanding Proposition Tokens
   * @param blockNumber Blocknumber at which to evaluate
   * @return total supply at blockNumber
   **/
  function getTotalPropositionSupplyAt(uint256 blockNumber) external view returns (uint256);

  /**
   * @dev Returns the total supply of Outstanding Voting Tokens
   * @param blockNumber Blocknumber at which to evaluate
   * @return total supply at blockNumber
   **/
  function getTotalVotingSupplyAt(uint256 blockNumber) external view returns (uint256);

  /**
   * @dev Returns the Vote Power of a user at a specific block number.
   * @param user Address of the user.
   * @param blockNumber Blocknumber at which to fetch Vote Power
   * @return Vote number
   **/
  function getVotingPowerAt(address user, uint256 blockNumber) external view returns (uint256);
}

interface IProposalValidator {

  /**
   * @dev Called to validate a proposal (e.g when creating new proposal in Governance)
   * @param governance Governance Contract
   * @param user Address of the proposal creator
   * @param blockNumber Block Number against which to make the test (e.g proposal creation block -1).
   * @return boolean, true if can be created
   **/
  function validateCreatorOfProposal(
    IAxorGovernor governance,
    address user,
    uint256 blockNumber
  ) external view returns (bool);

  /**
   * @dev Called to validate the cancellation of a proposal
   * @param governance Governance Contract
   * @param user Address of the proposal creator
   * @param blockNumber Block Number against which to make the test (e.g proposal creation block -1).
   * @return boolean, true if can be cancelled
   **/
  function validateProposalCancellation(
    IAxorGovernor governance,
    address user,
    uint256 blockNumber
  ) external view returns (bool);

  /**
   * @dev Returns whether a user has enough Proposition Power to make a proposal.
   * @param governance Governance Contract
   * @param user Address of the user to be challenged.
   * @param blockNumber Block Number against which to make the challenge.
   * @return true if user has enough power
   **/
  function isPropositionPowerEnough(
    IAxorGovernor governance,
    address user,
    uint256 blockNumber
  ) external view returns (bool);

  /**
   * @dev Returns the minimum Proposition Power needed to create a proposition.
   * @param governance Governance Contract
   * @param blockNumber Blocknumber at which to evaluate
   * @return minimum Proposition Power needed
   **/
  function getMinimumPropositionPowerNeeded(IAxorGovernor governance, uint256 blockNumber)
    external
    view
    returns (uint256);

  /**
   * @dev Returns whether a proposal passed or not
   * @param governance Governance Contract
   * @param proposalId Id of the proposal to set
   * @return true if proposal passed
   **/
  function isProposalPassed(IAxorGovernor governance, uint256 proposalId)
    external
    view
    returns (bool);

  /**
   * @dev Check whether a proposal has reached quorum, ie has enough FOR-voting-power
   * Here quorum is not to understand as number of votes reached, but number of for-votes reached
   * @param governance Governance Contract
   * @param proposalId Id of the proposal to verify
   * @return voting power needed for a proposal to pass
   **/
  function isQuorumValid(IAxorGovernor governance, uint256 proposalId)
    external
    view
    returns (bool);

  /**
   * @dev Check whether a proposal has enough extra FOR-votes than AGAINST-votes
   * FOR VOTES - AGAINST VOTES > VOTE_DIFFERENTIAL * voting supply
   * @param governance Governance Contract
   * @param proposalId Id of the proposal to verify
   * @return true if enough For-Votes
   **/
  function isVoteDifferentialValid(IAxorGovernor governance, uint256 proposalId)
    external
    view
    returns (bool);

  /**
   * @dev Calculates the minimum amount of Voting Power needed for a proposal to Pass
   * @param votingSupply Total number of oustanding voting tokens
   * @return voting power needed for a proposal to pass
   **/
  function getMinimumVotingPowerNeeded(uint256 votingSupply) external view returns (uint256);

  /**
   * @dev Get proposition threshold constant value
   * @return the proposition threshold value (100 <=> 1%)
   **/
  function PROPOSITION_THRESHOLD() external view returns (uint256);

  /**
   * @dev Get voting duration constant value
   * @return the voting duration value in seconds
   **/
  function VOTING_DURATION() external view returns (uint256);

  /**
   * @dev Get the vote differential threshold constant value
   * to compare with % of for votes/total supply - % of against votes/total supply
   * @return the vote differential threshold value (100 <=> 1%)
   **/
  function VOTE_DIFFERENTIAL() external view returns (uint256);

  /**
   * @dev Get quorum threshold constant value
   * to compare with % of for votes/total supply
   * @return the quorum threshold value (100 <=> 1%)
   **/
  function MINIMUM_QUORUM() external view returns (uint256);

  /**
   * @dev precision helper: 100% = 10000
   * @return one hundred percents with our chosen precision
   **/
  function ONE_HUNDRED_WITH_PRECISION() external view returns (uint256);
}

abstract contract ProposalValidatorMixin is
  IProposalValidator {
  using SafeMath for uint256;

  // ============ Constants ============

  /// @notice Minimum fraction of supply needed to submit a proposal.
  ///  Denominated in units out of ONE_HUNDRED_WITH_PRECISION.
  uint256 public immutable override PROPOSITION_THRESHOLD;

  /// @notice Duration of the voting period, in blocks.
  uint256 public immutable override VOTING_DURATION;

  /// @notice Minimum fraction of supply by which `for` votes must exceed `against` votes in order
  ///  for a proposal to pass. Denominated in units out of ONE_HUNDRED_WITH_PRECISION.
  uint256 public immutable override VOTE_DIFFERENTIAL;

  /// @notice Minimum fraction of the supply which a proposal must receive in `for` votes in order
  ///  for the proposal to pass. Denominated in units out of ONE_HUNDRED_WITH_PRECISION.
  uint256 public immutable override MINIMUM_QUORUM;

  /// @notice Represents 100%, for the purpose of specifying governance power thresholds.
  uint256 public constant override ONE_HUNDRED_WITH_PRECISION = 10000;

  // ============ Constructor ============

  /**
   * @notice Constructor.
   *
   * @param  propositionThreshold  Minimum fraction of supply needed to submit a proposal.
   *                               Denominated in units out of ONE_HUNDRED_WITH_PRECISION.
   * @param  votingDuration        Duration of the voting period, in blocks.
   * @param  voteDifferential      Minimum fraction of supply by which `for` votes must exceed
   *                               `against` votes in order for a proposal to pass.
   *                               Denominated in units out of ONE_HUNDRED_WITH_PRECISION.
   * @param  minimumQuorum         Minimum fraction of the supply which a proposal must receive
   *                               in `for` votes in order for the proposal to pass.
   *                               Denominated in units out of ONE_HUNDRED_WITH_PRECISION.
   */
  constructor(
    uint256 propositionThreshold,
    uint256 votingDuration,
    uint256 voteDifferential,
    uint256 minimumQuorum
  ) {
    PROPOSITION_THRESHOLD = propositionThreshold;
    VOTING_DURATION = votingDuration;
    VOTE_DIFFERENTIAL = voteDifferential;
    MINIMUM_QUORUM = minimumQuorum;
  }

  // ============ External and Public Functions ============

  /**
   * @notice Called to validate proposal creation.
   *
   *  A proposal may be created if the creator's proposition power meets the proposition threshold.
   *
   * @param  governor     Governor contract.
   * @param  user         Address of the proposal creator.
   * @param  blockNumber  Block number at which to check governance power (e.g. current block - 1).
   *
   * @return Boolean `true` if proposal may be created, otherwise `false`.
   */
  function validateCreatorOfProposal(
    IAxorGovernor governor,
    address user,
    uint256 blockNumber
  )
    external
    view
    override
    returns (bool)
  {
    return isPropositionPowerEnough(governor, user, blockNumber);
  }

  /**
   * @notice Called to validate proposal cancellation.
   *
   *  A proposal may be canceled if the creator's proposition power is below the proposition
   *  threshold.
   *
   * @param  governor     Governor contract.
   * @param  user         Address of the proposal creator.
   * @param  blockNumber  Block number at which to check governance power (e.g. current block - 1).
   *
   * @return Boolean `true` if the proposal may be canceled, otherwise `false`.
   */
  function validateProposalCancellation(
    IAxorGovernor governor,
    address user,
    uint256 blockNumber
  )
    external
    view
    override
    returns (bool)
  {
    return !isPropositionPowerEnough(governor, user, blockNumber);
  }

  /**
   * @notice Check whether a user has enough proposition power to create and maintain a proposal.
   *
   * @param  governor     Governor contract.
   * @param  user         Address of the proposal creator.
   * @param  blockNumber  Block number at which to check governance power.
   *
   * @return Boolean `true` if the user has enough proposition power, otherwise `false`.
   */
  function isPropositionPowerEnough(
    IAxorGovernor governor,
    address user,
    uint256 blockNumber
  )
    public
    view
    override
    returns (bool)
  {
    IGovernanceStrategy currentGovernanceStrategy = IGovernanceStrategy(
      governor.getGovernanceStrategy()
    );
    return (
      currentGovernanceStrategy.getPropositionPowerAt(user, blockNumber) >=
      getMinimumPropositionPowerNeeded(governor, blockNumber)
    );
  }

 /**
   * @notice Get the minimum proposition power needed to create and maintain a proposal.
   *
   * @param  governor     Governor contract.
   * @param  blockNumber  Block number at which to check governance power.
   *
   * @return The minimum proposition power needed.
   */
  function getMinimumPropositionPowerNeeded(
    IAxorGovernor governor,
    uint256 blockNumber
  )
    public
    view
    override
    returns (uint256)
  {
    IGovernanceStrategy strategy = IGovernanceStrategy(governor.getGovernanceStrategy());
    return strategy
      .getTotalPropositionSupplyAt(blockNumber)
      .mul(PROPOSITION_THRESHOLD)
      .div(ONE_HUNDRED_WITH_PRECISION);
  }

  /**
   * @notice Check whether a proposal has succeeded.
   *
   *  A proposal has succeeded if the number of `for` votes is greater than the quorum threshold
   *  and the difference between `for` and `against` votes is greater than the vote differential
   *  threshold.
   *
   * @param  governor    Governor contract.
   * @param  proposalId  ID of the proposal to check.
   *
   * @return Boolean `true` if the proposal succeeded, otherwise `false`.
   */
  function isProposalPassed(
    IAxorGovernor governor,
    uint256 proposalId
  )
    external
    view
    override
    returns (bool)
  {
    return (
      isQuorumValid(governor, proposalId) &&
      isVoteDifferentialValid(governor, proposalId)
    );
  }

  /**
   * @notice Get the minimum voting power needed for a proposal to meet the quorum threshold.
   *
   * @param  votingSupply  The total supply of voting power.
   *
   * @return The number of votes required to meet the quorum threshold.
   */
  function getMinimumVotingPowerNeeded(
    uint256 votingSupply
  )
    public
    view
    override
    returns (uint256)
  {
    return votingSupply.mul(MINIMUM_QUORUM).div(ONE_HUNDRED_WITH_PRECISION);
  }

  /**
   * @notice Check whether a proposal has enough `for` votes to meet the quorum requirement.
   *
   * @param  governor    Governor contract.
   * @param  proposalId  ID of the proposal to check.
   *
   * @return Boolean `true` if the proposal meets the quorum requirement, otherwise `false`.
   */
  function isQuorumValid(
    IAxorGovernor governor,
    uint256 proposalId
  )
    public
    view
    override
    returns (bool)
  {
    IAxorGovernor.ProposalWithoutVotes memory proposal = governor.getProposalById(proposalId);
    uint256 votingSupply = IGovernanceStrategy(proposal.strategy).getTotalVotingSupplyAt(
      proposal.startBlock
    );

    return proposal.forVotes >= getMinimumVotingPowerNeeded(votingSupply);
  }

  /**
   * @notice Check whether a proposal meets the vote differential threshold requirement.
   *
   *  Requirement: forVotes - againstVotes > VOTE_DIFFERENTIAL * votingSupply
   *
   * @param  governor    Governor contract.
   * @param  proposalId  ID of the proposal to check.
   *
   * @return Boolean `true` if the proposal meets the differential requirement, otherwise `false`.
   */
  function isVoteDifferentialValid(
    IAxorGovernor governor,
    uint256 proposalId
  )
    public
    view
    override
    returns (bool)
  {
    IAxorGovernor.ProposalWithoutVotes memory proposal = governor.getProposalById(proposalId);
    uint256 votingSupply = IGovernanceStrategy(proposal.strategy).getTotalVotingSupplyAt(
      proposal.startBlock
    );

    return (
      proposal.forVotes.mul(ONE_HUNDRED_WITH_PRECISION).div(votingSupply) >
      proposal.againstVotes.mul(ONE_HUNDRED_WITH_PRECISION).div(votingSupply).add(VOTE_DIFFERENTIAL)
    );
  }
}

// SPDX-License-Identifier: AGPL-3.0
/**
 * @title PriorityExecutor
 * @author Axor
 *
 * @notice A time-locked executor for governance, where certain addresses may expedite execution.
 *
 *  Responsible for the following:
 *   - Check proposition power to validate the creation or cancellation of proposals.
 *   - Check voting power to validate the success of proposals.
 *   - Queue, execute, and cancel the transactions of successful proposals.
 *   - Manage a list of priority controllers who may execute proposals during the priority window.
 */
contract PriorityExecutor is
  PriorityTimelockExecutorMixin,
  ProposalValidatorMixin {
  constructor(
    address admin,
    uint256 delay,
    uint256 gracePeriod,
    uint256 minimumDelay,
    uint256 maximumDelay,
    uint256 priorityPeriod,
    uint256 propositionThreshold,
    uint256 voteDuration,
    uint256 voteDifferential,
    uint256 minimumQuorum,
    address priorityExecutor
  )
    PriorityTimelockExecutorMixin(
      admin,
      delay,
      gracePeriod,
      minimumDelay,
      maximumDelay,
      priorityPeriod,
      priorityExecutor
    )
    ProposalValidatorMixin(
      propositionThreshold,
      voteDuration,
      voteDifferential,
      minimumQuorum
    )
  {}
}