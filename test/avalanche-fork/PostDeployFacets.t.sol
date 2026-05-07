// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { VmSafe } from "../../lib/forge-std/src/Vm.sol";

import { IEnumerableIntegrations } from "../../lib/diamond-pau/src/interfaces/IEnumerableIntegrations.sol";
import { Beacon }                  from "../../lib/diamond-pau/src/Beacon.sol";

import { PostDeployTestBase } from "../PostDeployTestBase.t.sol";

contract PostDeployFacetsTests is PostDeployTestBase {

    // paste from script/output/43114/facets-avalanche-{env}-latest.json
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
        return 24684236; // After the Facets deployment block.
    }

    function test_postDeployState_facetIntegrations() external {
        assertEq(beacon.integrations().length, 2);

        _assertIntegration("CENTRIFUGE_FACET", CENTRIFUGE_FACET, 12);
        _assertIntegration("ERC7540_FACET",    ERC7540_FACET,    8);
    }

    function test_postDeployEvents_facetIntegrationSet() external {
        // Expect 2 IntegrationSet events from BEACON, in deploy-script order.
        VmSafe.EthGetLogs[] memory logs = _getEvents(
            block.chainid,
            BEACON,
            IEnumerableIntegrations.IntegrationSet.selector
        );

        assertEq(logs.length, 2);

        _assertIntegrationSetLog(logs[0], "CENTRIFUGE_FACET", CENTRIFUGE_FACET, 12);
        _assertIntegrationSetLog(logs[1], "ERC7540_FACET",    ERC7540_FACET,    8);
    }

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
