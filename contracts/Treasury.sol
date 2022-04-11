/**
 *Submitted for verification at BscScan.com on 2021-11-12
 */

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }
}

library Address {
  function isContract(address account) internal view returns (bool) {
    // This method relies in extcodesize, which returns 0 for contracts in
    // construction, since the code is only stored at the end of the
    // constructor execution.

    uint256 size;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    return _functionCallWithValue(target, data, 0, errorMessage);
  }

  function _functionCallWithValue(
    address target,
    bytes memory data,
    uint256 weiValue,
    string memory errorMessage
  ) private returns (bytes memory) {
    require(isContract(target), 'Address: call to non-contract');

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.call{ value: weiValue }(
      data
    );
    if (success) {
      return returndata;
    } else {
      if (returndata.length > 0) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }

  function _verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) private pure returns (bytes memory) {
    if (success) {
      return returndata;
    } else {
      if (returndata.length > 0) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }
}

interface IOwnable {
  function manager() external view returns (address);

  function renounceManagement() external;

  function pushManagement(address newOwner_) external;

  function pullManagement() external;
}

contract Ownable is IOwnable {
  address internal _owner;
  address internal _newOwner;

  event OwnershipPushed(
    address indexed previousOwner,
    address indexed newOwner
  );
  event OwnershipPulled(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() {
    _owner = msg.sender;
    emit OwnershipPushed(address(0), _owner);
  }

  function manager() public view override returns (address) {
    return _owner;
  }

  modifier onlyManager() {
    require(_owner == msg.sender, 'Ownable: caller is not the owner');
    _;
  }

  function renounceManagement() public virtual override onlyManager {
    emit OwnershipPushed(_owner, address(0));
    _owner = address(0);
  }

  function pushManagement(address newOwner_)
    public
    virtual
    override
    onlyManager
  {
    require(newOwner_ != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipPushed(_owner, newOwner_);
    _newOwner = newOwner_;
  }

  function pullManagement() public virtual override {
    require(msg.sender == _newOwner, 'Ownable: must be new owner to pull');
    emit OwnershipPulled(_owner, _newOwner);
    _owner = _newOwner;
  }
}

interface IERC20 {
  function decimals() external view returns (uint8);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function approve(address spender, uint256 amount) external returns (bool);

  function totalSupply() external view returns (uint256);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transfer.selector, to, value)
    );
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
    );
  }

  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    bytes memory returndata = address(token).functionCall(
      data,
      'SafeERC20: low-level call failed'
    );
    if (returndata.length > 0) {
      // Return data is optional
      // solhint-disable-next-line max-line-length
      require(
        abi.decode(returndata, (bool)),
        'SafeERC20: ERC20 operation did not succeed'
      );
    }
  }
}

interface IERC20Mintable {
  function mint(uint256 amount_) external;

  function mint(address account_, uint256 ammount_) external;
}

interface IGLFIERC20 {
  function burnFrom(address account_, uint256 amount_) external;
}

interface IBondCalculator {
  function valuation(address pair_, uint256 amount_)
    external
    view
    returns (uint256 _value);
}

interface ITreasuryHelper {
  function isReserveToken(address token_) external view returns (bool);

  function isReserveDepositor(address token_) external view returns (bool);

  function isReserveSpender(address token_) external view returns (bool);

  function isLiquidityToken(address token_) external view returns (bool);

  function isLiquidityDepositor(address token_) external view returns (bool);

  function isReserveManager(address token_) external view returns (bool);

  function isLiquidityManager(address token_) external view returns (bool);

  function isDebtor(address token_) external view returns (bool);

  function isRewardManager(address token_) external view returns (bool);
}

contract GLFITreasury is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  event Deposit(address indexed token, uint256 amount, uint256 value);
  event Withdrawal(address indexed token, uint256 amount, uint256 value);
  event CreateDebt(
    address indexed debtor,
    address indexed token,
    uint256 amount,
    uint256 value
  );
  event RepayDebt(
    address indexed debtor,
    address indexed token,
    uint256 amount,
    uint256 value
  );
  event ReservesManaged(address indexed token, uint256 amount);
  event RewardsMinted(
    address indexed caller,
    address indexed recipient,
    uint256 amount
  );
  event ReservesUpdated(uint256 indexed totalReserves);

  address public immutable GLFI;
  address public immutable treasuryHelper;
  address public auditOwner;

  mapping(address => address) public bondCalculator; // bond calculator for liquidity token

  mapping(address => uint256) public debtorBalance;

  address public sGLFI;

  uint256 public totalReserves; // Risk-free value of all assets
  uint256 public totalDebt;

  constructor(address _GLFI, address _treasuryHelper) {
    require(_GLFI != address(0));
    GLFI = _GLFI;
    treasuryHelper = _treasuryHelper;
  }

  /**
        @notice allow approved address to deposit an asset for OHM
        @param _amount uint
        @param _token address
        @param _profit uint
        @return send_ uint
     */
  function deposit(
    uint256 _amount,
    address _token,
    uint256 _profit
  ) external returns (uint256 send_) {
    bool isReserveToken = ITreasuryHelper(treasuryHelper).isReserveToken(
      _token
    );
    bool isLiquidityToken = ITreasuryHelper(treasuryHelper).isLiquidityToken(
      _token
    );
    require(isReserveToken || isLiquidityToken, 'NA');
    IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

    if (isReserveToken) {
      require(
        ITreasuryHelper(treasuryHelper).isReserveDepositor(msg.sender),
        'NAPPROVED'
      );
    } else {
      require(
        ITreasuryHelper(treasuryHelper).isLiquidityDepositor(msg.sender),
        'NAPPROVED'
      );
    }

    uint256 value = valueOfToken(_token, _amount);
    // mint OHM needed and store amount of rewards for distribution
    send_ = value.sub(_profit);
    IERC20Mintable(GLFI).mint(msg.sender, send_);

    totalReserves = totalReserves.add(value);
    emit ReservesUpdated(totalReserves);

    emit Deposit(_token, _amount, value);
  }

  /**
        @notice allow approved address to burn OHM for reserves
        @param _amount uint
        @param _token address
     */
  function withdraw(uint256 _amount, address _token) external {
    // Only reserves can be used for redemptions
    require(ITreasuryHelper(treasuryHelper).isReserveToken(_token), 'NA');
    require(
      ITreasuryHelper(treasuryHelper).isReserveSpender(msg.sender),
      'NApproved'
    );

    uint256 value = valueOfToken(_token, _amount);
    IGLFIERC20(GLFI).burnFrom(msg.sender, value);

    totalReserves = totalReserves.sub(value);
    emit ReservesUpdated(totalReserves);

    IERC20(_token).safeTransfer(msg.sender, _amount);

    emit Withdrawal(_token, _amount, value);
  }

  /**
        @notice allow approved address to borrow reserves
        @param _amount uint
        @param _token address
     */
  function incurDebt(uint256 _amount, address _token) external {
    require(ITreasuryHelper(treasuryHelper).isDebtor(msg.sender), 'NApproved');

    require(ITreasuryHelper(treasuryHelper).isReserveToken(_token), 'NA');

    uint256 value = valueOfToken(_token, _amount);

    uint256 maximumDebt = IERC20(sGLFI).balanceOf(msg.sender); // Can only borrow against sOHM held
    uint256 availableDebt = maximumDebt.sub(debtorBalance[msg.sender]);
    require(value <= availableDebt, 'Exceeds debt limit');

    debtorBalance[msg.sender] = debtorBalance[msg.sender].add(value);
    totalDebt = totalDebt.add(value);

    totalReserves = totalReserves.sub(value);
    emit ReservesUpdated(totalReserves);

    IERC20(_token).transfer(msg.sender, _amount);

    emit CreateDebt(msg.sender, _token, _amount, value);
  }

  /**
        @notice allow approved address to repay borrowed reserves with reserves
        @param _amount uint
        @param _token address
     */
  function repayDebtWithReserve(uint256 _amount, address _token) external {
    require(ITreasuryHelper(treasuryHelper).isDebtor(msg.sender), 'NApproved');

    require(ITreasuryHelper(treasuryHelper).isReserveToken(_token), 'NA');

    IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

    uint256 value = valueOfToken(_token, _amount);
    debtorBalance[msg.sender] = debtorBalance[msg.sender].sub(value);
    totalDebt = totalDebt.sub(value);

    totalReserves = totalReserves.add(value);
    emit ReservesUpdated(totalReserves);

    emit RepayDebt(msg.sender, _token, _amount, value);
  }

  /**
        @notice allow approved address to repay borrowed reserves with OHM
        @param _amount uint
     */
  function repayDebtWithOHM(uint256 _amount) external {
    require(ITreasuryHelper(treasuryHelper).isDebtor(msg.sender), 'NApproved');

    IGLFIERC20(GLFI).burnFrom(msg.sender, _amount);

    debtorBalance[msg.sender] = debtorBalance[msg.sender].sub(_amount);
    totalDebt = totalDebt.sub(_amount);

    emit RepayDebt(msg.sender, GLFI, _amount, _amount);
  }

  /**
        @notice allow approved address to withdraw assets
        @param _token address
        @param _amount uint
     */
  function manage(address _token, uint256 _amount) external {
    bool isLPToken = ITreasuryHelper(treasuryHelper).isLiquidityToken(_token);
    if (isLPToken) {
      require(
        ITreasuryHelper(treasuryHelper).isLiquidityManager(msg.sender),
        'NApproved'
      );
    } else {
      require(
        ITreasuryHelper(treasuryHelper).isReserveManager(msg.sender),
        'NApproved'
      );
    }

    uint256 value = valueOfToken(_token, _amount);
    require(value <= excessReserves(), 'Insufficient reserves');

    totalReserves = totalReserves.sub(value);
    emit ReservesUpdated(totalReserves);

    IERC20(_token).safeTransfer(msg.sender, _amount);

    emit ReservesManaged(_token, _amount);
  }

  /**
        @notice send epoch reward to staking contract
     */
  function mintRewards(address _recipient, uint256 _amount) external {
    require(
      ITreasuryHelper(treasuryHelper).isRewardManager(msg.sender),
      'NApproved'
    );
    require(_amount <= excessReserves(), 'Insufficient reserves');

    IERC20Mintable(GLFI).mint(_recipient, _amount);

    emit RewardsMinted(msg.sender, _recipient, _amount);
  }

  /**
        @notice returns excess reserves not backing tokens
        @return uint
     */
  function excessReserves() public view returns (uint256) {
    return totalReserves.sub(IERC20(GLFI).totalSupply().sub(totalDebt));
  }

  /**
        @notice returns GLFI valuation of asset
        @param _token address
        @param _amount uint
        @return value_ uint
     */
  function valueOfToken(address _token, uint256 _amount)
    public
    view
    returns (uint256 value_)
  {
    if (ITreasuryHelper(treasuryHelper).isReserveToken(_token)) {
      // convert amount to match OHM decimals
      value_ = _amount.mul(10**IERC20(GLFI).decimals()).div(
        10**IERC20(_token).decimals()
      );
    } else if (ITreasuryHelper(treasuryHelper).isLiquidityToken(_token)) {
      value_ = IBondCalculator(bondCalculator[_token]).valuation(
        _token,
        _amount
      );
    }
  }

  modifier onlyAuditOwner() {
    require(auditOwner == msg.sender, 'Ownable: caller is not the audit owner');
    _;
  }

  function setTotalReserve(uint256 _totalReserves) external onlyAuditOwner {
    totalReserves = _totalReserves;
  }

  function setAuditOwner(address _auditOwner) public onlyManager {
    auditOwner = _auditOwner;
  }
}
