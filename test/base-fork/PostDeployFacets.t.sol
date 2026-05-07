// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { VmSafe } from "../../lib/forge-std/src/Vm.sol";

import { Base }              from "../../lib/diamond-pau/lib/spark-address-registry/src/Base.sol";
import { Base as GroveBase } from "../../lib/diamond-pau/lib/grove-address-registry/src/Base.sol";

import { IEnumerableIntegrations } from "../../lib/diamond-pau/src/interfaces/IEnumerableIntegrations.sol";
import { Beacon }                  from "../../lib/diamond-pau/src/Beacon.sol";

import { IPendleFacet }    from "../../lib/diamond-pau/src/facets/pendle/IPendleFacet.sol";
import { IPSM3Facet }      from "../../lib/diamond-pau/src/facets/psm3/IPSM3Facet.sol";
import { IUniswapV3Facet } from "../../lib/diamond-pau/src/facets/uniswap-v3/IUniswapV3Facet.sol";

import { PostDeployTestBase } from "../PostDeployTestBase.t.sol";

contract PostDeployFacetsTests is PostDeployTestBase {

    // From the DeployBaseFacets script (mirror of registry constants used at deploy time).
    address internal constant _UNISWAP_V3_POSITION_MANAGER = 0x03a520b32C04BF3bEEf7BEb72E919cf822Ed34f1;
    address internal constant _UNISWAP_V3_ROUTER           = 0x2626664c2603336E57B271c5C0b26F421741e481;

    // paste from script/output/8453/facets-base-{env}-latest.json
    address internal constant DEPLOYER             = 0x0000000000000000000000000000000000000000;
    address internal constant ADMIN                = 0x0000000000000000000000000000000000000000;
    address internal constant BEACON               = 0x0000000000000000000000000000000000000000;
    address internal constant AAVE_FACET           = 0x0000000000000000000000000000000000000000;
    address internal constant CURVE_FACET          = 0x0000000000000000000000000000000000000000;
    address internal constant ERC4626_FACET        = 0x0000000000000000000000000000000000000000;
    address internal constant MERKL_FACET          = 0x0000000000000000000000000000000000000000;
    address internal constant PENDLE_FACET         = 0x0000000000000000000000000000000000000000;
    address internal constant PSM3_FACET           = 0x0000000000000000000000000000000000000000;
    address internal constant SPARK_VAULT_FACET    = 0x0000000000000000000000000000000000000000;
    address internal constant TRANSFER_ASSET_FACET = 0x0000000000000000000000000000000000000000;
    address internal constant UNISWAP_V3_FACET     = 0x0000000000000000000000000000000000000000;

    Beacon internal beacon;

    function setUp() public {
        vm.createSelectFork(getChain("base").rpcUrl, _getBlock());

        beacon = Beacon(BEACON);
    }

    function _getBlock() internal pure returns (uint256) {
        return 24684236; // After the Facets deployment block.
    }

    function test_postDeployState_facetConstructorArgs() external {
        // PendleFacet constructor args.
        assertEq(IPendleFacet(PENDLE_FACET).router(), GroveBase.PENDLE_ROUTER);

        // PSM3Facet constructor args.
        assertEq(IPSM3Facet(PSM3_FACET).psm(), Base.PSM3);

        // UniswapV3Facet constructor args.
        assertEq(IUniswapV3Facet(UNISWAP_V3_FACET).positionManager(), _UNISWAP_V3_POSITION_MANAGER);
        assertEq(IUniswapV3Facet(UNISWAP_V3_FACET).router(),          _UNISWAP_V3_ROUTER);
    }

    function test_postDeployState_facetIntegrations() external {
        assertEq(beacon.integrations().length, 9);

        _assertIntegration("AAVE_FACET",           AAVE_FACET,           6);
        _assertIntegration("CURVE_FACET",          CURVE_FACET,          9);
        _assertIntegration("ERC4626_FACET",        ERC4626_FACET,        8);
        _assertIntegration("MERKL_FACET",          MERKL_FACET,          2);
        _assertIntegration("PENDLE_FACET",         PENDLE_FACET,         2);
        _assertIntegration("PSM3_FACET",           PSM3_FACET,           4);
        _assertIntegration("SPARK_VAULT_FACET",    SPARK_VAULT_FACET,    2);
        _assertIntegration("TRANSFER_ASSET_FACET", TRANSFER_ASSET_FACET, 2);
        _assertIntegration("UNISWAP_V3_FACET",     UNISWAP_V3_FACET,     16);
    }

    function test_postDeployEvents_facetIntegrationSet() external {
        // Expect 9 IntegrationSet events from BEACON, in deploy-script order.
        VmSafe.EthGetLogs[] memory logs = _getEvents(
            block.chainid,
            BEACON,
            IEnumerableIntegrations.IntegrationSet.selector
        );

        assertEq(logs.length, 9);

        _assertIntegrationSetLog(logs[0], "AAVE_FACET",           AAVE_FACET,           6);
        _assertIntegrationSetLog(logs[1], "CURVE_FACET",          CURVE_FACET,          9);
        _assertIntegrationSetLog(logs[2], "ERC4626_FACET",        ERC4626_FACET,        8);
        _assertIntegrationSetLog(logs[3], "MERKL_FACET",          MERKL_FACET,          2);
        _assertIntegrationSetLog(logs[4], "PENDLE_FACET",         PENDLE_FACET,         2);
        _assertIntegrationSetLog(logs[5], "PSM3_FACET",           PSM3_FACET,           4);
        _assertIntegrationSetLog(logs[6], "SPARK_VAULT_FACET",    SPARK_VAULT_FACET,    2);
        _assertIntegrationSetLog(logs[7], "TRANSFER_ASSET_FACET", TRANSFER_ASSET_FACET, 2);
        _assertIntegrationSetLog(logs[8], "UNISWAP_V3_FACET",     UNISWAP_V3_FACET,     16);
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
