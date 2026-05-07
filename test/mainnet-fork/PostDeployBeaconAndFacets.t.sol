// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { VmSafe } from "../../lib/forge-std/src/Vm.sol";

import { IAccessControl } from "../../lib/diamond-pau/lib/openzeppelin-contracts/contracts/access/IAccessControl.sol";

import { Ethereum }                  from "../../lib/diamond-pau/lib/spark-address-registry/src/Ethereum.sol";
import { Ethereum as GroveEthereum } from "../../lib/diamond-pau/lib/grove-address-registry/src/Ethereum.sol";

import { IBeacon }                 from "../../lib/diamond-pau/src/interfaces/IBeacon.sol";
import { IEnumerableIntegrations } from "../../lib/diamond-pau/src/interfaces/IEnumerableIntegrations.sol";

import { Beacon } from "../../lib/diamond-pau/src/Beacon.sol";

import { ICCTPFacet }         from "../../lib/diamond-pau/src/facets/cctp/ICCTPFacet.sol";
import { IDAIUSDSFacet }      from "../../lib/diamond-pau/src/facets/dai-usds/IDAIUSDSFacet.sol";
import { IEthenaFacet }       from "../../lib/diamond-pau/src/facets/ethena/IEthenaFacet.sol";
import { IPendleFacet }       from "../../lib/diamond-pau/src/facets/pendle/IPendleFacet.sol";
import { IPSMFacet }          from "../../lib/diamond-pau/src/facets/psm/IPSMFacet.sol";
import { ISuperstateFacet }   from "../../lib/diamond-pau/src/facets/superstate/ISuperstateFacet.sol";
import { IUniswapV3Facet }    from "../../lib/diamond-pau/src/facets/uniswap-v3/IUniswapV3Facet.sol";
import { IUniswapV4Facet }    from "../../lib/diamond-pau/src/facets/uniswap-v4/IUniswapV4Facet.sol";
import { IUSDSFacet }         from "../../lib/diamond-pau/src/facets/usds/IUSDSFacet.sol";
import { IWEETHFacet }        from "../../lib/diamond-pau/src/facets/weeth/IWEETHFacet.sol";
import { IWrapProxyETHFacet } from "../../lib/diamond-pau/src/facets/wrap-proxy-eth/IWrapProxyETHFacet.sol";
import { IWSTETHFacet }       from "../../lib/diamond-pau/src/facets/wsteth/IWSTETHFacet.sol";

import { PostDeployTestBase } from "../PostDeployTestBase.t.sol";

contract PostDeployBeaconAndFacetsTests is PostDeployTestBase {

    // From the DeployBeaconAndFacetsMainnet script (mirror of registry constants used at deploy time).
    address internal constant _UNISWAP_V3_POSITION_MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address internal constant _UNISWAP_V3_ROUTER           = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address internal constant _PERMIT2                     = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address internal constant _UNISWAP_V4_POSITION_MANAGER = 0xbD216513d74C8cf14cf4747E6AaA6420FF64ee9e;
    address internal constant _UNISWAP_V4_ROUTER           = 0x66a9893cC07D91D95644AEDD05D03f95e1dBA8Af;

    // Paste from script/output/1/beacon-and-facets-mainnet-{env}-latest.json
    address internal constant DEPLOYER             = 0x0000000000000000000000000000000000000000;
    address internal constant ADMIN                = 0x0000000000000000000000000000000000000000;
    address internal constant BEACON               = 0x0000000000000000000000000000000000000000;
    address internal constant AAVE_FACET           = 0x0000000000000000000000000000000000000000;
    address internal constant BASIN_FACET          = 0x0000000000000000000000000000000000000000;
    address internal constant CCTP_FACET           = 0x0000000000000000000000000000000000000000;
    address internal constant CENTRIFUGE_FACET     = 0x0000000000000000000000000000000000000000;
    address internal constant CURVE_FACET          = 0x0000000000000000000000000000000000000000;
    address internal constant DAIUSDS_FACET        = 0x0000000000000000000000000000000000000000;
    address internal constant ERC4626_FACET        = 0x0000000000000000000000000000000000000000;
    address internal constant ERC7540_FACET        = 0x0000000000000000000000000000000000000000;
    address internal constant ETHENA_FACET         = 0x0000000000000000000000000000000000000000;
    address internal constant FARM_FACET           = 0x0000000000000000000000000000000000000000;
    address internal constant LAYER_ZERO_FACET     = 0x0000000000000000000000000000000000000000;
    address internal constant MAPLE_FACET          = 0x0000000000000000000000000000000000000000;
    address internal constant MERKL_FACET          = 0x0000000000000000000000000000000000000000;
    address internal constant OTC_FACET            = 0x0000000000000000000000000000000000000000;
    address internal constant PENDLE_FACET         = 0x0000000000000000000000000000000000000000;
    address internal constant PSM_FACET            = 0x0000000000000000000000000000000000000000;
    address internal constant SPARK_VAULT_FACET    = 0x0000000000000000000000000000000000000000;
    address internal constant SUPERSTATE_FACET     = 0x0000000000000000000000000000000000000000;
    address internal constant TRANSFER_ASSET_FACET = 0x0000000000000000000000000000000000000000;
    address internal constant UNISWAP_V3_FACET     = 0x0000000000000000000000000000000000000000;
    address internal constant UNISWAP_V4_FACET     = 0x0000000000000000000000000000000000000000;
    address internal constant USDS_FACET           = 0x0000000000000000000000000000000000000000;
    address internal constant WEETH_FACET          = 0x0000000000000000000000000000000000000000;
    address internal constant WRAP_PROXY_ETH_FACET = 0x0000000000000000000000000000000000000000;
    address internal constant WSTETH_FACET         = 0x0000000000000000000000000000000000000000;

    Beacon internal beacon;

    function setUp() public {
        vm.createSelectFork(getChain("mainnet").rpcUrl, _getBlock());

        beacon = Beacon(BEACON);
    }

    function _getBlock() internal pure returns (uint256) {
        return 24684236; // After the BeaconAndFacets deployment block.
    }

    function test_postDeployState_beacon() external {
        // Final admin holds the role; deployer was revoked in the script.
        assertEq(beacon.hasRole(DEFAULT_ADMIN_ROLE, ADMIN),    true);
        assertEq(beacon.hasRole(DEFAULT_ADMIN_ROLE, DEPLOYER), false);

        assertEq(beacon.getRoleMemberCount(DEFAULT_ADMIN_ROLE), 1);
        assertEq(beacon.getRoleMember(DEFAULT_ADMIN_ROLE, 0),   ADMIN);

        assertEq(beacon.supportsInterface(type(IBeacon).interfaceId), true);
    }

    function test_postDeployState_facetConstructorArgs() external {
        // CCTPFacet constructor args.
        assertEq(ICCTPFacet(CCTP_FACET).cctp(), Ethereum.CCTP_TOKEN_MESSENGER);
        assertEq(ICCTPFacet(CCTP_FACET).usdc(), Ethereum.USDC);

        // DAIUSDSFacet constructor args.
        assertEq(IDAIUSDSFacet(DAIUSDS_FACET).dai(),     Ethereum.DAI);
        assertEq(IDAIUSDSFacet(DAIUSDS_FACET).daiUSDS(), Ethereum.DAI_USDS);
        assertEq(IDAIUSDSFacet(DAIUSDS_FACET).usds(),    Ethereum.USDS);

        // EthenaFacet constructor args.
        assertEq(IEthenaFacet(ETHENA_FACET).minter(), Ethereum.ETHENA_MINTER);
        assertEq(IEthenaFacet(ETHENA_FACET).susde(),  Ethereum.SUSDE);
        assertEq(IEthenaFacet(ETHENA_FACET).usdc(),   Ethereum.USDC);
        assertEq(IEthenaFacet(ETHENA_FACET).usde(),   Ethereum.USDE);

        // PendleFacet constructor args.
        assertEq(IPendleFacet(PENDLE_FACET).router(), GroveEthereum.PENDLE_ROUTER);

        // PSMFacet constructor args.
        assertEq(IPSMFacet(PSM_FACET).dai(),     Ethereum.DAI);
        assertEq(IPSMFacet(PSM_FACET).daiUSDS(), Ethereum.DAI_USDS);
        assertEq(IPSMFacet(PSM_FACET).psm(),     Ethereum.PSM);
        assertEq(IPSMFacet(PSM_FACET).usdc(),    Ethereum.USDC);
        assertEq(IPSMFacet(PSM_FACET).usds(),    Ethereum.USDS);

        // SuperstateFacet constructor args.
        assertEq(ISuperstateFacet(SUPERSTATE_FACET).usdc(), Ethereum.USDC);
        assertEq(ISuperstateFacet(SUPERSTATE_FACET).ustb(), Ethereum.USTB);

        // UniswapV3Facet constructor args.
        assertEq(IUniswapV3Facet(UNISWAP_V3_FACET).positionManager(), _UNISWAP_V3_POSITION_MANAGER);
        assertEq(IUniswapV3Facet(UNISWAP_V3_FACET).router(),          _UNISWAP_V3_ROUTER);

        // UniswapV4Facet constructor args.
        assertEq(IUniswapV4Facet(UNISWAP_V4_FACET).permit2(),         _PERMIT2);
        assertEq(IUniswapV4Facet(UNISWAP_V4_FACET).positionManager(), _UNISWAP_V4_POSITION_MANAGER);
        assertEq(IUniswapV4Facet(UNISWAP_V4_FACET).router(),          _UNISWAP_V4_ROUTER);

        // USDSFacet constructor args.
        assertEq(IUSDSFacet(USDS_FACET).usds(), Ethereum.USDS);

        // WEETHFacet constructor args.
        assertEq(IWEETHFacet(WEETH_FACET).weeth(), Ethereum.WEETH);
        assertEq(IWEETHFacet(WEETH_FACET).weth(),  Ethereum.WETH);

        // WrapProxyETHFacet constructor args.
        assertEq(IWrapProxyETHFacet(WRAP_PROXY_ETH_FACET).weth(), Ethereum.WETH);

        // WSTETHFacet constructor args.
        assertEq(IWSTETHFacet(WSTETH_FACET).weth(),          Ethereum.WETH);
        assertEq(IWSTETHFacet(WSTETH_FACET).withdrawQueue(), Ethereum.WSTETH_WITHDRAW_QUEUE);
        assertEq(IWSTETHFacet(WSTETH_FACET).wsteth(),        Ethereum.WSTETH);
    }

    function test_postDeployState_facetIntegrations() external {
        assertEq(beacon.integrations().length, 25);

        _assertIntegration("AAVE_FACET",           AAVE_FACET,           6);
        _assertIntegration("BASIN_FACET",          BASIN_FACET,          4);
        _assertIntegration("CCTP_FACET",           CCTP_FACET,           8);
        _assertIntegration("CENTRIFUGE_FACET",     CENTRIFUGE_FACET,     12);
        _assertIntegration("CURVE_FACET",          CURVE_FACET,          9);
        _assertIntegration("DAIUSDS_FACET",        DAIUSDS_FACET,        2);
        _assertIntegration("ERC4626_FACET",        ERC4626_FACET,        8);
        _assertIntegration("ERC7540_FACET",        ERC7540_FACET,        8);
        _assertIntegration("USDE_FACET",           ETHENA_FACET,         13);
        _assertIntegration("FARM_FACET",           FARM_FACET,           6);
        _assertIntegration("LAYER_ZERO_FACET",     LAYER_ZERO_FACET,     4);
        _assertIntegration("MAPLE_FACET",          MAPLE_FACET,          4);
        _assertIntegration("MERKL_FACET",          MERKL_FACET,          2);
        _assertIntegration("OTC_FACET",            OTC_FACET,            14);
        _assertIntegration("PENDLE_FACET",         PENDLE_FACET,         2);
        _assertIntegration("PSM_FACET",            PSM_FACET,            4);
        _assertIntegration("SPARK_VAULT_FACET",    SPARK_VAULT_FACET,    2);
        _assertIntegration("SUPERSTATE_FACET",     SUPERSTATE_FACET,     2);
        _assertIntegration("TRANSFER_ASSET_FACET", TRANSFER_ASSET_FACET, 2);
        _assertIntegration("UNISWAP_V3_FACET",     UNISWAP_V3_FACET,     16);
        _assertIntegration("UNISWAP_V4_FACET",     UNISWAP_V4_FACET,     12);
        _assertIntegration("USDS_FACET",           USDS_FACET,           6);
        _assertIntegration("WEETH_FACET",          WEETH_FACET,          6);
        _assertIntegration("WRAP_PROXY_ETH_FACET", WRAP_PROXY_ETH_FACET, 2);
        _assertIntegration("WSTETH_FACET",         WSTETH_FACET,         6);
    }

    function test_postDeployEvents() external {
        // Expect 28 events on Beacon: 1 RoleGranted (constructor) + 25 IntegrationSet
        // + 1 RoleGranted (final admin) + 1 RoleRevoked (deployer self-revoked).
        VmSafe.EthGetLogs[] memory allLogs = _getEvents(block.chainid, BEACON, "");

        assertEq(allLogs.length, 28);

        // [0] Constructor: RoleGranted(DEFAULT_ADMIN_ROLE, DEPLOYER, DEPLOYER)
        assertEq(allLogs[0].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(allLogs[0].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(allLogs[0].topics[2]), DEPLOYER);
        assertEq(_toAddress(allLogs[0].topics[3]), DEPLOYER);

        // [1..25] IntegrationSet x 25, in deploy-script order.
        _assertIntegrationSetLog(allLogs[1],  "AAVE_FACET",           AAVE_FACET,           6);
        _assertIntegrationSetLog(allLogs[2],  "BASIN_FACET",          BASIN_FACET,          4);
        _assertIntegrationSetLog(allLogs[3],  "CCTP_FACET",           CCTP_FACET,           8);
        _assertIntegrationSetLog(allLogs[4],  "CENTRIFUGE_FACET",     CENTRIFUGE_FACET,     12);
        _assertIntegrationSetLog(allLogs[5],  "CURVE_FACET",          CURVE_FACET,          9);
        _assertIntegrationSetLog(allLogs[6],  "DAIUSDS_FACET",        DAIUSDS_FACET,        2);
        _assertIntegrationSetLog(allLogs[7],  "ERC4626_FACET",        ERC4626_FACET,        8);
        _assertIntegrationSetLog(allLogs[8],  "ERC7540_FACET",        ERC7540_FACET,        8);
        _assertIntegrationSetLog(allLogs[9],  "USDE_FACET",           ETHENA_FACET,         13);
        _assertIntegrationSetLog(allLogs[10], "FARM_FACET",           FARM_FACET,           6);
        _assertIntegrationSetLog(allLogs[11], "LAYER_ZERO_FACET",     LAYER_ZERO_FACET,     4);
        _assertIntegrationSetLog(allLogs[12], "MAPLE_FACET",          MAPLE_FACET,          4);
        _assertIntegrationSetLog(allLogs[13], "MERKL_FACET",          MERKL_FACET,          2);
        _assertIntegrationSetLog(allLogs[14], "OTC_FACET",            OTC_FACET,            14);
        _assertIntegrationSetLog(allLogs[15], "PENDLE_FACET",         PENDLE_FACET,         2);
        _assertIntegrationSetLog(allLogs[16], "PSM_FACET",            PSM_FACET,            4);
        _assertIntegrationSetLog(allLogs[17], "SPARK_VAULT_FACET",    SPARK_VAULT_FACET,    2);
        _assertIntegrationSetLog(allLogs[18], "SUPERSTATE_FACET",     SUPERSTATE_FACET,     2);
        _assertIntegrationSetLog(allLogs[19], "TRANSFER_ASSET_FACET", TRANSFER_ASSET_FACET, 2);
        _assertIntegrationSetLog(allLogs[20], "UNISWAP_V3_FACET",     UNISWAP_V3_FACET,     16);
        _assertIntegrationSetLog(allLogs[21], "UNISWAP_V4_FACET",     UNISWAP_V4_FACET,     12);
        _assertIntegrationSetLog(allLogs[22], "USDS_FACET",           USDS_FACET,           6);
        _assertIntegrationSetLog(allLogs[23], "WEETH_FACET",          WEETH_FACET,          6);
        _assertIntegrationSetLog(allLogs[24], "WRAP_PROXY_ETH_FACET", WRAP_PROXY_ETH_FACET, 2);
        _assertIntegrationSetLog(allLogs[25], "WSTETH_FACET",         WSTETH_FACET,         6);

        // [26] Admin transfer: RoleGranted(DEFAULT_ADMIN_ROLE, ADMIN, DEPLOYER)
        assertEq(allLogs[26].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(allLogs[26].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(allLogs[26].topics[2]), ADMIN);
        assertEq(_toAddress(allLogs[26].topics[3]), DEPLOYER);

        // [27] Deployer self-revoke: RoleRevoked(DEFAULT_ADMIN_ROLE, DEPLOYER, DEPLOYER)
        assertEq(allLogs[27].topics[0],             IAccessControl.RoleRevoked.selector);
        assertEq(allLogs[27].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(allLogs[27].topics[2]), DEPLOYER);
        assertEq(_toAddress(allLogs[27].topics[3]), DEPLOYER);
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
