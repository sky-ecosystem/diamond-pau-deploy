// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { Script, stdJson, console } from "../lib/forge-std/src/Script.sol";

import { ScriptTools } from "../lib/dss-test/src/ScriptTools.sol";

import { Beacon } from "../lib/diamond-pau/src/Beacon.sol";

contract DeployBeacon is Script {

    using stdJson for string;

    function run() external {
        string memory chain = vm.envOr("CHAIN", string("mainnet"));
        string memory env   = vm.envString("ENV");

        vm.createSelectFork(getChain(chain).rpcUrl);

        vm.setEnv("FOUNDRY_ROOT_CHAINID",             vm.toString(block.chainid));
        vm.setEnv("FOUNDRY_EXPORTS_OVERWRITE_LATEST", "true");

        string memory fileSlug = string(abi.encodePacked("beacon-", chain, "-", env));
        string memory config   = ScriptTools.loadConfig(fileSlug);

        address admin = config.readAddress(".admin");

        console.log("Deploying PAU beacon...\n  Chain: %s\n  Env: %s", chain, env);

        vm.startBroadcast();

        address deployer = msg.sender;

        require(deployer != admin, "DeployBeacon/deployer-must-differ-from-admin");

        // Step 1: Deploy PAU beacon

        address beacon = address(new Beacon(admin));

        console.log("PAU beacon deployed at: ", beacon);

        vm.stopBroadcast();

        // Step 2: Export addresses

        ScriptTools.exportContract(fileSlug, "beacon", beacon);

    }

}
