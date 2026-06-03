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

deploy-beacon-mainnet-production:
	forge create lib/diamond-pau/src/Beacon.sol:Beacon --constructor-args $(ETH_FROM) \
		--rpc-url $(MAINNET_RPC_URL) --from $(ETH_FROM) --account deployer --broadcast --verify

deploy-beacon-mainnet-local:
	forge create lib/diamond-pau/src/Beacon.sol:Beacon --constructor-args $(ETH_FROM) \
		--rpc-url $(MAINNET_RPC_URL) --from $(ETH_FROM) --account deployer --verify

# --------------------------------------------------------------------------------------------------
# Deploy: PAU Factory 		                                                                       #
# --------------------------------------------------------------------------------------------------

deploy-pau-factory-mainnet-production:
	forge create lib/diamond-pau/src/PAUFactory.sol:PAUFactory --constructor-args $(BEACON) \
		--rpc-url $(MAINNET_RPC_URL) --from $(ETH_FROM) --account deployer --broadcast --verify

deploy-pau-factory-mainnet-local:
	forge create lib/diamond-pau/src/PAUFactory.sol:PAUFactory --constructor-args $(BEACON) \
		--rpc-url $(MAINNET_RPC_URL) --from $(ETH_FROM) --account deployer --verify

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
