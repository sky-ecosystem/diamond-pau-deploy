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

    bytes32 constant ALLOCATOR_ROLE       = keccak256("ALLOCATOR_ROLE");
    bytes32 constant ALLOCATOR_ADMIN_ROLE = keccak256("ALLOCATOR_ADMIN_ROLE");

    function run() external {
        string memory chain = vm.envOr("CHAIN", string("mainnet"));
        string memory env   = vm.envString("ENV");

        vm.createSelectFork(getChain(chain).rpcUrl);

        vm.setEnv("FOUNDRY_ROOT_CHAINID",             vm.toString(block.chainid));
        vm.setEnv("FOUNDRY_EXPORTS_OVERWRITE_LATEST", "true");

        string memory fileSlug = string(abi.encodePacked("pau-", chain, "-", env));
        string memory config   = ScriptTools.loadConfig(fileSlug);

        address admin          = config.readAddress(".admin");
        address allocator      = config.readAddress(".allocator");
        address allocatorAdmin = config.readAddress(".allocatorAdmin");
        address pauFactory     = config.readAddress(".pauFactory");

        console.log("Deploying PAU system...\n  Chain: %s\n  Env: %s", chain, env);

        vm.startBroadcast();

        address deployer = msg.sender;

        require(deployer != admin, "DeployPAU/deployer-must-differ-from-admin");

        // Step 1: Deploy AccessControls with deployer as temporary admin

        AccessControls accessControls = AccessControls(PAUFactory(pauFactory).deployAccessControls(deployer));

        console.log("AccessControls deployed at: ", address(accessControls));

        // Step 2: Deploy ALMProxy with deployer as temporary admin

        ALMProxy almProxy = ALMProxy(payable(PAUFactory(pauFactory).deployProxy(deployer)));

        console.log("ALMProxy deployed at: ", address(almProxy));

        // Step 3: Deploy RateLimits with deployer as temporary admin

        RateLimits rateLimits = RateLimits(PAUFactory(pauFactory).deployRateLimits(deployer));

        console.log("RateLimits deployed at: ", address(rateLimits));

        // Step 4: Deploy Controller with deployer as temporary admin

        Controller controller = Controller(payable(
            PAUFactory(pauFactory).deployController(
                address(accessControls),
                address(almProxy),
                address(rateLimits)
            ))
        );

        console.log("Controller deployed at: ", address(controller));

        // Step 5: Grant CONTROLLER role on ALMProxy and RateLimits to Controller

        almProxy.grantRole(almProxy.CONTROLLER(),     address(controller));
        rateLimits.grantRole(rateLimits.CONTROLLER(), address(controller));

        // Step 6: Grant roles to allocator and allocatorAdmin on AccessControls

        accessControls.grantRole(ALLOCATOR_ROLE,       allocator);
        accessControls.grantRole(ALLOCATOR_ADMIN_ROLE, allocatorAdmin);

        accessControls.setRoleAdmin(ALLOCATOR_ROLE, ALLOCATOR_ADMIN_ROLE);

        // Step 7: Transfer DEFAULT_ADMIN_ROLE to final admin and revoke from deployer.
        //         For AccessControls, ALMProxy, and RateLimits.

        accessControls.grantRole(accessControls.DEFAULT_ADMIN_ROLE(), admin);
        almProxy.grantRole(almProxy.DEFAULT_ADMIN_ROLE(),             admin);
        rateLimits.grantRole(rateLimits.DEFAULT_ADMIN_ROLE(),         admin);

        accessControls.revokeRole(accessControls.DEFAULT_ADMIN_ROLE(), deployer);
        almProxy.revokeRole(almProxy.DEFAULT_ADMIN_ROLE(),             deployer);
        rateLimits.revokeRole(rateLimits.DEFAULT_ADMIN_ROLE(),         deployer);

        console.log("Admin transferred to: ", admin);

        vm.stopBroadcast();

        // Step 8: Export addresses

        ScriptTools.exportContract(fileSlug, "accessControls", address(accessControls));
        ScriptTools.exportContract(fileSlug, "almProxy",       address(almProxy));
        ScriptTools.exportContract(fileSlug, "controller",     address(controller));
        ScriptTools.exportContract(fileSlug, "rateLimits",     address(rateLimits));

    }

}
