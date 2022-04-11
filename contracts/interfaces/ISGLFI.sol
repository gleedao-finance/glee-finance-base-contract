pragma solidity 0.7.5;

import './IERC20.sol';

interface ISGLFI is IERC20 {
  function rebase(uint256 ohmProfit_, uint256 epoch_)
    external
    returns (uint256);

  function circulatingSupply() external view returns (uint256);

  function balanceOf(address who) external view override returns (uint256);

  function gonsForBalance(uint256 amount) external view returns (uint256);

  function balanceForGons(uint256 gons) external view returns (uint256);

  function index() external view returns (uint256);
}
