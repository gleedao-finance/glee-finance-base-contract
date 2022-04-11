// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

import './interfaces/IERC20.sol';

contract StakingWarmup {
  address public immutable staking;
  IERC20 public immutable sGLFI;

  constructor(address _staking, address _sGLFI) {
    require(_staking != address(0));
    staking = _staking;
    require(_sGLFI != address(0));
    sGLFI = IERC20(_sGLFI);
  }

  function retrieve(address _staker, uint256 _amount) external {
    require(msg.sender == staking, 'NA');
    sGLFI.transfer(_staker, _amount);
  }
}
