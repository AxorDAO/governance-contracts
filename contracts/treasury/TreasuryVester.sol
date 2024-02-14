// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma abicoder v2;

import { SafeMath } from '../dependencies/open-zeppelin/SafeMath.sol';

interface IAxor {
  function balanceOf(
    address account
  )
    external
    view
    returns (uint256);

  function transfer(
    address destination,
    uint256 rawAmount
  )
    external
    returns (bool);
}

contract TreasuryVester {
  using SafeMath for uint256;

  address public axor;
  address public recipient;

  uint256 public vestingAmount;
  uint256 public vestingBegin;
  uint256 public vestingCliff;
  uint256 public vestingEnd;

  uint256 public lastUpdate;

  constructor(
    address axor_,
    address recipient_,
    uint256 vestingAmount_,
    uint256 vestingBegin_,
    uint256 vestingCliff_,
    uint256 vestingEnd_
  ) {
    require(
      vestingBegin_ >= block.timestamp,
      'VESTING_BEGIN_TOO_EARLY'
    );
    require(
      vestingCliff_ >= vestingBegin_,
      'VESTING_CLIFF_BEFORE_BEGIN'
    );
    require(
      vestingEnd_ > vestingCliff_,
      'VESTING_END_BEFORE_CLIFF'
    );

    axor = axor_;
    recipient = recipient_;

    vestingAmount = vestingAmount_;
    vestingBegin = vestingBegin_;
    vestingCliff = vestingCliff_;
    vestingEnd = vestingEnd_;

    lastUpdate = vestingBegin;
  }

  function setRecipient(
    address recipient_
  )
    public
  {
    require(
      msg.sender == recipient,
      'SET_RECIPIENT_UNAUTHORIZED'
    );
    recipient = recipient_;
  }

  function claim()
    public
  {
    require(
      block.timestamp >= vestingCliff,
      'CLAIM_TOO_EARLY'
    );
    uint256 amount;
    if (block.timestamp >= vestingEnd) {
      amount = IAxor(axor).balanceOf(address(this));
    } else {
      amount = vestingAmount.mul(block.timestamp - lastUpdate).div(vestingEnd - vestingBegin);
      lastUpdate = block.timestamp;
    }
    IAxor(axor).transfer(recipient, amount);
  }
}
