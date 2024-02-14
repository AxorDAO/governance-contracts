import { types } from 'hardhat/config';

import { getDeployerSigner } from '../../src/deploy-config/get-deployer-address';
import { hardhatTask } from '../../src/hre';
import { log } from '../../src/lib/logging';
import { waitForTx } from '../../src/lib/util';
import { GovernanceStrategy__factory } from '../../types';

const deployGovernanceStrategy = async ({
  axorAddress,
  stakeAxorAddress,
}: {
  axorAddress: string,
  stakeAxorAddress: string,
}) => {
  const deployer = await getDeployerSigner();

  const strategy = await new GovernanceStrategy__factory(deployer).deploy(
    axorAddress,
    stakeAxorAddress
  );
  await waitForTx(strategy.deployTransaction);

  log('AXR Governance strategy:', strategy.address);
  log('Constructor Args:', {
    axorAddress,
    stakeAxorAddress
  });
};

hardhatTask('deploy:governance-strategy', 'Governance strategy deployment.')
  .addParam(
    'axorAddress',
    'Address of axor token.',
    undefined,
    types.string,
  )
  .addParam(
    'stakeAxorAddress',
    'Address of axor stake token.',
    undefined,
    types.string,
  )
  .setAction(async (args) => {
    await deployGovernanceStrategy(args);
  });
