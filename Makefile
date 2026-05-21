# diamond-pau-deploy Makefile
#
# Prerequisites:
#   - ETH_FROM: deployer address
#   - {MAINNET,BASE,AVALANCHE}_RPC_URL: chain RPC URLs
#   - {MAINNET,BASESCAN,SNOWTRACE}_API_KEY: per-chain Etherscan keys (for --verify)
#   - foundry keystore account named "deployer" (cast wallet import deployer --interactive)
#
# Deployment order (per chain + env):
#   1. deploy-beacon-and-facets — deploys Beacon, wires all facets, transfers admin (one shot)
#   2. deploy-factory           — needs beacon address pasted into script/input/{chainId}/pau-factory-{chain}-{env}.json
#   3. deploy-pau               — needs pauFactory pasted into script/input/{chainId}/pau-{chain}-{env}.json

# --------------------------------------------------------------------------------------------------
# Build & Test                                                                                     #
# --------------------------------------------------------------------------------------------------

build:
	forge build

test:
	forge test

clean:
	forge clean

test-postdeploy-mainnet:
	forge test --match-path "test/mainnet-fork/PostDeploy*" -vvv

# test-postdeploy-base:
# 	forge test --match-path "test/base-fork/PostDeploy*" -vvv

# test-postdeploy-avalanche:
# 	forge test --match-path "test/avalanche-fork/PostDeploy*" -vvv

# --------------------------------------------------------------------------------------------------
# Deploy: Beacon + Facets                                                                          #
# --------------------------------------------------------------------------------------------------
# Deploys Beacon (with deployer as temporary admin), wires all integration facets, then transfers
# DEFAULT_ADMIN_ROLE to final admin and revokes deployer.
# Input:  script/input/{chainId}/beacon-and-facets-{chain}-{env}.json (admin)
# Output: script/output/{chainId}/beacon-and-facets-{chain}-{env}-latest.json (beacon + each facet address)
#
# Constructor args for facets sourced from spark-address-registry / grove-address-registry.

# Mainnet

deploy-beacon-and-facets-mainnet-production:
	ENV=production forge script script/DeployBeaconAndFacetsMainnet.s.sol:DeployBeaconAndFacetsMainnet \
		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(MAINNET_RPC_URL)

deploy-beacon-and-facets-mainnet-staging:
	ENV=staging forge script script/DeployBeaconAndFacetsMainnet.s.sol:DeployBeaconAndFacetsMainnet \
		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(MAINNET_RPC_URL)

# Base

# deploy-beacon-and-facets-base-production:
# 	ENV=production forge script script/DeployBeaconAndFacetsBase.s.sol:DeployBeaconAndFacetsBase \
# 		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(BASE_RPC_URL)

# deploy-beacon-and-facets-base-staging:
# 	ENV=staging forge script script/DeployBeaconAndFacetsBase.s.sol:DeployBeaconAndFacetsBase \
# 		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(BASE_RPC_URL)

# Avalanche

# deploy-beacon-and-facets-avalanche-production:
# 	ENV=production forge script script/DeployBeaconAndFacetsAvalanche.s.sol:DeployBeaconAndFacetsAvalanche \
# 		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(AVALANCHE_RPC_URL)

# deploy-beacon-and-facets-avalanche-staging:
# 	ENV=staging forge script script/DeployBeaconAndFacetsAvalanche.s.sol:DeployBeaconAndFacetsAvalanche \
# 		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(AVALANCHE_RPC_URL)

# --------------------------------------------------------------------------------------------------
# Deploy: PAU Factory                                                                              #
# --------------------------------------------------------------------------------------------------
# Deploys PAUFactory contract.
# Input:  script/input/{chainId}/pau-factory-{chain}-{env}.json (beacon)
# Output: script/output/{chainId}/pau-factory-{chain}-{env}-latest.json (pauFactory)
#
# Run AFTER deploy-beacon-and-facets.

# Mainnet

deploy-factory-mainnet-production:
	CHAIN=mainnet ENV=production forge script script/DeployPAUFactory.s.sol:DeployPAUFactory \
		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(MAINNET_RPC_URL)

deploy-factory-mainnet-staging:
	CHAIN=mainnet ENV=staging forge script script/DeployPAUFactory.s.sol:DeployPAUFactory \
		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(MAINNET_RPC_URL)

# Base

# deploy-factory-base-production:
# 	CHAIN=base ENV=production forge script script/DeployPAUFactory.s.sol:DeployPAUFactory \
# 		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(BASE_RPC_URL)

# deploy-factory-base-staging:
# 	CHAIN=base ENV=staging forge script script/DeployPAUFactory.s.sol:DeployPAUFactory \
# 		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(BASE_RPC_URL)

# Avalanche

# deploy-factory-avalanche-production:
# 	CHAIN=avalanche ENV=production forge script script/DeployPAUFactory.s.sol:DeployPAUFactory \
# 		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(AVALANCHE_RPC_URL)

# deploy-factory-avalanche-staging:
# 	CHAIN=avalanche ENV=staging forge script script/DeployPAUFactory.s.sol:DeployPAUFactory \
# 		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(AVALANCHE_RPC_URL)

# --------------------------------------------------------------------------------------------------
# Deploy: PAU System                                                                               #
# --------------------------------------------------------------------------------------------------
# Deploys Controller, AccessControls, ALMProxy, RateLimits via PAUFactory + role transfers.
# Input:  script/input/{chainId}/pau-{chain}-{env}.json (admin, allocator, freezer, pauFactory)
# Output: script/output/{chainId}/pau-{chain}-{env}-latest.json (controller, accessControls, almProxy, rateLimits)
#
# Run AFTER deploy-factory.

# Mainnet

deploy-pau-mainnet-production:
	CHAIN=mainnet ENV=production forge script script/DeployPAU.s.sol:DeployPAU \
		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(MAINNET_RPC_URL)

deploy-pau-mainnet-staging:
	CHAIN=mainnet ENV=staging forge script script/DeployPAU.s.sol:DeployPAU \
		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(MAINNET_RPC_URL)

# Base

# deploy-pau-base-production:
# 	CHAIN=base ENV=production forge script script/DeployPAU.s.sol:DeployPAU \
# 		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(BASE_RPC_URL)

# deploy-pau-base-staging:
# 	CHAIN=base ENV=staging forge script script/DeployPAU.s.sol:DeployPAU \
# 		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(BASE_RPC_URL)

# Avalanche

# deploy-pau-avalanche-production:
# 	CHAIN=avalanche ENV=production forge script script/DeployPAU.s.sol:DeployPAU \
# 		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(AVALANCHE_RPC_URL)

# deploy-pau-avalanche-staging:
# 	CHAIN=avalanche ENV=staging forge script script/DeployPAU.s.sol:DeployPAU \
# 		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(AVALANCHE_RPC_URL)
