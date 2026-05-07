// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { Script, stdJson, console } from "../lib/forge-std/src/Script.sol";

import { ScriptTools } from "../lib/dss-test/src/ScriptTools.sol";

import { AccessControls } from "../lib/diamond-pau/src/AccessControls.sol";
import { ALMProxy }       from "../lib/diamond-pau/src/ALMProxy.sol";
import { Controller }     from "../lib/diamond-pau/src/Controller.sol";
import { PAUFactory }     from "../lib/diamond-pau/src/PAUFactory.sol";
import { RateLimits }     from "../lib/diamond-pau/src/RateLimits.sol";

contract DeployPAU is Script {

    using stdJson for string;

    bytes32 constant ALLOCATOR_ROLE = keccak256("ALLOCATOR_ROLE");
    bytes32 constant FREEZER_ROLE   = keccak256("FREEZER_ROLE");

    function run() external {
        string memory chain = vm.envOr("CHAIN", string("mainnet"));
        string memory env   = vm.envString("ENV");

        vm.createSelectFork(getChain(chain).rpcUrl);

        vm.setEnv("FOUNDRY_ROOT_CHAINID",             vm.toString(block.chainid));
        vm.setEnv("FOUNDRY_EXPORTS_OVERWRITE_LATEST", "true");

        string memory fileSlug = string(abi.encodePacked("pau-", chain, "-", env));
        string memory config   = ScriptTools.loadConfig(fileSlug);

        address admin      = config.readAddress(".admin");
        address allocator  = config.readAddress(".allocator");
        address freezer    = config.readAddress(".freezer");
        address pauFactory = config.readAddress(".pauFactory");

        console.log("Deploying PAU system...\n  Chain: %s\n  Env: %s", chain, env);

        vm.startBroadcast();

        address deployer = msg.sender;

        require(deployer != admin, "DeployPAU/deployer-must-differ-from-admin");

        // Step 1: Deploy PAU system with deployer as temporary admin

        Controller controller = Controller(payable(PAUFactory(pauFactory).deploy(deployer)));

        console.log("Controller deployed at: ", address(controller));

        AccessControls accessControls = AccessControls(controller.accessControls());
        ALMProxy       almProxy       = ALMProxy(payable(controller.proxy()));
        RateLimits     rateLimits     = RateLimits(controller.rateLimits());

        // Step 2: Grant roles to relayer and freezer on AccessControls

        accessControls.grantRole(ALLOCATOR_ROLE, allocator);
        accessControls.grantRole(FREEZER_ROLE,   freezer);

        accessControls.setRoleRevoker(ALLOCATOR_ROLE, FREEZER_ROLE);

        // Step 3: Transfer DEFAULT_ADMIN_ROLE to final admin and revoke from deployer.
        //         For AccessControls, ALMProxy, and RateLimits.

        accessControls.grantRole(accessControls.DEFAULT_ADMIN_ROLE(), admin);
        almProxy.grantRole(almProxy.DEFAULT_ADMIN_ROLE(),             admin);
        rateLimits.grantRole(rateLimits.DEFAULT_ADMIN_ROLE(),         admin);

        accessControls.revokeRole(accessControls.DEFAULT_ADMIN_ROLE(), deployer);
        almProxy.revokeRole(almProxy.DEFAULT_ADMIN_ROLE(),             deployer);
        rateLimits.revokeRole(rateLimits.DEFAULT_ADMIN_ROLE(),         deployer);

        console.log("Admin transferred to: ", admin);

        vm.stopBroadcast();

        // Step 4: Export addresses

        ScriptTools.exportContract(fileSlug, "accessControls", address(accessControls));
        ScriptTools.exportContract(fileSlug, "almProxy",       address(almProxy));
        ScriptTools.exportContract(fileSlug, "controller",     address(controller));
        ScriptTools.exportContract(fileSlug, "rateLimits",     address(rateLimits));

    }

}
