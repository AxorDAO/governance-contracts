import { expect } from 'chai';

import { DIP_23_IPFS_HASH } from '../../src/lib/constants';
import { describeContractHardhatRevertBefore, TestContext } from '../helpers/describe-contract';
import { readIdFromProposal } from '../helpers/writeIdProposal';

function init() {}

describeContractHardhatRevertBefore('ops-trust-v2-proposal', init, (ctx: TestContext) => {

  it('Proposal IPFS hash is correct', async () => {
    const opsTrustV2ProposalId = await readIdFromProposal('OpsTrustViaProposalV2');
    if(!opsTrustV2ProposalId) return

    const proposal = await ctx.governor.getProposalById(opsTrustV2ProposalId);
    expect(proposal.ipfsHash).to.equal(DIP_23_IPFS_HASH);
  });

  it('DOT 2.0 receives tokens from the community treasury', async () => {
    const balance = await ctx.axorToken.balanceOf(ctx.config.DOT_MULTISIG_ADDRESS_V2);
    expect(balance).to.equal(ctx.config.DOT_FUNDING_AMOUNT_v2);
  });
});
