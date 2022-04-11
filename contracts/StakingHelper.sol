// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

import './interfaces/IERC20.sol';
import './interfaces/IStaking.sol';

contract StakingHelper {
  event LogStake(address indexed recipient, uint256 amount);

  IStaking public immutable staking;
  IERC20 public immutable GLFI;

  constructor(address _staking, address _GLFI) {
    require(_staking != address(0));
    staking = IStaking(_staking);
    require(_GLFI != address(0));
    GLFI = IERC20(_GLFI);
  }

  function stake(uint256 _amount, address recipient) external {
    GLFI.transferFrom(msg.sender, address(this), _amount);
    GLFI.approve(address(staking), _amount);
    staking.stake(_amount, recipient);
    staking.claim(recipient);
    emit LogStake(recipient, _amount);
  }
}
