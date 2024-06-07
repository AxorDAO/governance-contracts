#!/bin/bash

deployer="0xd8A7c92ccE4CA391385056f7D807E21600554AC3"
axorToken="0xfD25dc6C6682B6ff007F0E016aC4C689fEDD6087"
governor="0x311B8EFbEfc6277d10b8c704eed73fa7065FED13"
long_executor="0xaaB743DB4601b0fE9e3e776c7d3f3c5D496F943F"
short_executor="0xaaB743DB4601b0fE9e3e776c7d3f3c5D496F943F"
merkle_executor="0xBC49D17C2387A73cCf4c14FA5916172D1958e404"
collateralToken="0x40F5f1F3aCb954C4e88C2e9a0DE30c845b5e25cf"
multical="0x184DD06B9e16Bf8d814B299dca0922FA1a087CC4"

treasury="0x151cbE89491e9C0011c0C7070BEa4d1930313Add"
community_treasury="0x26D7E8DBB5f6b7581b36597B11FAD01Dc6def7a7"
strategyAddress="0xD1EDf1aA16c435aD6c347BBdF4F88297393f966C"
safetyModuleAddress='0x452FBaE1a6D093A2350ECb5957c851E6D1B60C21'
liquidityStakingAddress='0x1983B214616D37FB447bD651443dac681a34Fc09'
merkleDistributorAddress="0x666514545a3421b6a78da7B99fc9E04E937d2b85"
claimsProxyAddress="0x06AE9d3103A1de2cAbCef11AD3691f79C0CB8479"
rewardsTreasuryVesterAddress="0x20Bc8BC00ECb2f626CAE3728749d0FE3Dcd7D1Cf"
communityTreasuryVesterAddress="0x1E3Ec2E10Ac9Bf0a619ecbd42E2aF73E64Cc63a2"
oracleAdapterAddress="0xB26CA715f3AdF5431aF8060Db285ac646e2D80f9"

# -------------------- treasury ----------------------------

network="arbitrum_testnet"
# network="bsc_testnet"

# npx hardhat verify --network $network $treasury
# npx hardhat verify --network $network $community_treasury

npx hardhat verify --network $network \
	--contract contracts/governance/strategy/GovernanceStrategy.sol:GovernanceStrategy $strategyAddress $axorToken \
	$safetyModuleAddress

# # # ## ----------------------- ClaimsProxy  -------------------------

# npx hardhat verify --network $network \
# 	--contract contracts/misc/ClaimsProxy.sol:ClaimsProxy $claimsProxyAddress \
# 	$safetyModuleAddress \
# 	$liquidityStakingAddress \
# 	$merkleDistributorAddress \
# 	$rewardsTreasuryVesterAddress

# # ## ----------------------- Vester  -------------------------

# VESTING_AMOUNT=449000000000000000000000000
# VESTING_BEGIN=1716455871
# VESTING_CLIFF=1716455871
# VESTING_END=1874222271

# npx hardhat verify --network $network \
# 	--contract contracts/treasury/TreasuryVester.sol:TreasuryVester $rewardsTreasuryVesterAddress \
# 	$axorToken \
# 	$treasury \
# 	$VESTING_AMOUNT \
# 	$VESTING_BEGIN \
# 	$VESTING_CLIFF \
# 	$VESTING_END

# npx hardhat verify --network $network \
# 	--contract contracts/treasury/TreasuryVester.sol:TreasuryVester $communityTreasuryVesterAddress \
# 	$axorToken \
# 	$treasury \
# 	$VESTING_AMOUNT \
# 	$VESTING_BEGIN \
# 	$VESTING_CLIFF \
# 	$VESTING_END

# # # -------------------- safety module -----------------------

# sm_impl=0x11684e6eee7b8937910c46791c57efa3bd022898
# SM_DISTRIBUTION_START=1716458871
# SM_DISTRIBUTION_END=1717322391
# EPOCH_LENGTH=1680
# EPOCH_ZERO_START=1716455871
# BLACKOUT_WINDOW=300

# npx hardhat verify --network $network "$safetyModuleAddress"

# npx hardhat verify --network $network \
# 	--contract contracts/safety/v1/SafetyModuleV1.sol:SafetyModuleV1 $sm_impl \
# 	$axorToken \
# 	$axorToken \
# 	$treasury \
# 	$SM_DISTRIBUTION_START \
# 	$SM_DISTRIBUTION_END

# # ## -------------------- liquidity staking -----------------------

# ls_impl=0x4aa98de17db3b1bcd6b0a7d087583ee67190acbb
# LS_DISTRIBUTION_START="1716455871"
# LS_DISTRIBUTION_END="1717319391"

# npx hardhat verify --network $network "$liquidityStakingAddress"

# npx hardhat verify --network $network \
# 	--contract contracts/liquidity/v1/LiquidityStakingV1.sol:LiquidityStakingV1 $ls_impl \
# 	$collateralToken \
# 	$axorToken \
# 	$treasury \
# 	$LS_DISTRIBUTION_START \
# 	$LS_DISTRIBUTION_END

## -------------------- merkle distributor -----------------------

# merkle_impl="0x2fdc8f987295cab6570da6e42263199997aa5bf9"
#
# npx hardhat verify --network $network "$merkleDistributorAddress"
# npx hardhat verify --network $network \
# 	--contract contracts/merkle-distributor/v1/MerkleDistributorV1.sol:MerkleDistributorV1 $merkle_impl \
# 	$axorToken \
# 	$treasury
#
# linkToken='0x84b9b910527ad5c03a9ca831909e21e236ea7b06'
# oracleContract='0x8204C193ade6A1bB59BeF25B6A310E417953013f'
# oracleExternalAdapter='0xd8A7c92ccE4CA391385056f7D807E21600554AC3'
# jobId='0x6365366562393532363736373431666438323462626636643132313163313031'
#
# npx hardhat verify --network $network \
# 	--contract contracts/merkle-distributor/v1/oracles/MD1ChainlinkAdapter.sol:MD1ChainlinkAdapter $oracleAdapterAddress \
# 	$linkToken \
# 	$merkleDistributorAddress \
# 	$oracleContract \
# 	$oracleExternalAdapter \
# 	$jobId
