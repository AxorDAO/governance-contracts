import { hardhatTask } from '../../src/hre';
import { deployPhase2 } from '../../src/migrations/phase-2';

// import addressList from '../deployedContract/bsc_testnet.json';
import addressList from '../deployedContract/arbitrum_testnet.json';

const config = {
  startStep: 1,
  ...addressList,
};

hardhatTask('deploy:phase-2', 'Phase 2 of governance deployment.').setAction(
  async () => {
    await deployPhase2(config);
  },
);
