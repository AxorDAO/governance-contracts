import {
  GovernanceStrategyV2,
  GovernanceStrategyV2__factory,
} from '../../types';
import { getDeployerSigner } from '../deploy-config/get-deployer-address';
import { log } from '../lib/logging';
import { waitForTx } from '../lib/util';

export async function deployUpgradeGovernanceStrategyV2Contracts({
  startStep = 0,
  axorTokenAddress,
  safetyModuleAddress,
  governanceStrategyV2Address,
}: {
  startStep?: number,
  axorTokenAddress: string,
  safetyModuleAddress: string,
  governanceStrategyV2Address?: string,
}) {
  log('Beginning upgrade governance strategy V2 contracts deployment\n');
  const deployer = await getDeployerSigner();
  const deployerAddress = deployer.address;
  log(`Beginning deployment with deployer ${deployerAddress}\n`);

  let governanceStrategyV2: GovernanceStrategyV2;

  if (startStep <= 1) {
    log('Step 1. Deploy new governance strategy V2 contract.');
    governanceStrategyV2 = await new GovernanceStrategyV2__factory(deployer).deploy(
      axorTokenAddress,
      safetyModuleAddress,
    );
    await waitForTx(governanceStrategyV2.deployTransaction);
    log('\n=== NEW GOVERNANCE STRATEGY V2 DEPLOYMENT COMPLETE ===\n');
  } else if (!governanceStrategyV2Address) {
    throw new Error('Expected parameter governanceStrategyV2Address to be specified.');
  } else {
    governanceStrategyV2 = new GovernanceStrategyV2__factory(deployer).attach(governanceStrategyV2Address);
  }

  return { governanceStrategyV2, };
}
