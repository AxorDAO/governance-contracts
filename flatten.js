const fs = require('fs-extra');
const path = require('path');
const { exec } = require('child_process');

const contracts = [
  './contracts/governance/token/AxorToken.sol',
  './contracts/governance/AxorGovernor.sol',
  './contracts/governance/executor/Executor.sol',
  './contracts/dependencies/makerdao/multicall2.sol',
  './contracts/treasury/Treasury.sol',
  './contracts/dependencies/open-zeppelin/ProxyAdmin.sol',
  './contracts/dependencies/open-zeppelin/InitializableAdminUpgradeabilityProxy.sol',
  './contracts/safety/v1/SafetyModuleV1.sol',
  './contracts/governance/strategy/GovernanceStrategy.sol',
  './contracts/treasury/TreasuryVester.sol',
  './contracts/liquidity/v1/LiquidityStakingV1.sol',
  './contracts/merkle-distributor/v1/MerkleDistributorV1.sol',
  './contracts/merkle-distributor/v1/oracles/MD1ChainlinkAdapter.sol',
  './contracts/misc/ClaimsProxy.sol',
];

const outputDir = 'flattened-contracts'; // Directory to save the flattened files

// Ensure the output directory exists
fs.ensureDirSync(outputDir);

// Function to remove duplicate SPDX license identifiers from Solidity code
const removeDuplicateLicenses = (content) => {
    const licenseRegex = /\/\/\s*SPDX-License-Identifier:\s*[A-Za-z0-9.-]+\s*/g;
    const licenses = content.match(licenseRegex);
    if (licenses && licenses.length > 0) {
      const firstLicenseIndex = content.indexOf(licenses[0]);
      const contentWithoutLicenses = content.replace(licenseRegex, '');
      content = contentWithoutLicenses.slice(0, firstLicenseIndex) + licenses[0] + contentWithoutLicenses.slice(firstLicenseIndex).trim();
    }
    return content;
  };

// Function to flatten a Solidity file
const flattenContract = (filePath) => {
  return new Promise((resolve, reject) => {
    const fileName = path.basename(filePath, '.sol') + '_merged.sol';
    const sourceOutputFilePath = path.join(path.dirname(filePath), fileName);
    const outputFilePath = path.join(outputDir, fileName);

    exec(`npx sol-merger ${filePath}`, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error flattening ${filePath}: ${error}`);
        console.error(`stderr: ${stderr}`);
        reject(error);
      } else {
        // Read the merged file, remove duplicate licenses, and then write it back
        fs.readFile(sourceOutputFilePath, 'utf8', (readError, data) => {
          if (readError) {
            console.error(`Error reading merged file ${sourceOutputFilePath}: ${readError}`);
            reject(readError);
          } else {
            const cleanedContent = removeDuplicateLicenses(data);
            fs.writeFile(outputFilePath, cleanedContent, 'utf8', (writeError) => {
              if (writeError) {
                console.error(`Error writing cleaned file to ${outputFilePath}: ${writeError}`);
                reject(writeError);
              } else {
                // Remove the original merged file after processing
                fs.remove(sourceOutputFilePath, (removeError) => {
                  if (removeError) {
                    console.error(`Error removing temporary merged file ${sourceOutputFilePath}: ${removeError}`);
                    reject(removeError);
                  } else {
                    console.log(`Flattened, cleaned, and moved ${filePath} to ${outputFilePath}`);
                    resolve();
                  }
                });
              }
            });
          }
        });
      }
    });
  });
};

// Function to flatten all specified contracts
const flattenAllContracts = async () => {
  try {
    if (contracts.length === 0) {
      console.log('No Solidity files specified.');
      return;
    }

    for (const file of contracts) {
      await flattenContract(file);
    }
    console.log('All specified contracts have been flattened, cleaned, and moved successfully.');
  } catch (error) {
    console.error('Error flattening contracts:', error);
  }
};

// Run the script
flattenAllContracts();