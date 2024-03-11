import BNJS from 'bignumber.js';
import { expect } from 'chai';
import { BigNumber, BigNumberish, utils } from 'ethers';
import _ from 'lodash';

import { SM_EXCHANGE_RATE_BASE } from '../../src/lib/constants';
import { asBytes32, asUintHex, concatHex } from '../../src/lib/hex';
import { TestContext, describeContractHardhatRevertBeforeEach } from '../helpers/describe-contract';
import { getAffectedStakersForTest } from '../helpers/get-affected-stakers-for-test';
import hre from '../hre';

let testStakers: string[];

function init() {
  testStakers = getAffectedStakersForTest();
}

describeContractHardhatRevertBeforeEach('SafetyModule initial storage slots', init, (ctx: TestContext) => {
  it('0-49: AccessControlUpgradeable', async () => {
    await expectZeroes(_.range(0, 50));
  });

  it('50: ReentrancyGuard', async () => {
    expect(await read(50)).to.equal(1);
  });

  it('51-101: VersionedInitializable', async () => {
    expect(await read(51)).to.equal(1);
    await expectZeroes(_.range(52, 102));
  });

  it('102-127: SM1Storage', async () => {
    // Slot 102 and 103: Epoch parameters.
    const expectedEpochParametersStruct = concatHex(
      [
        ctx.config.EPOCH_ZERO_START, // offset
        ctx.config.EPOCH_LENGTH, // interval
      ].map((n) => asUintHex(n, 128)),
    );

    expect(await read(102)).to.equal(expectedEpochParametersStruct);
    expect(await read(103)).to.equal(ctx.config.BLACKOUT_WINDOW);
    await expectZeroes(_.range(104, 105));

    // Slot 105: Domain separator hash.
    expect((await read(105)).eq(0)).to.be.false();
    await expectZeroes(_.range(106, 113));

    // Slot 113: Rewards per second.
    // before that the emissions per second was set to zero
    // at executeWindDownBorrowingPoolProposalForTest function
    expect(await read(113)).to.equal(0);

    // Slot 114: Global index value and timestamp.
    const amountForStaking = 1_000_000
    await ctx.axorToken.approve(ctx.safetyModule.address, amountForStaking);
    await ctx.safetyModule.connect(ctx.deployer).stake(amountForStaking);

    const stakedFilter = ctx.safetyModule.filters.Staked();
    const stakedLogs = await ctx.safetyModule.queryFilter(stakedFilter);
    const lastStakeLog = stakedLogs[stakedLogs.length - 1];
    const lastStakeBlock = await lastStakeLog.getBlock();
    const lastStakeTimestamp = lastStakeBlock.timestamp;
    const expectedIndexAndTimestamp = concatHex([
      asUintHex(lastStakeTimestamp, 32), // timestamp
      asUintHex(0, 224), // index
    ]);

    await read(114);
    await expectZeroes(_.range(115, 119));

    // Slot 120: Total active balance (current epoch).
    await read(119)
    expect(await read(120)).to.equal(amountForStaking);
    await expectZeroes(_.range(121, 124));

    // Slot 115: Exchange rate.
    expect(await read(124)).to.equal(new BNJS(SM_EXCHANGE_RATE_BASE).toString());
    await expectZeroes(_.range(125, 200));
  });

  it('Mappings', async () => {
    
    const staker = ctx.deployer
    const amountForStaking = 1_000_000
    await ctx.axorToken.approve(ctx.safetyModule.address, amountForStaking);
    await ctx.safetyModule.connect(staker).stake(amountForStaking);

    const stakedFilter = ctx.safetyModule.filters.Staked(staker.address);
    const stakedLogs = await ctx.safetyModule.queryFilter(stakedFilter);
    expect(stakedLogs.length).to.equal(1);
    const stakeLog = stakedLogs[0];
    const stakeBlock = await stakeLog.getBlock();
    const stakeBlockNumber = stakeBlock.number;

    // Expect _VOTING_SNAPSHOTS_[staker].blockNumber to be the block number in which the staker
    // staked funds.
    const votingSnapshotBlockNumberSlot = utils.keccak256(
      concatHex([asUintHex(0, 256), utils.keccak256(concatHex([asBytes32(staker.address), asUintHex(107, 256)]))]),
    );
    expect(await read(votingSnapshotBlockNumberSlot)).to.equal(stakeBlockNumber);

    // Expect _PROPOSITION_SNAPSHOTS_[staker].blockNumber
    const propositionSnapshotBlockNumberSlot = utils.keccak256(
      concatHex([asUintHex(0, 256), utils.keccak256(concatHex([asBytes32(staker.address), asUintHex(110, 256)]))]),
    );
    expect(await read(propositionSnapshotBlockNumberSlot)).to.equal(stakeBlockNumber);

    // Expect _VOTING_SNAPSHOT_COUNTS_[staker]
    const votingSnapshotCountSlot = utils.keccak256(concatHex([asBytes32(staker.address), asUintHex(108, 256)]));
    expect(await read(votingSnapshotCountSlot)).to.equal(1);

    // Expect _PROPOSITION_SNAPSHOT_COUNTS_[staker]
    const propositionSnapshotCountSlot = utils.keccak256(
      concatHex([asBytes32(staker.address), asUintHex(111, 256)]),
    );
    expect(await read(propositionSnapshotCountSlot)).to.equal(1);

    // Expect _ACTIVE_BALANCES_[staker] ==> StoredBalance
    const activeBalanceCurrentEpochSlot = utils.keccak256(
      concatHex([asBytes32(staker.address), asUintHex(118, 256)]),
    );
    /** with StoredBalance has 
     *  currentEpoch -> uint16 and currentEpochBalance -> uint240 
     *  currentEpoch + currentEpochBalance = 256 bits 
     *  ==> they be stored at first slot
     *  exp: 0x0000000000000000000000000000000000000000000000000000000f42400002
     *  currentEpoch: 0x0002 - save as 2^4 = 16 bit => length = 4 from the right 
     *  currentEpochBalance: 0x0000000000000000000000000000000000000000000000000000000f4240 
     *  => other 240 bit => length = 60 from the currentEpoch value
    **/
    const value = await readHex(activeBalanceCurrentEpochSlot)
    const currentEpochBalance = value.toString().slice(0, 62)
    expect(Number(currentEpochBalance)).to.equal(amountForStaking);
  });

  async function expectZeroes(range: number[]): Promise<void> {
    for (const i of range) {
      expect(await read(i)).to.equal(0);
    }
  }

  async function readHex(slot: BigNumberish): Promise<string> {
    const value = await hre.ethers.provider.getStorageAt(ctx.safetyModule.address, BigNumber.from(slot));
    return value
  }

  async function read(slot: BigNumberish): Promise<BigNumber> {
    return BigNumber.from(await readHex(BigNumber.from(slot)));
  }
});
