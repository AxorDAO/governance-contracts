// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.7.5;

import {ERC20} from '../dependencies/open-zeppelin/ERC20.sol';

contract USDT is ERC20 {
  uint256 public constant INITIAL_SUPPLY = 1_000_000_000 ether;

  function decimals() public view virtual override returns (uint8) {
    return 6;
  }

  constructor() ERC20('Tether USD', 'USDT') {
    _mint(msg.sender, INITIAL_SUPPLY);
  }

  function mint(uint256 amount) public virtual {
    _mint(msg.sender, amount);
  }
}
