import { types } from 'hardhat/config';

import { getDeployerSigner } from '../../src/deploy-config/get-deployer-address';
import { hardhatTask } from '../../src/hre';
import { log } from '../../src/lib/logging';
import { waitForTx } from '../../src/lib/util';
import { AxorGovernor__factory } from '../../types';

const deployGovernor = async ({
  governanceStrategy,
  votingDelay,
  addExecutorAdmin,
}: {
  governanceStrategy: string;
  votingDelay: number;
  addExecutorAdmin: string;
}) => {
  const deployer = await getDeployerSigner();

  const strategy = await new AxorGovernor__factory(deployer).deploy(
    governanceStrategy,
    votingDelay,
    addExecutorAdmin,
  );
  await waitForTx(strategy.deployTransaction);

  log('AXR Governor:', strategy.address);
  log('Constructor Args:', {
    governanceStrategy,
    votingDelay,
    addExecutorAdmin,
  });
};

hardhatTask('deploy:governance-governor', 'AxorGovernor deployment.')
  .addParam('governanceStrategy', 'Address of governance strategy contract.', undefined, types.string)
  .addParam('votingDelay', 'Delay time period after proposal creation.', undefined, types.int)
  .addParam('addExecutorAdmin', 'Address of executor admin.', undefined, types.string)
  .setAction(async (args) => {
    await deployGovernor(args);
  });
