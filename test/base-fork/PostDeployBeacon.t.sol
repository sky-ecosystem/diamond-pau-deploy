// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { VmSafe } from "../../lib/forge-std/src/Vm.sol";

import { IAccessControl } from "../../lib/diamond-pau/lib/openzeppelin-contracts/contracts/access/IAccessControl.sol";

import { IBeacon }                 from "../../lib/diamond-pau/src/interfaces/IBeacon.sol";
import { IEnumerableIntegrations } from "../../lib/diamond-pau/src/interfaces/IEnumerableIntegrations.sol";
import { Beacon }                  from "../../lib/diamond-pau/src/Beacon.sol";

import { PostDeployTestBase } from "../PostDeployTestBase.t.sol";

contract PostDeployBeaconTests is PostDeployTestBase {

    // Paste from script/output/8453/beacon-base-{env}-latest.json
    address internal constant ADMIN    = 0x0000000000000000000000000000000000000000;
    address internal constant BEACON   = 0x0000000000000000000000000000000000000000;
    address internal constant DEPLOYER = 0x0000000000000000000000000000000000000000;

    Beacon internal beacon;

    function setUp() public {
        vm.createSelectFork(getChain("base").rpcUrl, _getBlock());

        beacon = Beacon(BEACON);
    }

    function _getBlock() internal pure returns (uint256) {
        return 24684236; // After the Beacon deployment block.
    }

    function test_postDeployState() external {
        assertEq(beacon.hasRole(DEFAULT_ADMIN_ROLE, ADMIN),    true);
        assertEq(beacon.hasRole(DEFAULT_ADMIN_ROLE, DEPLOYER), false);

        assertEq(beacon.getRoleMemberCount(DEFAULT_ADMIN_ROLE), 1);
        assertEq(beacon.getRoleMember(DEFAULT_ADMIN_ROLE, 0),   ADMIN);

        assertEq(beacon.integrations().length,                        0);
        assertEq(beacon.supportsInterface(type(IBeacon).interfaceId), true);

        // Expect only 1 RoleGranted event (constructor _grantRole).

        VmSafe.EthGetLogs[] memory allLogs = _getEvents(block.chainid, BEACON, "");

        assertEq(allLogs.length, 1);

        assertEq(allLogs[0].topics[0],             IAccessControl.RoleGranted.selector);
        assertEq(allLogs[0].topics[1],             DEFAULT_ADMIN_ROLE);
        assertEq(_toAddress(allLogs[0].topics[2]), ADMIN);
        assertEq(_toAddress(allLogs[0].topics[3]), DEPLOYER);
    }

}
