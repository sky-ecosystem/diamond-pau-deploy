// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { VmSafe } from "../../lib/forge-std/src/Vm.sol";

import { IAccessControl } from "../../lib/diamond-pau/lib/openzeppelin-contracts/contracts/access/IAccessControl.sol";

import { IBeacon }                 from "../../lib/diamond-pau/src/interfaces/IBeacon.sol";
import { IEnumerableIntegrations } from "../../lib/diamond-pau/src/interfaces/IEnumerableIntegrations.sol";
import { Beacon }                  from "../../lib/diamond-pau/src/Beacon.sol";

import { PostDeployTestBase } from "../PostDeployTestBase.t.sol";

contract PostDeployBeaconAndFacetsTests is PostDeployTestBase {

    // Paste from script/output/43114/beacon-and-facets-avalanche-{env}-latest.json
    address internal constant DEPLOYER         = 0x0000000000000000000000000000000000000000;
    address internal constant ADMIN            = 0x0000000000000000000000000000000000000000;
    address internal constant BEACON           = 0x0000000000000000000000000000000000000000;
    address internal constant CENTRIFUGE_FACET = 0x0000000000000000000000000000000000000000;
    address internal constant ERC7540_FACET    = 0x0000000000000000000000000000000000000000;

    Beacon internal beacon;

    function setUp() public {
        vm.createSelectFork(getChain("avalanche").rpcUrl, _getBlock());

        beacon = Beacon(BEACON);
    }

    function _getBlock() internal pure returns (uint256) {
        return 24684236; // After the BeaconAndFacets deployment block.
    }

    function test_postDeployState_beacon() external {
        assertEq(beacon.hasRole(DEFAULT_ADMIN_ROLE, ADMIN),    true);
        assertEq(beacon.hasRole(DEFAULT_ADMIN_ROLE, DEPLOYER), false);

        assertEq(beacon.getRoleMemberCount(DEFAULT_ADMIN_ROLE), 1);
        assertEq(beacon.getRoleMember(DEFAULT_ADMIN_ROLE, 0),   ADMIN);

        assertEq(beacon.supportsInterface(type(IBeacon).interfaceId), true);
    }

    function test_postDeployState_facetIntegrations() external {
        assertEq(beacon.integrations().length, 2);

        _assertIntegration("CENTRIFUGE_FACET", CENTRIFUGE_FACET, 12);
        _assertIntegration("ERC7540_FACET",    ERC7540_FACET,    8);
    }

    function test_postDeployEvents() external {
        // Expect 5 events on Beacon: 1 RoleGranted (ctor) + 2 IntegrationSet
        // + 1 RoleGranted (final admin) + 1 RoleRevoked (deployer self-revoke).
        VmSafe.EthGetLogs[] memory allLogs = _getEvents(block.chainid, BEACON, "");

        assertEq(allLogs.length, 5);

        // [0] Constructor: RoleGranted(DEFAULT_ADMIN_ROLE, DEPLOYER, DEPLOYER)
        assertEq(allLogs[0].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(allLogs[0].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(allLogs[0].topics[2]), DEPLOYER);
        assertEq(_toAddress(allLogs[0].topics[3]), DEPLOYER);

        // [1..2] IntegrationSet × 2, in deploy-script order.
        _assertIntegrationSetLog(allLogs[1], "CENTRIFUGE_FACET", CENTRIFUGE_FACET, 12);
        _assertIntegrationSetLog(allLogs[2], "ERC7540_FACET",    ERC7540_FACET,    8);

        // [3] Admin transfer: RoleGranted(DEFAULT_ADMIN_ROLE, ADMIN, DEPLOYER)
        assertEq(allLogs[3].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(allLogs[3].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(allLogs[3].topics[2]), ADMIN);
        assertEq(_toAddress(allLogs[3].topics[3]), DEPLOYER);

        // [4] Deployer self-revoke: RoleRevoked(DEFAULT_ADMIN_ROLE, DEPLOYER, DEPLOYER)
        assertEq(allLogs[4].topics[0],             IAccessControl.RoleRevoked.selector);
        assertEq(allLogs[4].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(allLogs[4].topics[2]), DEPLOYER);
        assertEq(_toAddress(allLogs[4].topics[3]), DEPLOYER);
    }

    function _assertIntegration(
        bytes32 id,
        address expectedFacet,
        uint256 expectedWireCount
    ) internal view {
        IEnumerableIntegrations.Config memory cfg = beacon.getConfig(id);

        assertEq(cfg.facet,        expectedFacet);
        assertEq(cfg.wires.length, expectedWireCount);

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

        ( IEnumerableIntegrations.Config memory cfg ) = abi.decode(log.data, (IEnumerableIntegrations.Config));

        assertEq(cfg.facet,        expectedFacet);
        assertEq(cfg.wires.length, expectedWireCount);
    }

}
