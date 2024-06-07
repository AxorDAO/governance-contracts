import { writeAddress } from '../../tasks/deployedContract/writeIdProposal';
import {
  AxorGovernor,
  AxorGovernor__factory,
  AxorToken,
  Executor,
  Executor__factory,
  MockAxorToken__factory,
  Multicall2__factory,
  USDT__factory,
} from '../../types';
import { getDeployConfig } from '../deploy-config';
import { getDeployerSigner } from '../deploy-config/get-deployer-address';
import { getNetworkName } from '../hre';
import { ZERO_ADDRESS } from '../lib/constants';
import { log } from '../lib/logging';
import { waitForTx } from '../lib/util';
import { deployExecutor } from './helpers/deploy-executor';

export async function deployPhase1({
  startStep = 0,
  axorTokenAddress,
  governorAddress = '',
  longTimelockAddress,
  shortTimelockAddress,
  merklePauserTimelockAddress,
  axorCollateralTokenAddress,
  multicallAddresses,
}: {
  startStep?: number;
  axorTokenAddress?: string;
  governorAddress?: string;
  longTimelockAddress?: string;
  shortTimelockAddress?: string;
  merklePauserTimelockAddress?: string;
  axorCollateralTokenAddress?: string;
  multicallAddresses?: string;
} = {}) {
  log('Beginning phase 1 deployment\n');
  const networkName = getNetworkName();
  const deployConfig = getDeployConfig();
  const deployer = await getDeployerSigner();
  const deployerAddress = deployer.address;
  log(`Beginning deployment with deployer ${deployerAddress}\n`);

  // Phase 1 deployed contracts.
  let axor: AxorToken;
  let governor: AxorGovernor;
  let longTimelock: Executor;
  let shortTimelock: Executor;
  let merklePauserTimelock: Executor;

  if (startStep <= 1) {
    log('Step 1. Deploy AXOR token');
    axor = await new MockAxorToken__factory(deployer).deploy(
      deployerAddress,
      deployConfig.TRANSFERS_RESTRICTED_BEFORE,
      deployConfig.TRANSFER_RESTRICTION_LIFTED_NO_LATER_THAN,
      deployConfig.MINTING_RESTRICTED_BEFORE,
      deployConfig.MINT_MAX_PERCENT,
    );
    await waitForTx(axor.deployTransaction);
    axorTokenAddress = axor.address;
    await writeAddress(networkName, 'axorTokenAddress', axorTokenAddress);
    log(axorTokenAddress, [
      deployConfig.TRANSFERS_RESTRICTED_BEFORE,
      deployConfig.TRANSFER_RESTRICTION_LIFTED_NO_LATER_THAN,
      deployConfig.MINTING_RESTRICTED_BEFORE,
      deployConfig.MINT_MAX_PERCENT,
    ]);
  } else {
    if (!axorTokenAddress) {
      throw new Error('Expected parameter axorTokenAddress to be specified.');
    }
    axor = new MockAxorToken__factory(deployer).attach(axorTokenAddress);
  }

  if (startStep <= 2) {
    log('Step 2. Deploy governor');
    governor = await new AxorGovernor__factory(deployer).deploy(
      // Phase 1 does not include the incentives contracts, including the safety module, so we
      // can't deploy the governance strategy yet.
      ZERO_ADDRESS,
      deployConfig.VOTING_DELAY_BLOCKS,
      deployerAddress,
    );
    await waitForTx(governor.deployTransaction);
    governorAddress = governor.address;
    await writeAddress(networkName, 'governorAddress', governorAddress);
    log(ZERO_ADDRESS, deployConfig.VOTING_DELAY_BLOCKS, deployerAddress);
  } else {
    if (!governorAddress) {
      throw new Error('Expected parameter governorAddress to be specified.');
    }
    governor = new AxorGovernor__factory(deployer).attach(governorAddress);
  }

  if (startStep <= 3) {
    log('Step 3. Deploy long timelock');
    longTimelock = await deployExecutor(
      deployer,
      governorAddress,
      deployConfig.LONG_TIMELOCK_CONFIG,
    );
    longTimelockAddress = longTimelock.address;
    await writeAddress(networkName, 'longTimelockAddress', longTimelockAddress);
    log(
      longTimelockAddress,
      governorAddress,
      deployConfig.LONG_TIMELOCK_CONFIG,
    );
  } else {
    if (!longTimelockAddress) {
      throw new Error(
        'Expected parameter longTimelockAddress to be specified.',
      );
    }
    longTimelock = new Executor__factory(deployer).attach(longTimelockAddress);
  }

  if (startStep <= 4) {
    log('Step 4. Deploy short timelock');
    shortTimelock = await deployExecutor(
      deployer,
      governorAddress,
      deployConfig.SHORT_TIMELOCK_CONFIG,
    );
    shortTimelockAddress = shortTimelock.address;
    await writeAddress(
      networkName,
      'shortTimelockAddress',
      shortTimelockAddress,
    );
    log(
      shortTimelockAddress,
      governorAddress,
      deployConfig.SHORT_TIMELOCK_CONFIG,
    );
  } else {
    if (!shortTimelockAddress) {
      throw new Error(
        'Expected parameter shortTimelockAddress to be specified.',
      );
    }
    shortTimelock = new Executor__factory(deployer).attach(
      shortTimelockAddress,
    );
  }

  if (startStep <= 6) {
    log('Step 6. Deploy merkle timelock');
    merklePauserTimelock = await deployExecutor(
      deployer,
      governorAddress,
      deployConfig.MERKLE_PAUSER_TIMELOCK_CONFIG,
    );
    merklePauserTimelockAddress = merklePauserTimelock.address;
    await writeAddress(
      networkName,
      'merklePauserTimelockAddress',
      merklePauserTimelockAddress,
    );

    log(
      merklePauserTimelockAddress,
      governorAddress,
      deployConfig.MERKLE_PAUSER_TIMELOCK_CONFIG,
    );
  } else {
    if (!merklePauserTimelockAddress) {
      throw new Error(
        'Expected parameter merklePauserTimelockAddress to be specified.',
      );
    }
    merklePauserTimelock = new Executor__factory(deployer).attach(
      merklePauserTimelockAddress,
    );
  }

  if (startStep <= 7) {
    log('Step 7. Authorize timelocks on governance contract');
    await waitForTx(
      await governor.authorizeExecutors([
        longTimelockAddress,
        shortTimelockAddress,
        merklePauserTimelockAddress,
      ]),
    );
  }

  if (startStep <= 8) {
    log('Step 8. Add deployer to token transfer allowlist');
    await waitForTx(
      await axor.addToTokenTransferAllowlist([
        deployerAddress,
        '0xe1273ffc7B41DD3A2f1e7349090cFC589D0c5375',
        '0x714d8c3543Da840d0aE23E7a8A1efFFC06Ad05b8',
      ]),
    );
  }

  if (startStep <= 9) {
    log('Step 9. Add test addresses to token transfer allowlist');
    await waitForTx(
      await axor.addToTokenTransferAllowlist(deployConfig.TOKEN_TEST_ADDRESSES),
    );
  }

  // if (startStep <= 10) {
  //   log('Step 10. Send test tokens.');

  //   const testAllocations = [
  //     deployConfig.TOKEN_ALLOCATIONS.TEST_TOKENS_1,
  //     deployConfig.TOKEN_ALLOCATIONS.TEST_TOKENS_2,
  //     deployConfig.TOKEN_ALLOCATIONS.TEST_TOKENS_3,
  //     deployConfig.TOKEN_ALLOCATIONS.TEST_TOKENS_4,
  //   ];
  //   for (const allocation of testAllocations) {
  //     await transferWithPrompt(axor, allocation.ADDRESS, allocation.AMOUNT);
  //   }
  // }

  if (startStep <= 11) {
    log('Step 11. Deploy axorCollateral token');
    const usdt = await new USDT__factory(deployer).deploy();
    await waitForTx(usdt.deployTransaction);
    axorCollateralTokenAddress = usdt.address;

    await writeAddress(
      networkName,
      'axorCollateralTokenAddress',
      axorCollateralTokenAddress,
    );
  }

  if (startStep <= 12) {
    log('Step 12. Deploy Maker Doo multicall Addresses');
    const makerdoo = await new Multicall2__factory(deployer).deploy();
    await waitForTx(makerdoo.deployTransaction);
    multicallAddresses = makerdoo.address;
    await writeAddress(networkName, 'multicallAddresses', multicallAddresses);
  }

  log('\n=== PHASE 1 DEPLOYMENT COMPLETE ===\n');
  const contracts = [
    ['AxorToken', axorTokenAddress],
    ['Governor', governorAddress],
    ['ShortTimelock', shortTimelockAddress],
    ['LongTimelock', longTimelockAddress],
    ['MerkleTimelock', merklePauserTimelockAddress],
    ['Distributor EOA', deployerAddress],
  ];

  contracts.forEach((data) => log(`${data[0]} at ${data[1]}`));

  return {
    axorToken: axor,
    governor,
    shortTimelock,
    longTimelock,
    merklePauserTimelock,
  };
}
