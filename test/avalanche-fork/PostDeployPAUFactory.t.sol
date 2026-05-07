// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { VmSafe } from "../../lib/forge-std/src/Vm.sol";

import { PAUFactory }  from "../../lib/diamond-pau/src/PAUFactory.sol";

import { PostDeployTestBase } from "../PostDeployTestBase.t.sol";

contract PostDeployPAUFactoryTests is PostDeployTestBase {

    // Paste from script/output/43114/pau-factory-avalanche-{env}-latest.json
    address internal constant BEACON      = 0x0000000000000000000000000000000000000000;
    address internal constant PAU_FACTORY = 0x0000000000000000000000000000000000000000;

    PAUFactory internal factory;

    function setUp() public {
        vm.createSelectFork(getChain("avalanche").rpcUrl, _getBlock());

        factory = PAUFactory(PAU_FACTORY);
    }

    function _getBlock() internal pure returns (uint256) {
        return 24684236; // After the PAUFactory deployment block.
    }

    function test_postDeployState() external {
        assertEq(factory.beacon(), BEACON);

        VmSafe.EthGetLogs[] memory allLogs = _getEvents(block.chainid, PAU_FACTORY, "");

        assertEq(allLogs.length, 0); // Factory has no roles or events at this stage.
    }

}
