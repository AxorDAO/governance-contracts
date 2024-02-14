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

export async function createGrantsProgramProposal({
  proposalIpfsHashHex,
  axorTokenAddress,
  governorAddress,
  shortTimelockAddress,
  communityTreasuryAddress,
  dgpMultisigAddress,
  signer,
}: {
  proposalIpfsHashHex: string,
  axorTokenAddress: string,
  governorAddress: string,
  shortTimelockAddress: string,
  communityTreasuryAddress: string,
  dgpMultisigAddress: string,
  signer?: SignerWithAddress,
}) {
  const hre = getHre();
  const deployConfig = getDeployConfig();
  const deployer = signer || await getDeployerSigner();
  const deployerAddress = deployer.address;
  log(`Creating Grants Program proposal with proposer ${deployerAddress}.\n`);

  const governor = await new AxorGovernor__factory(deployer).attach(governorAddress);
  const proposalId = await governor.getProposalsCount();
  const proposal: Proposal = [
    shortTimelockAddress,
    [communityTreasuryAddress],
    ['0'],
    ['transfer(address,address,uint256)'],
    [hre.ethers.utils.defaultAbiCoder.encode(
      ['address', 'address', 'uint256'],
      [axorTokenAddress, dgpMultisigAddress, deployConfig.DGP_FUNDING_AMOUNT],
    )],
    [false],
    proposalIpfsHashHex,
  ];

  await waitForTx(await governor.create(...proposal));

  return {
    proposalId,
  };
}
