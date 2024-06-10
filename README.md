# Prepare
- use Nodejs 18
```sh
npm i
npm run compile
```

# Run Test
Test safety module
```sh
npx hardhat test test/safety-module/*.ts
```

Test liquidity module
```sh
npx hardhat test test/liquidity-module/wind-down-borrowing-pool.spec.ts
```

# Deploy

1. Compile source code of project axor-governance-contracts
```sh
npm run compile
```

2. Config .env

```sh
ALCHEMY_KEY=
SEPOLIA_ETHERSCAN_API_KEY=
PRIVATE_KEY=<your-private-key>
ARB_SCAN_API_KEY=
```

3. Config arbitrum testnet network at `hardhat.config.ts`

4. Run tasks to deploy

```sh
npx hardhat deploy:phase-1

npx hardhat deploy:phase-2

npx hardhat deploy:phase-3
```

5. After deploy, can get list address at file `./tasks/deployed/Contract`

6. Verify contract
Use these files to verify contracts 
Update file ./verify-phase-1.sh
Update file ./verify-phase-2.sh

# Flatten contracts  :

1. Install depencency tool for flatten contract 
```
sudo npm install -g sol-merger

```
2. Run script flatten all smart contracts 

```
node flatten.js
```