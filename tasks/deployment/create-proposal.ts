import { types } from 'hardhat/config';

import mainnetAddresses from '../../src/deployed-addresses/mainnet.json';
import testnetAddresses from '../../tasks/deployedContract/bsc_testnet.json';
import { hardhatTask } from '../../src/hre';
import { DIP_18_IPFS_HASH } from '../../src/lib/constants';
import { createProposal } from '../../src/migrations/create-proposal';

hardhatTask('deploy:create-proposal', 'Create proposal.')
  .addParam('proposalIpfsHashHex', 'IPFS hash for the uploaded DIP describing the proposal', DIP_18_IPFS_HASH, types.string)
  .addParam('axorTokenAddress', 'Address of the deployed AXOR token contract', testnetAddresses.axorTokenAddress, types.string)
  .addParam('governorAddress', 'Address of the deployed AxorGovernor contract', testnetAddresses.governorAddress, types.string)
  .addParam('shortTimelockAddress', 'Address of the deployed short timelock Executor contract', testnetAddresses.shortTimelockAddress, types.string)
  .addParam('communityTreasuryAddress', 'Address of the deployed community treasury contract', testnetAddresses.communityTreasuryAddress, types.string)
  .setAction(async (args) => {
    await createProposal(args);
  });
