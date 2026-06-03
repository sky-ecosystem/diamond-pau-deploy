// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { DeployFacetsAndWire } from "../DeployFacetsAndWire.s.sol";

import { Ethereum }                  from "../../lib/diamond-pau/lib/spark-address-registry/src/Ethereum.sol";
import { Ethereum as GroveEthereum } from "../../lib/diamond-pau/lib/grove-address-registry/src/Ethereum.sol";

contract DeployFacetsAndWireMainnet is DeployFacetsAndWire {

    // NOTE: From https://docs.uniswap.org/contracts/v3/reference/deployments/ethereum-deployments.
    address internal constant _UNISWAP_V3_POSITION_MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address internal constant _UNISWAP_V3_ROUTER           = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;

    // NOTE: From https://docs.uniswap.org/contracts/v4/deployments (Ethereum Mainnet).
    address internal constant _PERMIT2                     = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address internal constant _UNISWAP_V4_POSITION_MANAGER = 0xbD216513d74C8cf14cf4747E6AaA6420FF64ee9e;
    address internal constant _UNISWAP_V4_ROUTER           = 0x66a9893cC07D91D95644AEDD05D03f95e1dBA8Af;

    function run() override public {
        vm.createSelectFork(getChain("mainnet").rpcUrl);

        super.run();
    }

    function _configFacetFileSlug() internal override returns (string memory) {
        return string(abi.encodePacked("wire-facets-mainnet-", vm.envString("ENV")));
    }
    
    function _logPrefix() internal override returns (string memory) {
        return "Wiring PAU facets...\n  Chain: Mainnet";
    }

    function _deployAndWireFacets() internal override {
        _deployAndWireAaveFacet();
        _deployAndWireBasinFacet();

        _deployAndWireCCTPFacet({
            cctp_ : Ethereum.CCTP_TOKEN_MESSENGER,
            usdc_ : Ethereum.USDC
        });

        _deployAndWireCentrifugeFacet();
        _deployAndWireCurveFacet();

        _deployAndWireDAIUSDSFacet({
            dai_     : Ethereum.DAI,
            daiUSDS_ : Ethereum.DAI_USDS,
            usds_    : Ethereum.USDS
        });

        _deployAndWireERC4626Facet();
        _deployAndWireERC7540Facet();

        _deployAndWireEthenaFacet({
            minter_ : Ethereum.ETHENA_MINTER,
            susde_  : Ethereum.SUSDE,
            usdc_   : Ethereum.USDC,
            usde_   : Ethereum.USDE
        });

        _deployAndWireFarmFacet();
        _deployAndWireLayerZeroFacet();
        _deployAndWireMapleFacet();
        _deployAndWireMerklFacet();
        _deployAndWireOTCFacet();

        _deployAndWirePendleFacet({
            router_ : GroveEthereum.PENDLE_ROUTER
        });

        _deployAndWirePSMFacet({
            dai_     : Ethereum.DAI,
            daiUSDS_ : Ethereum.DAI_USDS,
            psm_     : Ethereum.PSM,
            usdc_    : Ethereum.USDC,
            usds_    : Ethereum.USDS
        });

        _deployAndWireSparkVaultFacet();

        _deployAndWireSuperstateFacet({
            usdc_ : Ethereum.USDC,
            ustb_ : Ethereum.USTB
        });

        _deployAndWireTransferAssetFacet();

        _deployAndWireUniswapV3Facet({
            positionManager_ : _UNISWAP_V3_POSITION_MANAGER,
            router_          : _UNISWAP_V3_ROUTER
        });

        _deployAndWireUniswapV4Facet({
            permit2_         : _PERMIT2,
            positionManager_ : _UNISWAP_V4_POSITION_MANAGER,
            router_          : _UNISWAP_V4_ROUTER
        });

        _deployAndWireUSDSFacet({
            usds_ : Ethereum.USDS
        });

        _deployAndWireWEETHFacet({
            weeth_ : Ethereum.WEETH,
            weth_  : Ethereum.WETH
        });

        _deployAndWireWrapProxyETHFacet({
            weth_ : Ethereum.WETH
        });

        _deployAndWireWSTETHFacet({
            weth_          : Ethereum.WETH,
            withdrawQueue_ : Ethereum.WSTETH_WITHDRAW_QUEUE,
            wsteth_        : Ethereum.WSTETH
        });
    }

}
