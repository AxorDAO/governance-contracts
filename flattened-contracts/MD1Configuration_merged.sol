pragma solidity 0.7.5;
pragma abicoder v2;


interface IRewardsOracle {

  /**
   * @notice Returns the oracle value, agreed upon by all oracle signers. If the signers have not
   *  agreed upon a value, should return zero for all return values.
   *
   * @return  merkleRoot  The Merkle root for the next Merkle distributor update.
   * @return  epoch       The epoch number corresponding to the new Merkle root.
   * @return  ipfsCid     An IPFS CID pointing to the Merkle tree data.
   */
  function read()
    external
    virtual
    view
    returns (bytes32 merkleRoot, uint256 epoch, bytes memory ipfsCid);
}

library MD1Types {

  /**
   * @dev The parameters used to convert a timestamp to an epoch number.
   */
  struct EpochParameters {
    uint128 interval;
    uint128 offset;
  }

  /**
   * @dev The parameters related to a certain version of the Merkle root.
   */
  struct MerkleRoot {
    bytes32 merkleRoot;
    uint256 epoch;
    bytes ipfsCid;
  }
}

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

library SafeCast {

  /**
   * @dev Downcast to a uint128, reverting on overflow.
   */
  function toUint128(
    uint256 a
  )
    internal
    pure
    returns (uint128)
  {
    uint128 b = uint128(a);
    require(
      uint256(b) == a,
      'SafeCast: toUint128 overflow'
    );
    return b;
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

interface IERC20 {
  /**
    * @dev Returns the amount of tokens in existence.
    */
  function totalSupply() external view returns (uint256);

  /**
    * @dev Returns the amount of tokens owned by `account`.
    */
  function balanceOf(address account) external view returns (uint256);

  /**
    * @dev Moves `amount` tokens from the caller's account to `recipient`.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * Emits a {Transfer} event.
    */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
    * @dev Returns the remaining number of tokens that `spender` will be
    * allowed to spend on behalf of `owner` through {transferFrom}. This is
    * zero by default.
    *
    * This value changes when {approve} or {transferFrom} are called.
    */
  function allowance(address owner, address spender) external view returns (uint256);

  /**
    * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * IMPORTANT: Beware that changing an allowance with this method brings the risk
    * that someone may use both the old and the new allowance by unfortunate
    * transaction ordering. One possible solution to mitigate this race
    * condition is to first reduce the spender's allowance to 0 and set the
    * desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    *
    * Emits an {Approval} event.
    */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
    * @dev Moves `amount` tokens from `sender` to `recipient` using the
    * allowance mechanism. `amount` is then deducted from the caller's
    * allowance.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * Emits a {Transfer} event.
    */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
    * @dev Emitted when `value` tokens are moved from one account (`from`) to
    * another (`to`).
    *
    * Note that `value` may be zero.
    */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
    * @dev Emitted when the allowance of a `spender` for an `owner` is set by
    * a call to {approve}. `value` is the new allowance.
    */
  event Approval(address indexed owner, address indexed spender, uint256 value);
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

abstract contract MD1Storage is
  AccessControlUpgradeable,
  ReentrancyGuard,
  VersionedInitializable {
  // ============ Configuration ============

  /// @dev The oracle which provides Merkle root updates.
  IRewardsOracle internal _REWARDS_ORACLE_;

  /// @dev The IPNS name to which trader and market maker exchange statistics are published.
  string internal _IPNS_NAME_;

  /// @dev Period of time after the epoch end after which the new epoch exchange statistics should
  ///  be available on IPFS via the IPNS name. This can be used as a trigger for “keepers” who are
  ///  incentivized to call the proposeRoot() and updateRoot() functions as needed.
  uint256 internal _IPFS_UPDATE_PERIOD_;

  /// @dev Max rewards distributed per epoch as market maker incentives.
  uint256 internal _MARKET_MAKER_REWARDS_AMOUNT_;

  /// @dev Max rewards distributed per epoch as trader incentives.
  uint256 internal _TRADER_REWARDS_AMOUNT_;

  /// @dev Parameter affecting the calculation of trader rewards. This is a value
  ///  between 0 and 1, represented here in units out of 10^18.
  uint256 internal _TRADER_SCORE_ALPHA_;

  // ============ Epoch Schedule ============

  /// @dev The parameters specifying the function from timestamp to epoch number.
  MD1Types.EpochParameters internal _EPOCH_PARAMETERS_;

  // ============ Root Updates ============

  /// @dev The active Merkle root and associated parameters.
  MD1Types.MerkleRoot internal _ACTIVE_ROOT_;

  /// @dev The proposed Merkle root and associated parameters.
  MD1Types.MerkleRoot internal _PROPOSED_ROOT_;

  /// @dev The time at which the proposed root may become active.
  uint256 internal _WAITING_PERIOD_END_;

  /// @dev Whether root updates are currently paused.
  bool internal _ARE_ROOT_UPDATES_PAUSED_;

  // ============ Claims ============

  /// @dev Mapping of (user address) => (number of tokens claimed).
  mapping(address => uint256) internal _CLAIMED_;

  /// @dev Whether the user has opted into allowing anyone to trigger a claim on their behalf.
  mapping(address => bool) internal _ALWAYS_ALLOW_CLAIMS_FOR_;
}

abstract contract MD1EpochSchedule is
  MD1Storage {
  using SafeCast for uint256;
  using SafeMath for uint256;

  // ============ Events ============

  event EpochScheduleUpdated(
    MD1Types.EpochParameters epochParameters
  );

  // ============ Initializer ============

  function __MD1EpochSchedule_init(
    uint256 interval,
    uint256 offset
  )
    internal
  {
    _setEpochParameters(interval, offset);
  }

  // ============ External Functions ============

  /**
   * @notice Get the epoch at the current block timestamp.
   *
   *  Reverts if epoch zero has not started.
   *
   * @return The current epoch number.
   */
  function getCurrentEpoch()
    external
    view
    returns (uint256)
  {
    return _getEpochAtTimestamp(
      block.timestamp,
      'MD1EpochSchedule: Epoch zero has not started'
    );
  }

  /**
   * @notice Get the latest epoch number for which we expect to have data available on IPFS.
   *  This is equal to the current epoch number, delayed by the IPFS update period.
   *
   *  Reverts if epoch zero did not begin at least `_IPFS_UPDATE_PERIOD_` seconds ago.
   *
   * @return The latest epoch number for which we expect to have data available on IPFS.
   */
  function getIpfsEpoch()
    external
    view
    returns (uint256)
  {
    return _getEpochAtTimestamp(
      block.timestamp.sub(_IPFS_UPDATE_PERIOD_),
      'MD1EpochSchedule: IPFS epoch zero has not started'
    );
  }

  // ============ Internal Functions ============

  function _getEpochAtTimestamp(
    uint256 timestamp,
    string memory revertReason
  )
    internal
    view
    returns (uint256)
  {
    MD1Types.EpochParameters memory epochParameters = _EPOCH_PARAMETERS_;

    uint256 interval = uint256(epochParameters.interval);
    uint256 offset = uint256(epochParameters.offset);

    require(
      timestamp >= offset,
      revertReason
    );

    return timestamp.sub(offset).div(interval);
  }

  function _setEpochParameters(
    uint256 interval,
    uint256 offset
  )
    internal
  {
    require(
      interval != 0,
      'MD1EpochSchedule: Interval cannot be zero'
    );

    MD1Types.EpochParameters memory epochParameters = MD1Types.EpochParameters({
      interval: interval.toUint128(),
      offset: offset.toUint128()
    });

    _EPOCH_PARAMETERS_ = epochParameters;

    emit EpochScheduleUpdated(epochParameters);
  }
}

abstract contract MD1Roles is
  MD1Storage {
  bytes32 public constant OWNER_ROLE = keccak256('OWNER_ROLE');
  bytes32 public constant CONFIG_UPDATER_ROLE = keccak256('CONFIG_UPDATER_ROLE');
  bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
  bytes32 public constant UNPAUSER_ROLE = keccak256('UNPAUSER_ROLE');
  bytes32 public constant CLAIM_OPERATOR_ROLE = keccak256('CLAIM_OPERATOR_ROLE');

  function __MD1Roles_init()
    internal
  {
    // Assign the OWNER_ROLE to the sender.
    _setupRole(OWNER_ROLE, msg.sender);

    // Set OWNER_ROLE as the admin of all roles.
    _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
    _setRoleAdmin(CONFIG_UPDATER_ROLE, OWNER_ROLE);
    _setRoleAdmin(PAUSER_ROLE, OWNER_ROLE);
    _setRoleAdmin(UNPAUSER_ROLE, OWNER_ROLE);
    _setRoleAdmin(CLAIM_OPERATOR_ROLE, OWNER_ROLE);
  }
}

// SPDX-License-Identifier: AGPL-3.0
/**
 * @title MD1Configuration
 * @author Axor
 *
 * @notice Functions for modifying the Merkle distributor rewards configuration.
 *
 *  The more sensitive configuration values, which potentially give full control over the contents
 *  of the Merkle tree, may only be updated by the OWNER_ROLE. Other values may be configured by
 *  the CONFIG_UPDATER_ROLE.
 *
 *  Note that these configuration values are made available externally but are not used internally
 *  within this contract, with the exception of the IPFS update period which is used by
 *  the getIpfsEpoch() function.
 */
abstract contract MD1Configuration is
  MD1EpochSchedule,
  MD1Roles {
  // ============ Constants ============

  uint256 public constant TRADER_SCORE_ALPHA_BASE = 10 ** 18;

  // ============ Events ============

  event RewardsOracleChanged(
    address rewardsOracle
  );

  event IpnsNameUpdated(
    string ipnsName
  );

  event IpfsUpdatePeriodUpdated(
    uint256 ipfsUpdatePeriod
  );

  event RewardsParametersUpdated(
    uint256 marketMakerRewardsAmount,
    uint256 traderRewardsAmount,
    uint256 traderScoreAlpha
  );

  // ============ Initializer ============

  function __MD1Configuration_init(
    address rewardsOracle,
    string calldata ipnsName,
    uint256 ipfsUpdatePeriod,
    uint256 marketMakerRewardsAmount,
    uint256 traderRewardsAmount,
    uint256 traderScoreAlpha
  )
    internal
  {
    _setRewardsOracle(rewardsOracle);
    _setIpnsName(ipnsName);
    _setIpfsUpdatePeriod(ipfsUpdatePeriod);
    _setRewardsParameters(
      marketMakerRewardsAmount,
      traderRewardsAmount,
      traderScoreAlpha
    );
  }

  // ============ External Functions ============

  /**
   * @notice Set the address of the oracle which provides Merkle root updates.
   *
   * @param  rewardsOracle  The new oracle address.
   */
  function setRewardsOracle(
    address rewardsOracle
  )
    external
    onlyRole(OWNER_ROLE)
    nonReentrant
  {
    _setRewardsOracle(rewardsOracle);
  }

  /**
   * @notice Set the IPNS name to which trader and market maker exchange statistics are published.
   *
   * @param  ipnsName  The new IPNS name.
   */
  function setIpnsName(
    string calldata ipnsName
  )
    external
    onlyRole(OWNER_ROLE)
    nonReentrant
  {
    _setIpnsName(ipnsName);
  }

  /**
   * @notice Set the period of time after the epoch end after which the new epoch exchange
   *  statistics should be available on IPFS via the IPNS name.
   *
   *  This can be used as a trigger for “keepers” who are incentivized to call the proposeRoot()
   *  and updateRoot() functions as needed.
   *
   * @param  ipfsUpdatePeriod  The new IPFS update period, in seconds.
   */
  function setIpfsUpdatePeriod(
    uint256 ipfsUpdatePeriod
  )
    external
    onlyRole(CONFIG_UPDATER_ROLE)
    nonReentrant
  {
    _setIpfsUpdatePeriod(ipfsUpdatePeriod);
  }

  /**
   * @notice Set the rewards formula parameters.
   *
   * @param  marketMakerRewardsAmount  Max rewards distributed per epoch as market maker incentives.
   * @param  traderRewardsAmount       Max rewards distributed per epoch as trader incentives.
   * @param  traderScoreAlpha          The alpha parameter between 0 and 1, in units out of 10^18.
   */
  function setRewardsParameters(
    uint256 marketMakerRewardsAmount,
    uint256 traderRewardsAmount,
    uint256 traderScoreAlpha
  )
    external
    onlyRole(CONFIG_UPDATER_ROLE)
    nonReentrant
  {
    _setRewardsParameters(marketMakerRewardsAmount, traderRewardsAmount, traderScoreAlpha);
  }

  /**
   * @notice Set the parameters defining the function from timestamp to epoch number.
   *
   * @param  interval  The length of an epoch, in seconds.
   * @param  offset    The start of epoch zero, in seconds.
   */
  function setEpochParameters(
    uint256 interval,
    uint256 offset
  )
    external
    onlyRole(CONFIG_UPDATER_ROLE)
    nonReentrant
  {
    _setEpochParameters(interval, offset);
  }

  // ============ Internal Functions ============

  function _setRewardsOracle(
    address rewardsOracle
  )
    internal
  {
    _REWARDS_ORACLE_ = IRewardsOracle(rewardsOracle);
    emit RewardsOracleChanged(rewardsOracle);
  }

  function _setIpnsName(
    string calldata ipnsName
  )
    internal
  {
    _IPNS_NAME_ = ipnsName;
    emit IpnsNameUpdated(ipnsName);
  }

  function _setIpfsUpdatePeriod(
    uint256 ipfsUpdatePeriod
  )
    internal
  {
    _IPFS_UPDATE_PERIOD_ = ipfsUpdatePeriod;
    emit IpfsUpdatePeriodUpdated(ipfsUpdatePeriod);
  }

  function _setRewardsParameters(
    uint256 marketMakerRewardsAmount,
    uint256 traderRewardsAmount,
    uint256 traderScoreAlpha
  )
    internal
  {
    require(
      traderScoreAlpha <= TRADER_SCORE_ALPHA_BASE,
      'MD1Configuration: Invalid traderScoreAlpha'
    );

    _MARKET_MAKER_REWARDS_AMOUNT_ = marketMakerRewardsAmount;
    _TRADER_REWARDS_AMOUNT_ = traderRewardsAmount;
    _TRADER_SCORE_ALPHA_ = traderScoreAlpha;

    emit RewardsParametersUpdated(
      marketMakerRewardsAmount,
      traderRewardsAmount,
      traderScoreAlpha
    );
  }
}