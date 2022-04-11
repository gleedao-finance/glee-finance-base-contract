pragma solidity 0.7.5;

import '../interfaces/IERC20.sol';

contract MIMFAUCET {
    IERC20 public token;

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;
    address owner;

    constructor(address _token) {
        require(_token != address(0));
        owner = msg.sender;
        token = IERC20(_token);
    }

    function depositMiM(address _token, uint256 _amount, address sender) public payable {
        require(msg.sender == owner, "Only owner can call this method");
        token.transferFrom(sender, address(this), _amount);
    }

    function totalSupply() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function faucet(address receiver) public payable {
        token.transfer(receiver, 100000000000000000000);
    }
}