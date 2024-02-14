import { MintableERC20__factory } from '../../../types/factories/MintableERC20__factory';
import { IERC20 } from '../../../types/IERC20';
import { MintableERC20 } from '../../../types/MintableERC20';
import config from '../../config';
import { getDeployerSigner } from '../../deploy-config/get-deployer-address';
import { MAX_UINT_AMOUNT, USDC_TOKEN_DECIMALS } from '../../lib/constants';
import { log } from '../../lib/logging';
import { waitForTx } from '../../lib/util';

export async function deployMocks() {
  log('Beginning deployment of mock contracts.\n');
  if (!config.isHardhat() || config.FORK_MAINNET) {
    throw new Error('Can only deploy mock contracts on Hardhat network.');
  }

  const deployer = await getDeployerSigner();
  const deployerAddress = deployer.address;
  log(`Beginning deployment of mock contracts with deployer ${deployerAddress}.\n`);

  const mockAxorCollateralToken: MintableERC20 = await new MintableERC20__factory(deployer)
    .deploy(
      'Mock AXOR Collateral Token',
      'MOCK_USDC',
      USDC_TOKEN_DECIMALS,
    );

  await waitForTx(await mockAxorCollateralToken.mint(deployerAddress, MAX_UINT_AMOUNT));

  log(`Minting max AXOR collateral token to ${deployerAddress}.\n`);

  log('\n=== MOCK CONTRACT DEPLOYMENT COMPLETE ===\n');

  return {
    axorCollateralToken: mockAxorCollateralToken as IERC20,
  };
}
