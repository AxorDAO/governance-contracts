import { getDeployerSigner } from '../../src/deploy-config/get-deployer-address';
import { hardhatTask } from '../../src/hre';
import { waitForTx } from '../../src/lib/util';
import { MD1ChainlinkAdapter__factory } from '../../types';

const CHAINLINK_TOKEN = '0x326c977e6efc84e512bb9c30f76e30c160ed06fb',
  merkleDistributor = '0x88A75249F4935321940717692E2cB96637C01bC9',
  // oracleContract = '0x240BaE5A27233Fd3aC5440B5a598467725F7D1cd',
  oracleContract = '0x8204C193ade6A1bB59BeF25B6A310E417953013f',
  oracleExternalAdapter = '0x4aBfCf64bB323CC8B65e2E69F2221B14943C6EE1',
  jobId = '0x6365366562393532363736373431666438323462626636643132313163313031';

const chainlinkAdapter = async () => {
  const deployer = await getDeployerSigner();

  const contract = await new MD1ChainlinkAdapter__factory(deployer).deploy(
    CHAINLINK_TOKEN,
    merkleDistributor,
    oracleContract,
    oracleExternalAdapter,
    jobId,
  );

  await waitForTx(contract.deployTransaction);

  console.log('AXR chainlionk adapter:', contract.address);
};

hardhatTask('deploy:chainlionk-adapter', 'chainlionk-adapter.').setAction(
  async () => {
    await chainlinkAdapter();
  },
);
