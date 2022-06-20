pragma solidity 0.7.5;

import '../interfaces/IERC20.sol';

contract MIMFaucet {
    IERC20 public immutable mimContract;
    mapping(address => uint256) private _userMapping;

    constructor(address _mimContract) {
        require(_mimContract != address(0));
        mimContract = IERC20(_mimContract);
    }

    function faucet(address to_) external {
        require(to_ != address(0));
        require(_userMapping[to_] < (1e19), "User has MIM");
        require(mimContract.balanceOf(address(this)) >= 1e21, "Insufficient GLFI balance in faucet contract");
        mimContract.transfer(to_, 1e20);
    }
}