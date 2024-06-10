pragma solidity 0.7.5;
pragma abicoder v2;


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

library Address {
  /**
   * @dev Returns true if `account` is a contract.
   *
   * [IMPORTANT]
   * ====
   * It is unsafe to assume that an address for which this function returns
   * false is an externally-owned account (EOA) and not a contract.
   *
   * Among others, `isContract` will return false for the following
   * types of addresses:
   *
   *  - an externally-owned account
   *  - a contract in construction
   *  - an address where a contract will be created
   *  - an address where a contract lived, but was destroyed
   * ====
   */
  function isContract(address account) internal view returns (bool) {
    // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
    // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
    // for accounts without code, i.e. `keccak256('')`
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }

  /**
   * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
   * `recipient`, forwarding all available gas and reverting on errors.
   *
   * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
   * of certain opcodes, possibly making contracts go over the 2300 gas limit
   * imposed by `transfer`, making them unable to receive funds via
   * `transfer`. {sendValue} removes this limitation.
   *
   * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
   *
   * IMPORTANT: because control is transferred to `recipient`, care must be
   * taken to not create reentrancy vulnerabilities. Consider using
   * {ReentrancyGuard} or the
   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
   */
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, 'Address: insufficient balance');

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{value: amount}('');
    require(success, 'Address: unable to send value, recipient may have reverted');
  }
}

library SafeERC20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      'SafeERC20: approve from non-zero to non-zero allowance'
    );
    callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function callOptionalReturn(IERC20 token, bytes memory data) private {
    require(address(token).isContract(), 'SafeERC20: call to non-contract');

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = address(token).call(data);
    require(success, 'SafeERC20: low-level call failed');

    if (returndata.length > 0) {
      // Return data is optional
      // solhint-disable-next-line max-line-length
      require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
    }
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

library SafeCast {

  /**
   * @dev Downcast to a uint16, reverting on overflow.
   */
  function toUint16(
    uint256 a
  )
    internal
    pure
    returns (uint16)
  {
    uint16 b = uint16(a);
    require(
      uint256(b) == a,
      'SafeCast: toUint16 overflow'
    );
    return b;
  }

  /**
   * @dev Downcast to a uint32, reverting on overflow.
   */
  function toUint32(
    uint256 a
  )
    internal
    pure
    returns (uint32)
  {
    uint32 b = uint32(a);
    require(
      uint256(b) == a,
      'SafeCast: toUint32 overflow'
    );
    return b;
  }

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

  /**
   * @dev Downcast to a uint224, reverting on overflow.
   */
  function toUint224(
    uint256 a
  )
    internal
    pure
    returns (uint224)
  {
    uint224 b = uint224(a);
    require(
      uint256(b) == a,
      'SafeCast: toUint224 overflow'
    );
    return b;
  }

  /**
   * @dev Downcast to a uint240, reverting on overflow.
   */
  function toUint240(
    uint256 a
  )
    internal
    pure
    returns (uint240)
  {
    uint240 b = uint240(a);
    require(
      uint256(b) == a,
      'SafeCast: toUint240 overflow'
    );
    return b;
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

abstract contract SM1EpochSchedule is
  SM1Storage {
  using SafeCast for uint256;
  using SafeMath for uint256;

  // ============ Events ============

  event EpochParametersChanged(
    SM1Types.EpochParameters epochParameters
  );

  event BlackoutWindowChanged(
    uint256 blackoutWindow
  );

  // ============ Initializer ============

  function __SM1EpochSchedule_init(
    uint256 interval,
    uint256 offset,
    uint256 blackoutWindow
  )
    internal
  {
    require(
      block.timestamp < offset,
      'SM1EpochSchedule: Epoch zero must start after initialization'
    );
    _setBlackoutWindow(blackoutWindow);
    _setEpochParameters(interval, offset);
  }

  // ============ Public Functions ============

  /**
   * @notice Get the epoch at the current block timestamp.
   *
   *  NOTE: Reverts if epoch zero has not started.
   *
   * @return The current epoch number.
   */
  function getCurrentEpoch()
    public
    view
    returns (uint256)
  {
    (uint256 interval, uint256 offsetTimestamp) = _getIntervalAndOffsetTimestamp();
    return offsetTimestamp.div(interval);
  }

  /**
   * @notice Get the time remaining in the current epoch.
   *
   *  NOTE: Reverts if epoch zero has not started.
   *
   * @return The number of seconds until the next epoch.
   */
  function getTimeRemainingInCurrentEpoch()
    public
    view
    returns (uint256)
  {
    (uint256 interval, uint256 offsetTimestamp) = _getIntervalAndOffsetTimestamp();
    uint256 timeElapsedInEpoch = offsetTimestamp.mod(interval);
    return interval.sub(timeElapsedInEpoch);
  }

  /**
   * @notice Given an epoch number, get the start of that epoch. Calculated as `t = (n * a) + b`.
   *
   * @return The timestamp in seconds representing the start of that epoch.
   */
  function getStartOfEpoch(
    uint256 epochNumber
  )
    public
    view
    returns (uint256)
  {
    SM1Types.EpochParameters memory epochParameters = _EPOCH_PARAMETERS_;
    uint256 interval = uint256(epochParameters.interval);
    uint256 offset = uint256(epochParameters.offset);
    return epochNumber.mul(interval).add(offset);
  }

  /**
   * @notice Check whether we are at or past the start of epoch zero.
   *
   * @return Boolean `true` if the current timestamp is at least the start of epoch zero,
   *  otherwise `false`.
   */
  function hasEpochZeroStarted()
    public
    view
    returns (bool)
  {
    SM1Types.EpochParameters memory epochParameters = _EPOCH_PARAMETERS_;
    uint256 offset = uint256(epochParameters.offset);
    return block.timestamp >= offset;
  }

  /**
   * @notice Check whether we are in a blackout window, where withdrawal requests are restricted.
   *  Note that before epoch zero has started, there are no blackout windows.
   *
   * @return Boolean `true` if we are in a blackout window, otherwise `false`.
   */
  function inBlackoutWindow()
    public
    view
    returns (bool)
  {
    return hasEpochZeroStarted() && getTimeRemainingInCurrentEpoch() <= _BLACKOUT_WINDOW_;
  }

  // ============ Internal Functions ============

  function _setEpochParameters(
    uint256 interval,
    uint256 offset
  )
    internal
  {
    SM1Types.EpochParameters memory epochParameters =
      SM1Types.EpochParameters({interval: interval.toUint128(), offset: offset.toUint128()});
    _EPOCH_PARAMETERS_ = epochParameters;
    emit EpochParametersChanged(epochParameters);
  }

  function _setBlackoutWindow(
    uint256 blackoutWindow
  )
    internal
  {
    _BLACKOUT_WINDOW_ = blackoutWindow;
    emit BlackoutWindowChanged(blackoutWindow);
  }

  // ============ Private Functions ============

  /**
   * @dev Helper function to read params from storage and apply offset to the given timestamp.
   *  Recall that the formula for epoch number is `n = (t - b) / a`.
   *
   *  NOTE: Reverts if epoch zero has not started.
   *
   * @return The values `a` and `(t - b)`.
   */
  function _getIntervalAndOffsetTimestamp()
    private
    view
    returns (uint256, uint256)
  {
    SM1Types.EpochParameters memory epochParameters = _EPOCH_PARAMETERS_;
    uint256 interval = uint256(epochParameters.interval);
    uint256 offset = uint256(epochParameters.offset);

    require(
      block.timestamp >= offset,
      'SM1EpochSchedule: Epoch zero has not started'
    );

    uint256 offsetTimestamp = block.timestamp.sub(offset);
    return (interval, offsetTimestamp);
  }
}

// SPDX-License-Identifier: AGPL-3.0
/**
 * @title SM1Rewards
 * @author Axor
 *
 * @dev Manages the distribution of token rewards.
 *
 *  Rewards are distributed continuously. After each second, an account earns rewards `r` according
 *  to the following formula:
 *
 *      r = R * s / S
 *
 *  Where:
 *    - `R` is the rewards distributed globally each second, also called the “emission rate.”
 *    - `s` is the account's staked balance in that second (technically, it is measured at the
 *      end of the second)
 *    - `S` is the sum total of all staked balances in that second (again, measured at the end of
 *      the second)
 *
 *  The parameter `R` can be configured by the contract owner. For every second that elapses,
 *  exactly `R` tokens will accrue to users, save for rounding errors, and with the exception that
 *  while the total staked balance is zero, no tokens will accrue to anyone.
 *
 *  The accounting works as follows: A global index is stored which represents the cumulative
 *  number of rewards tokens earned per staked token since the start of the distribution.
 *  The value of this index increases over time, and there are two factors affecting the rate of
 *  increase:
 *    1) The emission rate (in the numerator)
 *    2) The total number of staked tokens (in the denominator)
 *
 *  Whenever either factor changes, in some timestamp T, we settle the global index up to T by
 *  calculating the increase in the index since the last update using the OLD values of the factors:
 *
 *    indexDelta = timeDelta * emissionPerSecond * INDEX_BASE / totalStaked
 *
 *  Where `INDEX_BASE` is a scaling factor used to allow more precision in the storage of the index.
 *
 *  For each user we store an accrued rewards balance, as well as a user index, which is a cache of
 *  the global index at the time that the user's accrued rewards balance was last updated. Then at
 *  any point in time, a user's claimable rewards are represented by the following:
 *
 *    rewards = _USER_REWARDS_BALANCES_[user] + userStaked * (
 *                settledGlobalIndex - _USER_INDEXES_[user]
 *              ) / INDEX_BASE
 */
abstract contract SM1Rewards is
  SM1EpochSchedule {
  using SafeCast for uint256;
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  // ============ Constants ============

  /// @dev Additional precision used to represent the global and user index values.
  uint256 private constant INDEX_BASE = 10**18;

  /// @notice The rewards token.
  IERC20 public immutable REWARDS_TOKEN;

  /// @notice Address to pull rewards from. Must have provided an allowance to this contract.
  address public immutable REWARDS_TREASURY;

  /// @notice Start timestamp (inclusive) of the period in which rewards can be earned.
  uint256 public immutable DISTRIBUTION_START;

  /// @notice End timestamp (exclusive) of the period in which rewards can be earned.
  uint256 public immutable DISTRIBUTION_END;

  // ============ Events ============

  event RewardsPerSecondUpdated(
    uint256 emissionPerSecond
  );

  event GlobalIndexUpdated(
    uint256 index
  );

  event UserIndexUpdated(
    address indexed user,
    uint256 index,
    uint256 unclaimedRewards
  );

  event ClaimedRewards(
    address indexed user,
    address recipient,
    uint256 claimedRewards
  );

  // ============ Constructor ============

  constructor(
    IERC20 rewardsToken,
    address rewardsTreasury,
    uint256 distributionStart,
    uint256 distributionEnd
  ) {
    require(
      distributionEnd >= distributionStart,
      'SM1Rewards: Invalid parameters'
    );
    REWARDS_TOKEN = rewardsToken;
    REWARDS_TREASURY = rewardsTreasury;
    DISTRIBUTION_START = distributionStart;
    DISTRIBUTION_END = distributionEnd;
  }

  // ============ External Functions ============

  /**
   * @notice The current emission rate of rewards.
   *
   * @return The number of rewards tokens issued globally each second.
   */
  function getRewardsPerSecond()
    external
    view
    returns (uint256)
  {
    return _REWARDS_PER_SECOND_;
  }

  // ============ Internal Functions ============

  /**
   * @dev Initialize the contract.
   */
  function __SM1Rewards_init()
    internal
  {
    _GLOBAL_INDEX_TIMESTAMP_ = Math.max(block.timestamp, DISTRIBUTION_START).toUint32();
  }

  /**
   * @dev Set the emission rate of rewards.
   *
   *  IMPORTANT: Do not call this function without settling the total staked balance first, to
   *  ensure that the index is settled up to the epoch boundaries.
   *
   * @param  emissionPerSecond  The new number of rewards tokens to give out each second.
   * @param  totalStaked        The total staked balance.
   */
  function _setRewardsPerSecond(
    uint256 emissionPerSecond,
    uint256 totalStaked
  )
    internal
  {
    _settleGlobalIndexUpToNow(totalStaked);
    _REWARDS_PER_SECOND_ = emissionPerSecond;
    emit RewardsPerSecondUpdated(emissionPerSecond);
  }

  /**
   * @dev Claim tokens, sending them to the specified recipient.
   *
   *  Note: In order to claim all accrued rewards, the total and user staked balances must first be
   *  settled before calling this function.
   *
   * @param  user       The user's address.
   * @param  recipient  The address to send rewards to.
   *
   * @return The number of rewards tokens claimed.
   */
  function _claimRewards(
    address user,
    address recipient
  )
    internal
    returns (uint256)
  {
    uint256 accruedRewards = _USER_REWARDS_BALANCES_[user];
    _USER_REWARDS_BALANCES_[user] = 0;
    REWARDS_TOKEN.safeTransferFrom(REWARDS_TREASURY, recipient, accruedRewards);
    emit ClaimedRewards(user, recipient, accruedRewards);
    return accruedRewards;
  }

  /**
   * @dev Settle a user's rewards up to the latest global index as of `block.timestamp`. Triggers a
   *  settlement of the global index up to `block.timestamp`. Should be called with the OLD user
   *  and total balances.
   *
   * @param  user         The user's address.
   * @param  userStaked   Tokens staked by the user during the period since the last user index
   *                      update.
   * @param  totalStaked  Total tokens staked by all users during the period since the last global
   *                      index update.
   *
   * @return The user's accrued rewards, including past unclaimed rewards.
   */
  function _settleUserRewardsUpToNow(
    address user,
    uint256 userStaked,
    uint256 totalStaked
  )
    internal
    returns (uint256)
  {
    uint256 globalIndex = _settleGlobalIndexUpToNow(totalStaked);
    return _settleUserRewardsUpToIndex(user, userStaked, globalIndex);
  }

  /**
   * @dev Settle a user's rewards up to an epoch boundary. Should be used to partially settle a
   *  user's rewards if their balance was known to have changed on that epoch boundary.
   *
   * @param  user         The user's address.
   * @param  userStaked   Tokens staked by the user. Should be accurate for the time period
   *                      since the last update to this user and up to the end of the
   *                      specified epoch.
   * @param  epochNumber  Settle the user's rewards up to the end of this epoch.
   *
   * @return The user's accrued rewards, including past unclaimed rewards, up to the end of the
   *  specified epoch.
   */
  function _settleUserRewardsUpToEpoch(
    address user,
    uint256 userStaked,
    uint256 epochNumber
  )
    internal
    returns (uint256)
  {
    uint256 globalIndex = _EPOCH_INDEXES_[epochNumber];
    return _settleUserRewardsUpToIndex(user, userStaked, globalIndex);
  }

  /**
   * @dev Settle the global index up to the end of the given epoch.
   *
   *  IMPORTANT: This function should only be called under conditions which ensure the following:
   *    - `epochNumber` < the current epoch number
   *    - `_GLOBAL_INDEX_TIMESTAMP_ < settleUpToTimestamp`
   *    - `_EPOCH_INDEXES_[epochNumber] = 0`
   */
  function _settleGlobalIndexUpToEpoch(
    uint256 totalStaked,
    uint256 epochNumber
  )
    internal
    returns (uint256)
  {
    uint256 settleUpToTimestamp = getStartOfEpoch(epochNumber.add(1));

    uint256 globalIndex = _settleGlobalIndexUpToTimestamp(totalStaked, settleUpToTimestamp);
    _EPOCH_INDEXES_[epochNumber] = globalIndex;
    return globalIndex;
  }

  // ============ Private Functions ============

  /**
   * @dev Updates the global index, reflecting cumulative rewards given out per staked token.
   *
   * @param  totalStaked          The total staked balance, which should be constant in the interval
   *                              since the last update to the global index.
   *
   * @return The new global index.
   */
  function _settleGlobalIndexUpToNow(
    uint256 totalStaked
  )
    private
    returns (uint256)
  {
    return _settleGlobalIndexUpToTimestamp(totalStaked, block.timestamp);
  }

  /**
   * @dev Helper function which settles a user's rewards up to a global index. Should be called
   *  any time a user's staked balance changes, with the OLD user and total balances.
   *
   * @param  user            The user's address.
   * @param  userStaked      Tokens staked by the user during the period since the last user index
   *                         update.
   * @param  newGlobalIndex  The new index value to bring the user index up to. MUST NOT be less
   *                         than the user's index.
   *
   * @return The user's accrued rewards, including past unclaimed rewards.
   */
  function _settleUserRewardsUpToIndex(
    address user,
    uint256 userStaked,
    uint256 newGlobalIndex
  )
    private
    returns (uint256)
  {
    uint256 oldAccruedRewards = _USER_REWARDS_BALANCES_[user];
    uint256 oldUserIndex = _USER_INDEXES_[user];

    if (oldUserIndex == newGlobalIndex) {
      return oldAccruedRewards;
    }

    uint256 newAccruedRewards;
    if (userStaked == 0) {
      // Note: Even if the user's staked balance is zero, we still need to update the user index.
      newAccruedRewards = oldAccruedRewards;
    } else {
      // Calculate newly accrued rewards since the last update to the user's index.
      uint256 indexDelta = newGlobalIndex.sub(oldUserIndex);
      uint256 accruedRewardsDelta = userStaked.mul(indexDelta).div(INDEX_BASE);
      newAccruedRewards = oldAccruedRewards.add(accruedRewardsDelta);

      // Update the user's rewards.
      _USER_REWARDS_BALANCES_[user] = newAccruedRewards;
    }

    // Update the user's index.
    _USER_INDEXES_[user] = newGlobalIndex;
    emit UserIndexUpdated(user, newGlobalIndex, newAccruedRewards);
    return newAccruedRewards;
  }

  /**
   * @dev Updates the global index, reflecting cumulative rewards given out per staked token.
   *
   * @param  totalStaked          The total staked balance, which should be constant in the interval
   *                              (_GLOBAL_INDEX_TIMESTAMP_, settleUpToTimestamp).
   * @param  settleUpToTimestamp  The timestamp up to which to settle rewards. It MUST satisfy
   *                              `settleUpToTimestamp <= block.timestamp`.
   *
   * @return The new global index.
   */
  function _settleGlobalIndexUpToTimestamp(
    uint256 totalStaked,
    uint256 settleUpToTimestamp
  )
    private
    returns (uint256)
  {
    uint256 oldGlobalIndex = uint256(_GLOBAL_INDEX_);

    // The goal of this function is to calculate rewards earned since the last global index update.
    // These rewards are earned over the time interval which is the intersection of the intervals
    // [_GLOBAL_INDEX_TIMESTAMP_, settleUpToTimestamp] and [DISTRIBUTION_START, DISTRIBUTION_END].
    //
    // We can simplify a bit based on the assumption:
    //   `_GLOBAL_INDEX_TIMESTAMP_ >= DISTRIBUTION_START`
    //
    // Get the start and end of the time interval under consideration.
    uint256 intervalStart = uint256(_GLOBAL_INDEX_TIMESTAMP_);
    uint256 intervalEnd = Math.min(settleUpToTimestamp, DISTRIBUTION_END);

    // Return early if the interval has length zero (incl. case where intervalEnd < intervalStart).
    if (intervalEnd <= intervalStart) {
      return oldGlobalIndex;
    }

    // Note: If we reach this point, we must update _GLOBAL_INDEX_TIMESTAMP_.

    uint256 emissionPerSecond = _REWARDS_PER_SECOND_;

    if (emissionPerSecond == 0 || totalStaked == 0) {
      // Ensure a log is emitted if the timestamp changed, even if the index does not change.
      _GLOBAL_INDEX_TIMESTAMP_ = intervalEnd.toUint32();
      emit GlobalIndexUpdated(oldGlobalIndex);
      return oldGlobalIndex;
    }

    // Calculate the change in index over the interval.
    uint256 timeDelta = intervalEnd.sub(intervalStart);
    uint256 indexDelta = timeDelta.mul(emissionPerSecond).mul(INDEX_BASE).div(totalStaked);

    // Calculate, update, and return the new global index.
    uint256 newGlobalIndex = oldGlobalIndex.add(indexDelta);

    // Update storage. (Shared storage slot.)
    _GLOBAL_INDEX_TIMESTAMP_ = intervalEnd.toUint32();
    _GLOBAL_INDEX_ = newGlobalIndex.toUint224();

    emit GlobalIndexUpdated(newGlobalIndex);
    return newGlobalIndex;
  }
}