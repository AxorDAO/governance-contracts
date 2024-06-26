import fs from 'fs';
import path from 'path';

import * as dotenv from 'dotenv';
import { HardhatUserConfig } from 'hardhat/config';
import { HardhatNetworkUserConfig, HttpNetworkUserConfig } from 'hardhat/types';

import config from './src/config';
import { NetworkName } from './src/types';

import '@typechain/hardhat';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-waffle';
import 'solidity-coverage';
import 'hardhat-abi-exporter';
import '@nomicfoundation/hardhat-verify';

dotenv.config();

// Should be set when running hardhat compile or hardhat typechain.
const SKIP_LOAD = process.env.SKIP_LOAD === 'true';

// Testnet and mainnet configuration.
const ALCHEMY_KEY = process.env.ALCHEMY_KEY || '';
const MNEMONIC_PATH = "m/44'/60'/0'/0";
let MNEMONIC = process.env.MNEMONIC || '';
if (MNEMONIC === '') {
  MNEMONIC = 'test test test test test test test test test test test test';
  console.log(
    'Note on-chain TXs cannot be created since a test mnemonic is being used that has no funds.',
  );
  console.log(
    'If this was not intentional, re-run the script with a valid seed phrase stored in the MNEMONIC environment variable.',
  );
}

// Load hardhat tasks.
if (!SKIP_LOAD) {
  console.log('Loading scripts...');
  const tasksDir = path.join(__dirname, 'tasks');
  const tasksDirs = fs.readdirSync(tasksDir);
  tasksDirs.forEach((dirName) => {
    const tasksDirPath = path.join(tasksDir, dirName);
    const tasksFiles = fs.readdirSync(tasksDirPath);
    tasksFiles.forEach((fileName) => {
      const tasksFilePath = path.join(tasksDirPath, fileName);
      /* eslint-disable-next-line global-require */
      require(tasksFilePath);
    });
  });
}

function getRemoteNetworkConfig(
  networkName: NetworkName,
  networkId: number,
): HttpNetworkUserConfig {
  return {
    // url: `https://eth-${networkName}.g.alchemy.com/v2/${ALCHEMY_KEY}`,
    url: `https://eth-${networkName}.g.alchemy.com/v2/${ALCHEMY_KEY}`,
    chainId: networkId,
    accounts: {
      mnemonic: MNEMONIC,
      path: MNEMONIC_PATH,
      initialIndex: 0,
      count: 10,
    },
  };
}

function getHardhatConfig(): HardhatNetworkUserConfig {
  const networkConfig: HardhatNetworkUserConfig = {
    hardfork: 'berlin',
    blockGasLimit: 15000000,
    chainId: 31337,
    throwOnTransactionFailures: true,
    throwOnCallFailures: true,
  };

  if (config.FORK_MAINNET) {
    networkConfig.forking = {
      url: `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_KEY}`,
      blockNumber: config.FORK_BLOCK_NUMBER,
    };
  }

  return networkConfig;
}

const hardhatConfig: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: '0.7.5',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
          evmVersion: 'berlin',
        },
      },
    ],
    overrides: {
      'contracts/utils/erc20.sol': {
        version: '0.5.16',
        settings: {
          evmVersion: 'istanbul',
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/utils/usdt.sol': {
        version: '0.5.16',
        settings: {
          evmVersion: 'istanbul',
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
  },
  typechain: {
    outDir: 'types',
    target: 'ethers-v5',
    alwaysGenerateOverloads: false,
  },
  mocha: {
    timeout: 0,
  },
  networks: {
    sepolia: getRemoteNetworkConfig(NetworkName.sepolia, 11155111),
    goerli: getRemoteNetworkConfig(NetworkName.goerli, 5),
    kovan: getRemoteNetworkConfig(NetworkName.kovan, 42),
    bsc_testnet: {
      url: 'https://data-seed-prebsc-2-s3.binance.org:8545',
      chainId: 97,
      accounts: [process.env.PRIVATE_KEY!],
    },
    ropsten: getRemoteNetworkConfig(NetworkName.ropsten, 3),
    mainnet: getRemoteNetworkConfig(NetworkName.mainnet, 1),
    arbitrum_testnet: {
      url: 'https://public.stackup.sh/api/v1/node/arbitrum-sepolia',
      chainId: 421614,
      accounts: [process.env.PRIVATE_KEY || ''],
    },
    hardhat: getHardhatConfig(),
  },
  abiExporter: {
    clear: true,
  },
  etherscan: {
    apiKey: {
      // Uncomment these and set the environment variable if you want to verify contracts on Etherscan.
      // mainnet: process.env.MAINNET_ETHERSCAN_API_KEY!,
      sepolia: process.env.SEPOLIA_ETHERSCAN_API_KEY!,
      goerli: process.env.SEPOLIA_ETHERSCAN_API_KEY!,
      bscTestnet: process.env.BSC_SCAN_API_KEY!,
      arbitrumTestnet: process.env.ARB_SCAN_API_KEY!,
    },
    customChains: [
      {
        network: 'arbitrumTestnet',
        chainId: 421614,
        urls: {
          apiURL: 'https://api-sepolia.arbiscan.io/api',
          browserURL: 'https://sepolia.arbiscan.io/',
        },
      },
    ],
  },
};

export default hardhatConfig;
