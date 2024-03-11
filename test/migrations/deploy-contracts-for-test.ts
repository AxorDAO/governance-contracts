/**
 * Perform all deployments which were used in the axor governance mainnet deployment.
 */

import config from '../../src/config';
import { getDeployConfig } from '../../src/deploy-config';
import { getDeployerSigner } from '../../src/deploy-config/get-deployer-address';
import { SM_ROLE_HASHES } from '../../src/lib/constants';
import { deployMocks } from '../../src/migrations/helpers/deploy-mocks';
import { impersonateAndFundAccount } from '../../src/migrations/helpers/impersonate-account';
import { deployPhase1 } from '../../src/migrations/phase-1';
import { deployPhase2 } from '../../src/migrations/phase-2';
import { deployPhase3 } from '../../src/migrations/phase-3';
import { AllDeployedContracts } from '../../src/types';
import { incrementTimeToTimestamp, latestBlockTimestamp } from '../helpers/evm';
import { simulateAffectedStakers } from './affected-stakers';
import { fundGrantsProgramNoProposal, fundGrantsProgramViaProposal } from './grants-program-proposal';
import { fundGrantsProgramV15NoProposal, fundGrantsProgramV15ViaProposal } from './grants-program-v1_5-proposal';
import { fundOpsTrustNoProposal, fundOpsTrustViaProposal } from './ops-trust-proposal';
import { fundOpsTrustV2NoProposal, fundOpsTrustV2ViaProposal } from './ops-trust-v2-proposal';
import { updateMerkleDistributorRewardsParametersDIP24NoProposal, updateMerkleDistributorRewardsParametersDIP24ViaProposal } from './update-merkle-distributor-rewards-parameters-dip24';
import { updateMerkleDistributorRewardsParametersNoProposal, updateMerkleDistributorRewardsParametersViaProposal } from './update-merkle-distributor-rewards-parameters-proposal';
import { updateMerkleDistributorRewardsParametersV2NoProposal, updateMerkleDistributorRewardsParametersV2ViaProposal } from './update-merkle-distributor-rewards-parameters-v2-proposal';
import { executeWindDownBorrowingPoolNoProposal, executeWindDownBorrowingPoolViaProposal } from './wind-down-borrowing-pool';
import { executeWindDownSafetyModuleNoProposal, executeWindDownSafetyModuleViaProposal } from './wind-down-safety-module';

/**
 * Perform all deployments steps for the test environment.
 *
 * We use the mainnet deployments scripts to mimic the mainnet environment as closely as possible.
 */
export async function deployContractsForTest(): Promise<AllDeployedContracts> {
  // Phase 1: Deploy core governance contracts.
  const phase1Contracts = await deployPhase1();

  const mockContracts = await deployMocks();

  // Phase 2: Deploy and configure governance and incentive contracts.
  const phase2Contracts = await deployPhase2({
    // Mock contracts.
    axorCollateralTokenAddress: mockContracts.axorCollateralToken.address,

    // Phase 1 contracts.
    axorTokenAddress: phase1Contracts.axorToken.address,
    governorAddress: phase1Contracts.governor.address,
    shortTimelockAddress: phase1Contracts.shortTimelock.address,
    merklePauserTimelockAddress: phase1Contracts.merklePauserTimelock.address,
    longTimelockAddress: phase1Contracts.longTimelock.address,
    starkwarePriorityAddress: phase1Contracts.starkwarePriorityTimelock.address,
  });

  // Phase 3: Finalize the deployment w/ actions that cannot be reversed without governance action.
  await deployPhase3({
    // Phase 1 deployed contracts.
    axorTokenAddress: phase1Contracts.axorToken.address,
    governorAddress: phase1Contracts.governor.address,
    shortTimelockAddress: phase1Contracts.shortTimelock.address,
    longTimelockAddress: phase1Contracts.longTimelock.address,
    starkwarePriorityAddress: phase1Contracts.starkwarePriorityTimelock.address,

    // Phase 2 deployed contracts.
    rewardsTreasuryAddress: phase2Contracts.rewardsTreasury.address,
    rewardsTreasuryProxyAdminAddress: phase2Contracts.rewardsTreasuryProxyAdmin.address,
    safetyModuleAddress: phase2Contracts.safetyModule.address,
    safetyModuleProxyAdminAddress: phase2Contracts.safetyModuleProxyAdmin.address,
    communityTreasuryAddress: phase2Contracts.communityTreasury.address,
    communityTreasuryProxyAdminAddress: phase2Contracts.communityTreasuryProxyAdmin.address,
    rewardsTreasuryVesterAddress: phase2Contracts.rewardsTreasuryVester.address,
    communityTreasuryVesterAddress: phase2Contracts.communityTreasuryVester.address,
    liquidityStakingAddress: phase2Contracts.liquidityStaking.address,
    liquidityStakingProxyAdminAddress: phase2Contracts.liquidityStakingProxyAdmin.address,
    merkleDistributorAddress: phase2Contracts.merkleDistributor.address,
    merkleDistributorProxyAdminAddress: phase2Contracts.merkleDistributorProxyAdmin.address,
  });

  // Simulate mainnet staking activity with the broken Safety Module.
  const deployConfig = getDeployConfig();
  await incrementTimeToTimestamp(deployConfig.TRANSFERS_RESTRICTED_BEFORE);
  await simulateAffectedStakers({
    axorTokenAddress: phase1Contracts.axorToken.address,
    safetyModuleAddress: phase2Contracts.safetyModule.address,
  });

  return {
    ...phase1Contracts,
    ...phase2Contracts,
    ...mockContracts,
  };
}

export async function executeGrantsProgramProposalForTest(
  deployedContracts: AllDeployedContracts,
) {
  const deployConfig = getDeployConfig();
  if (config.TEST_FUND_GRANTS_PROGRAM_WITH_PROPOSAL) {
    await fundGrantsProgramViaProposal({
      axorTokenAddress: deployedContracts.axorToken.address,
      governorAddress: deployedContracts.governor.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
      communityTreasuryAddress: deployedContracts.communityTreasury.address,
      dgpMultisigAddress: deployConfig.DGP_MULTISIG_ADDRESS,
    });
  } else {
    await fundGrantsProgramNoProposal({
      axorTokenAddress: deployedContracts.axorToken.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
      communityTreasuryAddress: deployedContracts.communityTreasury.address,
      dgpMultisigAddress: deployConfig.DGP_MULTISIG_ADDRESS,
    });
  }
}

export async function executeGrantsProgramv15ProposalForTest(
  deployedContracts: AllDeployedContracts,
) {
  const deployConfig = getDeployConfig();
  if (config.TEST_FUND_GRANTS_PROGRAM_v1_5_WITH_PROPOSAL) {
    await fundGrantsProgramV15ViaProposal({
      axorTokenAddress: deployedContracts.axorToken.address,
      governorAddress: deployedContracts.governor.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
      communityTreasuryAddress: deployedContracts.communityTreasury.address,
      dgpMultisigAddress: deployConfig.DGP_MULTISIG_ADDRESS,
    });
  } else {
    await fundGrantsProgramV15NoProposal({
      axorTokenAddress: deployedContracts.axorToken.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
      communityTreasuryAddress: deployedContracts.communityTreasury.address,
      dgpMultisigAddress: deployConfig.DGP_MULTISIG_ADDRESS,
    });
  }
}

export async function executeWindDownBorrowingPoolProposalForTest(
  deployedContracts: AllDeployedContracts,
) {
  if (config.WIND_DOWN_BORROWING_POOL_WITH_PROPOSAL) {
    await executeWindDownBorrowingPoolViaProposal({
      axorTokenAddress: deployedContracts.axorToken.address,
      governorAddress: deployedContracts.governor.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
      liquidityModuleAddress: deployedContracts.liquidityStaking.address,
    });
  } else {
    await executeWindDownBorrowingPoolNoProposal({
      shortTimelockAddress: deployedContracts.shortTimelock.address,
      liquidityModuleAddress: deployedContracts.liquidityStaking.address,
    });
  }
}

export async function executeWindDownSafetyModuleProposalForTest(
  deployedContracts: AllDeployedContracts,
) {
  if (config.TEST_WIND_DOWN_SAFETY_MODULE_WITH_PROPOSAL) {
    await executeWindDownSafetyModuleViaProposal({
      axorTokenAddress: deployedContracts.axorToken.address,
      governorAddress: deployedContracts.governor.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
      safetyModuleAddress: deployedContracts.safetyModule.address,
    });
  } else {
    await executeWindDownSafetyModuleNoProposal({
      shortTimelockAddress: deployedContracts.shortTimelock.address,
      safetyModuleAddress: deployedContracts.safetyModule.address,
    });
  }
}


export async function executeUpdateMerkleDistributorRewardsParametersProposalForTest(
  deployedContracts: AllDeployedContracts,
) {
  if (config.TEST_UPDATE_MERKLE_DISTRIBUTOR_REWARDS_PARAMETERS_WITH_PROPOSAL) {
    await updateMerkleDistributorRewardsParametersViaProposal({
      axorTokenAddress: deployedContracts.axorToken.address,
      governorAddress: deployedContracts.governor.address,
      merkleDistributorAddress: deployedContracts.merkleDistributor.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
    });
  } else {
    await updateMerkleDistributorRewardsParametersNoProposal({
      merkleDistributorAddress: deployedContracts.merkleDistributor.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
    });
  }
}

export async function executeOpsTrustProposalForTest(
  deployedContracts: AllDeployedContracts,
) {
  const deployConfig = getDeployConfig();
  if (config.TEST_FUND_OPS_TRUST_WITH_PROPOSAL) {
    await fundOpsTrustViaProposal({
      axorTokenAddress: deployedContracts.axorToken.address,
      governorAddress: deployedContracts.governor.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
      communityTreasuryAddress: deployedContracts.communityTreasury.address,
      dotMultisigAddress: deployConfig.DOT_MULTISIG_ADDRESS,
    });
  } else {
    await fundOpsTrustNoProposal({
      axorTokenAddress: deployedContracts.axorToken.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
      communityTreasuryAddress: deployedContracts.communityTreasury.address,
      dotMultisigAddress: deployConfig.DOT_MULTISIG_ADDRESS,
    });
  }
}

export async function executeUpdateMerkleDistributorRewardsParametersV2ProposalForTest(
  deployedContracts: AllDeployedContracts,
) {
  if (config.TEST_UPDATE_MERKLE_DISTRIBUTOR_REWARDS_PARAMETERS_v2_WITH_PROPOSAL) {
    await updateMerkleDistributorRewardsParametersV2ViaProposal({
      axorTokenAddress: deployedContracts.axorToken.address,
      governorAddress: deployedContracts.governor.address,
      merkleDistributorAddress: deployedContracts.merkleDistributor.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
    });
  } else {
    await updateMerkleDistributorRewardsParametersV2NoProposal({
      merkleDistributorAddress: deployedContracts.merkleDistributor.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
    });
  }
}

export async function executeOpsTrustV2ProposalForTest(
  deployedContracts: AllDeployedContracts,
) {
  const deployConfig = getDeployConfig();
  if (config.TEST_FUND_OPS_TRUST_v2_WITH_PROPOSAL) {
    await fundOpsTrustV2ViaProposal({
      axorTokenAddress: deployedContracts.axorToken.address,
      governorAddress: deployedContracts.governor.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
      communityTreasuryAddress: deployedContracts.communityTreasury.address,
      dotMultisigAddress: deployConfig.DOT_MULTISIG_ADDRESS_V2,
    });
  } else {
    await fundOpsTrustV2NoProposal({
      axorTokenAddress: deployedContracts.axorToken.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
      communityTreasuryAddress: deployedContracts.communityTreasury.address,
      dotMultisigAddress: deployConfig.DOT_MULTISIG_ADDRESS_V2,
    });
  }
}

export async function executeUpdateMerkleDistributorRewardsParametersDIP24ProposalForTest(
  deployedContracts: AllDeployedContracts,
) {
  if (config.TEST_UPDATE_MERKLE_DISTRIBUTOR_REWARDS_PARAMETERS_DIP24_WITH_PROPOSAL) {
    await updateMerkleDistributorRewardsParametersDIP24ViaProposal({
      axorTokenAddress: deployedContracts.axorToken.address,
      governorAddress: deployedContracts.governor.address,
      merkleDistributorAddress: deployedContracts.merkleDistributor.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
    });
  } else {
    await updateMerkleDistributorRewardsParametersDIP24NoProposal({
      merkleDistributorAddress: deployedContracts.merkleDistributor.address,
      shortTimelockAddress: deployedContracts.shortTimelock.address,
    });
  }
}

/**
 * After the deploy scripts have run, this function configures the contracts for testing.
 */
export async function configureForTest(
  deployedContracts: AllDeployedContracts,
): Promise<void> {
  const {
    axorToken,
    shortTimelock,
    safetyModule,
  } = deployedContracts;
  const deployer = await getDeployerSigner();

  // Give some tokens back to the deployer to use during testing.
  const foundationAddress = getDeployConfig().TOKEN_ALLOCATIONS.AXOR_DAO.ADDRESS;
  const foundation = await impersonateAndFundAccount(foundationAddress);
  const balance = await axorToken.balanceOf(foundationAddress);
  await axorToken.connect(foundation).transfer(deployer.address, balance);

  // Assign roles to the deployer for use during testing.
  const mockShortTimelock = await impersonateAndFundAccount(shortTimelock.address);
  for (const role of SM_ROLE_HASHES) {
    await safetyModule.connect(mockShortTimelock).grantRole(
      role,
      deployer.address,
    );
  }

  // Advance to the next epoch start, to ensure we don't begin the tests in a blackout window.
  const nextEpochStart = (
    await latestBlockTimestamp() +
    Number(await deployedContracts.safetyModule.getTimeRemainingInCurrentEpoch())
  );
  await incrementTimeToTimestamp(nextEpochStart);
}
