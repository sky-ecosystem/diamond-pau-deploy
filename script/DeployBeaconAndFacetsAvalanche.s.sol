// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { Script, stdJson, console } from "../lib/forge-std/src/Script.sol";

import { ScriptTools } from "../lib/dss-test/src/ScriptTools.sol";

import { CentrifugeFacet } from "../lib/diamond-pau/src/facets/centrifuge/CentrifugeFacet.sol";
import { ERC7540Facet }    from "../lib/diamond-pau/src/facets/erc7540/ERC7540Facet.sol";

import { ICentrifugeFacet } from "../lib/diamond-pau/src/facets/centrifuge/ICentrifugeFacet.sol";
import { IERC7540Facet }    from "../lib/diamond-pau/src/facets/erc7540/IERC7540Facet.sol";

import { IEnumerableIntegrations } from "../lib/diamond-pau/src/interfaces/IEnumerableIntegrations.sol";

import { IForeignControllerFull } from "../lib/diamond-pau/test/interfaces/IForeignControllerFull.sol";

import { Beacon } from "../lib/diamond-pau/src/Beacon.sol";

contract DeployBeaconAndFacetsAvalanche is Script {

    using stdJson for string;

    /**********************************************************************************************/
    /*** Structs                                                                                ***/
    /**********************************************************************************************/

    struct AvalancheFacetAddresses {
        address centrifugeFacet;
        address erc7540Facet;
    }

    /**********************************************************************************************/
    /*** State variables                                                                        ***/
    /**********************************************************************************************/

    Beacon internal beacon;

    /**********************************************************************************************/
    /*** Run function                                                                           ***/
    /**********************************************************************************************/

    function run() external {
        string memory env = vm.envString("ENV");

        vm.createSelectFork(getChain("avalanche").rpcUrl);

        vm.setEnv("FOUNDRY_ROOT_CHAINID",             vm.toString(block.chainid));
        vm.setEnv("FOUNDRY_EXPORTS_OVERWRITE_LATEST", "true");

        string memory fileSlug = string(abi.encodePacked("beacon-and-facets-avalanche-", env));
        string memory config   = ScriptTools.loadConfig(fileSlug);

        address admin = config.readAddress(".admin");

        console.log("Deploying PAU beacon + facets...\n  Chain: Avalanche\n  Env: %s", env);

        vm.startBroadcast();

        address deployer = msg.sender;

        require(deployer != admin, "DeployBeaconAndFacetsAvalanche/deployer-must-differ-from-admin");

        // Step 1: deploy Beacon with deployer as TEMPORARY admin so this script can wire facets.

        beacon = new Beacon(deployer);

        console.log("PAU beacon deployed at: ", address(beacon));

        // Step 2: deploy each facet and wire it through beacon.setIntegration.
        AvalancheFacetAddresses memory facets = _deployAndWireFacets();

        // Step 3: Grant admin role to final admin, then revoke deployer.

        beacon.grantRole(beacon.DEFAULT_ADMIN_ROLE(),  admin);
        beacon.revokeRole(beacon.DEFAULT_ADMIN_ROLE(), deployer);

        console.log("Beacon admin transferred to: ", admin);

        vm.stopBroadcast();

        // Step 4: export addresses.

        ScriptTools.exportContract(fileSlug, "beacon", address(beacon));

        _exportFacets(facets, fileSlug);
    }

    /**********************************************************************************************/
    /*** Deploy + wire orchestration                                                            ***/
    /**********************************************************************************************/

    function _deployAndWireFacets() internal returns (AvalancheFacetAddresses memory facets) {
        facets.centrifugeFacet = _deployAndWireCentrifugeFacet();
        facets.erc7540Facet    = _deployAndWireERC7540Facet();
    }

    function _exportFacets(AvalancheFacetAddresses memory facets, string memory fileSlug) internal {
        ScriptTools.exportContract(fileSlug, "centrifugeFacet", facets.centrifugeFacet);
        ScriptTools.exportContract(fileSlug, "erc7540Facet",    facets.erc7540Facet);
    }

    /**********************************************************************************************/
    /*** Per-facet deploy + wire helpers                                                        ***/
    /**********************************************************************************************/

    function _deployAndWireCentrifugeFacet() internal returns (address facet) {
        facet = address(new CentrifugeFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](12);

        wires[0] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.setCentrifugeRecipient.selector,
            ICentrifugeFacet.setRecipient.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.cancelCentrifugeDepositRequest.selector,
            ICentrifugeFacet.cancelDepositRequest.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.claimCentrifugeCancelDepositRequest.selector,
            ICentrifugeFacet.claimCancelDepositRequest.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.cancelCentrifugeRedeemRequest.selector,
            ICentrifugeFacet.cancelRedeemRequest.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.claimCentrifugeCancelRedeemRequest.selector,
            ICentrifugeFacet.claimCancelRedeemRequest.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.transferSharesCentrifuge.selector,
            ICentrifugeFacet.transferShares.selector
        );
        wires[6] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getCentrifugeRecipient.selector,
            ICentrifugeFacet.getRecipient.selector
        );
        wires[7] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getCentrifugeCancelDepositRateLimitKey.selector,
            ICentrifugeFacet.getCancelDepositRateLimitKey.selector
        );
        wires[8] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getCentrifugeClaimCancelDepositRateLimitKey.selector,
            ICentrifugeFacet.getClaimCancelDepositRateLimitKey.selector
        );
        wires[9] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getCentrifugeCancelRedeemRateLimitKey.selector,
            ICentrifugeFacet.getCancelRedeemRateLimitKey.selector
        );
        wires[10] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getCentrifugeClaimCancelRedeemRateLimitKey.selector,
            ICentrifugeFacet.getClaimCancelRedeemRateLimitKey.selector
        );
        wires[11] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getCentrifugeTransferRateLimitKey.selector,
            ICentrifugeFacet.getTransferRateLimitKey.selector
        );

        beacon.setIntegration("CENTRIFUGE_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireERC7540Facet() internal returns (address facet) {
        facet = address(new ERC7540Facet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](8);

        wires[0] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.requestDepositERC7540.selector,
            IERC7540Facet.requestDeposit.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.claimDepositERC7540.selector,
            IERC7540Facet.claimDeposit.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.requestRedeemERC7540.selector,
            IERC7540Facet.requestRedeem.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.claimRedeemERC7540.selector,
            IERC7540Facet.claimRedeem.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getERC7540RequestDepositRateLimitKey.selector,
            IERC7540Facet.getRequestDepositRateLimitKey.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getERC7540ClaimDepositRateLimitKey.selector,
            IERC7540Facet.getClaimDepositRateLimitKey.selector
        );
        wires[6] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getERC7540RequestRedeemRateLimitKey.selector,
            IERC7540Facet.getRequestRedeemRateLimitKey.selector
        );
        wires[7] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getERC7540ClaimRedeemRateLimitKey.selector,
            IERC7540Facet.getClaimRedeemRateLimitKey.selector
        );

        beacon.setIntegration("ERC7540_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

}
