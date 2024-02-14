import { BigNumberish } from 'ethers';
import { formatEther } from 'ethers/lib/utils';

import { AxorToken } from '../../../types';
import { getDeployerSigner } from '../../deploy-config/get-deployer-address';

export async function expectDeployerBalance(
  axorToken: AxorToken,
  expectedBalance: BigNumberish,
): Promise<void> {
  const deployer = await getDeployerSigner();
  const actualBalance = await axorToken.balanceOf(deployer.address);

  if (!actualBalance.eq(expectedBalance)) {
    throw new Error(
      `Expected deployer to have a balance of ${formatEther(expectedBalance)} AXOR ` +
      `but actual balance was ${formatEther(actualBalance)} AXOR`,
    );
  }
}
