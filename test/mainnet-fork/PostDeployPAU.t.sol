// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { VmSafe } from "../../lib/forge-std/src/Vm.sol";

import { IAccessControl } from "../../lib/diamond-pau/lib/openzeppelin-contracts/contracts/access/IAccessControl.sol";
import { Initializable }  from "../../lib/diamond-pau/lib/oz-upgradeable/contracts/proxy/utils/Initializable.sol";

import { IPAUFactory } from "../../lib/diamond-pau/src/interfaces/IPAUFactory.sol";

import { AccessControls } from "../../lib/diamond-pau/src/AccessControls.sol";
import { ALMProxy }       from "../../lib/diamond-pau/src/ALMProxy.sol";
import { Controller }     from "../../lib/diamond-pau/src/Controller.sol";
import { PAUFactory }     from "../../lib/diamond-pau/src/PAUFactory.sol";
import { RateLimits }     from "../../lib/diamond-pau/src/RateLimits.sol";

import { PostDeployTestBase } from "../PostDeployTestBase.t.sol";

contract PostDeployPAUTests is PostDeployTestBase {

    // Paste from script/output/1/pau-mainnet-{env}-latest.json + the PAUFactory output
    address internal constant ACCESS_CONTROLS = 0x190451a957bB48675Da9376c242449B366aB42A7;
    address internal constant ADMIN           = 0x3300f198988e4C9C63F75dF86De36421f06af8c4;
    address internal constant ALLOCATOR       = 0x8a25A24EDE9482C4Fc0738F99611BE58F1c839AB;
    address internal constant ALLOCATOR_ADMIN = 0x90D8c80C028B4C09C0d8dcAab9bbB057F0513431;
    address internal constant ALM_PROXY       = 0xC0060BB5d333C1F2D3159058AE3223D4FD73abe4;
    address internal constant CONTROLLER      = 0x4A412f032536F6c4139F24b813872f8A44CF7148;
    address internal constant DEPLOYER        = 0x1ca4ECaF0E13ca833c80dA835DEEa15e1684361d;
    address internal constant PAU_FACTORY     = 0xabd7925b6a72937FA38F56a2aA466f17BefFEe65;
    address internal constant RATE_LIMITS     = 0xC9DEa685709d154CA1218BeE1d409b3E44F9Cb26;

    AccessControls internal accessControls;
    ALMProxy       internal almProxy;
    Controller     internal controller;
    PAUFactory     internal factory;
    RateLimits     internal rateLimits;

    function setUp() public {
        vm.createSelectFork(getChain("mainnet").rpcUrl, _getBlock());

        accessControls = AccessControls(ACCESS_CONTROLS);
        almProxy       = ALMProxy(payable(ALM_PROXY));
        controller     = Controller(payable(CONTROLLER));
        factory        = PAUFactory(PAU_FACTORY);
        rateLimits     = RateLimits(RATE_LIMITS);
    }

    function _getBlock() internal pure returns (uint256) {
        return 25143126; // May-21-2026 10:49:11 AM +UTC : After the PAU deployment block.
    }

    function test_postDeployState() external view {
        // Controller initializes with the correct state.
        assertEq(controller.accessControls(), ACCESS_CONTROLS);
        assertEq(controller.beacon(),         factory.beacon());
        assertEq(controller.proxy(),          ALM_PROXY);
        assertEq(controller.rateLimits(),     RATE_LIMITS);

        // ALMProxy/RateLimits roles
        assertEq(almProxy.hasRole(DEFAULT_ADMIN_ROLE, ADMIN),       true);
        assertEq(almProxy.hasRole(CONTROLLER_ROLE,    CONTROLLER),  true);

        assertEq(rateLimits.hasRole(DEFAULT_ADMIN_ROLE, ADMIN),       true);
        assertEq(rateLimits.hasRole(CONTROLLER_ROLE,    CONTROLLER),  true);

        // AccessControls roles
        assertEq(accessControls.hasRole(ALLOCATOR_ROLE,       ALLOCATOR),       true);
        assertEq(accessControls.hasRole(ALLOCATOR_ADMIN_ROLE, ALLOCATOR_ADMIN), true);
        assertEq(accessControls.hasRole(DEFAULT_ADMIN_ROLE,   ADMIN),           true);

        assertEq(accessControls.getRoleMemberCount(DEFAULT_ADMIN_ROLE),   1);
        assertEq(accessControls.getRoleMemberCount(ALLOCATOR_ROLE),       1);
        assertEq(accessControls.getRoleMemberCount(ALLOCATOR_ADMIN_ROLE), 1);

        assertEq(accessControls.getRoleAdmin(ALLOCATOR_ROLE), ALLOCATOR_ADMIN_ROLE); // via setRoleAdmin.

        // DEPLOYER/Factory has no roles on AccessControls, ALMProxy, or RateLimits.
        assertEq(accessControls.hasRole(ALLOCATOR_ROLE,       DEPLOYER), false);
        assertEq(accessControls.hasRole(DEFAULT_ADMIN_ROLE,   DEPLOYER), false);
        assertEq(accessControls.hasRole(ALLOCATOR_ADMIN_ROLE, DEPLOYER), false);
        assertEq(almProxy.hasRole(CONTROLLER_ROLE,            DEPLOYER), false);
        assertEq(almProxy.hasRole(DEFAULT_ADMIN_ROLE,         DEPLOYER), false);
        assertEq(rateLimits.hasRole(CONTROLLER_ROLE,          DEPLOYER), false);
        assertEq(rateLimits.hasRole(DEFAULT_ADMIN_ROLE,       DEPLOYER), false);

        assertEq(accessControls.hasRole(ALLOCATOR_ROLE,       PAU_FACTORY), false);
        assertEq(accessControls.hasRole(DEFAULT_ADMIN_ROLE,   PAU_FACTORY), false);
        assertEq(accessControls.hasRole(ALLOCATOR_ADMIN_ROLE, PAU_FACTORY), false);
        assertEq(almProxy.hasRole(CONTROLLER_ROLE,            PAU_FACTORY), false);
        assertEq(almProxy.hasRole(DEFAULT_ADMIN_ROLE,         PAU_FACTORY), false);
        assertEq(rateLimits.hasRole(CONTROLLER_ROLE,          PAU_FACTORY), false);
        assertEq(rateLimits.hasRole(DEFAULT_ADMIN_ROLE,       PAU_FACTORY), false);
    }

    function test_postDeployEvents() external {
       /*******************************************************************************************/
       /*** PAUFactory events                                                                   ***/
       /*******************************************************************************************/

        // PAUFactory emits only one event: PAUDeployed.
        VmSafe.EthGetLogs[] memory factoryAllLogs = _getEvents(block.chainid, PAU_FACTORY, "");

        assertEq(factoryAllLogs.length,                   1);
        assertEq(factoryAllLogs[0].topics[0],             IPAUFactory.PAUDeployed.selector);
        assertEq(_toAddress(factoryAllLogs[0].topics[1]), DEPLOYER);
        assertEq(_toAddress(factoryAllLogs[0].topics[2]), CONTROLLER);

        (
            address accessControls_,
            address almProxy_,
            address rateLimits_
        ) = abi.decode(factoryAllLogs[0].data, (address, address, address));

        assertEq(accessControls_, ACCESS_CONTROLS);
        assertEq(almProxy_,       ALM_PROXY);
        assertEq(rateLimits_,     RATE_LIMITS);


       /*******************************************************************************************/
       /*** Controller events                                                                   ***/
       /*******************************************************************************************/

        // Controller emits no events on construction or initialization.

        VmSafe.EthGetLogs[] memory controllerAllLogs = _getEvents(block.chainid, CONTROLLER, "");

        assertEq(controllerAllLogs.length, 1);

        // Initialized(1) from PAUFactory.deploy.
        assertEq(controllerAllLogs[0].topics[0], Initializable.Initialized.selector);
        assertEq(controllerAllLogs[0].data,      abi.encode(uint64(1)));

       /*******************************************************************************************/
       /*** AccessControls events                                                               ***/
       /*******************************************************************************************/

        VmSafe.EthGetLogs[] memory accessControlsAllLogs = _getEvents(block.chainid, ACCESS_CONTROLS, "");

        assertEq(accessControlsAllLogs.length, 6);

        // RoleGranted(DEFAULT_ADMIN_ROLE, DEPLOYER, PAU_FACTORY) from PAUFactory.deploy.
        assertEq(accessControlsAllLogs[0].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(accessControlsAllLogs[0].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(accessControlsAllLogs[0].topics[2]), DEPLOYER);
        assertEq(_toAddress(accessControlsAllLogs[0].topics[3]), PAU_FACTORY);

        // RoleGranted(ALLOCATOR_ROLE, ALLOCATOR, DEPLOYER) from DeployPAU.
        assertEq(accessControlsAllLogs[1].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(accessControlsAllLogs[1].topics[1],             ALLOCATOR_ROLE);
        assertEq(_toAddress(accessControlsAllLogs[1].topics[2]), ALLOCATOR);
        assertEq(_toAddress(accessControlsAllLogs[1].topics[3]), DEPLOYER);

        // RoleGranted(ALLOCATOR_ADMIN_ROLE, ALLOCATOR_ADMIN, DEPLOYER) from DeployPAU.
        assertEq(accessControlsAllLogs[2].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(accessControlsAllLogs[2].topics[1],             ALLOCATOR_ADMIN_ROLE);
        assertEq(_toAddress(accessControlsAllLogs[2].topics[2]), ALLOCATOR_ADMIN);
        assertEq(_toAddress(accessControlsAllLogs[2].topics[3]), DEPLOYER);

        // RoleAdminChanged(ALLOCATOR_ROLE, DEFAULT_ADMIN_ROLE, ALLOCATOR_ADMIN_ROLE) from DeployPAU.
        // From AccessControls.setRoleAdmin.
        assertEq(accessControlsAllLogs[3].topics[0], IAccessControl.RoleAdminChanged.selector);
        assertEq(accessControlsAllLogs[3].topics[1], ALLOCATOR_ROLE);
        assertEq(accessControlsAllLogs[3].topics[2], DEFAULT_ADMIN_ROLE);
        assertEq(accessControlsAllLogs[3].topics[3], ALLOCATOR_ADMIN_ROLE);

        // RoleGranted(DEFAULT_ADMIN_ROLE, ADMIN, DEPLOYER) from DeployPAU.
        // Role transfers from deployer to admin.
        assertEq(accessControlsAllLogs[4].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(accessControlsAllLogs[4].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(accessControlsAllLogs[4].topics[2]), ADMIN);
        assertEq(_toAddress(accessControlsAllLogs[4].topics[3]), DEPLOYER);

        // RoleRevoked(DEFAULT_ADMIN_ROLE, DEPLOYER, DEPLOYER) from DeployPAU.
        // Role revoked from deployer.
        assertEq(accessControlsAllLogs[5].topics[0],             IAccessControl.RoleRevoked.selector);
        assertEq(accessControlsAllLogs[5].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(accessControlsAllLogs[5].topics[2]), DEPLOYER);
        assertEq(_toAddress(accessControlsAllLogs[5].topics[3]), DEPLOYER);


       /*******************************************************************************************/
       /*** ALMProxy events                                                                     ***/
       /*******************************************************************************************/

        VmSafe.EthGetLogs[] memory almProxyAllLogs = _getEvents(block.chainid, ALM_PROXY, "");

        assertEq(almProxyAllLogs.length, 6);

        // RoleGranted(DEFAULT_ADMIN_ROLE, PAU_FACTORY, PAU_FACTORY) from PAUFactory.deploy.
        assertEq(almProxyAllLogs[0].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(almProxyAllLogs[0].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(almProxyAllLogs[0].topics[2]), PAU_FACTORY);
        assertEq(_toAddress(almProxyAllLogs[0].topics[3]), PAU_FACTORY);

        // RoleGranted(CONTROLLER_ROLE, CONTROLLER, PAU_FACTORY) from PAUFactory.deploy.
        assertEq(almProxyAllLogs[1].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(almProxyAllLogs[1].topics[1],             CONTROLLER_ROLE);
        assertEq(_toAddress(almProxyAllLogs[1].topics[2]), CONTROLLER);
        assertEq(_toAddress(almProxyAllLogs[1].topics[3]), PAU_FACTORY);

        // RoleGranted(DEFAULT_ADMIN_ROLE, DEPLOYER, PAU_FACTORY) from PAUFactory.deploy.
        // Role granted to deployer from factory.
        assertEq(almProxyAllLogs[2].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(almProxyAllLogs[2].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(almProxyAllLogs[2].topics[2]), DEPLOYER);
        assertEq(_toAddress(almProxyAllLogs[2].topics[3]), PAU_FACTORY);

        // RoleRevoked(DEFAULT_ADMIN_ROLE, PAU_FACTORY, PAU_FACTORY) from PAUFactory.deploy.
        // Role revoked from factory.
        assertEq(almProxyAllLogs[3].topics[0],             IAccessControl.RoleRevoked.selector);
        assertEq(almProxyAllLogs[3].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(almProxyAllLogs[3].topics[2]), PAU_FACTORY);
        assertEq(_toAddress(almProxyAllLogs[3].topics[3]), PAU_FACTORY);

        // RoleGranted(DEFAULT_ADMIN_ROLE, ADMIN, DEPLOYER) from DeployPAU.
        // Role granted to admin from deployer.
        assertEq(almProxyAllLogs[4].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(almProxyAllLogs[4].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(almProxyAllLogs[4].topics[2]), ADMIN);
        assertEq(_toAddress(almProxyAllLogs[4].topics[3]), DEPLOYER);

        // RoleRevoked(DEFAULT_ADMIN_ROLE, DEPLOYER, DEPLOYER) from DeployPAU.
        // Role revoked from deployer.
        assertEq(almProxyAllLogs[5].topics[0],             IAccessControl.RoleRevoked.selector);
        assertEq(almProxyAllLogs[5].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(almProxyAllLogs[5].topics[2]), DEPLOYER);
        assertEq(_toAddress(almProxyAllLogs[5].topics[3]), DEPLOYER);

       /*******************************************************************************************/
       /*** RateLimits events                                                                   ***/
       /*******************************************************************************************/

        VmSafe.EthGetLogs[] memory rateLimitsAllLogs = _getEvents(block.chainid, RATE_LIMITS, "");

        assertEq(rateLimitsAllLogs.length, 6);

        // RoleGranted(DEFAULT_ADMIN_ROLE, PAU_FACTORY, PAU_FACTORY) from PAUFactory.deploy.
        assertEq(rateLimitsAllLogs[0].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(rateLimitsAllLogs[0].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(rateLimitsAllLogs[0].topics[2]), PAU_FACTORY);
        assertEq(_toAddress(rateLimitsAllLogs[0].topics[3]), PAU_FACTORY);

        // RoleGranted(CONTROLLER_ROLE, CONTROLLER, PAU_FACTORY) from PAUFactory.deploy.
        assertEq(rateLimitsAllLogs[1].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(rateLimitsAllLogs[1].topics[1],             CONTROLLER_ROLE);
        assertEq(_toAddress(rateLimitsAllLogs[1].topics[2]), CONTROLLER);
        assertEq(_toAddress(rateLimitsAllLogs[1].topics[3]), PAU_FACTORY);

        // RoleGranted(DEFAULT_ADMIN_ROLE, DEPLOYER, PAU_FACTORY) from PAUFactory.deploy.
        // Role granted to deployer from factory.
        assertEq(rateLimitsAllLogs[2].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(rateLimitsAllLogs[2].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(rateLimitsAllLogs[2].topics[2]), DEPLOYER);
        assertEq(_toAddress(rateLimitsAllLogs[2].topics[3]), PAU_FACTORY);

        // RoleRevoked(DEFAULT_ADMIN_ROLE, PAU_FACTORY, PAU_FACTORY) from PAUFactory.deploy.
        // Role revoked from factory.
        assertEq(rateLimitsAllLogs[3].topics[0],             IAccessControl.RoleRevoked.selector);
        assertEq(rateLimitsAllLogs[3].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(rateLimitsAllLogs[3].topics[2]), PAU_FACTORY);
        assertEq(_toAddress(rateLimitsAllLogs[3].topics[3]), PAU_FACTORY);

        // RoleGranted(DEFAULT_ADMIN_ROLE, ADMIN, DEPLOYER) from DeployPAU.
        // Role granted to admin from deployer.
        assertEq(rateLimitsAllLogs[4].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(rateLimitsAllLogs[4].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(rateLimitsAllLogs[4].topics[2]), ADMIN);
        assertEq(_toAddress(rateLimitsAllLogs[4].topics[3]), DEPLOYER);

        // RoleRevoked(DEFAULT_ADMIN_ROLE, DEPLOYER, DEPLOYER) from DeployPAU.
        // Role revoked from deployer.
        assertEq(rateLimitsAllLogs[5].topics[0],             IAccessControl.RoleRevoked.selector);
        assertEq(rateLimitsAllLogs[5].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(rateLimitsAllLogs[5].topics[2]), DEPLOYER);
        assertEq(_toAddress(rateLimitsAllLogs[5].topics[3]), DEPLOYER);
    }

}
