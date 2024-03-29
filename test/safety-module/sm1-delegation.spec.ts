import { expect } from 'chai';
import { parseEther } from 'ethers/lib/utils';

import { MAX_UINT_AMOUNT, ZERO_ADDRESS } from '../../src/lib/constants';
import { waitForTx } from '../../src/lib/util';
import {
  DoubleTransferHelper__factory,
} from '../../types';
import { describeContract, TestContext } from '../helpers/describe-contract';
import {
  advanceBlock,
  latestBlock,
  latestBlockTimestamp,
} from '../helpers/evm';
import { getUserKeys } from '../helpers/keys';
import { buildDelegateByTypeParams, buildDelegateParams, getChainIdForSigning, getSignatureFromTypedData } from '../helpers/signature-helpers';
import hre from '../hre';

const SAFETY_MODULE_EIP_712_DOMAIN_NAME = 'Axor Safety Module';

let userKeys: string[];

async function init(ctx: TestContext) {
  userKeys = getUserKeys();

  // Give some tokens to stakers and set allowance.
  const amount = hre.ethers.utils.parseEther('100').toString();
  for (const user of ctx.users) {
    await ctx.axorToken.connect(ctx.deployer).transfer(user.address, amount);
    await ctx.axorToken.connect(user).approve(ctx.safetyModule.address, amount);
  }
}

describeContract('Safety Module Staked AXOR - Power Delegation', init, (ctx: TestContext) => {

  it('User 1 tries to delegate voting power to user 2', async () => {
    await ctx.safetyModule.connect(ctx.users[1]).delegateByType(ctx.users[2].address, '0');

    const delegatee = await ctx.safetyModule.getDelegateeByType(ctx.users[1].address, '0');

    expect(delegatee).to.be.equal(ctx.users[2].address);
  });

  it('User 1 tries to delegate proposition power to user 3', async () => {
    await ctx.safetyModule.connect(ctx.users[1]).delegateByType(ctx.users[3].address, '1');

    const delegatee = await ctx.safetyModule.getDelegateeByType(ctx.users[1].address, '1');

    expect(delegatee).to.be.equal(ctx.users[3].address);
  });

  it('User 1 tries to delegate voting power to ZERO_ADDRESS but delegator should remain', async () => {
    const tokenBalance = parseEther('1');

    // Stake
    await ctx.safetyModule.connect(ctx.users[1]).stake(tokenBalance);

    // Track current power
    const priorPowerUser = await ctx.safetyModule.getPowerCurrent(ctx.users[1].address, '0');
    const priorPowerUserZeroAddress = await ctx.safetyModule.getPowerCurrent(ZERO_ADDRESS, '0');

    expect(priorPowerUser).to.be.equal(tokenBalance, 'user power should equal balance');
    expect(priorPowerUserZeroAddress).to.be.equal('0', 'zero address should have zero power');

    await expect(
      ctx.safetyModule.connect(ctx.users[1]).delegateByType(ZERO_ADDRESS, '0'),
    ).to.be.revertedWith('INVALID_DELEGATEE');
  });

  it('User 1 stakes 2 AXOR; checks voting and proposition power of user 2 and 3', async () => {
    // Setup: user 1 has delegated to ctx.users 2 and 3...
    await ctx.safetyModule.connect(ctx.users[1]).delegateByType(ctx.users[2].address, '0');
    await ctx.safetyModule.connect(ctx.users[1]).delegateByType(ctx.users[3].address, '1');

    const tokenBalance = parseEther('2');
    const expectedStaked = parseEther('2');

    // Stake
    await ctx.safetyModule.connect(ctx.users[1]).stakeFor(ctx.users[1].address, tokenBalance);

    const stakedTokenBalanceAfterMigration = await ctx.safetyModule.balanceOf(ctx.users[1].address);

    const user1PropPower = await ctx.safetyModule.getPowerCurrent(ctx.users[1].address, '0');
    const user1VotingPower = await ctx.safetyModule.getPowerCurrent(ctx.users[1].address, '1');

    const user2VotingPower = await ctx.safetyModule.getPowerCurrent(ctx.users[2].address, '0');
    const user2PropPower = await ctx.safetyModule.getPowerCurrent(ctx.users[2].address, '1');

    const user3VotingPower = await ctx.safetyModule.getPowerCurrent(ctx.users[3].address, '0');
    const user3PropPower = await ctx.safetyModule.getPowerCurrent(ctx.users[3].address, '1');

    expect(user1PropPower).to.be.equal('0', 'Incorrect prop power for user 1');
    expect(user1VotingPower).to.be.equal('0', 'Incorrect voting power for user 1');

    expect(user2PropPower).to.be.equal('0', 'Incorrect prop power for user 2');
    expect(user2VotingPower).to.be.equal(
      stakedTokenBalanceAfterMigration,
      'Incorrect voting power for user 2',
    );

    expect(user3PropPower).to.be.equal(
      stakedTokenBalanceAfterMigration,
      'Incorrect prop power for user 3',
    );
    expect(user3VotingPower).to.be.equal('0', 'Incorrect voting power for user 3');

    expect(expectedStaked).to.be.equal(stakedTokenBalanceAfterMigration);
  });

  describe('after user 1 delegates to ctx.users 2 and 3, and stakes 2 AXOR', () => {

    beforeEach(async () => {
      // Setup: user 1 has delegated to ctx.users 2 and 3 and stakes 2 AXOR...
      await ctx.safetyModule.connect(ctx.users[1]).delegateByType(ctx.users[2].address, '0');
      await ctx.safetyModule.connect(ctx.users[1]).delegateByType(ctx.users[3].address, '1');
      await ctx.safetyModule.connect(ctx.users[1]).stakeFor(ctx.users[1].address, parseEther('2'));
    });

    it('User 2 stakes 2 AXOR; checks voting and proposition power of user 2', async () => {
      const tokenBalance = parseEther('2');
      const expectedStakedTokenBalanceAfterStake = parseEther('2');

      // Stake
      await ctx.safetyModule.connect(ctx.users[2]).stakeFor(ctx.users[2].address, tokenBalance);

      const user2VotingPower = await ctx.safetyModule.getPowerCurrent(ctx.users[2].address, '0');
      const user2PropPower = await ctx.safetyModule.getPowerCurrent(ctx.users[2].address, '1');

      expect(user2PropPower).to.be.equal(
        expectedStakedTokenBalanceAfterStake,
        'Incorrect prop power for user 2',
      );
      expect(user2VotingPower).to.be.equal(
        expectedStakedTokenBalanceAfterStake.mul('2'),
        'Incorrect voting power for user 2',
      );
    });

    it('User 3 stakes 2 AXOR; checks voting and proposition power of user 3', async () => {
      // Stake
      await ctx.safetyModule.connect(ctx.users[3]).stakeFor(ctx.users[3].address, parseEther('2'));

      const user3VotingPower = await ctx.safetyModule.getPowerCurrent(ctx.users[3].address, '0');
      const user3PropPower = await ctx.safetyModule.getPowerCurrent(ctx.users[3].address, '1');

      expect(user3PropPower.toString()).to.be.equal(
        parseEther('4'),
        'Incorrect prop power for user 3',
      );
      expect(user3VotingPower.toString()).to.be.equal(
        parseEther('2'),
        'Incorrect voting power for user 3',
      );
    });

    it('User 2 also delegates powers to user 3', async () => {
      // Stake
      await ctx.safetyModule.connect(ctx.users[2]).stakeFor(ctx.users[2].address, parseEther('2'));
      await ctx.safetyModule.connect(ctx.users[3]).stakeFor(ctx.users[3].address, parseEther('2'));

      // Delegate
      await ctx.safetyModule.connect(ctx.users[2]).delegate(ctx.users[3].address);

      expect(await ctx.safetyModule.getPowerCurrent(ctx.users[3].address, '0')).to.be.equal(
        parseEther('4'),
        'Incorrect voting power for user 3',
      );
      expect(await ctx.safetyModule.getPowerCurrent(ctx.users[3].address, '1')).to.be.equal(
        parseEther('6'),
        'Incorrect prop power for user 3',
      );
    });
  });

  it('Checks the delegation at a past block', async () => {
    // Setup: user 1 has delegated to ctx.users 2 and 3...
    await ctx.safetyModule.connect(ctx.users[1]).delegateByType(ctx.users[2].address, '0');
    await ctx.safetyModule.connect(ctx.users[1]).delegateByType(ctx.users[3].address, '1');

    // Stake
    await ctx.safetyModule.connect(ctx.users[1]).stakeFor(ctx.users[1].address, parseEther('2'));
    const blockNumber = await latestBlock();

    const user1 = ctx.users[1];
    const user2 = ctx.users[2];
    const user3 = ctx.users[3];

    const user1VotingPower = await ctx.safetyModule.getPowerAtBlock(
      user1.address,
      blockNumber,
      '0',
    );
    const user1PropPower = await ctx.safetyModule.getPowerAtBlock(
      user1.address,
      blockNumber,
      '1',
    );

    const user2VotingPower = await ctx.safetyModule.getPowerAtBlock(
      user2.address,
      blockNumber,
      '0',
    );
    const user2PropPower = await ctx.safetyModule.getPowerAtBlock(
      user2.address,
      blockNumber,
      '1',
    );

    const user3VotingPower = await ctx.safetyModule.getPowerAtBlock(
      user3.address,
      blockNumber,
      '0',
    );
    const user3PropPower = await ctx.safetyModule.getPowerAtBlock(
      user3.address,
      blockNumber,
      '1',
    );

    const expectedUser1DelegatedVotingPower = '0';
    const expectedUser1DelegatedPropPower = '0';

    const expectedUser2DelegatedVotingPower = parseEther('2');
    const expectedUser2DelegatedPropPower = '0';

    const expectedUser3DelegatedVotingPower = '0';
    const expectedUser3DelegatedPropPower = parseEther('2');

    expect(user1VotingPower.toString()).to.be.equal(
      expectedUser1DelegatedPropPower,
      'Incorrect voting power for user 1',
    );
    expect(user1PropPower.toString()).to.be.equal(
      expectedUser1DelegatedVotingPower,
      'Incorrect prop power for user 1',
    );

    expect(user2VotingPower.toString()).to.be.equal(
      expectedUser2DelegatedVotingPower,
      'Incorrect voting power for user 2',
    );
    expect(user2PropPower.toString()).to.be.equal(
      expectedUser2DelegatedPropPower,
      'Incorrect prop power for user 2',
    );

    expect(user3VotingPower.toString()).to.be.equal(
      expectedUser3DelegatedVotingPower,
      'Incorrect voting power for user 3',
    );
    expect(user3PropPower.toString()).to.be.equal(
      expectedUser3DelegatedPropPower,
      'Incorrect prop power for user 3',
    );
  });

  it('Ensure that getting the power at the current block is the same as using getPowerCurrent', async () => {
    // Setup: user 1 has delegated to ctx.users 2 and 3...
    await ctx.safetyModule.connect(ctx.users[1]).delegateByType(ctx.users[2].address, '0');
    await ctx.safetyModule.connect(ctx.users[1]).delegateByType(ctx.users[3].address, '1');

    // Stake
    await ctx.safetyModule.connect(ctx.users[1]).stakeFor(ctx.users[1].address, parseEther('2'));

    const currTime = await latestBlockTimestamp();

    await advanceBlock(currTime + 1);

    const currentBlock = await latestBlock();

    const votingPowerAtPreviousBlock = await ctx.safetyModule.getPowerAtBlock(
      ctx.users[1].address,
      currentBlock - 1,
      '0',
    );
    const votingPowerCurrent = await ctx.safetyModule.getPowerCurrent(ctx.users[1].address, '0');

    const propPowerAtPreviousBlock = await ctx.safetyModule.getPowerAtBlock(
      ctx.users[1].address,
      currentBlock - 1,
      '1',
    );
    const propPowerCurrent = await ctx.safetyModule.getPowerCurrent(ctx.users[1].address, '1');

    expect(votingPowerAtPreviousBlock.toString()).to.be.equal(
      votingPowerCurrent.toString(),
      'Incorrect voting power for user 1',
    );
    expect(propPowerAtPreviousBlock.toString()).to.be.equal(
      propPowerCurrent.toString(),
      'Incorrect voting power for user 1',
    );
  });

  it("Checks you can't fetch power at a block in the future", async () => {
    const currentBlock = await latestBlock();

    await expect(
      ctx.safetyModule.getPowerAtBlock(ctx.users[1].address, currentBlock + 1, '0'),
    ).to.be.revertedWith('INVALID_BLOCK_NUMBER');
    await expect(
      ctx.safetyModule.getPowerAtBlock(ctx.users[1].address, currentBlock + 1, '1'),
    ).to.be.revertedWith('INVALID_BLOCK_NUMBER');
  });

  it('User 1 transfers value to himself. Ensures nothing changes in the delegated power', async () => {
    const user1VotingPowerBefore = await ctx.safetyModule.getPowerCurrent(ctx.users[1].address, '0');
    const user1PropPowerBefore = await ctx.safetyModule.getPowerCurrent(ctx.users[1].address, '1');

    const balance = await ctx.safetyModule.balanceOf(ctx.users[1].address);

    await ctx.safetyModule.connect(ctx.users[1]).transfer(ctx.users[1].address, balance);

    const user1VotingPowerAfter = await ctx.safetyModule.getPowerCurrent(ctx.users[1].address, '0');
    const user1PropPowerAfter = await ctx.safetyModule.getPowerCurrent(ctx.users[1].address, '1');

    expect(user1VotingPowerBefore.toString()).to.be.equal(
      user1VotingPowerAfter,
      'Incorrect voting power for user 1',
    );
    expect(user1PropPowerBefore.toString()).to.be.equal(
      user1PropPowerAfter,
      'Incorrect prop power for user 1',
    );
  });

  it('User 1 delegates voting power to User 2 via signature', async () => {
    const [user1, user2] = ctx.users;

    // Calculate expected voting power
    const user2VotingPower = await ctx.safetyModule.getPowerCurrent(user2.address, '1');
    const expectedVotingPower = (await ctx.safetyModule.getPowerCurrent(user1.address, '1')).add(
      user2VotingPower,
    );

    // Check prior delegatee is still user1
    const priorDelegatee = await ctx.safetyModule.getDelegateeByType(user1.address, '0');
    expect(priorDelegatee).to.be.equal(user1.address);

    // Prepare params to sign message
    const chainId = await getChainIdForSigning();

    const nonce = (await ctx.safetyModule.nonces(user1.address)).toString();
    const expiration = MAX_UINT_AMOUNT;
    const msgParams = buildDelegateByTypeParams(
      chainId,
      ctx.safetyModule.address,
      user2.address,
      '0',
      nonce,
      expiration,
      SAFETY_MODULE_EIP_712_DOMAIN_NAME,
    );
    const ownerPrivateKey = userKeys[0];

    const { v, r, s } = getSignatureFromTypedData(ownerPrivateKey, msgParams);

    // Transmit message via delegateByTypeBySig
    const tx = await ctx.safetyModule
      .connect(user1)
      .delegateByTypeBySig(user2.address, '0', nonce, expiration, v, r, s);
    await waitForTx(tx);

    // Check tx success and DelegateChanged
    await expect(tx)
      .to.emit(ctx.safetyModule, 'DelegateChanged')
      .withArgs(user1.address, user2.address, 0);

    // Check DelegatedPowerChanged event: ctx.users[1] power should drop to zero
    await expect(tx)
      .to.emit(ctx.safetyModule, 'DelegatedPowerChanged')
      .withArgs(user1.address, 0, 0);

    // Check DelegatedPowerChanged event: ctx.users[2] power should increase to expectedVotingPower
    await expect(tx)
      .to.emit(ctx.safetyModule, 'DelegatedPowerChanged')
      .withArgs(user2.address, expectedVotingPower, 0);

    // Check internal state
    const delegatee = await ctx.safetyModule.getDelegateeByType(user1.address, '0');
    expect(delegatee).to.be.equal(user2.address, 'Delegatee should be user 2');

    const user2VotingPowerFinal = await ctx.safetyModule.getPowerCurrent(user2.address, '0');
    expect(user2VotingPowerFinal).to.be.equal(
      expectedVotingPower,
      'Delegatee should have voting power from user 1',
    );
  });

  it('User 1 delegates proposition to User 3 via signature', async () => {
    const [ user1, ,user3] = ctx.users;

    // Calculate expected proposition power
    const user3PropPower = await ctx.safetyModule.getPowerCurrent(user3.address, '1');
    const expectedPropPower = (await ctx.safetyModule.getPowerCurrent(user1.address, '1')).add(
      user3PropPower,
    );

    // Check prior proposition delegatee is still user1
    const priorDelegatee = await ctx.safetyModule.getDelegateeByType(user1.address, '1');
    expect(priorDelegatee).to.be.equal(
      user1.address,
      'expected proposition delegatee to be user1',
    );

    // Prepare parameters to sign message
    const chainId = await getChainIdForSigning();

    const nonce = (await ctx.safetyModule.nonces(user1.address)).toString();
    const expiration = MAX_UINT_AMOUNT;
    const msgParams = buildDelegateByTypeParams(
      chainId,
      ctx.safetyModule.address,
      user3.address,
      '1',
      nonce,
      expiration,
      SAFETY_MODULE_EIP_712_DOMAIN_NAME,
    );
    const ownerPrivateKey = userKeys[0];
    const { v, r, s } = getSignatureFromTypedData(ownerPrivateKey, msgParams);

    // Transmit tx via delegateByTypeBySig
    const tx = await ctx.safetyModule
      .connect(user1)
      .delegateByTypeBySig(user3.address, '1', nonce, expiration, v, r, s);

    // Check tx success and DelegateChanged
    await expect(tx)
      .to.emit(ctx.safetyModule, 'DelegateChanged')
      .withArgs(user1.address, user3.address, 1);

    // Check DelegatedPowerChanged event: ctx.users[1] power should drop to zero
    await expect(tx)
      .to.emit(ctx.safetyModule, 'DelegatedPowerChanged')
      .withArgs(user1.address, 0, 1);

    // Check DelegatedPowerChanged event: ctx.users[2] power should increase to expectedVotingPower
    await expect(tx)
      .to.emit(ctx.safetyModule, 'DelegatedPowerChanged')
      .withArgs(user3.address, expectedPropPower, 1);

    // Check internal state matches events
    const delegatee = await ctx.safetyModule.getDelegateeByType(user1.address, '1');
    expect(delegatee).to.be.equal(user3.address, 'Delegatee should be user 3');

    const user3PropositionPower = await ctx.safetyModule.getPowerCurrent(user3.address, '1');
    expect(user3PropositionPower).to.be.equal(
      expectedPropPower,
      'Delegatee should have propostion power from user 1',
    );
  });

  it('User 2 delegates all to User 4 via signature', async () => {
    const [ user1, user2, , user4] = ctx.users;

    await ctx.safetyModule.connect(user2,
    ).delegate(user2.address);

    // Calculate expected powers
    const user4PropPower = await ctx.safetyModule.getPowerCurrent(user4.address, '1');
    const expectedPropPower = (await ctx.safetyModule.getPowerCurrent(user2.address, '1')).add(
      user4PropPower,
    );

    const user1VotingPower = await ctx.safetyModule.balanceOf(user1.address);
    const user4VotingPower = await ctx.safetyModule.getPowerCurrent(user4.address, '0');
    const user2ExpectedVotingPower = user1VotingPower;
    const user4ExpectedVotingPower = (await ctx.safetyModule.getPowerCurrent(user2.address, '0'))
      .add(user4VotingPower)
      .sub(user1VotingPower); // Delegation does not delegate votes others from other delegations

    // Check prior proposition delegatee is still user1
    const priorPropDelegatee = await ctx.safetyModule.getDelegateeByType(user2.address, '1');
    expect(priorPropDelegatee).to.be.equal(
      user2.address,
      'expected proposition delegatee to be user1',
    );

    const priorVotDelegatee = await ctx.safetyModule.getDelegateeByType(user2.address, '0');
    expect(priorVotDelegatee).to.be.equal(
      user2.address,
      'expected proposition delegatee to be user1',
    );

    // Prepare parameters to sign message
    const chainId = await getChainIdForSigning();

    const nonce = (await ctx.safetyModule.nonces(user2.address)).toString();
    const expiration = MAX_UINT_AMOUNT;
    const msgParams = buildDelegateParams(
      chainId,
      ctx.safetyModule.address,
      user4.address,
      nonce,
      expiration,
      SAFETY_MODULE_EIP_712_DOMAIN_NAME,
    );
    const ownerPrivateKey = userKeys[1];
    const { v, r, s } = getSignatureFromTypedData(ownerPrivateKey, msgParams);

    // Transmit tx via delegateByTypeBySig
    const tx = await ctx.safetyModule
      .connect(user2,
      )
      .delegateBySig(user4.address, nonce, expiration, v, r, s);

    // Check tx success and DelegateChanged for voting
    await expect(tx)
      .to.emit(ctx.safetyModule, 'DelegateChanged')
      .withArgs(user2.address, user4.address, 1);
    // Check tx success and DelegateChanged for proposition
    await expect(tx)
      .to.emit(ctx.safetyModule, 'DelegateChanged')
      .withArgs(user2.address, user4.address, 0);

    // Check DelegatedPowerChanged event: ctx.users[2] power should drop to zero
    await expect(tx)
      .to.emit(ctx.safetyModule, 'DelegatedPowerChanged')
      .withArgs(user2.address, 0, 1);

    // Check DelegatedPowerChanged event: ctx.users[4] power should increase to expectedVotingPower
    await expect(tx)
      .to.emit(ctx.safetyModule, 'DelegatedPowerChanged')
      .withArgs(user4.address, expectedPropPower, 1);

    // Check DelegatedPowerChanged event: ctx.users[2] power should drop to zero
    await expect(tx)
      .to.emit(ctx.safetyModule, 'DelegatedPowerChanged')
      .withArgs(user2.address, user2ExpectedVotingPower, 0);

    // Check DelegatedPowerChanged event: ctx.users[4] power should increase to expectedVotingPower
    await expect(tx)
      .to.emit(ctx.safetyModule, 'DelegatedPowerChanged')
      .withArgs(user4.address, user4ExpectedVotingPower, 0);

    // Check internal state matches events
    const propDelegatee = await ctx.safetyModule.getDelegateeByType(user2.address, '1');
    expect(propDelegatee).to.be.equal(
      user4.address,
      'Proposition delegatee should be user 4',
    );

    const votDelegatee = await ctx.safetyModule.getDelegateeByType(user2.address, '0');
    expect(votDelegatee).to.be.equal(user4.address, 'Voting delegatee should be user 4');

    const user4PropositionPower = await ctx.safetyModule.getPowerCurrent(user4.address, '1');
    expect(user4PropositionPower).to.be.equal(
      expectedPropPower,
      'Delegatee should have propostion power from user 2',
    );
    const user4VotingPowerFinal = await ctx.safetyModule.getPowerCurrent(user4.address, '0');
    expect(user4VotingPowerFinal).to.be.equal(
      user4ExpectedVotingPower,
      'Delegatee should have votinh power from user 2',
    );

    const user2PropositionPower = await ctx.safetyModule.getPowerCurrent(user2.address, '1');
    expect(user2PropositionPower).to.be.equal('0', 'User 2 should have zero prop power');
    const user2VotingPower = await ctx.safetyModule.getPowerCurrent(user2.address, '0');
    expect(user2VotingPower).to.be.equal(
      user2ExpectedVotingPower,
      'User 2 should still have voting power from user 1 delegation',
    );
  });

  it('User 1 should not be able to delegate with bad signature', async () => {
    const [ user1, user2] = ctx.users;

    // Prepare params to sign message
    const chainId = await getChainIdForSigning();

    const nonce = (await ctx.safetyModule.nonces(user1.address)).toString();
    const expiration = MAX_UINT_AMOUNT;
    const msgParams = buildDelegateByTypeParams(
      chainId,
      ctx.safetyModule.address,
      user2.address,
      '0',
      nonce,
      expiration,
      SAFETY_MODULE_EIP_712_DOMAIN_NAME,
    );
    const ownerPrivateKey = userKeys[0];

    const { r, s } = getSignatureFromTypedData(ownerPrivateKey, msgParams);

    // Transmit message via delegateByTypeBySig
    await expect(
      ctx.safetyModule
        .connect(user1,
        )
        .delegateByTypeBySig(user2.address, '0', nonce, expiration, 0, r, s),
    ).to.be.revertedWith('INVALID_SIGNATURE');
  });

  it('User 1 should not be able to delegate with bad nonce', async () => {
    const [ user1, user2] = ctx.users;

    // Prepare params to sign message
    const chainId = await getChainIdForSigning();

    const expiration = MAX_UINT_AMOUNT;
    const msgParams = buildDelegateByTypeParams(
      chainId,
      ctx.safetyModule.address,
      user2.address,
      '0',
      MAX_UINT_AMOUNT, // bad nonce
      expiration,
      SAFETY_MODULE_EIP_712_DOMAIN_NAME,
    );
    const ownerPrivateKey = userKeys[0];

    const { v, r, s } = getSignatureFromTypedData(ownerPrivateKey, msgParams);

    // Transmit message via delegateByTypeBySig
    await expect(
      ctx.safetyModule
        .connect(user1,
        )
        .delegateByTypeBySig(user2.address, '0', MAX_UINT_AMOUNT, expiration, v, r, s),
    ).to.be.revertedWith('INVALID_NONCE');
  });

  it('User 1 should not be able to delegate if signature expired', async () => {
    const [ user1, user2] = ctx.users;

    // Prepare params to sign message
    const chainId = await getChainIdForSigning();

    const nonce = (await ctx.safetyModule.nonces(user1.address)).toString();
    const expiration = '0';
    const msgParams = buildDelegateByTypeParams(
      chainId,
      ctx.safetyModule.address,
      user2.address,
      '0',
      nonce,
      expiration,
      SAFETY_MODULE_EIP_712_DOMAIN_NAME,
    );
    const ownerPrivateKey = userKeys[2];

    const { v, r, s } = getSignatureFromTypedData(ownerPrivateKey, msgParams);

    // Transmit message via delegateByTypeBySig
    await expect(
      ctx.safetyModule
        .connect(user1,
        )
        .delegateByTypeBySig(user2.address, '0', nonce, expiration, v, r, s),
    ).to.be.revertedWith('INVALID_EXPIRATION');
  });

  it('User 2 should not be able to delegate all with bad signature', async () => {
    const [ , user2, , user4] = ctx.users;

    // Prepare parameters to sign message
    const chainId = await getChainIdForSigning();

    const nonce = (await ctx.safetyModule.nonces(user2.address)).toString();
    const expiration = MAX_UINT_AMOUNT;
    const msgParams = buildDelegateParams(
      chainId,
      ctx.safetyModule.address,
      user4.address,
      nonce,
      expiration,
      SAFETY_MODULE_EIP_712_DOMAIN_NAME,
    );
    const ownerPrivateKey = userKeys[3];
    const { r, s } = getSignatureFromTypedData(ownerPrivateKey, msgParams);

    // Transmit tx via delegateBySig
    await expect(
      ctx.safetyModule.connect(user2,
      ).delegateBySig(user4.address, nonce, expiration, '0', r, s),
    ).to.be.revertedWith('INVALID_SIGNATURE');
  });

  it('User 2 should not be able to delegate all with bad nonce', async () => {
    const [ , user2, , user4] = ctx.users;

    // Prepare parameters to sign message
    const chainId = await getChainIdForSigning();

    const nonce = MAX_UINT_AMOUNT;
    const expiration = MAX_UINT_AMOUNT;
    const msgParams = buildDelegateParams(
      chainId,
      ctx.safetyModule.address,
      user4.address,
      nonce,
      expiration,
      SAFETY_MODULE_EIP_712_DOMAIN_NAME,
    );
    const ownerPrivateKey = userKeys[3];
    const { v, r, s } = getSignatureFromTypedData(ownerPrivateKey, msgParams);

    // Transmit tx via delegateByTypeBySig
    await expect(
      ctx.safetyModule.connect(user2,
      ).delegateBySig(user4.address, nonce, expiration, v, r, s),
    ).to.be.revertedWith('INVALID_NONCE');
  });

  it('User 2 should not be able to delegate all if signature expired', async () => {
    const [ , user2, , user4] = ctx.users;

    // Prepare parameters to sign message
    const chainId = await getChainIdForSigning();

    const nonce = (await ctx.safetyModule.nonces(user2.address)).toString();
    const expiration = '0';
    const msgParams = buildDelegateParams(
      chainId,
      ctx.safetyModule.address,
      user4.address,
      nonce,
      expiration,
      SAFETY_MODULE_EIP_712_DOMAIN_NAME,
    );
    const ownerPrivateKey = userKeys[3];
    const { v, r, s } = getSignatureFromTypedData(ownerPrivateKey, msgParams);

    // Transmit tx via delegateByTypeBySig
    await expect(
      ctx.safetyModule.connect(user2,
      ).delegateBySig(user4.address, nonce, expiration, v, r, s),
    ).to.be.revertedWith('INVALID_EXPIRATION');
  });

  it('Correct proposal and voting snapshotting on double action in the same block', async () => {
    const [ sender, receiver] = ctx.users;

    // Stake
    const initialBalance = parseEther('1');
    await ctx.safetyModule.connect(sender).stake(initialBalance);

    const receiverPriorPower = await ctx.safetyModule.getPowerCurrent(receiver.address, '0');
    const senderPriorPower = await ctx.safetyModule.getPowerCurrent(sender.address, '0');

    // Deploy double transfer helper
    const doubleTransferHelper = await new DoubleTransferHelper__factory(ctx.deployer).deploy(
      ctx.safetyModule.address,
    );

    await waitForTx(
      await ctx.safetyModule
        .connect(sender)
        .transfer(doubleTransferHelper.address, initialBalance),
    );

    // Do double transfer
    await waitForTx(
      await doubleTransferHelper
        .connect(sender)
        .doubleSend(receiver.address, parseEther('0.7'), initialBalance.sub(parseEther('0.7'))),
    );

    const receiverCurrentPower = await ctx.safetyModule.getPowerCurrent(receiver.address, '0');
    const senderCurrentPower = await ctx.safetyModule.getPowerCurrent(sender.address, '0');

    expect(receiverCurrentPower).to.be.equal(
      senderPriorPower.add(receiverPriorPower),
      'Receiver should have added the sender power after double transfer',
    );
    expect(senderCurrentPower).to.be.equal(
      '0',
      'Sender power should be zero due transfered all the funds',
    );
  });
});
