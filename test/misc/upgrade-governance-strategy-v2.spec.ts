import { expect } from 'chai';

import { describeContract, TestContext } from '../helpers/describe-contract';
import { ethers } from 'hardhat';
import { DelegationType } from '../../src';
import { DIP_26_IPFS_HASH } from '../../src/lib/constants';
import { readIdFromProposal } from '../helpers/writeIdProposal';
import { getAffectedStakersForTest } from '../helpers/get-affected-stakers-for-test';

function init() { }

describeContract('upgrade-governance-strategy-v2', init, (ctx: TestContext) => {

  it('Proposal IPFS hash is set correctly', async () => {
    const proposalId = await readIdFromProposal('createUpgradeGovernanceStrategyV2Proposal');
    if(!proposalId) return

    const proposal = await ctx.governor.getProposalById(proposalId);

    // Verify that the number of proposals is correct and the IPFS hash is set correctly on the proposal.
    expect(proposal.ipfsHash).to.equal(DIP_26_IPFS_HASH);
  });

  it('New governance strategy is set on AXOR governor, has correct token addresses and supply', async () => {
    const axorTokenAddress = await ctx.governanceStrategyV2.AXOR_TOKEN();
    const stakedAxorTokenAddress = await ctx.governanceStrategyV2.STAKED_AXOR_TOKEN();

    expect(axorTokenAddress).to.equal(ctx.axorToken.address);
    expect(stakedAxorTokenAddress).to.equal(ctx.safetyModule.address);

    const currentBlock = await ethers.provider.getBlockNumber();
    const totalPropositionSupply = await ctx.governanceStrategyV2.getTotalPropositionSupplyAt(currentBlock);
    const totalVotingSupply = await ctx.governanceStrategyV2.getTotalVotingSupplyAt(currentBlock);
    const expectedSupply = ethers.utils.parseEther('1000000000'); // 1B * 10^18

    expect(totalPropositionSupply).to.equal(expectedSupply);
    expect(totalVotingSupply).to.equal(expectedSupply);

    const axorGovernorStrategy = await ctx.governor.getGovernanceStrategy();
    expect(axorGovernorStrategy).to.equal(ctx.governanceStrategyV2.address);
  });

  it('New governance strategy still counts voting power from AXOR and staked AXOR tokens', async () => {
    // Address with non-zero balances of AXOR and staked AXOR tokens that has not delegated
    // their voting power.

    const addressWithAxorAndStakedAxor = '0x8031EEC1118D1321387b1870F32984f72b447b04';

    const currentBlock = await ethers.provider.getBlockNumber();
    const axorVotingPower = await ctx.axorToken.getPowerAtBlock(addressWithAxorAndStakedAxor, currentBlock, DelegationType.VOTING_POWER);
    const stakedAxorVotingPower = await ctx.safetyModule.getPowerAtBlock(addressWithAxorAndStakedAxor, currentBlock, DelegationType.VOTING_POWER);

    const axorPropositionPower = await ctx.axorToken.getPowerAtBlock(addressWithAxorAndStakedAxor, currentBlock, DelegationType.PROPOSITION_POWER);
    const stakedAxorPropositionPower = await ctx.safetyModule.getPowerAtBlock(addressWithAxorAndStakedAxor, currentBlock, DelegationType.PROPOSITION_POWER);

    const totalVotingPower = await ctx.governanceStrategyV2.getVotingPowerAt(addressWithAxorAndStakedAxor, currentBlock);
    const totalPropositionPower = await ctx.governanceStrategyV2.getPropositionPowerAt(addressWithAxorAndStakedAxor, currentBlock);

    expect(axorVotingPower.add(stakedAxorVotingPower)).to.equal(totalVotingPower);
    expect(axorPropositionPower.add(stakedAxorPropositionPower)).to.equal(totalPropositionPower);
  });
});
