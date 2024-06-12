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

library Math {
  using SafeMath for uint256;

  // ============ Library Functions ============

  /**
   * @dev Return `ceil(numerator / denominator)`.
   */
  function divRoundUp(
    uint256 numerator,
    uint256 denominator
  )
    internal
    pure
    returns (uint256)
  {
    if (numerator == 0) {
      // SafeMath will check for zero denominator
      return SafeMath.div(0, denominator);
    }
    return numerator.sub(1).div(denominator).add(1);
  }

  /**
   * @dev Returns the minimum between a and b.
   */
  function min(
    uint256 a,
    uint256 b
  )
    internal
    pure
    returns (uint256)
  {
    return a < b ? a : b;
  }

  /**
   * @dev Returns the maximum between a and b.
   */
  function max(
    uint256 a,
    uint256 b
  )
    internal
    pure
    returns (uint256)
  {
    return a > b ? a : b;
  }
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

/**
 * @title SM1Getters
 * @author Axor
 *
 * @dev Some external getter functions.
 */
abstract contract SM1Getters is
  SM1Storage {
  using SafeMath for uint256;

  // ============ External Functions ============

  /**
   * @notice The parameters specifying the function from timestamp to epoch number.
   *
   * @return The parameters struct with `interval` and `offset` fields.
   */
  function getEpochParameters()
    external
    view
    returns (SM1Types.EpochParameters memory)
  {
    return _EPOCH_PARAMETERS_;
  }

  /**
   * @notice The period of time at the end of each epoch in which withdrawals cannot be requested.
   *
   * @return The blackout window duration, in seconds.
   */
  function getBlackoutWindow()
    external
    view
    returns (uint256)
  {
    return _BLACKOUT_WINDOW_;
  }

  /**
   * @notice Get the domain separator used for EIP-712 signatures.
   *
   * @return The EIP-712 domain separator.
   */
  function getDomainSeparator()
    external
    view
    returns (bytes32)
  {
    return _DOMAIN_SEPARATOR_;
  }

  /**
   * @notice The value of one underlying token, in the units used for staked balances, denominated
   *  as a mutiple of EXCHANGE_RATE_BASE for additional precision.
   *
   *  To convert from an underlying amount to a staked amount, multiply by the exchange rate.
   *
   * @return The exchange rate.
   */
  function getExchangeRate()
    external
    view
    returns (uint256)
  {
    return _EXCHANGE_RATE_;
  }

  /**
   * @notice Get an exchange rate snapshot.
   *
   * @param  index  The index number of the exchange rate snapshot.
   *
   * @return The snapshot struct with `blockNumber` and `value` fields.
   */
  function getExchangeRateSnapshot(
    uint256 index
  )
    external
    view
    returns (SM1Types.Snapshot memory)
  {
    return _EXCHANGE_RATE_SNAPSHOTS_[index];
  }

  /**
   * @notice Get the number of exchange rate snapshots.
   *
   * @return The number of snapshots that have been taken of the exchange rate.
   */
  function getExchangeRateSnapshotCount()
    external
    view
    returns (uint256)
  {
    return _EXCHANGE_RATE_SNAPSHOT_COUNT_;
  }
}