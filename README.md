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