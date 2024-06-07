import { hardhatTask } from '../../src/hre';
import { deployPhase3 } from '../../src/migrations/phase-3';

import addressList from '../deployedContract/bsc_testnet.json';
const config = {
  startStep: 1,
  ...addressList,
};

hardhatTask('deploy:phase-3', 'Phase 3 of governance deployment.').setAction(
  async () => {
    await deployPhase3(config);
  },
);
