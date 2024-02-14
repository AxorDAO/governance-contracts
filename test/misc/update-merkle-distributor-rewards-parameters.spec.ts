import { expect } from 'chai';
import { BigNumber } from 'ethers';

import { DIP_16_IPFS_HASH } from '../../src/lib/constants';
import { describeContractHardhatRevertBefore, TestContext } from '../helpers/describe-contract';
import { readIdFromProposal } from '../helpers/writeIdProposal';

// LP rewards should stay the same (1150685000000000000000000)
// Trader rewards should be reduced by 25% (3835616000000000000000000 => 2876712000000000000000000)
// Alpha parameter should be set to 0

function init() {}

describeContractHardhatRevertBefore(
  'update-merkle-distributor-rewards-parameters',
  init,
  (ctx: TestContext) => {
    it('Proposal IPFS hash is correct', async () => {
      const proposalId = await readIdFromProposal('updateMerkleDistributorRewardsParametersProposal');
      if (!proposalId) return;

      const proposal = await ctx.governor.getProposalById(proposalId);
      expect(proposal.ipfsHash).to.equal(DIP_16_IPFS_HASH);
    });

    it('Merkle distributor reward parameters are updated', async () => {
      const [lpRewardsAmount, traderRewardsAmount, alphaParameter]: Array<BigNumber> =
        await ctx.merkleDistributor.getRewardsParameters();

      expect(lpRewardsAmount.toString()).to.equal('575343000000000000000000');
      expect(traderRewardsAmount.toString()).to.equal('1582192000000000000000000');
      expect(alphaParameter).to.equal(0);
    });
  },
);
