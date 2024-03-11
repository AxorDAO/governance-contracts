/* eslint-disable @typescript-eslint/naming-convention */
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';

import { SafetyModuleV1 } from '../../types';
import {
  TestContext,
  describeContractHardhatRevertBeforeEach,
} from '../helpers/describe-contract';
import { advanceBlock, latestBlockTimestamp } from '../helpers/evm';
import { StakingHelper } from '../helpers/staking-helper';

const stakerInitialBalance: number = 1_000_000;

// Users.
let staker1: SignerWithAddress;
let staker2: SignerWithAddress;
let fundsRecipient: SignerWithAddress;

let contract: StakingHelper;

async function init(ctx: TestContext) {
  // Users.
  [staker1, staker2, fundsRecipient] = ctx.users;

  // Use helper class to automatically check contract invariants after every update.
  contract = new StakingHelper(
    ctx,
    ctx.safetyModule,
    ctx.axorToken,
    ctx.rewardsTreasury.address,
    ctx.deployer,
    ctx.deployer,
    [staker1, staker2],
    true,
  );

  // Mint to stakers 1 and 2.
  await contract.mintAndApprove(staker1, stakerInitialBalance);
  await contract.mintAndApprove(staker2, stakerInitialBalance);

  // Set initial rewards rate to zero.
  await contract.setRewardsPerSecond(0);
}

describeContractHardhatRevertBeforeEach(
  'SM1Slashing',
  init,
  (ctx: TestContext) => {
    before(() => {
      contract.saveSnapshot('main');
    });

    afterEach(() => {
      contract.loadSnapshot('main');
    });

    describe('slash', () => {
      it('slashing when there are no balances does nothing', async () => {
        await ctx.safetyModule.slash(0, fundsRecipient.address);
        await ctx.safetyModule.slash(1, fundsRecipient.address);
        await ctx.safetyModule.slash(
          stakerInitialBalance,
          fundsRecipient.address,
        );
        expect(await ctx.safetyModule.getExchangeRateSnapshotCount()).to.equal(
          0,
        );
      });

      it('slashing when there is only one token does nothing', async () => {
        await contract.stake(staker1, 1);
        await ctx.safetyModule.slash(0, fundsRecipient.address);
        await ctx.safetyModule.slash(1, fundsRecipient.address);
        await ctx.safetyModule.slash(
          stakerInitialBalance,
          fundsRecipient.address,
        );
        expect(await ctx.safetyModule.getExchangeRateSnapshotCount()).to.equal(
          0,
        );
      });

      it('slashing zero does nothing', async () => {
        await contract.stake(staker1, stakerInitialBalance);
        await ctx.safetyModule.slash(0, fundsRecipient.address);

        // Check underlying token balances.
        expect(await ctx.axorToken.balanceOf(staker1.address)).to.equal(0);
        expect(
          await ctx.axorToken.balanceOf(ctx.safetyModule.address),
        ).to.equal(stakerInitialBalance);
        expect(await ctx.axorToken.balanceOf(fundsRecipient.address)).to.equal(
          0,
        );

        // Check stake balances.
        expect(await ctx.safetyModule.balanceOf(staker1.address)).to.equal(
          stakerInitialBalance,
        );
        expect(await ctx.safetyModule.totalSupply()).to.equal(
          stakerInitialBalance,
        );

        // Check slash snapshots.
        expect(await ctx.safetyModule.getExchangeRateSnapshotCount()).to.equal(
          0,
        );
      });

      it('slashes one token', async () => {
        // Stake 2 tokens.
        await contract.stake(staker1, 2);

        // Request to slash 3 tokens, should be limited to 1.
        await ctx.safetyModule.slash(3, fundsRecipient.address);

        // Check underlying token balances.
        expect(
          await ctx.axorToken.balanceOf(ctx.safetyModule.address),
        ).to.equal(1);
        expect(await ctx.axorToken.balanceOf(fundsRecipient.address)).to.equal(
          1,
        );

        // Check stake balances.
        expect(await ctx.safetyModule.balanceOf(staker1.address)).to.equal(2);
        expect(await ctx.safetyModule.totalSupply()).to.equal(2);

        // Check slash snapshots.
        expect(await ctx.safetyModule.getExchangeRateSnapshotCount()).to.equal(
          1,
        );
      });

      it('does not affect stake balance, but affects gov power and tokens received on withdrawal', async () => {
        const slashAmount = stakerInitialBalance / 2;
        const remainingAmount = stakerInitialBalance - slashAmount;
        await contract.stake(staker1, stakerInitialBalance);
        await ctx.safetyModule.slash(slashAmount, fundsRecipient.address);

        // Check underlying token balances.
        expect(await ctx.axorToken.balanceOf(staker1.address)).to.equal(0);
        expect(
          await ctx.axorToken.balanceOf(ctx.safetyModule.address),
        ).to.equal(remainingAmount);
        expect(await ctx.axorToken.balanceOf(fundsRecipient.address)).to.equal(
          slashAmount,
        );

        // Check stake balances.
        expect(await ctx.safetyModule.balanceOf(staker1.address)).to.equal(
          stakerInitialBalance,
        );
        expect(
          await ctx.safetyModule.balanceOf(ctx.safetyModule.address),
        ).to.equal(0);
        expect(
          await ctx.safetyModule.balanceOf(fundsRecipient.address),
        ).to.equal(0);
        expect(await ctx.safetyModule.totalSupply()).to.equal(
          stakerInitialBalance,
        );

        // Check slash snapshots.
        await advanceBlock();
        await advanceBlock();
        const slashBlock = await getLatestSlashBlockNumber(ctx.safetyModule);
        expect(await ctx.safetyModule.getExchangeRateSnapshotCount()).to.equal(
          1,
        );
        expect((await ctx.safetyModule.getExchangeRateSnapshot(0))[0]).to.equal(
          slashBlock,
        );
        expect((await ctx.safetyModule.getExchangeRateSnapshot(0))[1]).to.equal(
          '2000000000000000000',
        ); // 2e18

        // Check gov power.
        expect(
          await ctx.safetyModule.getPowerAtBlock(
            staker1.address,
            slashBlock - 1,
            0,
          ),
        ).to.equal(stakerInitialBalance);
        expect(
          await ctx.safetyModule.getPowerAtBlock(
            staker1.address,
            slashBlock - 1,
            1,
          ),
        ).to.equal(stakerInitialBalance);
        expect(
          await ctx.safetyModule.getPowerAtBlock(
            staker1.address,
            slashBlock,
            0,
          ),
        ).to.equal(remainingAmount);
        expect(
          await ctx.safetyModule.getPowerAtBlock(
            staker1.address,
            slashBlock,
            1,
          ),
        ).to.equal(remainingAmount);
        expect(
          await ctx.safetyModule.getPowerAtBlock(
            staker1.address,
            slashBlock + 1,
            0,
          ),
        ).to.equal(remainingAmount);
        expect(
          await ctx.safetyModule.getPowerAtBlock(
            staker1.address,
            slashBlock + 1,
            1,
          ),
        ).to.equal(remainingAmount);
        expect(
          await ctx.safetyModule.getPowerCurrent(staker1.address, 0),
        ).to.equal(remainingAmount);
        expect(
          await ctx.safetyModule.getPowerCurrent(staker1.address, 1),
        ).to.equal(remainingAmount);

        // Withdraw funds.
        await contract.requestWithdrawal(staker1, stakerInitialBalance); // In stake units
        await contract.elapseEpoch();
        // Note: Skip invariant check since net deposits will not match the total balance, due to slashing.
        const withdrawalAmount = await contract.withdrawMaxStake(
          staker1,
          staker1,
          { skipInvariantChecks: true },
        );
        expect(withdrawalAmount).to.equal(stakerInitialBalance); // In stake units

        // Check underlying token balances.
        expect(await ctx.axorToken.balanceOf(staker1.address)).to.equal(
          remainingAmount,
        );
        expect(
          await ctx.axorToken.balanceOf(ctx.safetyModule.address),
        ).to.equal(0);
        expect(await ctx.axorToken.balanceOf(fundsRecipient.address)).to.equal(
          slashAmount,
        );

        // Check total supply.
        expect(await ctx.safetyModule.totalSupply()).to.equal(0);
      });

      it('does not affect rewards earned', async () => {
        await contract.stake(staker1, stakerInitialBalance);

        // Earn some rewards before the slash.
        const lastTimestamp = await latestBlockTimestamp();
        await contract.setRewardsPerSecond(150);
        await contract.elapseEpoch();

        // Slash.
        await ctx.safetyModule.slash(
          stakerInitialBalance / 2,
          fundsRecipient.address,
        );

        // Earn some rewards after the slash.
        await contract.elapseEpoch();

        // Slash again.
        await ctx.safetyModule.slash(
          stakerInitialBalance / 4,
          fundsRecipient.address,
        );

        // Earn some rewards after the second slash.
        await contract.elapseEpoch();

        // Claim rewards (with assertions within the helper function).
        await contract.claimRewards(staker1, fundsRecipient, lastTimestamp);
      });

      it('affects rewards earned relative to a new depositor', async () => {
        await contract.stake(staker1, stakerInitialBalance);

        // Slash by 50%, three times.
        await ctx.safetyModule.slash(
          stakerInitialBalance / 2,
          fundsRecipient.address,
        );
        await ctx.safetyModule.slash(
          stakerInitialBalance / 4,
          fundsRecipient.address,
        );
        await ctx.safetyModule.slash(
          stakerInitialBalance / 8,
          fundsRecipient.address,
        );

        // Second staker after first three slashes.
        //
        // Note: Skip invariant check since net deposits will not match the total balance, due to slashing.
        await contract.stake(staker2, stakerInitialBalance, {
          skipInvariantChecks: true,
        });

        // Slash again by 50%.
        await ctx.safetyModule.slash(
          (await ctx.axorToken.balanceOf(ctx.safetyModule.address)).div(2),
          fundsRecipient.address,
        );

        // Earn some rewards after the slash.
        const lastTimestamp = await latestBlockTimestamp();
        await contract.setRewardsPerSecond(150);
        await contract.elapseEpoch();

        // Expect staker 2 to earn an 8x share vs. staker 1.
        const staker1Rewards = await contract.claimRewards(
          staker1,
          fundsRecipient,
          lastTimestamp,
          null,
          1 / 9,
        );
        const staker2Rewards = await contract.claimRewards(
          staker2,
          fundsRecipient,
          lastTimestamp,
          null,
          8 / 9,
        );
        const error = staker1Rewards
          .mul(8)
          .sub(staker2Rewards)
          .abs()
          .toNumber();
        expect(error).to.be.lte(300);
      });
    });

    describe('max slash', () => {
      it('slashes 95%', async () => {
        await contract.stake(staker1, stakerInitialBalance);
        await ctx.safetyModule.slash(
          stakerInitialBalance,
          fundsRecipient.address,
        );

        // Check underlying token balances.
        expect(await ctx.axorToken.balanceOf(staker1.address)).to.equal(0);
        expect(
          await ctx.axorToken.balanceOf(ctx.safetyModule.address),
        ).to.equal(stakerInitialBalance / 20);
        expect(await ctx.axorToken.balanceOf(fundsRecipient.address)).to.equal(
          (stakerInitialBalance / 20) * 19,
        );

        // Check stake balances.
        expect(await ctx.safetyModule.balanceOf(staker1.address)).to.equal(
          stakerInitialBalance,
        );
        expect(
          await ctx.safetyModule.balanceOf(ctx.safetyModule.address),
        ).to.equal(0);
        expect(
          await ctx.safetyModule.balanceOf(fundsRecipient.address),
        ).to.equal(0);
        expect(await ctx.safetyModule.totalSupply()).to.equal(
          stakerInitialBalance,
        );

        // Withdraw.
        await ctx.safetyModule
          .connect(staker1)
          .requestWithdrawal(stakerInitialBalance);
        await contract.elapseEpoch();
        await ctx.safetyModule
          .connect(staker1)
          .withdrawMaxStake(staker1.address);
        expect(await ctx.axorToken.balanceOf(staker1.address)).to.equal(
          stakerInitialBalance / 20,
        );
      });

      it('staker continues earning rewards', async () => {
        await contract.stake(staker1, stakerInitialBalance);

        // Earn some rewards before the slash.
        const lastTimestamp = await latestBlockTimestamp();
        await contract.setRewardsPerSecond(150);
        await contract.elapseEpoch();

        // Slash.
        await ctx.safetyModule.slash(
          stakerInitialBalance,
          fundsRecipient.address,
        );

        // Earn some rewards after the slash.
        await contract.elapseEpoch();

        // Slash again.
        await ctx.safetyModule.slash(
          stakerInitialBalance,
          fundsRecipient.address,
        );

        // Earn some rewards after the second slash.
        await contract.elapseEpoch();

        // Claim rewards (with assertions within the helper function).
        await contract.claimRewards(staker1, fundsRecipient, lastTimestamp);
      });

      it('staker receive funds via transfer after being slashed', async () => {
        await contract.stake(staker1, stakerInitialBalance);
        await ctx.safetyModule.slash(
          stakerInitialBalance,
          fundsRecipient.address,
        );

        // New deposit multiplied by exchange rate of 20...
        //
        // Note: Skip invariant check since net deposits will not match the total balance, due to slashing.
        await contract.stake(staker2, stakerInitialBalance, {
          skipInvariantChecks: true,
        });
        await contract.transfer(staker2, staker1, stakerInitialBalance * 10, {
          skipInvariantChecks: true,
        }); // Transfer half.

        // Check balances.
        expect(await ctx.safetyModule.balanceOf(staker1.address)).to.equal(
          stakerInitialBalance * 11,
        );
        expect(await ctx.safetyModule.balanceOf(staker2.address)).to.equal(
          stakerInitialBalance * 10,
        );
        expect(await ctx.safetyModule.totalSupply()).to.equal(
          stakerInitialBalance * 21,
        );

        // Check underlying balance of the contract.
        expect(
          await ctx.axorToken.balanceOf(ctx.safetyModule.address),
        ).to.equal(stakerInitialBalance + stakerInitialBalance / 20);

        // Can earn rewards.
        const startTimestamp = await latestBlockTimestamp();
        await contract.setRewardsPerSecond(150);
        await contract.elapseEpoch();
        const rewards1 = await contract.claimRewards(
          staker1,
          fundsRecipient,
          startTimestamp,
          null,
          11 / 21,
        );
        const rewards2 = await contract.claimRewards(
          staker2,
          fundsRecipient,
          startTimestamp,
          null,
          10 / 21,
        );
        const error = rewards1.sub(rewards2.mul(11).div(10)).abs().toNumber();
        expect(error).to.be.lte(300);
      });
    });
  },
);

async function getLatestSlashBlockNumber(
  safetyModule: SafetyModuleV1,
): Promise<number> {
  const filter = safetyModule.filters.Slashed(null, null, null);
  const events = await safetyModule.queryFilter(filter);
  return events[events.length - 1].blockNumber;
}
