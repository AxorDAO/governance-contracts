import { getDeployerSigner } from '../../src/deploy-config/get-deployer-address';
import { hardhatTask } from '../../src/hre';
import { ZERO_ADDRESS } from '../../src/lib/constants';
import { toWad } from '../../src/lib/util';
import { deployUpgradeable } from '../../src/migrations/helpers/deploy-upgradeable';
import { MerkleDistributorV1__factory } from '../../types';

const ONE_MIN = 60,
  EPOCH_LENGTH = 6 * ONE_MIN,
  EPOCH_ZERO_START = Math.floor(Date.now() / 1000) + 5 * ONE_MIN,
  IPNS_NAME = 'rewards-data.axor.dao',
  IPFS_UPDATE_PERIOD = 3 * ONE_MIN,
  MARKET_MAKER_REWARDS_AMOUNT = 1_150_685,
  TRADER_REWARDS_AMOUNT = 3_835_616,
  TRADER_SCORE_ALPHA = 0.7;

const AXOR_ADDRESS = '0x0d5Ec9FE02e599E35c92fcdEacbA20331541FFA3',
  TREASURY_ADDRESS = '0x8B4539FCB24Cdab59B5FABe3257402547AAF4dc3';

const deployLiquidityStaking = async () => {
  const deployer = await getDeployerSigner();
  const [proxyInstance, implementation, proxyAdmin] = await deployUpgradeable(
    MerkleDistributorV1__factory,
    deployer,
    [AXOR_ADDRESS, TREASURY_ADDRESS],
    [
      ZERO_ADDRESS,
      IPNS_NAME,
      IPFS_UPDATE_PERIOD,
      toWad(MARKET_MAKER_REWARDS_AMOUNT),
      toWad(TRADER_REWARDS_AMOUNT),
      toWad(TRADER_SCORE_ALPHA),
      EPOCH_ZERO_START,
      EPOCH_LENGTH,
    ],
  );

  console.log('proxyInstance:', proxyInstance.address);
  console.log('admin:', proxyAdmin.address);
  console.log('implementation:', implementation.address);

  console.log({
    deployer: deployer.address,
    axorAddress: AXOR_ADDRESS,
    TREASURY_ADDRESS,
    ZERO_ADDRESS,
    IPNS_NAME: IPNS_NAME,
    IPFS_UPDATE_PERIOD,
    MARKET_MAKER_REWARDS_AMOUNT: toWad(MARKET_MAKER_REWARDS_AMOUNT),
    TRADER_REWARDS_AMOUNT: toWad(TRADER_REWARDS_AMOUNT),
    TRADER_SCORE_ALPHA: toWad(TRADER_SCORE_ALPHA),
    EPOCH_ZERO_START,
    EPOCH_LENGTH,
  });
};

hardhatTask(
  'deploy:merkle-distributor',
  'Merkle Distributor upgradeable deployment.',
).setAction(async () => {
  await deployLiquidityStaking();
});
