pragma solidity ^0.4.24;

import "./ERC20.sol";

contract MockSpinToken is ERC20 {

  uint256 constant initialSupply = 1075000000 * (10 ** 18);

  constructor() public {
    _mint(msg.sender, initialSupply);
  }
}
