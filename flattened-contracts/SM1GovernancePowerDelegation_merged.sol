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

interface IGovernancePowerDelegationERC20 {

  enum DelegationType {
    VOTING_POWER,
    PROPOSITION_POWER
  }

  /**
   * @dev Emitted when a user delegates governance power to another user.
   *
   * @param  delegator       The delegator.
   * @param  delegatee       The delegatee.
   * @param  delegationType  The type of delegation (VOTING_POWER, PROPOSITION_POWER).
   */
  event DelegateChanged(
    address indexed delegator,
    address indexed delegatee,
    DelegationType delegationType
  );

  /**
   * @dev Emitted when an action changes the delegated power of a user.
   *
   * @param  user            The user whose delegated power has changed.
   * @param  amount          The new amount of delegated power for the user.
   * @param  delegationType  The type of delegation (VOTING_POWER, PROPOSITION_POWER).
   */
  event DelegatedPowerChanged(address indexed user, uint256 amount, DelegationType delegationType);

  /**
   * @dev Delegates a specific governance power to a delegatee.
   *
   * @param  delegatee       The address to delegate power to.
   * @param  delegationType  The type of delegation (VOTING_POWER, PROPOSITION_POWER).
   */
  function delegateByType(address delegatee, DelegationType delegationType) external virtual;

  /**
   * @dev Delegates all governance powers to a delegatee.
   *
   * @param  delegatee  The user to which the power will be delegated.
   */
  function delegate(address delegatee) external virtual;

  /**
   * @dev Returns the delegatee of an user.
   *
   * @param  delegator       The address of the delegator.
   * @param  delegationType  The type of delegation (VOTING_POWER, PROPOSITION_POWER).
   */
  function getDelegateeByType(address delegator, DelegationType delegationType)
    external
    view
    virtual
    returns (address);

  /**
   * @dev Returns the current delegated power of a user. The current power is the power delegated
   *  at the time of the last snapshot.
   *
   * @param  user            The user whose power to query.
   * @param  delegationType  The type of power (VOTING_POWER, PROPOSITION_POWER).
   */
  function getPowerCurrent(address user, DelegationType delegationType)
    external
    view
    virtual
    returns (uint256);

  /**
   * @dev Returns the delegated power of a user at a certain block.
   *
   * @param  user            The user whose power to query.
   * @param  blockNumber     The block number at which to get the user's power.
   * @param  delegationType  The type of power (VOTING_POWER, PROPOSITION_POWER).
   */
  function getPowerAtBlock(
    address user,
    uint256 blockNumber,
    DelegationType delegationType
  )
    external
    view
    virtual
    returns (uint256);
}

library SM1Types {
  /**
   * @dev The parameters used to convert a timestamp to an epoch number.
   */
  struct EpochParameters {
    uint128 interval;
    uint128 offset;
  }

  /**
   * @dev Snapshot of a value at a specific block, used to track historical governance power.
   */
  struct Snapshot {
    uint256 blockNumber;
    uint256 value;
  }

  /**
   * @dev A balance, possibly with a change scheduled for the next epoch.
   *
   * @param  currentEpoch         The epoch in which the balance was last updated.
   * @param  currentEpochBalance  The balance at epoch `currentEpoch`.
   * @param  nextEpochBalance     The balance at epoch `currentEpoch + 1`.
   */
  struct StoredBalance {
    uint16 currentEpoch;
    uint240 currentEpochBalance;
    uint240 nextEpochBalance;
  }
}

// SPDX-License-Identifier: MIT
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

// SPDX-License-Identifier: MIT
/**
 * @dev String operations.
 */
library Strings {
  bytes16 private constant alphabet = '0123456789abcdef';

  /**
   * @dev Converts a `uint256` to its ASCII `string` decimal representation.
   */
  function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT licence
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

    if (value == 0) {
      return '0';
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }

  /**
   * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
   */
  function toHexString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return '0x00';
    }
    uint256 temp = value;
    uint256 length = 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    return toHexString(value, length);
  }

  /**
   * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
   */
  function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = '0';
    buffer[1] = 'x';
    for (uint256 i = 2 * length + 1; i > 1; --i) {
      buffer[i] = alphabet[value & 0xf];
      value >>= 4;
    }
    require(value == 0, 'Strings: hex length insufficient');
    return string(buffer);
  }
}

// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
  /**
   * @dev Returns true if this contract implements the interface defined by
   * `interfaceId`. See the corresponding
   * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
   * to learn more about how these ids are created.
   *
   * This function call must use less than 30 000 gas.
   */
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IERC165).interfaceId;
  }
}

abstract contract AccessControlUpgradeable is Context, IAccessControlUpgradeable, ERC165 {
  struct RoleData {
    mapping(address => bool) members;
    bytes32 adminRole;
  }

  mapping(bytes32 => RoleData) private _roles;

  bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

  /**
   * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
   *
   * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
   * {RoleAdminChanged} not being emitted signaling this.
   *
   * _Available since v3.1._
   */
  event RoleAdminChanged(
    bytes32 indexed role,
    bytes32 indexed previousAdminRole,
    bytes32 indexed newAdminRole
  );

  /**
   * @dev Emitted when `account` is granted `role`.
   *
   * `sender` is the account that originated the contract call, an admin role
   * bearer except when using {_setupRole}.
   */
  event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

  /**
   * @dev Emitted when `account` is revoked `role`.
   *
   * `sender` is the account that originated the contract call:
   *   - if using `revokeRole`, it is the admin role bearer
   *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
   */
  event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

  /**
   * @dev Modifier that checks that an account has a specific role. Reverts
   * with a standardized message including the required role.
   *
   * The format of the revert reason is given by the following regular expression:
   *
   *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
   *
   * _Available since v4.1._
   */
  modifier onlyRole(bytes32 role) {
    _checkRole(role, _msgSender());
    _;
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return
      interfaceId == type(IAccessControlUpgradeable).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  /**
   * @dev Returns `true` if `account` has been granted `role`.
   */
  function hasRole(bytes32 role, address account) public view override returns (bool) {
    return _roles[role].members[account];
  }

  /**
   * @dev Revert with a standard message if `account` is missing `role`.
   *
   * The format of the revert reason is given by the following regular expression:
   *
   *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
   */
  function _checkRole(bytes32 role, address account) internal view {
    if (!hasRole(role, account)) {
      revert(
        string(
          abi.encodePacked(
            'AccessControl: account ',
            Strings.toHexString(uint160(account), 20),
            ' is missing role ',
            Strings.toHexString(uint256(role), 32)
          )
        )
      );
    }
  }

  /**
   * @dev Returns the admin role that controls `role`. See {grantRole} and
   * {revokeRole}.
   *
   * To change a role's admin, use {_setRoleAdmin}.
   */
  function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
    return _roles[role].adminRole;
  }

  /**
   * @dev Grants `role` to `account`.
   *
   * If `account` had not been already granted `role`, emits a {RoleGranted}
   * event.
   *
   * Requirements:
   *
   * - the caller must have ``role``'s admin role.
   */
  function grantRole(bytes32 role, address account)
    public
    virtual
    override
    onlyRole(getRoleAdmin(role))
  {
    _grantRole(role, account);
  }

  /**
   * @dev Revokes `role` from `account`.
   *
   * If `account` had been granted `role`, emits a {RoleRevoked} event.
   *
   * Requirements:
   *
   * - the caller must have ``role``'s admin role.
   */
  function revokeRole(bytes32 role, address account)
    public
    virtual
    override
    onlyRole(getRoleAdmin(role))
  {
    _revokeRole(role, account);
  }

  /**
   * @dev Revokes `role` from the calling account.
   *
   * Roles are often managed via {grantRole} and {revokeRole}: this function's
   * purpose is to provide a mechanism for accounts to lose their privileges
   * if they are compromised (such as when a trusted device is misplaced).
   *
   * If the calling account had been granted `role`, emits a {RoleRevoked}
   * event.
   *
   * Requirements:
   *
   * - the caller must be `account`.
   */
  function renounceRole(bytes32 role, address account) public virtual override {
    require(account == _msgSender(), 'AccessControl: can only renounce roles for self');

    _revokeRole(role, account);
  }

  /**
   * @dev Grants `role` to `account`.
   *
   * If `account` had not been already granted `role`, emits a {RoleGranted}
   * event. Note that unlike {grantRole}, this function doesn't perform any
   * checks on the calling account.
   *
   * [WARNING]
   * ====
   * This function should only be called from the constructor when setting
   * up the initial roles for the system.
   *
   * Using this function in any other way is effectively circumventing the admin
   * system imposed by {AccessControl}.
   * ====
   */
  function _setupRole(bytes32 role, address account) internal virtual {
    _grantRole(role, account);
  }

  /**
   * @dev Sets `adminRole` as ``role``'s admin role.
   *
   * Emits a {RoleAdminChanged} event.
   */
  function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
    emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
    _roles[role].adminRole = adminRole;
  }

  function _grantRole(bytes32 role, address account) private {
    if (!hasRole(role, account)) {
      _roles[role].members[account] = true;
      emit RoleGranted(role, account, _msgSender());
    }
  }

  function _revokeRole(bytes32 role, address account) private {
    if (hasRole(role, account)) {
      _roles[role].members[account] = false;
      emit RoleRevoked(role, account, _msgSender());
    }
  }

  uint256[49] private __gap;
}

abstract contract ReentrancyGuard {
  uint256 private constant NOT_ENTERED = 1;
  uint256 private constant ENTERED = uint256(int256(-1));

  uint256 private _STATUS_;

  constructor()
    internal
  {
    _STATUS_ = NOT_ENTERED;
  }

  modifier nonReentrant() {
    require(_STATUS_ != ENTERED, 'ReentrancyGuard: reentrant call');
    _STATUS_ = ENTERED;
    _;
    _STATUS_ = NOT_ENTERED;
  }
}

abstract contract VersionedInitializable {
    /**
   * @dev Indicates that the contract has been initialized.
   */
    uint256 internal lastInitializedRevision = 0;

   /**
   * @dev Modifier to use in the initializer function of a contract.
   */
    modifier initializer() {
        uint256 revision = getRevision();
        require(revision > lastInitializedRevision, "Contract instance has already been initialized");

        lastInitializedRevision = revision;

        _;

    }

    /// @dev returns the revision number of the contract.
    /// Needs to be defined in the inherited class as a constant.
    function getRevision() internal pure virtual returns(uint256);


    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

abstract contract SM1Storage is
  AccessControlUpgradeable,
  ReentrancyGuard,
  VersionedInitializable {
  // ============ Epoch Schedule ============

  /// @dev The parameters specifying the function from timestamp to epoch number.
  SM1Types.EpochParameters internal _EPOCH_PARAMETERS_;

  /// @dev The period of time at the end of each epoch in which withdrawals cannot be requested.
  uint256 internal _BLACKOUT_WINDOW_;

  // ============ Staked Token ERC20 ============

  /// @dev Allowances for ERC-20 transfers.
  mapping(address => mapping(address => uint256)) internal _ALLOWANCES_;

  // ============ Governance Power Delegation ============

  /// @dev Domain separator for EIP-712 signatures.
  bytes32 internal _DOMAIN_SEPARATOR_;

  /// @dev Mapping from (owner) => (next valid nonce) for EIP-712 signatures.
  mapping(address => uint256) internal _NONCES_;

  /// @dev Snapshots and delegates for governance voting power.
  mapping(address => mapping(uint256 => SM1Types.Snapshot)) internal _VOTING_SNAPSHOTS_;
  mapping(address => uint256) internal _VOTING_SNAPSHOT_COUNTS_;
  mapping(address => address) internal _VOTING_DELEGATES_;

  /// @dev Snapshots and delegates for governance proposition power.
  mapping(address => mapping(uint256 => SM1Types.Snapshot)) internal _PROPOSITION_SNAPSHOTS_;
  mapping(address => uint256) internal _PROPOSITION_SNAPSHOT_COUNTS_;
  mapping(address => address) internal _PROPOSITION_DELEGATES_;

  // ============ Rewards Accounting ============

  /// @dev The emission rate of rewards.
  uint256 internal _REWARDS_PER_SECOND_;

  /// @dev The cumulative rewards earned per staked token. (Shared storage slot.)
  uint224 internal _GLOBAL_INDEX_;

  /// @dev The timestamp at which the global index was last updated. (Shared storage slot.)
  uint32 internal _GLOBAL_INDEX_TIMESTAMP_;

  /// @dev The value of the global index when the user's staked balance was last updated.
  mapping(address => uint256) internal _USER_INDEXES_;

  /// @dev The user's accrued, unclaimed rewards (as of the last update to the user index).
  mapping(address => uint256) internal _USER_REWARDS_BALANCES_;

  /// @dev The value of the global index at the end of a given epoch.
  mapping(uint256 => uint256) internal _EPOCH_INDEXES_;

  // ============ Staker Accounting ============

  /// @dev The active balance by staker.
  mapping(address => SM1Types.StoredBalance) internal _ACTIVE_BALANCES_;

  /// @dev The total active balance of stakers.
  SM1Types.StoredBalance internal _TOTAL_ACTIVE_BALANCE_;

  /// @dev The inactive balance by staker.
  mapping(address => SM1Types.StoredBalance) internal _INACTIVE_BALANCES_;

  /// @dev The total inactive balance of stakers.
  SM1Types.StoredBalance internal _TOTAL_INACTIVE_BALANCE_;

  // ============ Exchange Rate ============

  /// @dev The value of one underlying token, in the units used for staked balances, denominated
  ///  as a mutiple of EXCHANGE_RATE_BASE for additional precision.
  uint256 internal _EXCHANGE_RATE_;

  /// @dev Historical snapshots of the exchange rate, in each block that it has changed.
  mapping(uint256 => SM1Types.Snapshot) internal _EXCHANGE_RATE_SNAPSHOTS_;

  /// @dev Number of snapshots of the exchange rate.
  uint256 internal _EXCHANGE_RATE_SNAPSHOT_COUNT_;
}

abstract contract SM1Snapshots {
  /**
   * @dev Writes a snapshot of a value at the current block.
   *
   * @param  snapshots      Storage mapping from snapshot index to snapshot struct.
   * @param  snapshotCount  The total number of snapshots in the provided mapping.
   * @param  newValue       The new value to snapshot at the current block.
   *
   * @return The new snapshot count.
   */
  function _writeSnapshot(
    mapping(uint256 => SM1Types.Snapshot) storage snapshots,
    uint256 snapshotCount,
    uint256 newValue
  ) internal returns (uint256) {
    uint256 currentBlock = block.number;

    if (
      snapshotCount != 0 &&
      snapshots[snapshotCount - 1].blockNumber == currentBlock
    ) {
      // If there was a previous snapshot for this block, overwrite it.
      snapshots[snapshotCount - 1].value = newValue;
      return snapshotCount;
    } else {
      snapshots[snapshotCount] = SM1Types.Snapshot(currentBlock, newValue);
      return snapshotCount + 1;
    }
  }

  /**
   * @dev Search for the snapshot value at a given block. Uses binary search.
   *
   *  Reverts if `blockNumber` is greater than the current block number.
   *
   * @param  snapshots      Storage mapping from snapshot index to snapshot struct.
   * @param  snapshotCount  The total number of snapshots in the provided mapping.
   * @param  blockNumber    The block number to search for.
   * @param  initialValue   The value to return if `blockNumber` is before the earliest snapshot.
   *
   * @return The snapshot value at the specified block number.
   */
  function _findValueAtBlock(
    mapping(uint256 => SM1Types.Snapshot) storage snapshots,
    uint256 snapshotCount,
    uint256 blockNumber,
    uint256 initialValue
  ) internal view returns (uint256) {
    require(blockNumber <= block.number, 'SM1Snapshots: INVALID_BLOCK_NUMBER');

    if (snapshotCount == 0) {
      return initialValue;
    }

    // Check earliest snapshot.
    if (blockNumber < snapshots[0].blockNumber) {
      return initialValue;
    }

    // Check latest snapshot.
    if (blockNumber >= snapshots[snapshotCount - 1].blockNumber) {
      return snapshots[snapshotCount - 1].value;
    }

    uint256 lower = 0;
    uint256 upper = snapshotCount - 1;
    while (upper > lower) {
      uint256 center = upper - (upper - lower) / 2; // Ceil, avoiding overflow.
      SM1Types.Snapshot memory snapshot = snapshots[center];
      if (snapshot.blockNumber == blockNumber) {
        return snapshot.value;
      } else if (snapshot.blockNumber < blockNumber) {
        lower = center;
      } else {
        upper = center - 1;
      }
    }
    return snapshots[lower].value;
  }
}

abstract contract SM1ExchangeRate is
  SM1Snapshots,
  SM1Storage {
  using SafeMath for uint256;

  // ============ Constants ============

  /// @notice The assumed upper bound on the total supply of the staked token.
  uint256 public constant MAX_UNDERLYING_BALANCE = 1e28;

  /// @notice Base unit used to represent the exchange rate, for additional precision.
  uint256 public constant EXCHANGE_RATE_BASE = 1e18;

  /// @notice Cutoff where an exchange rate may overflow after multiplying by an underlying balance.
  /// @dev Approximately 1.2e49
  uint256 public constant EXCHANGE_RATE_MAY_OVERFLOW = (2 ** 256 - 1) / MAX_UNDERLYING_BALANCE;

  /// @notice Cutoff where a stake amount may overflow after multiplying by EXCHANGE_RATE_BASE.
  /// @dev Approximately 1.2e59
  uint256 public constant STAKE_AMOUNT_MAY_OVERFLOW = (2 ** 256 - 1) / EXCHANGE_RATE_BASE;

  /// @notice Max exchange rate.
  /// @dev Approximately 1.8e62
  uint256 public constant MAX_EXCHANGE_RATE = (
    ((2 ** 240 - 1) / MAX_UNDERLYING_BALANCE) * EXCHANGE_RATE_BASE
  );

  // ============ Initializer ============

  function __SM1ExchangeRate_init()
    internal
  {
    _EXCHANGE_RATE_ = EXCHANGE_RATE_BASE;
  }

  function stakeAmountFromUnderlyingAmount(
    uint256 underlyingAmount
  )
    internal
    view
    returns (uint256)
  {
    uint256 exchangeRate = _EXCHANGE_RATE_;

    if (exchangeRate > EXCHANGE_RATE_MAY_OVERFLOW) {
      uint256 exchangeRateUnbased = exchangeRate.div(EXCHANGE_RATE_BASE);
      return underlyingAmount.mul(exchangeRateUnbased);
    } else {
      return underlyingAmount.mul(exchangeRate).div(EXCHANGE_RATE_BASE);
    }
  }

  function underlyingAmountFromStakeAmount(
    uint256 stakeAmount
  )
    internal
    view
    returns (uint256)
  {
    return underlyingAmountFromStakeAmountWithExchangeRate(stakeAmount, _EXCHANGE_RATE_);
  }

  function underlyingAmountFromStakeAmountWithExchangeRate(
    uint256 stakeAmount,
    uint256 exchangeRate
  )
    internal
    pure
    returns (uint256)
  {
    if (stakeAmount > STAKE_AMOUNT_MAY_OVERFLOW) {
      // Note that this case implies that exchangeRate > EXCHANGE_RATE_MAY_OVERFLOW.
      uint256 exchangeRateUnbased = exchangeRate.div(EXCHANGE_RATE_BASE);
      return stakeAmount.div(exchangeRateUnbased);
    } else {
      return stakeAmount.mul(EXCHANGE_RATE_BASE).div(exchangeRate);
    }
  }

  function updateExchangeRate(
    uint256 numerator,
    uint256 denominator
  )
    internal
    returns (uint256)
  {
    uint256 oldExchangeRate = _EXCHANGE_RATE_;

    // Avoid overflow.
    // Note that the numerator and denominator are both denominated in underlying token units.
    uint256 newExchangeRate;
    if (oldExchangeRate > EXCHANGE_RATE_MAY_OVERFLOW) {
      newExchangeRate = oldExchangeRate.div(denominator).mul(numerator);
    } else {
      newExchangeRate = oldExchangeRate.mul(numerator).div(denominator);
    }

    require(
      newExchangeRate <= MAX_EXCHANGE_RATE,
      'SM1ExchangeRate: Max exchange rate exceeded'
    );

    _EXCHANGE_RATE_SNAPSHOT_COUNT_ = _writeSnapshot(
      _EXCHANGE_RATE_SNAPSHOTS_,
      _EXCHANGE_RATE_SNAPSHOT_COUNT_,
      newExchangeRate
    );

    _EXCHANGE_RATE_ = newExchangeRate;
    return newExchangeRate;
  }
}

// SPDX-License-Identifier: AGPL-3.0
/**
 * @title SM1GovernancePowerDelegation
 * @author Axor
 *
 * @dev Provides support for two types of governance powers which are separately delegatable.
 *  Provides functions for delegation and for querying a user's power at a certain block number.
 *
 *  Internally, makes use of staked balances denoted in staked units, but returns underlying token
 *  units from the getPowerAtBlock() and getPowerCurrent() functions.
 *
 *  This is based on, and is designed to match, Aave's implementation, which is used in their
 *  governance token and staked token contracts.
 */
abstract contract SM1GovernancePowerDelegation is
  SM1ExchangeRate,
  IGovernancePowerDelegationERC20 {
  using SafeMath for uint256;

  // ============ Constants ============

  /// @notice EIP-712 typehash for delegation by signature of a specific governance power type.
  bytes32 public constant DELEGATE_BY_TYPE_TYPEHASH = keccak256(
    'DelegateByType(address delegatee,uint256 type,uint256 nonce,uint256 expiry)'
  );

  /// @notice EIP-712 typehash for delegation by signature of all governance powers.
  bytes32 public constant DELEGATE_TYPEHASH = keccak256(
    'Delegate(address delegatee,uint256 nonce,uint256 expiry)'
  );

  // ============ External Functions ============

  /**
   * @notice Delegates a specific governance power of the sender to a delegatee.
   *
   * @param  delegatee       The address to delegate power to.
   * @param  delegationType  The type of delegation (VOTING_POWER, PROPOSITION_POWER).
   */
  function delegateByType(
    address delegatee,
    DelegationType delegationType
  )
    external
    override
  {
    _delegateByType(msg.sender, delegatee, delegationType);
  }

  /**
   * @notice Delegates all governance powers of the sender to a delegatee.
   *
   * @param  delegatee  The address to delegate power to.
   */
  function delegate(
    address delegatee
  )
    external
    override
  {
    _delegateByType(msg.sender, delegatee, DelegationType.VOTING_POWER);
    _delegateByType(msg.sender, delegatee, DelegationType.PROPOSITION_POWER);
  }

  /**
   * @dev Delegates specific governance power from signer to `delegatee` using an EIP-712 signature.
   *
   * @param  delegatee       The address to delegate votes to.
   * @param  delegationType  The type of delegation (VOTING_POWER, PROPOSITION_POWER).
   * @param  nonce           The signer's nonce for EIP-712 signatures on this contract.
   * @param  expiry          Expiration timestamp for the signature.
   * @param  v               Signature param.
   * @param  r               Signature param.
   * @param  s               Signature param.
   */
  function delegateByTypeBySig(
    address delegatee,
    DelegationType delegationType,
    uint256 nonce,
    uint256 expiry,
    uint8 v,
    bytes32 r,
    bytes32 s
  )
    external
  {
    bytes32 structHash = keccak256(
      abi.encode(DELEGATE_BY_TYPE_TYPEHASH, delegatee, uint256(delegationType), nonce, expiry)
    );
    bytes32 digest = keccak256(abi.encodePacked('\x19\x01', _DOMAIN_SEPARATOR_, structHash));
    address signer = ecrecover(digest, v, r, s);
    require(
      signer != address(0),
      'SM1GovernancePowerDelegation: INVALID_SIGNATURE'
    );
    require(
      nonce == _NONCES_[signer]++,
      'SM1GovernancePowerDelegation: INVALID_NONCE'
    );
    require(
      block.timestamp <= expiry,
      'SM1GovernancePowerDelegation: INVALID_EXPIRATION'
    );
    _delegateByType(signer, delegatee, delegationType);
  }

  /**
   * @dev Delegates both governance powers from signer to `delegatee` using an EIP-712 signature.
   *
   * @param  delegatee  The address to delegate votes to.
   * @param  nonce      The signer's nonce for EIP-712 signatures on this contract.
   * @param  expiry     Expiration timestamp for the signature.
   * @param  v          Signature param.
   * @param  r          Signature param.
   * @param  s          Signature param.
   */
  function delegateBySig(
    address delegatee,
    uint256 nonce,
    uint256 expiry,
    uint8 v,
    bytes32 r,
    bytes32 s
  )
    external
  {
    bytes32 structHash = keccak256(abi.encode(DELEGATE_TYPEHASH, delegatee, nonce, expiry));
    bytes32 digest = keccak256(abi.encodePacked('\x19\x01', _DOMAIN_SEPARATOR_, structHash));
    address signer = ecrecover(digest, v, r, s);
    require(
      signer != address(0),
      'SM1GovernancePowerDelegation: INVALID_SIGNATURE'
    );
    require(
      nonce == _NONCES_[signer]++,
      'SM1GovernancePowerDelegation: INVALID_NONCE'
    );
    require(
      block.timestamp <= expiry,
      'SM1GovernancePowerDelegation: INVALID_EXPIRATION'
    );
    _delegateByType(signer, delegatee, DelegationType.VOTING_POWER);
    _delegateByType(signer, delegatee, DelegationType.PROPOSITION_POWER);
  }

  /**
   * @notice Returns the delegatee of a user.
   *
   * @param  delegator       The address of the delegator.
   * @param  delegationType  The type of delegation (VOTING_POWER, PROPOSITION_POWER).
   */
  function getDelegateeByType(
    address delegator,
    DelegationType delegationType
  )
    external
    override
    view
    returns (address)
  {
    (, , mapping(address => address) storage delegates) = _getDelegationDataByType(delegationType);

    return _getDelegatee(delegator, delegates);
  }

  /**
   * @notice Returns the current power of a user. The current power is the power delegated
   *  at the time of the last snapshot.
   *
   * @param  user            The user whose power to query.
   * @param  delegationType  The type of power (VOTING_POWER, PROPOSITION_POWER).
   */
  function getPowerCurrent(
    address user,
    DelegationType delegationType
  )
    external
    override
    view
    returns (uint256)
  {
    return getPowerAtBlock(user, block.number, delegationType);
  }

  /**
   * @notice Get the next valid nonce for EIP-712 signatures.
   *
   *  This nonce should be used when signing for any of the following functions:
   *   - permit()
   *   - delegateByTypeBySig()
   *   - delegateBySig()
   */
  function nonces(
    address owner
  )
    external
    view
    returns (uint256)
  {
    return _NONCES_[owner];
  }

  // ============ Public Functions ============

  function balanceOf(
    address account
  )
    public
    view
    virtual
    returns (uint256);

  /**
   * @notice Returns the power of a user at a certain block, denominated in underlying token units.
   *
   * @param  user            The user whose power to query.
   * @param  blockNumber     The block number at which to get the user's power.
   * @param  delegationType  The type of power (VOTING_POWER, PROPOSITION_POWER).
   *
   * @return The user's governance power of the specified type, in underlying token units.
   */
  function getPowerAtBlock(
    address user,
    uint256 blockNumber,
    DelegationType delegationType
  )
    public
    override
    view
    returns (uint256)
  {
    (
      mapping(address => mapping(uint256 => SM1Types.Snapshot)) storage snapshots,
      mapping(address => uint256) storage snapshotCounts,
      // unused: delegates
    ) = _getDelegationDataByType(delegationType);

    uint256 stakeAmount = _findValueAtBlock(
      snapshots[user],
      snapshotCounts[user],
      blockNumber,
      0
    );
    uint256 exchangeRate = _findValueAtBlock(
      _EXCHANGE_RATE_SNAPSHOTS_,
      _EXCHANGE_RATE_SNAPSHOT_COUNT_,
      blockNumber,
      EXCHANGE_RATE_BASE
    );
    return underlyingAmountFromStakeAmountWithExchangeRate(stakeAmount, exchangeRate);
  }

  // ============ Internal Functions ============

  /**
   * @dev Delegates one specific power to a delegatee.
   *
   * @param  delegator       The user whose power to delegate.
   * @param  delegatee       The address to delegate power to.
   * @param  delegationType  The type of power (VOTING_POWER, PROPOSITION_POWER).
   */
  function _delegateByType(
    address delegator,
    address delegatee,
    DelegationType delegationType
  )
    internal
  {
    require(
      delegatee != address(0),
      'SM1GovernancePowerDelegation: INVALID_DELEGATEE'
    );

    (, , mapping(address => address) storage delegates) = _getDelegationDataByType(delegationType);
    uint256 delegatorBalance = balanceOf(delegator);
    address previousDelegatee = _getDelegatee(delegator, delegates);

    delegates[delegator] = delegatee;

    _moveDelegatesByType(previousDelegatee, delegatee, delegatorBalance, delegationType);
    emit DelegateChanged(delegator, delegatee, delegationType);
  }

  /**
   * @dev Update delegate snapshots whenever staked tokens are transfered, minted, or burned.
   *
   * @param  from          The sender.
   * @param  to            The recipient.
   * @param  stakedAmount  The amount being transfered, denominated in staked units.
   */
  function _moveDelegatesForTransfer(
    address from,
    address to,
    uint256 stakedAmount
  )
    internal
  {
    address votingPowerFromDelegatee = _getDelegatee(from, _VOTING_DELEGATES_);
    address votingPowerToDelegatee = _getDelegatee(to, _VOTING_DELEGATES_);

    _moveDelegatesByType(
      votingPowerFromDelegatee,
      votingPowerToDelegatee,
      stakedAmount,
      DelegationType.VOTING_POWER
    );

    address propositionPowerFromDelegatee = _getDelegatee(from, _PROPOSITION_DELEGATES_);
    address propositionPowerToDelegatee = _getDelegatee(to, _PROPOSITION_DELEGATES_);

    _moveDelegatesByType(
      propositionPowerFromDelegatee,
      propositionPowerToDelegatee,
      stakedAmount,
      DelegationType.PROPOSITION_POWER
    );
  }

  /**
   * @dev Moves power from one user to another.
   *
   * @param  from            The user from which delegated power is moved.
   * @param  to              The user that will receive the delegated power.
   * @param  amount          The amount of power to be moved.
   * @param  delegationType  The type of power (VOTING_POWER, PROPOSITION_POWER).
   */
  function _moveDelegatesByType(
    address from,
    address to,
    uint256 amount,
    DelegationType delegationType
  )
    internal
  {
    if (from == to) {
      return;
    }

    (
      mapping(address => mapping(uint256 => SM1Types.Snapshot)) storage snapshots,
      mapping(address => uint256) storage snapshotCounts,
      // unused: delegates
    ) = _getDelegationDataByType(delegationType);

    if (from != address(0)) {
      mapping(uint256 => SM1Types.Snapshot) storage fromSnapshots = snapshots[from];
      uint256 fromSnapshotCount = snapshotCounts[from];
      uint256 previousBalance = 0;

      if (fromSnapshotCount != 0) {
        previousBalance = fromSnapshots[fromSnapshotCount - 1].value;
      }

      uint256 newBalance = previousBalance.sub(amount);
      snapshotCounts[from] = _writeSnapshot(
        fromSnapshots,
        fromSnapshotCount,
        newBalance
      );

      emit DelegatedPowerChanged(from, newBalance, delegationType);
    }

    if (to != address(0)) {
      mapping(uint256 => SM1Types.Snapshot) storage toSnapshots = snapshots[to];
      uint256 toSnapshotCount = snapshotCounts[to];
      uint256 previousBalance = 0;

      if (toSnapshotCount != 0) {
        previousBalance = toSnapshots[toSnapshotCount - 1].value;
      }

      uint256 newBalance = previousBalance.add(amount);
      snapshotCounts[to] = _writeSnapshot(
        toSnapshots,
        toSnapshotCount,
        newBalance
      );

      emit DelegatedPowerChanged(to, newBalance, delegationType);
    }
  }

  /**
   * @dev Returns delegation data (snapshot, snapshotCount, delegates) by delegation type.
   *
   * @param  delegationType  The type of power (VOTING_POWER, PROPOSITION_POWER).
   *
   * @return The mapping of each user to a mapping of snapshots.
   * @return The mapping of each user to the total number of snapshots for that user.
   * @return The mapping of each user to the user's delegate.
   */
  function _getDelegationDataByType(
    DelegationType delegationType
  )
    internal
    view
    returns (
      mapping(address => mapping(uint256 => SM1Types.Snapshot)) storage,
      mapping(address => uint256) storage,
      mapping(address => address) storage
    )
  {
    if (delegationType == DelegationType.VOTING_POWER) {
      return (
        _VOTING_SNAPSHOTS_,
        _VOTING_SNAPSHOT_COUNTS_,
        _VOTING_DELEGATES_
      );
    } else {
      return (
        _PROPOSITION_SNAPSHOTS_,
        _PROPOSITION_SNAPSHOT_COUNTS_,
        _PROPOSITION_DELEGATES_
      );
    }
  }

  /**
   * @dev Returns the delegatee of a user. If a user never performed any delegation, their
   *  delegated address will be 0x0, in which case we return the user's own address.
   *
   * @param  delegator  The address of the user for which return the delegatee.
   * @param  delegates  The mapping of delegates for a particular type of delegation.
   */
  function _getDelegatee(
    address delegator,
    mapping(address => address) storage delegates
  )
    internal
    view
    returns (address)
  {
    address previousDelegatee = delegates[delegator];

    if (previousDelegatee == address(0)) {
      return delegator;
    }

    return previousDelegatee;
  }
}