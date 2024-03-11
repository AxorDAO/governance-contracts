import {
  ClaimsProxy__factory,
  AxorGovernor__factory,
  AxorToken__factory,
  Executor__factory,
  GovernanceStrategy__factory,
  ProxyAdmin__factory,
  SafetyModuleV1__factory,
  Treasury__factory,
  TreasuryVester__factory,
} from '../../../types';
import { IERC20__factory } from '../../../types/factories/IERC20__factory';
import { LiquidityStakingV1__factory } from '../../../types/factories/LiquidityStakingV1__factory';
import { MerkleDistributorV1__factory } from '../../../types/factories/MerkleDistributorV1__factory';
import config from '../../config';
import { getDeployerSigner } from '../../deploy-config/get-deployer-address';
import mainnetAddresses from '../../deployed-addresses/mainnet.json';
import { getNetworkName } from '../../hre';
import { MainnetDeployedContracts } from '../../types';

type DeployedAddresses = typeof mainnetAddresses;

export async function getMainnetDeployedContracts(): Promise<MainnetDeployedContracts> {
  const deployer = await getDeployerSigner();

  let deployedAddresses: DeployedAddresses;
  if (
    config.isMainnet() ||
    (config.isHardhat() && config.FORK_MAINNET)
  ) {
    deployedAddresses = mainnetAddresses;
  } else {
    throw new Error(`Deployed addresses not found for network ${getNetworkName()}`);
  }

  return {
    axorToken: new AxorToken__factory(deployer).attach(deployedAddresses.axorToken),
    governor: new AxorGovernor__factory(deployer).attach(deployedAddresses.governor),
    shortTimelock: new Executor__factory(deployer).attach(deployedAddresses.shortTimelock),
    longTimelock: new Executor__factory(deployer).attach(deployedAddresses.longTimelock),
    merklePauserTimelock: new Executor__factory(deployer).attach(deployedAddresses.merklePauserTimelock),
    starkwarePriorityTimelock: new Executor__factory(deployer).attach(deployedAddresses.starkwarePriorityTimelock),
    rewardsTreasury: new Treasury__factory(deployer).attach(deployedAddresses.rewardsTreasury),
    rewardsTreasuryProxyAdmin: new ProxyAdmin__factory(deployer).attach(deployedAddresses.rewardsTreasuryProxyAdmin),
    safetyModule: new SafetyModuleV1__factory(deployer).attach(deployedAddresses.safetyModule),
    safetyModuleProxyAdmin: new ProxyAdmin__factory(deployer).attach(deployedAddresses.safetyModuleProxyAdmin),
    strategy: new GovernanceStrategy__factory(deployer).attach(deployedAddresses.strategy),
    communityTreasury: new Treasury__factory(deployer).attach(deployedAddresses.communityTreasury),
    communityTreasuryProxyAdmin: new ProxyAdmin__factory(deployer).attach(deployedAddresses.communityTreasuryProxyAdmin),
    rewardsTreasuryVester: new TreasuryVester__factory(deployer).attach(deployedAddresses.rewardsTreasuryVester),
    communityTreasuryVester: new TreasuryVester__factory(deployer).attach(deployedAddresses.communityTreasuryVester),
    claimsProxy: new ClaimsProxy__factory(deployer).attach(deployedAddresses.claimsProxy),
    liquidityStaking: new LiquidityStakingV1__factory(deployer).attach(deployedAddresses.liquidityStaking),
    liquidityStakingProxyAdmin: new ProxyAdmin__factory(deployer).attach(deployedAddresses.liquidityStakingProxyAdmin),
    merkleDistributor: new MerkleDistributorV1__factory(deployer).attach(deployedAddresses.merkleDistributor),
    merkleDistributorProxyAdmin: new ProxyAdmin__factory(deployer).attach(deployedAddresses.merkleDistributorProxyAdmin),
    axorCollateralToken: IERC20__factory.connect(deployedAddresses.axorCollateralToken, deployer),
  };
}
