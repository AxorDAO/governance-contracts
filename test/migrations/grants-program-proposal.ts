import BNJS from 'bignumber.js';
import { BigNumber, BigNumberish } from 'ethers';

import config from '../../src/config';
import { getDeployConfig } from '../../src/deploy-config';
import { getDeployerSigner } from '../../src/deploy-config/get-deployer-address';
import { log } from '../../src/lib/logging';
import { waitForTx } from '../../src/lib/util';
import { createGrantsProgramProposal } from '../../src/migrations/grants-program-proposal';
import { impersonateAndFundAccount } from '../../src/migrations/helpers/impersonate-account';
import {
  AxorGovernor__factory,
  AxorToken__factory,
  Treasury__factory,
} from '../../types';
import { advanceBlock, increaseTimeAndMine } from '../helpers/evm';

const MOCK_PROPOSAL_IPFS_HASH = (
  '0x0000000000000000000000000000000000000000000000000000000000000000'
);

export async function fundGrantsProgramViaProposal({
  axorTokenAddress,
  governorAddress,
  shortTimelockAddress,
  communityTreasuryAddress,
  dgpMultisigAddress,
}: {
  axorTokenAddress: string,
  governorAddress: string,
  shortTimelockAddress: string,
  communityTreasuryAddress: string,
  dgpMultisigAddress: string,
}): Promise<void> {
  const deployConfig = getDeployConfig();
  const deployer = await getDeployerSigner();
  const axorToken = new AxorToken__factory(deployer).attach(axorTokenAddress);
  const governor = new AxorGovernor__factory(deployer).attach(governorAddress);

  await fundCommunityTreasuryFromFoundationIfNecessary({
    axorTokenAddress,
    communityTreasuryAddress,
    minTreasuryBalance: deployConfig.DGP_FUNDING_AMOUNT,
  });

  // Pick a voter with enough tokens to meet the quorum requirement.
  const voterAddress = deployConfig.TOKEN_ALLOCATIONS.AXOR_TRADING.ADDRESS;
  const voter = await impersonateAndFundAccount(voterAddress);
  const voterBalance = await axorToken.balanceOf(voterAddress);

  if (voterBalance.lt(new BNJS('2e25').toFixed())) {
    throw new Error('Not enough votes to pass the proposal.');
  }

  // Vote on an existing proposal (can be used with mainnet forking).
  let proposalId: BigNumberish;

  if (config.FUND_GRANTS_PROGRAM_PROPOSAL_ID !== null) {
    proposalId = config.FUND_GRANTS_PROGRAM_PROPOSAL_ID;
  } else {
    log('Creating proposal');
    ({ proposalId } = await createGrantsProgramProposal({
      proposalIpfsHashHex: MOCK_PROPOSAL_IPFS_HASH,
      axorTokenAddress,
      governorAddress,
      shortTimelockAddress,
      communityTreasuryAddress,
      dgpMultisigAddress,
      signer: voter,
    }));

    log('Waiting for voting to begin');
    for (let i = 0; i < deployConfig.VOTING_DELAY_BLOCKS + 1; i++) {
      if (i > 0 && i % 2000 === 0) {
        log('mining', i);
      }
      await advanceBlock();
    }
  }

  let proposalState = await governor.getProposalState(proposalId);
  if (proposalState !== 2) {
    throw new Error('Expected proposal to be in the voting phase.');
  }

  log('Submitting vote');
  await waitForTx(await governor.connect(voter).submitVote(proposalId, true));

  log('Waiting for voting to end');
  let minedCount = 0;
  for (; ;) {
    for (let i = 0; i < 2000; i++) {
      await advanceBlock();
      minedCount++;
    }
    log('mining', minedCount);
    proposalState = await governor.getProposalState(proposalId);
    if (proposalState !== 2) {
      break;
    }
  }

  if (proposalState !== 4) {
    throw new Error(`Expected proposal to have succeeded but state was ${proposalState}`);
  }

  log('Queueing the proposal');
  await waitForTx(await governor.queue(proposalId));
  const delaySeconds = deployConfig.SHORT_TIMELOCK_CONFIG.DELAY;
  await increaseTimeAndMine(delaySeconds);

  log('Executing the proposal');
  await waitForTx(await governor.execute(proposalId));
  log('Proposal executed');

  log('\n=== GRANTS PROGRAM FUNDING COMPLETE ===\n');
}

export async function fundGrantsProgramNoProposal({
  axorTokenAddress,
  shortTimelockAddress,
  communityTreasuryAddress,
  dgpMultisigAddress,
}: {
  axorTokenAddress: string,
  shortTimelockAddress: string,
  communityTreasuryAddress: string,
  dgpMultisigAddress: string,
}): Promise<void> {
  const deployConfig = getDeployConfig();
  const mockShortTimelock = await impersonateAndFundAccount(shortTimelockAddress);
  const communityTreasury = new Treasury__factory(mockShortTimelock).attach(
    communityTreasuryAddress,
  );

  await fundCommunityTreasuryFromFoundationIfNecessary({
    axorTokenAddress,
    communityTreasuryAddress,
    minTreasuryBalance: deployConfig.DGP_FUNDING_AMOUNT,
  });

  await waitForTx(
    await communityTreasury.transfer(
      axorTokenAddress,
      dgpMultisigAddress,
      deployConfig.DGP_FUNDING_AMOUNT,
    ),
  );

  log('\n=== GRANTS PROGRAM FUNDING COMPLETE ===\n');
}

async function fundCommunityTreasuryFromFoundationIfNecessary({
  axorTokenAddress,
  communityTreasuryAddress,
  minTreasuryBalance,
}: {
  axorTokenAddress: string,
  communityTreasuryAddress: string,
  minTreasuryBalance: string,
}): Promise<void> {
  const deployConfig = getDeployConfig();

  const mockFoundation = await impersonateAndFundAccount(deployConfig.TOKEN_ALLOCATIONS.AXOR_DAO.ADDRESS);
  const axorToken = new AxorToken__factory(mockFoundation).attach(axorTokenAddress);
  const communityTreasuryBalance: BigNumber = await axorToken.balanceOf(communityTreasuryAddress);

  if (communityTreasuryBalance.lt(minTreasuryBalance)) {
    // Transfer necessary funds to the treasury.
    await waitForTx(
      await axorToken.transfer(
        communityTreasuryAddress,
        minTreasuryBalance,
      ),
    );
  }
}
