import { expect } from 'chai';
import { DIP_18_IPFS_HASH } from '../../src/lib/constants';
import { describeContractHardhatRevertBefore, TestContext } from '../helpers/describe-contract';
import { readIdFromProposal } from '../helpers/writeIdProposal';

function init() {}

describeContractHardhatRevertBefore('ops-trust-proposal', init, (ctx: TestContext) => {

  it('Proposal IPFS hash is correct', async () => {
    const opsTrustProposalId = await readIdFromProposal('OpsTrustViaProposal');
    if(!opsTrustProposalId) return

    const proposal = await ctx.governor.getProposalById(opsTrustProposalId);
    expect(proposal.ipfsHash).to.equal(DIP_18_IPFS_HASH);
  });

  it('DOT multisig receives tokens from the community treasury', async () => {
    const balance = await ctx.axorToken.balanceOf(ctx.config.DOT_MULTISIG_ADDRESS);
    expect(balance).to.equal(ctx.config.DOT_FUNDING_AMOUNT);
  });
});
