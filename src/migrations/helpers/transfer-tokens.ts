import { BigNumberish } from 'ethers';

import { AxorToken } from '../../../types';
import config from '../../config';
import { log } from '../../lib/logging';
import { promptYes } from '../../lib/prompt';
import { waitForTx } from '../../lib/util';

/**
 * Transfer AXOR tokens, prompting for confirmation on mainnet.
 */
export async function transferWithPrompt(
  axorToken: AxorToken,
  recipientAddress: string,
  amount: BigNumberish,
): Promise<void> {
  if (await config.isMainnet()) {
    log('\n======================================================\n');
    log();
    log(`to:     ${recipientAddress}`);
    log(`amount: ${amount}`);
    log();
    await promptYes('> Enter "yes" to execute the above token transfer.');
  }

  await waitForTx(
    await axorToken.transfer(
      recipientAddress,
      amount,
    ),
  );
}
