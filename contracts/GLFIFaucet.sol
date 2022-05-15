// SPDX-License-Identifier: Apache 2.0
pragma solidity 0.7.5;

import './interfaces/IERC20.sol';

contract GLFIFaucet {
    IERC20 public immutable glfiContract;
    mapping(address => uint256) private _userMapping;

    constructor(address glfiAddress) {
        require(glfiAddress != address(0));
        glfiContract = IERC20(glfiAddress);
    }

    function faucet(address to_) external {
        require(to_ != address(0));
        require(_userMapping[to_] < (1e10), "User has GLFI");
        require(glfiContract.balanceOf(address(this)) >= 1e11, "Insufficient GLFI balance in faucet contract");
        glfiContract.transfer(to_, 1e11);
    }
}