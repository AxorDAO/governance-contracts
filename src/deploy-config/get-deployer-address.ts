/**
 * Get the deployer address that was used for the deployment on a given network.
 */

import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

import config from '../config';
import { getHre } from '../hre';
import { impersonateAndFundAccount } from '../migrations/helpers/impersonate-account';

const MAINNET_DEPLOYER_ADDRESS = '0xe1273ffc7B41DD3A2f1e7349090cFC589D0c5375';

export async function getDeployerSigner(): Promise<SignerWithAddress> {
  const hre = getHre();
  if (config.isHardhat() && config.FORK_MAINNET) {
    return impersonateAndFundAccount(
      config.OVERRIDE_DEPLOYER_ADDRESS || MAINNET_DEPLOYER_ADDRESS,
    );
  } else if (config.OVERRIDE_DEPLOYER_ADDRESS) {
    return hre.ethers.getSigner(config.OVERRIDE_DEPLOYER_ADDRESS);
  } else {
    const accounts = await hre.ethers.getSigners();
    return accounts[0];
  }
}
