// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { VmSafe } from "../../lib/forge-std/src/Vm.sol";

import { IAccessControl } from "../../lib/diamond-pau/lib/openzeppelin-contracts/contracts/access/IAccessControl.sol";

import { Base } from "../../lib/diamond-pau/lib/spark-address-registry/src/Base.sol";

import { IBeacon }                 from "../../lib/diamond-pau/src/interfaces/IBeacon.sol";
import { IEnumerableIntegrations } from "../../lib/diamond-pau/src/interfaces/IEnumerableIntegrations.sol";

import { ForkTestBase } from "../../lib/diamond-pau/test/mainnet-fork/ForkTestBase.t.sol";

import { Beacon } from "../../lib/diamond-pau/src/Beacon.sol";

import { ICCTPFacet } from "../../lib/diamond-pau/src/facets/cctp/ICCTPFacet.sol";

import { PostDeployFacetsAndWireBase } from "../PostDeployFacetsAndWireBase.t.sol";

contract PostDeployFacetsAndWireTests is PostDeployFacetsAndWireBase {

    address internal constant BEACON = 0x829dC2b7E94B1954F0764E573f2E0d45Afa28199;

    // Paste from script/output/8453/wire-facets-base-{env}-latest.json
    address internal constant DEPLOYER   = 0x1ca4ECaF0E13ca833c80dA835DEEa15e1684361d;
    address internal constant ADMIN      = 0x0000000000000000000000000000000000000000;
    address internal constant CCTP_FACET = 0x0000000000000000000000000000000000000000;

    Beacon internal beacon;

    function setUp() public {
        vm.createSelectFork(getChain("base").rpcUrl, _getBlock());

        beacon = Beacon(BEACON);
    }

    function _getBlock() internal pure returns (uint256) {
        return 0;
    }

    function test_postDeployState_beacon() external view {
        // Final admin holds the role; deployer was revoked in the script.
        assertEq(beacon.hasRole(DEFAULT_ADMIN_ROLE, ADMIN),    true);
        assertEq(beacon.hasRole(DEFAULT_ADMIN_ROLE, DEPLOYER), false);

        assertEq(beacon.getRoleMemberCount(DEFAULT_ADMIN_ROLE), 1);
        assertEq(beacon.getRoleMember(DEFAULT_ADMIN_ROLE, 0),   ADMIN);

        assertEq(beacon.supportsInterface(type(IBeacon).interfaceId), true);
    }

    function test_postDeployState_facetConstructorArgs() external view {
        // CCTPFacet constructor args.
        assertEq(ICCTPFacet(CCTP_FACET).cctp(), Base.CCTP_TOKEN_MESSENGER);
        assertEq(ICCTPFacet(CCTP_FACET).usdc(), Base.USDC);
    }

    function test_postDeployState_facetIntegrations() external view {
        assertEq(beacon.integrations().length, 1);

        _assertIntegration("CCTP_FACET", CCTP_FACET, 0);
    }

    function test_postDeployEvents() external {
        // Expect 4 events on Beacon: 1 RoleGranted (constructor) + 1 IntegrationSet
        // + 1 RoleGranted (final admin) + 1 RoleRevoked (deployer self-revoked).
        VmSafe.EthGetLogs[] memory allLogs = _getEvents(block.chainid, BEACON, "");

        assertEq(allLogs.length, 4);

        // [0] Constructor: RoleGranted(DEFAULT_ADMIN_ROLE, DEPLOYER, DEPLOYER)
        assertEq(allLogs[0].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(allLogs[0].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(allLogs[0].topics[2]), DEPLOYER);
        assertEq(_toAddress(allLogs[0].topics[3]), DEPLOYER);

        // [1] IntegrationSet: CCTP_FACET
        _assertIntegrationSetLog(allLogs[1], "CCTP_FACET", CCTP_FACET, 0);

        // [2] Admin transfer: RoleGranted(DEFAULT_ADMIN_ROLE, ADMIN, DEPLOYER)
        assertEq(allLogs[2].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(allLogs[2].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(allLogs[2].topics[2]), ADMIN);
        assertEq(_toAddress(allLogs[2].topics[3]), DEPLOYER);

        // [3] Deployer self-revoke: RoleRevoked(DEFAULT_ADMIN_ROLE, DEPLOYER, DEPLOYER)
        assertEq(allLogs[3].topics[0],             IAccessControl.RoleRevoked.selector);
        assertEq(allLogs[3].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(allLogs[3].topics[2]), DEPLOYER);
        assertEq(_toAddress(allLogs[3].topics[3]), DEPLOYER);
    }

    function test_postDeployState_wiringMatchesReference() external {
        uint256 postDeployFork = vm.activeFork();

        (
            IEnumerableIntegrations.Integration[] memory refIntegrations,
            bytes32[]                             memory refFacetCodehashes
        ) = new WiredBeaconHarness().buildReferenceIntegrations();

        vm.selectFork(postDeployFork);

        assertEq(refIntegrations.length, beacon.integrations().length);

        for (uint256 i; i < refIntegrations.length; ++i) {
            bytes32 refId = refIntegrations[i].id;

            IEnumerableIntegrations.Wire[] memory refWires    = refIntegrations[i].config.wires;
            IEnumerableIntegrations.Config memory deployedCfg = beacon.getConfig(refId);

            assertEq(deployedCfg.facet != address(0), true,                     "missing integration on deployed beacon");
            assertEq(deployedCfg.facet.codehash,      refFacetCodehashes[i],    "facet bytecode mismatch");
            assertEq(refWires.length,                 deployedCfg.wires.length, "wire count mismatch");

            for (uint256 j; j < refWires.length; ++j) {
                IEnumerableIntegrations.Dispatch memory deployedDispatch = beacon.getDispatch(refWires[j].callSelector);

                assertEq(deployedDispatch.facet != address(0), true);
                assertEq(deployedDispatch.facet.codehash,      refFacetCodehashes[i]);
                assertEq(deployedDispatch.delegateSelector,    refWires[j].delegateSelector);
            }
        }
    }

    /**********************************************************************************************/
    /*** Helper functions                                                                       ***/
    /**********************************************************************************************/

    function _assertIntegration(
        bytes32 id,
        address expectedFacet,
        uint256 expectedWireCount
    ) internal view {
        IEnumerableIntegrations.Config memory cfg = beacon.getConfig(id);

        assertEq(cfg.facet,        expectedFacet);
        assertEq(cfg.wires.length, expectedWireCount);

        // Each wired callSelector resolves through the Beacon's dispatch to the same facet.
        for (uint256 i = 0; i < cfg.wires.length; ++i) {
            IEnumerableIntegrations.Dispatch memory d = beacon.getDispatch(cfg.wires[i].callSelector);
            assertEq(d.facet,            expectedFacet);
            assertEq(d.delegateSelector, cfg.wires[i].delegateSelector);
        }
    }

    function _assertIntegrationSetLog(
        VmSafe.EthGetLogs memory log,
        bytes32                  expectedId,
        address                  expectedFacet,
        uint256                  expectedWireCount
    ) internal pure {
        assertEq(log.topics[0], IEnumerableIntegrations.IntegrationSet.selector);
        assertEq(log.topics[1], expectedId);

        // Decode Config from data: facet (address) + wires (Wire[]).
        ( IEnumerableIntegrations.Config memory cfg ) = abi.decode(log.data, (IEnumerableIntegrations.Config));

        assertEq(cfg.facet,        expectedFacet);
        assertEq(cfg.wires.length, expectedWireCount);
    }

}

contract WiredBeaconHarness is ForkTestBase {

    function buildReferenceIntegrations()
        external
        returns (
            IEnumerableIntegrations.Integration[] memory integrations_,
            bytes32[]                             memory facetCodehashes
        )
    {
        setUp();

        integrations_   = beacon.integrations();
        facetCodehashes = new bytes32[](integrations_.length);

        for (uint256 i; i < integrations_.length; ++i) {
            facetCodehashes[i] = integrations_[i].config.facet.codehash;
        }
    }

}
