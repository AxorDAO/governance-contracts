import { types } from 'hardhat/config';

import { getDeployerSigner } from '../../src/deploy-config/get-deployer-address';
import { hardhatTask } from '../../src/hre';
import { log } from '../../src/lib/logging';
import { waitForTx } from '../../src/lib/util';
import { AxorToken__factory } from '../../types';

const deployAxorToken = async ({
  transfersRestrictedBefore,
  transferRestrictionLiftedNoLaterThan,
  mintingRestrictedBefore,
  mintMaxPercent,
}: {
  transfersRestrictedBefore: number,
  transferRestrictionLiftedNoLaterThan: number,
  mintingRestrictedBefore: number,
  mintMaxPercent: number
}) => {
  const deployer = await getDeployerSigner();
  const deployerAddress = deployer.address;

  const token = await new AxorToken__factory(deployer).deploy(
    deployerAddress,
    transfersRestrictedBefore,
    transferRestrictionLiftedNoLaterThan,
    mintingRestrictedBefore,
    mintMaxPercent,
  );
  await waitForTx(token.deployTransaction);

  log('AXR Token:', token.address);
  log('Constructor Args:', {
    deployerAddress,
    transfersRestrictedBefore,
    transferRestrictionLiftedNoLaterThan,
    mintingRestrictedBefore,
    mintMaxPercent,
  });
};

hardhatTask('deploy:AXR', 'AXR token deployment.')
  .addParam(
    'transfersRestrictedBefore',
    'Timestamp, before which transfers are restricted unless the origin or destination address is in the allowlist.',
    undefined,
    types.int,
  )
  .addParam(
    'transferRestrictionLiftedNoLaterThan',
    'Timestamp, which is the maximum timestamp that transfer restrictions can be extended to.',
    undefined,
    types.int,
  )
  .addParam('mintingRestrictedBefore', 'Timestamp, before which minting is not allowed.', undefined, types.int)
  .addParam('mintMaxPercent', 'Cap on the percentage of the total supply that can be minted at each mint.', 2, types.int)
  .setAction(async (args) => {
    await deployAxorToken(args);
  });
