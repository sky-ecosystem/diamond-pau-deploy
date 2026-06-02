// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { Script, stdJson, console } from "../../lib/forge-std/src/Script.sol";

import { ScriptTools } from "../../lib/dss-test/src/ScriptTools.sol";

import { DeployFacetsAndWire } from "../DeployFacetsAndWire.s.sol";

contract DeployFacetsAndWireMainnet is DeployFacetsAndWire {

    using stdJson for string;

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
        _deployAndWireCCTPFacet();
        _deployAndWireCentrifugeFacet();
        _deployAndWireCurveFacet();
        _deployAndWireDAIUSDSFacet();
        _deployAndWireERC4626Facet();
        _deployAndWireERC7540Facet();
        _deployAndWireEthenaFacet();
        _deployAndWireFarmFacet();
        _deployAndWireLayerZeroFacet();
        _deployAndWireMapleFacet();
        _deployAndWireMerklFacet();
        _deployAndWireOTCFacet();
        _deployAndWirePendleFacet();
        _deployAndWirePSMFacet();
        _deployAndWireSparkVaultFacet();
        _deployAndWireSuperstateFacet();
        _deployAndWireTransferAssetFacet();
        _deployAndWireUniswapV3Facet();
        _deployAndWireUniswapV4Facet();
        _deployAndWireUSDSFacet();
        _deployAndWireWEETHFacet();
        _deployAndWireWrapProxyETHFacet();
        _deployAndWireWSTETHFacet();
    }

}
