import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

import {
  AxorGovernor__factory,
} from '../../types';
import { getDeployConfig } from '../deploy-config';
import { getDeployerSigner } from '../deploy-config/get-deployer-address';
import { getHre } from '../hre';
import { log } from '../lib/logging';
import { waitForTx } from '../lib/util';
import { Proposal } from '../types';

export async function createProposal({
  proposalIpfsHashHex,
  axorTokenAddress,
  governorAddress,
  shortTimelockAddress,
  communityTreasuryAddress,
  signer,
}: {
  proposalIpfsHashHex: string,
  axorTokenAddress: string,
  governorAddress: string,
  shortTimelockAddress: string,
  communityTreasuryAddress: string,
  signer?: SignerWithAddress,
}) {
  const hre = getHre();
  const deployConfig = getDeployConfig();
  const deployer = signer || await getDeployerSigner();
  const deployerAddress = deployer.address;
  log(`Creating proposal with proposer ${deployerAddress}.\n`);

  const governor = await new AxorGovernor__factory(deployer).attach(governorAddress);
  const proposalId = await governor.getProposalsCount();
  const proposal: Proposal = [
    shortTimelockAddress,
    [communityTreasuryAddress],
    ['0'],
    ['transfer(address,address,uint256)'],
    [hre.ethers.utils.defaultAbiCoder.encode(
      ['address', 'address', 'uint256'],
      [axorTokenAddress, "0xe1273ffc7B41DD3A2f1e7349090cFC589D0c5375", 10000],
    )],
    [false],
    proposalIpfsHashHex,
  ];
  console.log({ proposal: JSON.stringify(proposal) })

  await waitForTx(await governor.create(...proposal));

  return {
    proposalId,
  };
}
