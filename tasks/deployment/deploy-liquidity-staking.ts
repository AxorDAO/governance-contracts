import { getDeployerSigner } from '../../src/deploy-config/get-deployer-address';
import { hardhatTask } from '../../src/hre';
import { deployUpgradeable } from '../../src/migrations/helpers/deploy-upgradeable';
import { LiquidityStakingV1__factory } from '../../types';

const ONE_MIN = 60;
const DAY = 60 * ONE_MIN * 24;
const REWARDS_DISTRIBUTION_LENGTH = 30 * DAY; // total seconds in 30 day

const EPOCH_LENGTH = 6 * ONE_MIN;
const BLACKOUT_WINDOW = 3 * ONE_MIN;
const EPOCH_ZERO_START = Math.floor(Date.now() / 1000) + 5 * ONE_MIN;

const LS_DISTRIBUTION_START = EPOCH_ZERO_START;
const LS_DISTRIBUTION_END = EPOCH_ZERO_START + REWARDS_DISTRIBUTION_LENGTH;

const usdcAddress = '';
const axorAddress = '';
const treasuryAddress = '';

const deployLiquidityStaking = async () => {
  const deployer = await getDeployerSigner();
  console.log({
    deployer: deployer.address,
    usdcAddress,
    axorAddress,
    treasuryAddress,
    LS_DISTRIBUTION_START,
    LS_DISTRIBUTION_END,
    EPOCH_LENGTH,
    EPOCH_ZERO_START,
    BLACKOUT_WINDOW,
  });

  const [proxyInstance, , proxyAdmin] = await deployUpgradeable(
    LiquidityStakingV1__factory,
    deployer,
    [
      usdcAddress,
      axorAddress,
      treasuryAddress,
      LS_DISTRIBUTION_START,
      LS_DISTRIBUTION_END,
    ],
    [EPOCH_LENGTH, EPOCH_ZERO_START, BLACKOUT_WINDOW],
  );

  console.log('AXR Liquidity Staking:', proxyInstance.address);
  console.log('AXR Liquidity Staking Proxy Admin:', proxyAdmin.address);
};

hardhatTask(
  'deploy:liquidity-staking',
  'Liquidity staking upgradeable deployment.',
).setAction(async () => {
  await deployLiquidityStaking();
});
