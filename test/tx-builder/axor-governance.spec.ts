import { expect } from 'chai';
import hre from 'hardhat';

import {
  AXOR_GOVERNOR_DEPLOYMENT_BLOCK,
  Network,
  tDistinctGovernanceAddresses,
  TxBuilder,
} from '../../src';
import { NetworkName } from '../../src/types';
import { describeContract, describeContractForNetwork, TestContext } from '../helpers/describe-contract';

const BLOCK_AFTER_GOVERNANCE_VOTES: number = 13679600;

let txBuilder: TxBuilder;

function init(ctx: TestContext): void {
  txBuilder = new TxBuilder(
    {
      network: Network.hardhat,
      hardhatGovernanceAddresses: {
        AXOR_GOVERNANCE: ctx.governor.address,
      } as tDistinctGovernanceAddresses,
      injectedProvider: hre.ethers.provider,
    },
  );
}

describeContract('AxorGovernance', init, (ctx: TestContext) => {
  describeContractForNetwork(
    'AxorGovernance',
    ctx,
    NetworkName.hardhat,
    true,
    () => {
      it('getGovernanceVoters with large range and expected votes', async () => {
        const voters = await txBuilder.axorGovernanceService.getGovernanceVoters(
          BLOCK_AFTER_GOVERNANCE_VOTES,
        );
        expect(voters.size).to.be.eq(790);
      });

      it('getGovernanceVoters with no range and no expected votes', async () => {
        const emptyVoters = await txBuilder.axorGovernanceService.getGovernanceVoters(
          AXOR_GOVERNOR_DEPLOYMENT_BLOCK,
          AXOR_GOVERNOR_DEPLOYMENT_BLOCK,
        );
        expect(emptyVoters.size).to.be.eq(0);
      });

      it('getGovernanceVoters with range and no expected votes', async () => {
        const emptyVoters = await txBuilder.axorGovernanceService.getGovernanceVoters(
          BLOCK_AFTER_GOVERNANCE_VOTES + 1000,
          BLOCK_AFTER_GOVERNANCE_VOTES,
        );
        expect(emptyVoters.size).to.be.eq(0);
      });
    },
  );
});
