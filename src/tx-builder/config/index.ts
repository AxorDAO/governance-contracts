import { BigNumber, constants } from 'ethers';
import { formatUnits } from 'ethers/lib/utils';

import {
  GasRecommendationType,
  ProtocolAction,
  tStringDecimalUnits,
} from '../types';

export const EPOCH_ZERO: number = 0;
export const AXOR_GOVERNOR_DEPLOYMENT_BLOCK: number = 12678600;
export const ONE_DAY_SECONDS: BigNumber = BigNumber.from(60 * 60 * 24);
export const DEFAULT_NULL_VALUE_ON_TX = BigNumber.from(0).toHexString();
export const DEFAULT_APPROVE_AMOUNT = constants.MaxUint256.toString();
export const MAX_UINT_AMOUNT =
  '115792089237316195423570985008687907853269984665640564039457584007913129639935';
export const AXOR_TOKEN_DECIMALS = 18;
export const USDC_TOKEN_DECIMALS = 6;
// 500M tokens locked for 18 months
export const LOCKED_ALLOCATION: tStringDecimalUnits = formatUnits(
  500_000_000,
  0,
);
// market maker rewards + trading rewards
export const MERKLE_DISTRIBUTOR_REWARDS_PER_EPOCH: number =
  1_150_685 + 3_835_616;
// 75M tokens were allocated as retroactive mining rewards
export const RETROACTIVE_MINING_REWARDS: tStringDecimalUnits =
  '50,309,197.21323933';

const BASE_SUBGRAPH_URL = 'https://api.thegraph.com/subgraphs/name/';
export const GOERLI_SUBGRAPH_URL =
  'https://api.studio.thegraph.com/query/66875/axor-governance/version/latest';
export const BSC_TESTNET_SUBGRAPH_URL =
  'https://api.studio.thegraph.com/query/47685/axor-bsc-testnet/version/latest';
export const ARBITRUM_TESTNET_SUBGRAPH_URL =
  'https://api.studio.thegraph.com/query/66875/axor-governance-test/version/latest';
export const MAINNET_SUBGRAPH_URL = `${BASE_SUBGRAPH_URL}`;

export const gasLimitRecommendations: GasRecommendationType = {
  [ProtocolAction.default]: {
    limit: '210000',
    recommended: '210000',
  },
};

export * from './addresses';
