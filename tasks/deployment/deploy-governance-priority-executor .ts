import { types } from 'hardhat/config';

import { getDeployerSigner } from '../../src/deploy-config/get-deployer-address';
import { hardhatTask } from '../../src/hre';
import { log } from '../../src/lib/logging';
import { waitForTx } from '../../src/lib/util';
import { PriorityExecutor__factory } from '../../types';

const deployGovernanceExecutor = async ({
  admin,
  delay,
  gracePeriod,
  minimumDelay,
  maximumDelay,
  propositionThreshold,
  voteDuration,
  voteDifferential,
  minimumQuorum,
  priorityPeriod,
  priorityExecutor,
}: {
  admin: string;
  delay: number;
  gracePeriod: number;
  minimumDelay: number;
  maximumDelay: number;
  propositionThreshold: number;
  voteDuration: number;
  voteDifferential: number;
  minimumQuorum: number;
  priorityPeriod: number;
  priorityExecutor: string;
}) => {
  const deployer = await getDeployerSigner();

  const executor = await new PriorityExecutor__factory(deployer).deploy(
    admin,
    delay,
    gracePeriod,
    minimumDelay,
    maximumDelay,
    priorityPeriod,
    propositionThreshold,
    voteDuration,
    voteDifferential,
    minimumQuorum,
    priorityExecutor,
  );
  await waitForTx(executor.deployTransaction);

  console.log('AXOR Governance executor:', executor.address);
  console.log('Constructor Args:', {
    admin,
    delay,
    gracePeriod,
    minimumDelay,
    maximumDelay,
    propositionThreshold,
    voteDuration,
    voteDifferential,
    minimumQuorum,
  });
};

hardhatTask(
  'deploy:governance-priority-executor',
  'Governance executor deployment.',
)
  .addParam('admin', 'string, admin of this executor.', undefined, types.string)
  .addParam(
    'delay',
    'number, a delay time from queue time to executionTime.',
    undefined,
    types.int,
  )
  .addParam(
    'gracePeriod',
    'number, a period available for execute proposol.',
    undefined,
    types.int,
  )
  .addParam('minimumDelay', 'number, minimum delay value', undefined, types.int)
  .addParam('maximumDelay', 'number, maximum delay value', undefined, types.int)
  .addParam(
    'propositionThreshold',
    'number, minimum power needed (%), 100%=10000',
    undefined,
    types.int,
  )
  .addParam(
    'voteDuration',
    'number, voting duration (caculate by block), 1000 mean 1000 blocks',
    undefined,
    types.int,
  )
  .addParam(
    'voteDifferential',
    'number, different between forVotes and againstVotes, (forVotes - againstVotes)*100/votingSupply > voteDifferential ==> proposol will be executed',
    undefined,
    types.int,
  )
  .addParam(
    'minimumQuorum',
    'number, the minimum voting power needed for a proposal to meet the quorum threshold',
    undefined,
    types.int,
  )
  .setAction(async (args) => {
    await deployGovernanceExecutor(args);
  });
