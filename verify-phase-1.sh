#!/bin/bash

deployer="0xd8A7c92ccE4CA391385056f7D807E21600554AC3"
axorToken="0xfD25dc6C6682B6ff007F0E016aC4C689fEDD6087"
governor="0x311B8EFbEfc6277d10b8c704eed73fa7065FED13"
long_executor="0xaaB743DB4601b0fE9e3e776c7d3f3c5D496F943F"
short_executor="0xaaB743DB4601b0fE9e3e776c7d3f3c5D496F943F"
merkle_executor="0xBC49D17C2387A73cCf4c14FA5916172D1958e404"
collateralToken="0x40F5f1F3aCb954C4e88C2e9a0DE30c845b5e25cf"
multical="0x184DD06B9e16Bf8d814B299dca0922FA1a087CC4"

network="arbitrum_testnet"
# network="bsc_testnet"

# -------------------- AxorGovernor ----------------------------
TRANSFERS_RESTRICTED_BEFORE=1716457290
TRANSFER_RESTRICTION_LIFTED_NO_LATER_THAN=1716457290
MINTING_RESTRICTED_BEFORE=1874223690
MINT_MAX_PERCENT=2

npx hardhat verify --network $network --show-stack-traces \
	--contract contracts/governance/token/AxorToken.sol:AxorToken $axorToken \
	$deployer \
	$TRANSFERS_RESTRICTED_BEFORE \
	$TRANSFER_RESTRICTION_LIFTED_NO_LATER_THAN \
	$MINTING_RESTRICTED_BEFORE \
	$MINT_MAX_PERCENT

block_count=20
npx hardhat verify --network $network --show-stack-traces \
	--contract contracts/governance/AxorGovernor.sol:AxorGovernor \
	$governor \
	"0x0000000000000000000000000000000000000000" \
	$block_count \
	$deployer

DELAY=604800
GRACE_PERIOD=604800
MINIMUM_DELAY=432000
MAXIMUM_DELAY=1814400
PROPOSITION_THRESHOLD=200
VOTING_DURATION_BLOCKS=100
VOTE_DIFFERENTIAL=1000
MINIMUM_QUORUM=1000

npx hardhat verify --network $network --show-stack-traces \
	--contract contracts/governance/executor/Executor.sol:Executor $long_executor \
	$governor \
	$DELAY \
	$GRACE_PERIOD \
	$MINIMUM_DELAY \
	$MAXIMUM_DELAY \
	$PROPOSITION_THRESHOLD \
	$VOTING_DURATION_BLOCKS \
	$VOTE_DIFFERENTIAL \
	$MINIMUM_QUORUM

DELAY=120
GRACE_PERIOD=420
MINIMUM_DELAY=60
MAXIMUM_DELAY=420
PROPOSITION_THRESHOLD=50
VOTING_DURATION_BLOCKS=4000
VOTE_DIFFERENTIAL=50
MINIMUM_QUORUM=200

npx hardhat verify --network $network --show-stack-traces \
	--contract contracts/governance/executor/Executor.sol:Executor $short_executor \
	$governor \
	$DELAY \
	$GRACE_PERIOD \
	$MINIMUM_DELAY \
	$MAXIMUM_DELAY \
	$PROPOSITION_THRESHOLD \
	$VOTING_DURATION_BLOCKS \
	$VOTE_DIFFERENTIAL \
	$MINIMUM_QUORUM

DELAY=0
GRACE_PERIOD=420
MINIMUM_DELAY=0
MAXIMUM_DELAY=60
PROPOSITION_THRESHOLD=50
VOTING_DURATION_BLOCKS=2000
VOTE_DIFFERENTIAL=50
MINIMUM_QUORUM=100

npx hardhat verify --network $network --show-stack-traces \
	--contract contracts/governance/executor/Executor.sol:Executor $merkle_executor \
	$governor \
	$DELAY \
	$GRACE_PERIOD \
	$MINIMUM_DELAY \
	$MAXIMUM_DELAY \
	$PROPOSITION_THRESHOLD \
	$VOTING_DURATION_BLOCKS \
	$VOTE_DIFFERENTIAL \
	$MINIMUM_QUORUM

DELAY=600
GRACE_PERIOD=420
MINIMUM_DELAY=240
MAXIMUM_DELAY=1260
PROPOSITION_THRESHOLD=50
VOTING_DURATION_BLOCKS=4000
VOTE_DIFFERENTIAL=50
MINIMUM_QUORUM=200

# # -------------------- ERC20 Token ----------------------------

npx hardhat verify --network $network --show-stack-traces \
	--contract contracts/test/CollateralToken.sol:USDT $collateralToken

# # # -------------------- Maker DAO Multicall ----------------------------

npx hardhat verify --network $network --show-stack-traces \
	--contract contracts/dependencies/makerdao/multicall2.sol:Multicall2 $multical
