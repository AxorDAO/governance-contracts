import { BigNumber } from 'ethers';
import { formatEther } from 'ethers/lib/utils';
import _ from 'lodash';

import {
  AxorGovernor__factory,
  AxorToken__factory,
  Executor__factory,
  LiquidityStakingV1__factory,
  ProxyAdmin__factory,
  SafetyModuleV1__factory,
  Treasury__factory,
} from '../../types';
import { MerkleDistributorV1__factory } from '../../types/factories/MerkleDistributorV1__factory';
import { getDeployConfig } from '../deploy-config';
import { getDeployerSigner } from '../deploy-config/get-deployer-address';
import { log } from '../lib/logging';
import { getRole, toWad, waitForTx } from '../lib/util';
import { Role } from '../types';
import { upgradeContract } from './helpers/deploy-upgradeable';
import { expectDeployerBalance } from './helpers/expect-deployer-balance';
import { transferWithPrompt } from './helpers/transfer-tokens';

export async function deployPhase3({
  startStep = 0,

  // Phase 1 deployed contracts.
  axorTokenAddress,
  governorAddress,
  shortTimelockAddress,
  longTimelockAddress,

  // Phase 2 deployed contracts.
  rewardsTreasuryAddress,
  rewardsTreasuryProxyAdminAddress,
  safetyModuleAddress,
  safetyModuleProxyAdminAddress,
  communityTreasuryAddress,
  communityTreasuryProxyAdminAddress,
  rewardsTreasuryVesterAddress,
  communityTreasuryVesterAddress,
  liquidityStakingAddress,
  liquidityStakingProxyAdminAddress,
  merkleDistributorAddress,
  merkleDistributorProxyAdminAddress,
}: {
  startStep?: number,

  // Phase 1 deployed contracts.
  axorTokenAddress: string,
  governorAddress: string,
  longTimelockAddress: string,
  shortTimelockAddress: string,
  starkwarePriorityAddress: string,

  // Phase 2 deployed contracts.
  rewardsTreasuryAddress: string,
  rewardsTreasuryProxyAdminAddress: string,
  safetyModuleAddress: string,
  safetyModuleProxyAdminAddress: string,
  communityTreasuryAddress: string,
  communityTreasuryProxyAdminAddress: string,
  rewardsTreasuryVesterAddress: string,
  communityTreasuryVesterAddress: string,
  liquidityStakingAddress: string,
  liquidityStakingProxyAdminAddress: string,
  merkleDistributorAddress: string,
  merkleDistributorProxyAdminAddress: string,
}) {
  log('Beginning phase 3 deployment\n');
  const deployConfig = getDeployConfig();
  const deployer = await getDeployerSigner();
  const deployerAddress = deployer.address;
  log(`Beginning deployment with deployer ${deployerAddress}\n`);

  // Phase 1 deployed contracts.
  const axorToken = new AxorToken__factory(deployer).attach(axorTokenAddress);
  const governor = new AxorGovernor__factory(deployer).attach(governorAddress);
  const longTimelock = new Executor__factory(deployer).attach(longTimelockAddress);
  const shortTimelock = new Executor__factory(deployer).attach(shortTimelockAddress);

  // Phase 2 deployed contracts.
  const rewardsTreasury = new Treasury__factory(deployer).attach(rewardsTreasuryAddress);
  const rewardsTreasuryProxyAdmin = new ProxyAdmin__factory(deployer).attach(rewardsTreasuryProxyAdminAddress);
  const safetyModule = new SafetyModuleV1__factory(deployer).attach(safetyModuleAddress);
  const safetyModuleProxyAdmin = new ProxyAdmin__factory(deployer).attach(safetyModuleProxyAdminAddress);
  const communityTreasury = new Treasury__factory(deployer).attach(communityTreasuryAddress);
  const communityTreasuryProxyAdmin = new ProxyAdmin__factory(deployer).attach(communityTreasuryProxyAdminAddress);
  const liquidityStaking = new LiquidityStakingV1__factory(deployer).attach(liquidityStakingAddress);
  const liquidityStakingProxyAdmin = new ProxyAdmin__factory(deployer).attach(liquidityStakingProxyAdminAddress);
  const merkleDistributor = new MerkleDistributorV1__factory(deployer).attach(merkleDistributorAddress);
  const merkleDistributorProxyAdmin = new ProxyAdmin__factory(deployer).attach(merkleDistributorProxyAdminAddress);

  const deployerBalance = await axorToken.balanceOf(deployerAddress);
  if (deployerBalance.lt(toWad(500_000_00))) {
    throw new Error(`Need at least 500M AXOR to run this deploy script. Current balance: ${formatEther(deployerBalance)}`);
  }

  if (startStep <= 2) {
    log('Step 2. Add token allocation recipients to the transfer allowlist');
    await waitForTx(
      await axorToken.addToTokenTransferAllowlist([
        deployConfig.TOKEN_ALLOCATIONS.AXOR_DAO.ADDRESS,
        deployConfig.TOKEN_ALLOCATIONS.AXOR_TRADING.ADDRESS,
        deployConfig.TOKEN_ALLOCATIONS.AXOR_LLC.ADDRESS,
      ]),
    );
  }

  if (startStep <= 3) {
    log('Step 3: Push back transfer restriction.');
    await waitForTx(await axorToken.updateTransfersRestrictedBefore(deployConfig.TRANSFERS_RESTRICTED_BEFORE));
  }

  if (startStep <= 9) {
    log('Step 9: Transfer rewards treasury proxy admin ownership to short timelock');
    await waitForTx(await rewardsTreasuryProxyAdmin.transferOwnership(shortTimelock.address));
  }

  if (startStep <= 10) {
    log('Step 10: Transfer community treasury proxy admin ownership to short timelock');
    await waitForTx(await communityTreasuryProxyAdmin.transferOwnership(shortTimelock.address));
  }

  if (startStep <= 11) {
    log('Step 11: Transfer merkle distributor proxy admin ownership to short timelock');
    await waitForTx(await merkleDistributorProxyAdmin.transferOwnership(shortTimelock.address));
  }

  if (startStep <= 12) {
    log('Step 12: Transfer liquidity staking proxy admin ownership to short timelock');
    await waitForTx(await liquidityStakingProxyAdmin.transferOwnership(shortTimelock.address));
  }

  if (startStep <= 13) {
    log('Step 13: Transfer safety module proxy admin ownership to long timelock');
    await waitForTx(await safetyModuleProxyAdmin.transferOwnership(longTimelock.address));
  }

  if (startStep <= 14) {
    log('Step 14: Transfer ownership of community treasury to short timelock');
    await waitForTx(await communityTreasury.transferOwnership(shortTimelock.address));
  }

  if (startStep <= 15) {
    log('Step 15. Revoke all roles from EOAs on incentives contracts');

    const txs = [
      // Revoke roles from the Merkle Distributor Module.
      await merkleDistributor.revokeRole(getRole(Role.PAUSER_ROLE), deployerAddress),
      await merkleDistributor.revokeRole(getRole(Role.UNPAUSER_ROLE), deployerAddress),
      await merkleDistributor.revokeRole(getRole(Role.CLAIM_OPERATOR_ROLE), deployerAddress),
      await merkleDistributor.revokeRole(getRole(Role.OWNER_ROLE), deployerAddress),

      // Revoke roles from the Liquidity Staking Module.
      await liquidityStaking.revokeRole(getRole(Role.EPOCH_PARAMETERS_ROLE), deployerAddress),
      await liquidityStaking.revokeRole(getRole(Role.REWARDS_RATE_ROLE), deployerAddress),
      await liquidityStaking.revokeRole(getRole(Role.BORROWER_ADMIN_ROLE), deployerAddress),
      await liquidityStaking.revokeRole(getRole(Role.OWNER_ROLE), deployerAddress),

      // Revoke roles from the Safety Module.
      await safetyModule.revokeRole(getRole(Role.SLASHER_ROLE), deployerAddress),
      await safetyModule.revokeRole(getRole(Role.EPOCH_PARAMETERS_ROLE), deployerAddress),
      await safetyModule.revokeRole(getRole(Role.REWARDS_RATE_ROLE), deployerAddress),
      await safetyModule.revokeRole(getRole(Role.OWNER_ROLE), deployerAddress),
    ];

    await Promise.all(txs.map((tx) => waitForTx(tx)));
  }

  await expectDeployerBalance(
    axorToken,
    BigNumber.from(toWad(500_000_000))
      .sub(deployConfig.REWARDS_TREASURY_FRONTLOADED_FUNDS)
      .add(deployConfig.TOKEN_ALLOCATIONS.AXOR_DAO.AMOUNT)
      .add(deployConfig.TOKEN_ALLOCATIONS.AXOR_LLC.AMOUNT)
      .add(deployConfig.TOKEN_ALLOCATIONS.AXOR_TRADING.AMOUNT),
  );

  if (startStep <= 16) {
    log('Step 16. Send tokens to axor Trading Inc');
    await transferWithPrompt(
      axorToken,
      deployConfig.TOKEN_ALLOCATIONS.AXOR_TRADING.ADDRESS,
      deployConfig.TOKEN_ALLOCATIONS.AXOR_TRADING.AMOUNT,
    );
  }

  await expectDeployerBalance(
    axorToken,
    BigNumber.from(toWad(500_000_000))
      .sub(deployConfig.REWARDS_TREASURY_FRONTLOADED_FUNDS)
      .add(deployConfig.TOKEN_ALLOCATIONS.AXOR_DAO.AMOUNT)
      .add(deployConfig.TOKEN_ALLOCATIONS.AXOR_LLC.AMOUNT),
  );

  if (startStep <= 17) {
    log('Step 17. Send tokens to axor LLC');
    await transferWithPrompt(
      axorToken,
      deployConfig.TOKEN_ALLOCATIONS.AXOR_LLC.ADDRESS,
      deployConfig.TOKEN_ALLOCATIONS.AXOR_LLC.AMOUNT,
    );
  }

  await expectDeployerBalance(
    axorToken,
    BigNumber.from(toWad(500_000_000))
      .sub(deployConfig.REWARDS_TREASURY_FRONTLOADED_FUNDS)
      .add(deployConfig.TOKEN_ALLOCATIONS.AXOR_DAO.AMOUNT),
  );

  if (startStep <= 18) {
    log('Step 18. Send tokens to AxorDAO');
    await transferWithPrompt(
      axorToken,
      deployConfig.TOKEN_ALLOCATIONS.AXOR_DAO.ADDRESS,
      deployConfig.TOKEN_ALLOCATIONS.AXOR_DAO.AMOUNT,
    );
  }

  if (startStep <= 19) {
    log('Step 19: Transfer ownership of rewards treasury to short timelock');
    await waitForTx(await rewardsTreasury.transferOwnership(shortTimelock.address));
  }

  await expectDeployerBalance(
    axorToken,
    BigNumber.from(toWad(500_000_000))
      .sub(deployConfig.REWARDS_TREASURY_FRONTLOADED_FUNDS),
  );

  if (startStep <= 20) {
    log('Step 20. Send tokens to be locked up in the rewards treasury vester');
    await transferWithPrompt(
      axorToken,
      rewardsTreasuryVesterAddress,
      deployConfig.REWARDS_TREASURY_VESTER_CONFIG.VESTING_AMOUNT,
    );
  }

  await expectDeployerBalance(
    axorToken,
    BigNumber.from(toWad(500_000_000))
      .sub(deployConfig.REWARDS_TREASURY_FRONTLOADED_FUNDS)
      .sub(deployConfig.REWARDS_TREASURY_VESTER_CONFIG.VESTING_AMOUNT),
  );

  if (startStep <= 21) {
    log('Step 21. Send tokens to be locked up in the community treasury vester');
    await transferWithPrompt(
      axorToken,
      communityTreasuryVesterAddress,
      deployConfig.COMMUNITY_TREASURY_VESTER_CONFIG.VESTING_AMOUNT,
    );
  }

  if (startStep <= 22) {
    log('Step 22. Revoke all roles from EOAs on the Governor contract');

    const txs = [
      // Revoke roles from the Governor.
      await governor.grantRole(getRole(Role.ADD_EXECUTOR_ROLE), shortTimelock.address),
      await governor.grantRole(getRole(Role.OWNER_ROLE), longTimelock.address),
    ];

    await Promise.all(txs.map((tx) => waitForTx(tx)));
  }

  if (startStep <= 23) {
    log('Step 23: Transfer AXOR token contract ownership to the short timelock');
    await waitForTx(await axorToken.transferOwnership(shortTimelock.address));
  }

  log('\n=== PHASE 3 DEPLOYMENT COMPLETE ===\n');
}
