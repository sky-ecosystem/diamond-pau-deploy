// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { VmSafe } from "../../lib/forge-std/src/Vm.sol";

import { PAUFactory }  from "../../lib/diamond-pau/src/PAUFactory.sol";

import { PostDeployTestBase } from "../PostDeployTestBase.t.sol";

contract PostDeployPAUFactoryTests is PostDeployTestBase {

    // Paste from script/output/1/pau-factory-mainnet-{env}-latest.json
    address internal constant BEACON      = 0x9EA465978500399C6b4b9A356b14b00e6597e705;
    address internal constant PAU_FACTORY = 0xabd7925b6a72937FA38F56a2aA466f17BefFEe65;

    PAUFactory internal factory;

    function setUp() public {
        vm.createSelectFork(getChain("mainnet").rpcUrl, _getBlock());

        factory = PAUFactory(PAU_FACTORY);
    }

    function _getBlock() internal pure returns (uint256) {
        return 25143000; // May-21-2026 10:23:47 AM +UTC : After the PAUFactory deployment block.
    }

    function test_postDeployState() external {
        assertEq(factory.beacon(), BEACON);

        VmSafe.EthGetLogs[] memory allLogs = _getEvents(block.chainid, PAU_FACTORY, "");

        assertEq(allLogs.length, 0); // Factory has no roles or events at this stage.
    }

}
