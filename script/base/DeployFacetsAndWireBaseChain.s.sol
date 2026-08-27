// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { DeployFacetsAndWire } from "../DeployFacetsAndWire.s.sol";

import { Base } from "../../lib/diamond-pau/lib/spark-address-registry/src/Base.sol";

contract DeployFacetsAndWireBaseChain is DeployFacetsAndWire {

    function run() override public {
        vm.createSelectFork(getChain("base").rpcUrl);

        super.run();
    }

    function _configFacetFileSlug() internal view override returns (string memory) {
        return string(abi.encodePacked("wire-facets-base-chain-", vm.envString("ENV")));
    }
    
    function _logPrefix() internal pure override returns (string memory) {
        return "Wiring PAU facets...\n  Chain: Base";
    }

    function _deployAndWireFacets() internal override {
        _deployAndWireCCTPFacet({
            cctp_ : Base.CCTP_TOKEN_MESSENGER,
            usdc_ : Base.USDC
        });
    }

}
