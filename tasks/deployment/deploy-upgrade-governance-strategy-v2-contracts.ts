import { types } from 'hardhat/config';

import mainnetAddresses from '../../src/deployed-addresses/mainnet.json';
import { hardhatTask } from '../../src/hre';
import { log } from '../../src/lib/logging';
import { deployUpgradeGovernanceStrategyV2Contracts } from '../../src/migrations/deploy-upgrade-governance-strategy-v2-contracts';

hardhatTask(
  'deploy:upgrade-governance-strategy-v2-contracts',
  'governance strategy V2 contract.',
)
  .addParam(
    'axorTokenAddress',
    'Address of the deployed AxorToken contract',
    mainnetAddresses.axorToken,
    types.string,
  )
  .addParam(
    'safetyModuleAddress',
    'Address of the deployed safety module contract (staked AXOR token)',
    mainnetAddresses.safetyModule,
    types.string,
  )
  .setAction(async (args: { axorTokenAddress: string; safetyModuleAddress: string }) => {
    const { governanceStrategyV2 } = await deployUpgradeGovernanceStrategyV2Contracts({
      axorTokenAddress: args.axorTokenAddress,
      safetyModuleAddress: args.safetyModuleAddress,
    });
    // Log out the contract addresses.
    log(`New Governance Strategy V2 contract deployed to: ${governanceStrategyV2.address}`);

    // Log out instructions to verify the contracts on the desired network.
    log('Perform the following steps to verify the deployed contracts on Etherscan:');
    log(
      '2. Run the following command to verify the Ethereum Wrapped Axor Token Contract (using mainnet as an example):\n',
    );
    log(
      '\n3. Run the following command with a network and Etherscan API key to verify the Governance Strategy V2 Contract (using mainnet as an example):\n',
    );
    log(
      '\nUsing mainnet as an example, run the following command to get the upgrade governance strategy V2 proposal creation calldata:',
    );
    log(
      `npx hardhat --network mainnet upgrade-governance-strategy-v2-proposal --governance-strategy-v2-address ${governanceStrategyV2.address}`,
    );
  });
