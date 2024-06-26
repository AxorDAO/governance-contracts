import { hardhatTask } from '../../src/hre';
import { deployPhase1 } from '../../src/migrations/phase-1';

import addressList from '../deployedContract/bsc_testnet.json';
const config = {
  startStep: 1,
  ...addressList,
};

hardhatTask('deploy:phase-1', 'Phase 1 of governance deployment.').setAction(
  async () => {
    await deployPhase1(config);
  },
);
