import { types } from 'hardhat/config';

import mainnetAddresses from '../../src/deployed-addresses/mainnet.json';
import { hardhatTask } from '../../src/hre';
import { DIP_18_IPFS_HASH } from '../../src/lib/constants';
import { createOpsTrustProposal } from '../../src/migrations/ops-trust-proposal';

hardhatTask('deploy:ops-trust-proposal', 'Create proposal to launch DOT with multisig funding.')
  .addParam('proposalIpfsHashHex', 'IPFS hash for the uploaded DIP describing the proposal', DIP_18_IPFS_HASH, types.string)
  .addParam('axorTokenAddress', 'Address of the deployed AXOR token contract', mainnetAddresses.axorToken, types.string)
  .addParam('governorAddress', 'Address of the deployed AxorGovernor contract', mainnetAddresses.governor, types.string)
  .addParam('shortTimelockAddress', 'Address of the deployed short timelock Executor contract', mainnetAddresses.shortTimelock, types.string)
  .addParam('communityTreasuryAddress', 'Address of the deployed community treasury contract', mainnetAddresses.communityTreasury, types.string)
  .setAction(async (args) => {
    await createOpsTrustProposal(args);
  });
