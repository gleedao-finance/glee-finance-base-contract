pragma solidity 0.7.5;

import './interfaces/IERC20.sol';
import './interfaces/IBondCalculator.sol';

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

interface ITreasury {
  function setTotalReserve(uint256 _totalReserve) external;
}

contract TreasuryHelper is Ownable {
  using SafeMath for uint256;

  address public immutable GLFI;
  address public treasuryAddress;

  event ChangeQueued(MANAGING indexed managing, address queued);
  event ChangeActivated(
    MANAGING indexed managing,
    address activated,
    bool result
  );
  event ReservesUpdated(uint256 indexed totalReserves);
  event ReservesAudited(uint256 indexed totalReserves);

  enum MANAGING {
    RESERVEDEPOSITOR,
    RESERVESPENDER,
    RESERVETOKEN,
    RESERVEMANAGER,
    LIQUIDITYDEPOSITOR,
    LIQUIDITYTOKEN,
    LIQUIDITYMANAGER,
    DEBTOR,
    REWARDMANAGER,
    SGLFI
  }

  uint256 public immutable blocksNeededForQueue;

  address[] public reserveTokens; // Push only, beware false-positives.
  mapping(address => bool) public isReserveToken;
  mapping(address => uint256) public reserveTokenQueue; // Delays changes to mapping.

  address[] public reserveDepositors; // Push only, beware false-positives. Only for viewing.
  mapping(address => bool) public isReserveDepositor;
  mapping(address => uint256) public reserveDepositorQueue; // Delays changes to mapping.

  address[] public reserveSpenders; // Push only, beware false-positives. Only for viewing.
  mapping(address => bool) public isReserveSpender;
  mapping(address => uint256) public reserveSpenderQueue; // Delays changes to mapping.

  address[] public liquidityTokens; // Push only, beware false-positives.
  mapping(address => bool) public isLiquidityToken;
  mapping(address => uint256) public LiquidityTokenQueue; // Delays changes to mapping.

  address[] public liquidityDepositors; // Push only, beware false-positives. Only for viewing.
  mapping(address => bool) public isLiquidityDepositor;
  mapping(address => uint256) public LiquidityDepositorQueue; // Delays changes to mapping.

  mapping(address => address) public bondCalculator; // bond calculator for liquidity token

  address[] public reserveManagers; // Push only, beware false-positives. Only for viewing.
  mapping(address => bool) public isReserveManager;
  mapping(address => uint256) public ReserveManagerQueue; // Delays changes to mapping.

  address[] public liquidityManagers; // Push only, beware false-positives. Only for viewing.
  mapping(address => bool) public isLiquidityManager;
  mapping(address => uint256) public LiquidityManagerQueue; // Delays changes to mapping.

  address[] public debtors; // Push only, beware false-positives. Only for viewing.
  mapping(address => bool) public isDebtor;
  mapping(address => uint256) public debtorQueue; // Delays changes to mapping.

  address[] public rewardManagers; // Push only, beware false-positives. Only for viewing.
  mapping(address => bool) public isRewardManager;
  mapping(address => uint256) public rewardManagerQueue; // Delays changes to mapping.

  address public sGLFI;
  uint256 public sGLFIQueue;

  constructor(
    address _GLFI,
    address _MIM,
    uint256 _blocksNeededForQueue
  ) {
    GLFI = _GLFI;
    reserveTokens.push(_MIM);
    isReserveToken[_MIM] = true;
    blocksNeededForQueue = _blocksNeededForQueue;
  }

  function setTreasuryAddress(address _treasuryAddress) public onlyManager {
    treasuryAddress = _treasuryAddress;
  }

  /**
        @notice takes inventory of all tracked assets
        @notice always consolidate to recognized reserves before audit
     */
  function auditReserves() external onlyManager {
    uint256 reserves;
    for (uint256 i = 0; i < reserveTokens.length; i++) {
      reserves = reserves.add(
        valueOfToken(
          reserveTokens[i],
          IERC20(reserveTokens[i]).balanceOf(address(this))
        )
      );
    }
    for (uint256 i = 0; i < liquidityTokens.length; i++) {
      reserves = reserves.add(
        valueOfToken(
          liquidityTokens[i],
          IERC20(liquidityTokens[i]).balanceOf(address(this))
        )
      );
    }
    ITreasury(treasuryAddress).setTotalReserve(reserves);
    emit ReservesUpdated(reserves);
    emit ReservesAudited(reserves);
  }

  /**
        @notice queue address to change boolean in mapping
        @param _managing MANAGING
        @param _address address
        @return bool
     */
  function queue(MANAGING _managing, address _address)
    external
    onlyManager
    returns (bool)
  {
    require(_address != address(0));
    if (_managing == MANAGING.RESERVEDEPOSITOR) {
      // 0
      reserveDepositorQueue[_address] = block.number.add(blocksNeededForQueue);
    } else if (_managing == MANAGING.RESERVESPENDER) {
      // 1
      reserveSpenderQueue[_address] = block.number.add(blocksNeededForQueue);
    } else if (_managing == MANAGING.RESERVETOKEN) {
      // 2
      reserveTokenQueue[_address] = block.number.add(blocksNeededForQueue);
    } else if (_managing == MANAGING.RESERVEMANAGER) {
      // 3
      ReserveManagerQueue[_address] = block.number.add(
        blocksNeededForQueue.mul(2)
      );
    } else if (_managing == MANAGING.LIQUIDITYDEPOSITOR) {
      // 4
      LiquidityDepositorQueue[_address] = block.number.add(
        blocksNeededForQueue
      );
    } else if (_managing == MANAGING.LIQUIDITYTOKEN) {
      // 5
      LiquidityTokenQueue[_address] = block.number.add(blocksNeededForQueue);
    } else if (_managing == MANAGING.LIQUIDITYMANAGER) {
      // 6
      LiquidityManagerQueue[_address] = block.number.add(
        blocksNeededForQueue.mul(2)
      );
    } else if (_managing == MANAGING.DEBTOR) {
      // 7
      debtorQueue[_address] = block.number.add(blocksNeededForQueue);
    } else if (_managing == MANAGING.REWARDMANAGER) {
      // 8
      rewardManagerQueue[_address] = block.number.add(blocksNeededForQueue);
    } else if (_managing == MANAGING.SGLFI) {
      // 9
      sGLFIQueue = block.number.add(blocksNeededForQueue);
    } else return false;

    emit ChangeQueued(_managing, _address);
    return true;
  }

  /**
        @notice verify queue then set boolean in mapping
        @param _managing MANAGING
        @param _address address
        @param _calculator address
        @return bool
     */
  function toggle(
    MANAGING _managing,
    address _address,
    address _calculator
  ) external onlyManager returns (bool) {
    require(_address != address(0));
    bool result;
    if (_managing == MANAGING.RESERVEDEPOSITOR) {
      // 0
      if (requirements(reserveDepositorQueue, isReserveDepositor, _address)) {
        reserveDepositorQueue[_address] = 0;
        if (!listContains(reserveDepositors, _address)) {
          reserveDepositors.push(_address);
        }
      }
      result = !isReserveDepositor[_address];
      isReserveDepositor[_address] = result;
    } else if (_managing == MANAGING.RESERVESPENDER) {
      // 1
      if (requirements(reserveSpenderQueue, isReserveSpender, _address)) {
        reserveSpenderQueue[_address] = 0;
        if (!listContains(reserveSpenders, _address)) {
          reserveSpenders.push(_address);
        }
      }
      result = !isReserveSpender[_address];
      isReserveSpender[_address] = result;
    } else if (_managing == MANAGING.RESERVETOKEN) {
      // 2
      if (requirements(reserveTokenQueue, isReserveToken, _address)) {
        reserveTokenQueue[_address] = 0;
        if (!listContains(reserveTokens, _address)) {
          reserveTokens.push(_address);
        }
      }
      result = !isReserveToken[_address];
      isReserveToken[_address] = result;
    } else if (_managing == MANAGING.RESERVEMANAGER) {
      // 3
      if (requirements(ReserveManagerQueue, isReserveManager, _address)) {
        reserveManagers.push(_address);
        ReserveManagerQueue[_address] = 0;
        if (!listContains(reserveManagers, _address)) {
          reserveManagers.push(_address);
        }
      }
      result = !isReserveManager[_address];
      isReserveManager[_address] = result;
    } else if (_managing == MANAGING.LIQUIDITYDEPOSITOR) {
      // 4
      if (
        requirements(LiquidityDepositorQueue, isLiquidityDepositor, _address)
      ) {
        liquidityDepositors.push(_address);
        LiquidityDepositorQueue[_address] = 0;
        if (!listContains(liquidityDepositors, _address)) {
          liquidityDepositors.push(_address);
        }
      }
      result = !isLiquidityDepositor[_address];
      isLiquidityDepositor[_address] = result;
    } else if (_managing == MANAGING.LIQUIDITYTOKEN) {
      // 5
      if (requirements(LiquidityTokenQueue, isLiquidityToken, _address)) {
        LiquidityTokenQueue[_address] = 0;
        if (!listContains(liquidityTokens, _address)) {
          liquidityTokens.push(_address);
        }
      }
      result = !isLiquidityToken[_address];
      isLiquidityToken[_address] = result;
      bondCalculator[_address] = _calculator;
    } else if (_managing == MANAGING.LIQUIDITYMANAGER) {
      // 6
      if (requirements(LiquidityManagerQueue, isLiquidityManager, _address)) {
        LiquidityManagerQueue[_address] = 0;
        if (!listContains(liquidityManagers, _address)) {
          liquidityManagers.push(_address);
        }
      }
      result = !isLiquidityManager[_address];
      isLiquidityManager[_address] = result;
    } else if (_managing == MANAGING.DEBTOR) {
      // 7
      if (requirements(debtorQueue, isDebtor, _address)) {
        debtorQueue[_address] = 0;
        if (!listContains(debtors, _address)) {
          debtors.push(_address);
        }
      }
      result = !isDebtor[_address];
      isDebtor[_address] = result;
    } else if (_managing == MANAGING.REWARDMANAGER) {
      // 8
      if (requirements(rewardManagerQueue, isRewardManager, _address)) {
        rewardManagerQueue[_address] = 0;
        if (!listContains(rewardManagers, _address)) {
          rewardManagers.push(_address);
        }
      }
      result = !isRewardManager[_address];
      isRewardManager[_address] = result;
    } else if (_managing == MANAGING.SGLFI) {
      // 9
      sGLFIQueue = 0;
      sGLFI = _address;
      result = true;
    } else return false;

    emit ChangeActivated(_managing, _address, result);
    return true;
  }

  /**
        @notice checks requirements and returns altered structs
        @param queue_ mapping( address => uint )
        @param status_ mapping( address => bool )
        @param _address address
        @return bool 
     */
  function requirements(
    mapping(address => uint256) storage queue_,
    mapping(address => bool) storage status_,
    address _address
  ) internal view returns (bool) {
    if (!status_[_address]) {
      require(queue_[_address] != 0, 'Must queue');
      require(queue_[_address] <= block.number, 'Queue not expired');
      return true;
    }
    return false;
  }

  /**
        @notice checks array to ensure against duplicate
        @param _list address[]
        @param _token address
        @return bool
     */
  function listContains(address[] storage _list, address _token)
    internal
    view
    returns (bool)
  {
    for (uint256 i = 0; i < _list.length; i++) {
      if (_list[i] == _token) {
        return true;
      }
    }
    return false;
  }

  /**
        @notice returns OHM valuation of asset
        @param _token address
        @param _amount uint
        @return value_ uint
     */
  function valueOfToken(address _token, uint256 _amount) public view returns (uint256 value_) {
    if (isReserveToken[_token]) {
      // convert amount to match OHM decimals
      value_ = _amount.mul(10**IERC20(GLFI).decimals()).div(
        10**IERC20(_token).decimals()
      );
    } else if (isLiquidityToken[_token]) {
      value_ = IBondCalculator(bondCalculator[_token]).valuation(
        _token,
        _amount
      );
    }
  }
}
