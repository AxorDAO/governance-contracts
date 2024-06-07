import BNJS from 'bignumber.js';
import { DateTime } from 'luxon';
import { toWad } from '../lib/util';
import { TimelockConfig, MerkleDistributorConfig } from './types';

export const MINUTE = 60;
export const ONE_DAY_BLOCKS = 1000;

// Schedule parameters.
const EPOCH_LENGTH = 28 * MINUTE;
const BLACKOUT_WINDOW = 5 * MINUTE;
const MERKLE_DISTRIBUTOR_WAITING_PERIOD = 7 * MINUTE;

// Equal to 514 epochs plus a portion of an epoch, to account for leftover rewards due to the
// different start dates of the two staking modules.
// It's approximately 10 days 
const REWARDS_DISTRIBUTION_LENGTH = 863_520;

// Staking parameters.
//
// Equal to 25M tokens per staking module divided by 157,679,998 seconds of distributing rewards
const STAKING_REWARDS_PER_SECOND = toWad('0.1585489619');

// Treasury parameters.
const REWARDS_TREASURY_FRONTLOADED_FUNDS = toWad(1_000_000);

const LONG_TIMELOCK_CONFIG: TimelockConfig = {
  DELAY: MINUTE * 7,
  GRACE_PERIOD: MINUTE * 30,
  MINIMUM_DELAY: MINUTE * 5, // delay time is time from queue action to execution action
  MAXIMUM_DELAY: MINUTE * 21,
  PROPOSITION_THRESHOLD: 200, // 2%
  VOTING_DURATION_BLOCKS: ONE_DAY_BLOCKS * 2, // voting duration in 10000 block
  VOTE_DIFFERENTIAL: 1000, // 10%
  MINIMUM_QUORUM: 1000, // 10%
};

const SHORT_TIMELOCK_CONFIG: TimelockConfig = {
  DELAY: MINUTE * 2,
  GRACE_PERIOD: MINUTE * 7,
  MINIMUM_DELAY: MINUTE,
  MAXIMUM_DELAY: MINUTE * 7,
  PROPOSITION_THRESHOLD: 50,
  VOTING_DURATION_BLOCKS: ONE_DAY_BLOCKS * 4,
  VOTE_DIFFERENTIAL: 50,
  MINIMUM_QUORUM: 200,
};

const MERKLE_PAUSER_TIMELOCK_CONFIG: TimelockConfig = {
  DELAY: 0,
  GRACE_PERIOD: MINUTE * 7,
  MINIMUM_DELAY: 0,
  MAXIMUM_DELAY: MINUTE,
  PROPOSITION_THRESHOLD: 50,
  VOTING_DURATION_BLOCKS: ONE_DAY_BLOCKS * 2,
  VOTE_DIFFERENTIAL: 50,
  MINIMUM_QUORUM: 100,
};

const MERKLE_DISTRIBUTOR_CONFIG: MerkleDistributorConfig = {
  IPNS_NAME: 'rewards-data.axor.dao',
  IPFS_UPDATE_PERIOD: 60 * 3,  // 3 minutes
  MARKET_MAKER_REWARDS_AMOUNT: 1_150_685,
  TRADER_REWARDS_AMOUNT: 3_835_616,
  TRADER_SCORE_ALPHA: 0.7,
};


const config = {
  // Common schedule parameters.
  EPOCH_LENGTH,
  BLACKOUT_WINDOW,
  REWARDS_DISTRIBUTION_LENGTH,

  // AXOR token parameters.
  MINT_MAX_PERCENT: 2,

  // Governance parameters.
  VOTING_DELAY_BLOCKS: 6570, // One day, assuming average block time of 13s.

  // Treasury parameters.
  REWARDS_TREASURY_VESTING_AMOUNT: new BNJS(toWad(450_000_000))
    .minus(REWARDS_TREASURY_FRONTLOADED_FUNDS)
    .toFixed(),
  COMMUNITY_TREASURY_VESTING_AMOUNT: toWad(50_000_000),

  // Timelock parameters.
  LONG_TIMELOCK_CONFIG,
  SHORT_TIMELOCK_CONFIG,
  MERKLE_PAUSER_TIMELOCK_CONFIG,

  // Merkle Distributor.
  MERKLE_DISTRIBUTOR_CONFIG,
  MERKLE_DISTRIBUTOR_WAITING_PERIOD,

  // Safety Module.
  SM_REWARDS_PER_SECOND: STAKING_REWARDS_PER_SECOND,

  // Liquidity Staking.
  LS_MIN_BLACKOUT_LENGTH: 3 * MINUTE,
  LS_MAX_EPOCH_LENGTH: 92 * MINUTE,
  LS_REWARDS_PER_SECOND: STAKING_REWARDS_PER_SECOND,
  getLiquidityStakingMinEpochLength() {
    return this.LS_MIN_BLACKOUT_LENGTH * 2;
  },
  getLiquidityStakingMaxBlackoutLength() {
    return this.LS_MAX_EPOCH_LENGTH / 2;
  },

  // Treasuries.
  REWARDS_TREASURY_FRONTLOADED_FUNDS,

  // Initial token allocations.
  TOKEN_ALLOCATIONS: {
    TEST_TOKENS_1: {
      ADDRESS: '0xeb74327ddd3f0d359321f06d84a9d3871b4d96a4',
      AMOUNT: toWad(2),
    },
    TEST_TOKENS_2: {
      ADDRESS: '0xb03414a51a625e8ce16d284e34941ba66c5683c9',
      AMOUNT: toWad(2),
    },
    TEST_TOKENS_3: {
      ADDRESS: '0x1eec5afab429859c46db6552bc973bdd525fd7b1',
      AMOUNT: toWad(2),
    },
    TEST_TOKENS_4: {
      ADDRESS: '0x69112552fac655bb76a3e0ee7779843451db02b6',
      AMOUNT: toWad(2),
    },
    AXOR_DAO: {
      ADDRESS: '0xb4fbF1Cd41BB174ABeFf6001B85490b58b117B22',
      AMOUNT: toWad(293_355_248.288681),
    },
    AXOR_TRADING: {
      ADDRESS: '0xf95746B2c3D120B78Fd1Cb3f9954CB451c2163E4',
      AMOUNT: toWad(115_941_170.358637),
    },
    AXOR_LLC: {
      ADDRESS: '0xCc9507708a918b1d44Cf63FaB4E7B98b7517060f',
      AMOUNT: toWad(90_703_573.352682),
    },
  },

  // Addresses which were used on mainnet for token custody testing.
  TOKEN_TEST_ADDRESSES: [
    // '0x4aBfCf64bB323CC8B65e2E69F2221B14943C6EE1',
    // '0x4c58f30d3C028a5Fc28Ed709eE0041a37f438023',
    // '0xD2353b46fEd0BB1286d01b2BD89C40b76Cfe8874'
  ],

  // Safety Module recovery.
  //
  // The owed amount is the amount that was initially staked and stuck in the Safety Module,
  // plus additional compensation.
  //
  // Compensation for each user is 10% of what they staked, rounded down to the nearest 1e-18 AXOR.
  // The total owed amount is calculated by summing the staked amounts and compensation amounts
  // for all users who staked to the Safety Module.
  //
  // Snapshot of staked balances taken on September 14, 2021 UTC. The last tx was on September 9.
  //
  SM_RECOVERY_OWED_AMOUNT: '173204761823871505252385', // About 173205 AXOR.
  //
  // Distribution start is unchanged from the mainnet deployment
  SM_RECOVERY_DISTRIBUTION_START: (
    DateTime.fromISO('2021-09-08T15:00:00', { zone: 'utc' }).toSeconds()
  ),
  //
  // Calculate the distribution end as follows:
  //
  //   25,000,000 - 15745.887438533773204745 AXOR are available as rewards once staking resumes.
  //   The rewards rate is unchanged at 0.1585489619 AXOR per second, so we can issue rewards for
  //   157580685 whole seconds.
  //
  //   Assuming for now that the earliest staking may resume (counting 18 days from when a proposal
  //   is created) is 2021-11-02T01:00:00 UTC, we arrive at the following time.
  //
  SM_RECOVERY_DISTRIBUTION_END: (
    DateTime.fromISO('2026-10-30T21:24:45', { zone: 'utc' }).toSeconds()
  ),

  // axor Grants Program.
  // Amount to be transferred is $6,250,000 of AXOR at market.
  // Per the DIP, price has been calculated using 24h VWAP from market data.
  // Price derived is $8.31 using Binance.com AXOR/USDT on 01/01/22.
  // Using market price of $8.31, rounded amount to be transferred is 752,000.00 AXOR.
  //
  DGP_MULTISIG_ADDRESS: '0xFa3811E5C92358133330f9F787980ba1e8E0D99a',
  //
  DGP_FUNDING_AMOUNT: '752000000000000000000000',
  // DGP Funding Round v1.5
  // Amount to be transferred is $5,500,000 of AXOR at 24 hour TWAP price of $2.13.
  //
  DGP_FUNDING_AMOUNT_v1_5: '2582000000000000000000000',

  // Update Merkle Distributor Rewards Parameters.
  // This is to reduce trading rewards by 25%. LP rewards are unaffected.
  // Alpha parameter is set to 0 to indicate that it is not used anymore.
  UPDATE_MERKLE_DISTRIBUTOR_LP_REWARDS_AMOUNT: '1150685000000000000000000',
  // Trading rewards are being reduced by 25% from `3,835,616` tokens to `2,876,712` per epoch.
  UPDATE_MERKLE_DISTRIBUTOR_TRADER_REWARDS_AMOUNT: '2876712000000000000000000',
  UPDATE_MERKLE_DISTRIBUTOR_ALPHA_PARAMETER: '0',

  // Ops Trust ("DOT") Funding Amount (DIP 18)
  // Amount to be transferred is $360,000 of AXOR at 24 hour TWAP price of $1.855
  // Per the DIP price has been calculated using 24h VWAP from market data
  // Price derived is $1.606 using Binance.com AXOR/USDT on
  // Using market price of $1.606, rounded amount to be transferred is 225,000 AXOR
  DOT_MULTISIG_ADDRESS:    '0xa8541f948411b3F95d9e89e8D339a56A9ed3D00b',
  DOT_MULTISIG_ADDRESS_V2: '0x4abfcf64bb323cc8b65e2e69f2221b14943c6ee1',
  DOT_FUNDING_AMOUNT: '225000000000000000000000',

  // Update Merkle Distributor Rewards Parameters v2. (DIP 20)
  // This is to reduce trading rewards by 45%. LP rewards are unaffected.
  // Alpha parameter remains unchanged since the last update and is equal to 0.
  UPDATE_MERKLE_DISTRIBUTOR_LP_REWARDS_AMOUNT_v2: '1150685000000000000000000',
  // Trading rewards are being reduced by 45% from `2,876,712` tokens to `1,582,192` per epoch.
  UPDATE_MERKLE_DISTRIBUTOR_TRADER_REWARDS_AMOUNT_v2: '1582192000000000000000000',
  UPDATE_MERKLE_DISTRIBUTOR_ALPHA_PARAMETER_v2: '0',


  // Ops Trust ("DOT") Funding Amount (DIP 23)
  // Amount to be transferred is $6,600,000 of AXOR
  // Per the DIP price has been calculated using 24h VWAP from market data
  // Price derived is $1.53 using Binance.com AXOR/USDT on
  // Using market price of $1.53, rounded amount to be transferred is 4,314,000 AXOR
  DOT_FUNDING_AMOUNT_v2: '4314000000000000000000000',

  // Update Merkle Distributor LP Rewards (DIP 24)
  // Proposal to reduce the current LP rewards by 50%. Trading rewards will not be changed.
  // Alpha parameter will remain unchanged.
  // LP rewards being reduced by 50% from '1,150,685' to '575,343' per epoch.
  UPDATE_MERKLE_DISTRIBUTOR_LP_REWARDS_AMOUNT_DIP24: '575343000000000000000000',
  // Trading rewards and alpha are unchanged.
  UPDATE_MERKLE_DISTRIBUTOR_TRADER_REWARDS_AMOUNT_DIP24: '1582192000000000000000000',
  UPDATE_MERKLE_DISTRIBUTOR_ALPHA_PARAMETER_DIP24: '0',
  
  // Treasury Bridge Proposal
  UNALLOCATED_REWARDS_TO_BRIDGE_AMOUNT: toWad('240519495.4607200971'),
};

export type BaseConfig = typeof config;

export default config;
