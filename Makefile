# diamond-pau-deploy Makefile
#
# Prerequisites:
#   - ETH_FROM: deployer address
#   - {MAINNET,BASE,AVALANCHE}_RPC_URL: chain RPC URLs
#   - {MAINNET,BASESCAN,SNOWTRACE}_API_KEY: per-chain Etherscan keys (for --verify)
#   - foundry keystore account named "deployer" (cast wallet import deployer --interactive)
#
# Deployment order (per chain + env):
#   1. deploy-facets-and-wire — deploys facets, wires them through Beacon, transfers admin (one shot)

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

# --------------------------------------------------------------------------------------------------
# Deploy: Beacon 		                                                                           #
# --------------------------------------------------------------------------------------------------
# Admin: Deployer as admin

deploy-beacon-mainnet:
	forge create lib/diamond-pau/src/Beacon.sol:Beacon \
		--rpc-url $(MAINNET_RPC_URL) --from $(ETH_FROM) --account deployer --broadcast --verify \
		--constructor-args $(ETH_FROM)

deploy-beacon-mainnet-dryrun:
	forge create lib/diamond-pau/src/Beacon.sol:Beacon \
		--rpc-url $(MAINNET_RPC_URL) --from $(ETH_FROM) --account deployer \
		--constructor-args $(ETH_FROM)

# --------------------------------------------------------------------------------------------------
# Deploy: PAU Factory 		                                                                       #
# --------------------------------------------------------------------------------------------------

deploy-pau-factory-mainnet:
	forge create lib/diamond-pau/src/PAUFactory.sol:PAUFactory \
		--rpc-url $(MAINNET_RPC_URL) --from $(ETH_FROM) --account deployer --broadcast --verify \
		--constructor-args $(BEACON)

deploy-pau-factory-mainnet-dryrun:
	forge create lib/diamond-pau/src/PAUFactory.sol:PAUFactory \
		--rpc-url $(MAINNET_RPC_URL) --from $(ETH_FROM) --account deployer \
		--constructor-args $(BEACON)

# --------------------------------------------------------------------------------------------------
# Deploy: Facets + Wire                                                                            #
# --------------------------------------------------------------------------------------------------
# Deploys facets, wires them through Beacon, then transfers DEFAULT_ADMIN_ROLE to final admin and revokes deployer.
# Input:  script/input/{chainId}/wire-facets-{chain}-{env}.json (admin)
# Output: script/output/{chainId}/wire-facets-{chain}-{env}-latest.json (each facet address)
#
# Constructor args for facets sourced from spark-address-registry / grove-address-registry.

# Mainnet

deploy-facets-and-wire-mainnet-production:
	ENV=production forge script script/mainnet/DeployFacetsAndWireMainnet.s.sol:DeployFacetsAndWireMainnet \
		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(MAINNET_RPC_URL)

deploy-facets-and-wire-mainnet-staging:
	ENV=staging forge script script/mainnet/DeployFacetsAndWireMainnet.s.sol:DeployFacetsAndWireMainnet \
		--sender $(ETH_FROM) --account deployer --broadcast --verify --rpc-url $(MAINNET_RPC_URL)

deploy-facets-and-wire-mainnet-production-dryrun:
	ENV=production forge script script/mainnet/DeployFacetsAndWireMainnet.s.sol:DeployFacetsAndWireMainnet \
		--sender $(ETH_FROM) --account deployer --rpc-url $(MAINNET_RPC_URL)

deploy-facets-and-wire-mainnet-staging-dryrun:
	ENV=staging forge script script/mainnet/DeployFacetsAndWireMainnet.s.sol:DeployFacetsAndWireMainnet \
		--sender $(ETH_FROM) --account deployer --rpc-url $(MAINNET_RPC_URL)
