// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { Script, stdJson, console } from "../lib/forge-std/src/Script.sol";

import { ScriptTools } from "../lib/dss-test/src/ScriptTools.sol";

import { Ethereum }                  from "../lib/diamond-pau/lib/spark-address-registry/src/Ethereum.sol";
import { Ethereum as GroveEthereum } from "../lib/diamond-pau/lib/grove-address-registry/src/Ethereum.sol";

import { AaveFacet }          from "../lib/diamond-pau/src/facets/aave/AaveFacet.sol";
import { BasinFacet }         from "../lib/diamond-pau/src/facets/basin/BasinFacet.sol";
import { CCTPFacet }          from "../lib/diamond-pau/src/facets/cctp/CCTPFacet.sol";
import { CentrifugeFacet }    from "../lib/diamond-pau/src/facets/centrifuge/CentrifugeFacet.sol";
import { CurveFacet }         from "../lib/diamond-pau/src/facets/curve/CurveFacet.sol";
import { DAIUSDSFacet }       from "../lib/diamond-pau/src/facets/dai-usds/DAIUSDSFacet.sol";
import { ERC4626Facet }       from "../lib/diamond-pau/src/facets/erc4626/ERC4626Facet.sol";
import { ERC7540Facet }       from "../lib/diamond-pau/src/facets/erc7540/ERC7540Facet.sol";
import { EthenaFacet }        from "../lib/diamond-pau/src/facets/ethena/EthenaFacet.sol";
import { FarmFacet }          from "../lib/diamond-pau/src/facets/farm/FarmFacet.sol";
import { LayerZeroFacet }     from "../lib/diamond-pau/src/facets/layer-zero/LayerZeroFacet.sol";
import { MapleFacet }         from "../lib/diamond-pau/src/facets/maple/MapleFacet.sol";
import { MerklFacet }         from "../lib/diamond-pau/src/facets/merkl/MerklFacet.sol";
import { OTCFacet }           from "../lib/diamond-pau/src/facets/otc/OTCFacet.sol";
import { PendleFacet }        from "../lib/diamond-pau/src/facets/pendle/PendleFacet.sol";
import { PSMFacet }           from "../lib/diamond-pau/src/facets/psm/PSMFacet.sol";
import { SparkVaultFacet }    from "../lib/diamond-pau/src/facets/spark-vault/SparkVaultFacet.sol";
import { SuperstateFacet }    from "../lib/diamond-pau/src/facets/superstate/SuperstateFacet.sol";
import { TransferAssetFacet } from "../lib/diamond-pau/src/facets/transfer-asset/TransferAssetFacet.sol";
import { UniswapV3Facet }     from "../lib/diamond-pau/src/facets/uniswap-v3/UniswapV3Facet.sol";
import { UniswapV4Facet }     from "../lib/diamond-pau/src/facets/uniswap-v4/UniswapV4Facet.sol";
import { USDSFacet }          from "../lib/diamond-pau/src/facets/usds/USDSFacet.sol";
import { WEETHFacet }         from "../lib/diamond-pau/src/facets/weeth/WEETHFacet.sol";
import { WrapProxyETHFacet }  from "../lib/diamond-pau/src/facets/wrap-proxy-eth/WrapProxyETHFacet.sol";
import { WSTETHFacet }        from "../lib/diamond-pau/src/facets/wsteth/WSTETHFacet.sol";

import { IAaveFacet }          from "../lib/diamond-pau/src/facets/aave/IAaveFacet.sol";
import { IBasinFacet }         from "../lib/diamond-pau/src/facets/basin/IBasinFacet.sol";
import { ICCTPFacet }          from "../lib/diamond-pau/src/facets/cctp/ICCTPFacet.sol";
import { ICentrifugeFacet }    from "../lib/diamond-pau/src/facets/centrifuge/ICentrifugeFacet.sol";
import { ICurveFacet }         from "../lib/diamond-pau/src/facets/curve/ICurveFacet.sol";
import { IDAIUSDSFacet }       from "../lib/diamond-pau/src/facets/dai-usds/IDAIUSDSFacet.sol";
import { IERC4626Facet }       from "../lib/diamond-pau/src/facets/erc4626/IERC4626Facet.sol";
import { IERC7540Facet }       from "../lib/diamond-pau/src/facets/erc7540/IERC7540Facet.sol";
import { IEthenaFacet }        from "../lib/diamond-pau/src/facets/ethena/IEthenaFacet.sol";
import { IFarmFacet }          from "../lib/diamond-pau/src/facets/farm/IFarmFacet.sol";
import { ILayerZeroFacet }     from "../lib/diamond-pau/src/facets/layer-zero/ILayerZeroFacet.sol";
import { IMapleFacet }         from "../lib/diamond-pau/src/facets/maple/IMapleFacet.sol";
import { IMerklFacet }         from "../lib/diamond-pau/src/facets/merkl/IMerklFacet.sol";
import { IOTCFacet }           from "../lib/diamond-pau/src/facets/otc/IOTCFacet.sol";
import { IPendleFacet }        from "../lib/diamond-pau/src/facets/pendle/IPendleFacet.sol";
import { IPSMFacet }           from "../lib/diamond-pau/src/facets/psm/IPSMFacet.sol";
import { ISparkVaultFacet }    from "../lib/diamond-pau/src/facets/spark-vault/ISparkVaultFacet.sol";
import { ISuperstateFacet }    from "../lib/diamond-pau/src/facets/superstate/ISuperstateFacet.sol";
import { ITransferAssetFacet } from "../lib/diamond-pau/src/facets/transfer-asset/ITransferAssetFacet.sol";
import { IUniswapV3Facet }     from "../lib/diamond-pau/src/facets/uniswap-v3/IUniswapV3Facet.sol";
import { IUniswapV4Facet }     from "../lib/diamond-pau/src/facets/uniswap-v4/IUniswapV4Facet.sol";
import { IUSDSFacet }          from "../lib/diamond-pau/src/facets/usds/IUSDSFacet.sol";
import { IWEETHFacet }         from "../lib/diamond-pau/src/facets/weeth/IWEETHFacet.sol";
import { IWrapProxyETHFacet }  from "../lib/diamond-pau/src/facets/wrap-proxy-eth/IWrapProxyETHFacet.sol";
import { IWSTETHFacet }        from "../lib/diamond-pau/src/facets/wsteth/IWSTETHFacet.sol";

import { IFacet } from "../lib/diamond-pau/src/facets/IFacet.sol";

import { IEnumerableIntegrations as IEI } from "../lib/diamond-pau/src/interfaces/IEnumerableIntegrations.sol";

import { IMainnetControllerFull as IControllerFull } from "../lib/diamond-pau/test/interfaces/IMainnetControllerFull.sol";

import { Beacon } from "../lib/diamond-pau/src/Beacon.sol";

contract DeployBeaconAndFacetsMainnet is Script {

    using stdJson for string;

    /**********************************************************************************************/
    /*** Structs                                                                                ***/
    /**********************************************************************************************/

    struct MainnetFacetAddresses {
        address aaveFacet;
        address basinFacet;
        address cctpFacet;
        address centrifugeFacet;
        address curveFacet;
        address daiUSDSFacet;
        address erc4626Facet;
        address erc7540Facet;
        address ethenaFacet;
        address farmFacet;
        address layerZeroFacet;
        address mapleFacet;
        address merklFacet;
        address otcFacet;
        address pendleFacet;
        address psmFacet;
        address sparkVaultFacet;
        address superstateFacet;
        address transferAssetFacet;
        address uniswapV3Facet;
        address uniswapV4Facet;
        address usdsFacet;
        address weethFacet;
        address wrapProxyETHFacet;
        address wstethFacet;
    }

    /**********************************************************************************************/
    /*** Constants                                                                              ***/
    /**********************************************************************************************/

    // NOTE: From https://docs.uniswap.org/contracts/v3/reference/deployments/ethereum-deployments.
    address internal constant _UNISWAP_V3_POSITION_MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address internal constant _UNISWAP_V3_ROUTER           = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;

    // NOTE: From https://docs.uniswap.org/contracts/v4/deployments (Ethereum Mainnet).
    address internal constant _PERMIT2                     = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address internal constant _UNISWAP_V4_POSITION_MANAGER = 0xbD216513d74C8cf14cf4747E6AaA6420FF64ee9e;
    address internal constant _UNISWAP_V4_ROUTER           = 0x66a9893cC07D91D95644AEDD05D03f95e1dBA8Af;

    /**********************************************************************************************/
    /*** State variables                                                                        ***/
    /**********************************************************************************************/

    Beacon internal beacon;

    /**********************************************************************************************/
    /*** Run function                                                                           ***/
    /**********************************************************************************************/

    function run() external {
        string memory env = vm.envString("ENV");

        vm.createSelectFork(getChain("mainnet").rpcUrl);

        vm.setEnv("FOUNDRY_ROOT_CHAINID",             vm.toString(block.chainid));
        vm.setEnv("FOUNDRY_EXPORTS_OVERWRITE_LATEST", "true");

        string memory fileSlug = string(abi.encodePacked("beacon-and-facets-mainnet-", env));
        string memory config   = ScriptTools.loadConfig(fileSlug);

        address admin = config.readAddress(".admin");

        console.log("Deploying PAU beacon + facets...\n  Chain: Mainnet\n  Env: %s", env);

        vm.startBroadcast();

        address deployer = msg.sender;

        require(deployer != admin, "DeployBeaconAndFacetsMainnet/deployer-must-differ-from-admin");

        // Step 1: deploy Beacon with deployer as temporary admin so this script can wire facets.

        beacon = new Beacon(deployer);

        console.log("PAU beacon deployed at: ", address(beacon));

        // Step 2: deploy each facet and wire it through beacon.setIntegration.
        MainnetFacetAddresses memory facets = _deployAndWireFacets();

        // Step 3: Grant admin role to final admin, then revoke deployer.
        
        beacon.grantRole(beacon.DEFAULT_ADMIN_ROLE(),  admin);
        beacon.revokeRole(beacon.DEFAULT_ADMIN_ROLE(), deployer);

        console.log("Beacon admin transferred to: ", admin);

        vm.stopBroadcast();

        // Step 4: export addresses.

        ScriptTools.exportContract(fileSlug, "beacon", address(beacon));

        _exportFacets(facets, fileSlug);
    }

    /**********************************************************************************************/
    /*** Deploy + Wire Facets                                                                   ***/
    /**********************************************************************************************/

    function _deployAndWireFacets() internal returns (MainnetFacetAddresses memory facets) {
        facets.aaveFacet          = _deployAndWireAaveFacet();
        facets.basinFacet         = _deployAndWireBasinFacet();
        facets.cctpFacet          = _deployAndWireCCTPFacet();
        facets.centrifugeFacet    = _deployAndWireCentrifugeFacet();
        facets.curveFacet         = _deployAndWireCurveFacet();
        facets.daiUSDSFacet       = _deployAndWireDAIUSDSFacet();
        facets.erc4626Facet       = _deployAndWireERC4626Facet();
        facets.erc7540Facet       = _deployAndWireERC7540Facet();
        facets.ethenaFacet        = _deployAndWireEthenaFacet();
        facets.farmFacet          = _deployAndWireFarmFacet();
        facets.layerZeroFacet     = _deployAndWireLayerZeroFacet();
        facets.mapleFacet         = _deployAndWireMapleFacet();
        facets.merklFacet         = _deployAndWireMerklFacet();
        facets.otcFacet           = _deployAndWireOTCFacet();
        facets.pendleFacet        = _deployAndWirePendleFacet();
        facets.psmFacet           = _deployAndWirePSMFacet();
        facets.sparkVaultFacet    = _deployAndWireSparkVaultFacet();
        facets.superstateFacet    = _deployAndWireSuperstateFacet();
        facets.transferAssetFacet = _deployAndWireTransferAssetFacet();
        facets.uniswapV3Facet     = _deployAndWireUniswapV3Facet();
        facets.uniswapV4Facet     = _deployAndWireUniswapV4Facet();
        facets.usdsFacet          = _deployAndWireUSDSFacet();
        facets.weethFacet         = _deployAndWireWEETHFacet();
        facets.wrapProxyETHFacet  = _deployAndWireWrapProxyETHFacet();
        facets.wstethFacet        = _deployAndWireWSTETHFacet();
    }

    function _exportFacets(MainnetFacetAddresses memory facets, string memory fileSlug) internal {
        ScriptTools.exportContract(fileSlug, "aaveFacet",          facets.aaveFacet);
        ScriptTools.exportContract(fileSlug, "basinFacet",         facets.basinFacet);
        ScriptTools.exportContract(fileSlug, "cctpFacet",          facets.cctpFacet);
        ScriptTools.exportContract(fileSlug, "centrifugeFacet",    facets.centrifugeFacet);
        ScriptTools.exportContract(fileSlug, "curveFacet",         facets.curveFacet);
        ScriptTools.exportContract(fileSlug, "daiUSDSFacet",       facets.daiUSDSFacet);
        ScriptTools.exportContract(fileSlug, "erc4626Facet",       facets.erc4626Facet);
        ScriptTools.exportContract(fileSlug, "erc7540Facet",       facets.erc7540Facet);
        ScriptTools.exportContract(fileSlug, "ethenaFacet",        facets.ethenaFacet);
        ScriptTools.exportContract(fileSlug, "farmFacet",          facets.farmFacet);
        ScriptTools.exportContract(fileSlug, "layerZeroFacet",     facets.layerZeroFacet);
        ScriptTools.exportContract(fileSlug, "mapleFacet",         facets.mapleFacet);
        ScriptTools.exportContract(fileSlug, "merklFacet",         facets.merklFacet);
        ScriptTools.exportContract(fileSlug, "otcFacet",           facets.otcFacet);
        ScriptTools.exportContract(fileSlug, "pendleFacet",        facets.pendleFacet);
        ScriptTools.exportContract(fileSlug, "psmFacet",           facets.psmFacet);
        ScriptTools.exportContract(fileSlug, "sparkVaultFacet",    facets.sparkVaultFacet);
        ScriptTools.exportContract(fileSlug, "superstateFacet",    facets.superstateFacet);
        ScriptTools.exportContract(fileSlug, "transferAssetFacet", facets.transferAssetFacet);
        ScriptTools.exportContract(fileSlug, "uniswapV3Facet",     facets.uniswapV3Facet);
        ScriptTools.exportContract(fileSlug, "uniswapV4Facet",     facets.uniswapV4Facet);
        ScriptTools.exportContract(fileSlug, "usdsFacet",          facets.usdsFacet);
        ScriptTools.exportContract(fileSlug, "weethFacet",         facets.weethFacet);
        ScriptTools.exportContract(fileSlug, "wrapProxyETHFacet",  facets.wrapProxyETHFacet);
        ScriptTools.exportContract(fileSlug, "wstethFacet",        facets.wstethFacet);
    }

    /**********************************************************************************************/
    /*** Per-facet deploy + wire helpers                                                        ***/
    /**********************************************************************************************/

    function _deployAndWireAaveFacet() internal returns (address facet) {
        facet = address(new AaveFacet());

        IEI.Wire[] memory wires = new IEI.Wire[](7);

        wires[0] = IEI.Wire(IControllerFull.aave_VERSION.selector,                 IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.aave_setMaxSlippage.selector,          IAaveFacet.setMaxSlippage.selector);
        wires[2] = IEI.Wire(IControllerFull.aave_getMaxSlippage.selector,          IAaveFacet.getMaxSlippage.selector);
        wires[3] = IEI.Wire(IControllerFull.aave_deposit.selector,                 IAaveFacet.deposit.selector);
        wires[4] = IEI.Wire(IControllerFull.aave_withdraw.selector,                IAaveFacet.withdraw.selector);
        wires[5] = IEI.Wire(IControllerFull.aave_getDepositRateLimitKey.selector,  IAaveFacet.getDepositRateLimitKey.selector);
        wires[6] = IEI.Wire(IControllerFull.aave_getWithdrawRateLimitKey.selector, IAaveFacet.getWithdrawRateLimitKey.selector);

        beacon.setIntegration("AAVE_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireBasinFacet() internal returns (address facet) {
        facet = address(new BasinFacet());

        IEI.Wire[] memory wires = new IEI.Wire[](5);

        wires[0] = IEI.Wire(IControllerFull.basin_VERSION.selector,                 IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.basin_deposit.selector,                 IBasinFacet.deposit.selector);
        wires[2] = IEI.Wire(IControllerFull.basin_withdraw.selector,                IBasinFacet.withdraw.selector);
        wires[3] = IEI.Wire(IControllerFull.basin_getDepositRateLimitKey.selector,  IBasinFacet.getDepositRateLimitKey.selector);
        wires[4] = IEI.Wire(IControllerFull.basin_getWithdrawRateLimitKey.selector, IBasinFacet.getWithdrawRateLimitKey.selector);

        beacon.setIntegration("BASIN_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireCCTPFacet() internal returns (address facet) {
        facet = address(new CCTPFacet({
            cctp_ : Ethereum.CCTP_TOKEN_MESSENGER,
            usdc_ : Ethereum.USDC
        }));

        IEI.Wire[] memory wires = new IEI.Wire[](10);

        wires[0] = IEI.Wire(IControllerFull.cctp_VERSION.selector,                 IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.cctp_DESTINATION_CALLER.selector,      ICCTPFacet.DESTINATION_CALLER.selector);
        wires[2] = IEI.Wire(IControllerFull.cctp_MAX_FINALITY_THRESHOLD.selector,  ICCTPFacet.MAX_FINALITY_THRESHOLD.selector);
        wires[3] = IEI.Wire(IControllerFull.cctp_cctp.selector,                    ICCTPFacet.cctp.selector);
        wires[4] = IEI.Wire(IControllerFull.cctp_usdc.selector,                    ICCTPFacet.usdc.selector);
        wires[5] = IEI.Wire(IControllerFull.cctp_setDomainParameters.selector,     ICCTPFacet.setDomainParameters.selector);
        wires[6] = IEI.Wire(IControllerFull.cctp_transfer.selector,                ICCTPFacet.transfer.selector);
        wires[7] = IEI.Wire(IControllerFull.cctp_toCCTPRateLimitKey.selector,      ICCTPFacet.toCCTPRateLimitKey.selector);
        wires[8] = IEI.Wire(IControllerFull.cctp_getDomainParameters.selector,     ICCTPFacet.getDomainParameters.selector);
        wires[9] = IEI.Wire(IControllerFull.cctp_getToDomainRateLimitKey.selector, ICCTPFacet.getToDomainRateLimitKey.selector);

        beacon.setIntegration("CCTP_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireCentrifugeFacet() internal returns (address facet) {
        facet = address(new CentrifugeFacet());

        IEI.Wire[] memory wires = new IEI.Wire[](14);

        wires[0]  = IEI.Wire(IControllerFull.centrifuge_VERSION.selector,                           IFacet.VERSION.selector);
        wires[1]  = IEI.Wire(IControllerFull.centrifuge_REQUEST_ID.selector,                        ICentrifugeFacet.REQUEST_ID.selector);
        wires[2]  = IEI.Wire(IControllerFull.centrifuge_setRecipient.selector,                      ICentrifugeFacet.setRecipient.selector);
        wires[3]  = IEI.Wire(IControllerFull.centrifuge_cancelDepositRequest.selector,              ICentrifugeFacet.cancelDepositRequest.selector);
        wires[4]  = IEI.Wire(IControllerFull.centrifuge_claimCancelDepositRequest.selector,         ICentrifugeFacet.claimCancelDepositRequest.selector);
        wires[5]  = IEI.Wire(IControllerFull.centrifuge_cancelRedeemRequest.selector,               ICentrifugeFacet.cancelRedeemRequest.selector);
        wires[6]  = IEI.Wire(IControllerFull.centrifuge_claimCancelRedeemRequest.selector,          ICentrifugeFacet.claimCancelRedeemRequest.selector);
        wires[7]  = IEI.Wire(IControllerFull.centrifuge_transferShares.selector,                    ICentrifugeFacet.transferShares.selector);
        wires[8]  = IEI.Wire(IControllerFull.centrifuge_getRecipient.selector,                      ICentrifugeFacet.getRecipient.selector);
        wires[9]  = IEI.Wire(IControllerFull.centrifuge_getCancelDepositRateLimitKey.selector,      ICentrifugeFacet.getCancelDepositRateLimitKey.selector);
        wires[10] = IEI.Wire(IControllerFull.centrifuge_getClaimCancelDepositRateLimitKey.selector, ICentrifugeFacet.getClaimCancelDepositRateLimitKey.selector);
        wires[11] = IEI.Wire(IControllerFull.centrifuge_getCancelRedeemRateLimitKey.selector,       ICentrifugeFacet.getCancelRedeemRateLimitKey.selector);
        wires[12] = IEI.Wire(IControllerFull.centrifuge_getClaimCancelRedeemRateLimitKey.selector,  ICentrifugeFacet.getClaimCancelRedeemRateLimitKey.selector);
        wires[13] = IEI.Wire(IControllerFull.centrifuge_getTransferRateLimitKey.selector,           ICentrifugeFacet.getTransferRateLimitKey.selector);

        beacon.setIntegration("CENTRIFUGE_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireCurveFacet() internal returns (address facet) {
        facet = address(new CurveFacet());

        IEI.Wire[] memory wires = new IEI.Wire[](11);

        wires[0]  = IEI.Wire(IControllerFull.curve_VERSION.selector,                          IFacet.VERSION.selector);
        wires[1]  = IEI.Wire(IControllerFull.curve_setMaxSlippage.selector,                   ICurveFacet.setMaxSlippage.selector);
        wires[2]  = IEI.Wire(IControllerFull.curve_getMaxSlippage.selector,                   ICurveFacet.getMaxSlippage.selector);
        wires[3]  = IEI.Wire(IControllerFull.curve_swap.selector,                             ICurveFacet.swap.selector);
        wires[4]  = IEI.Wire(IControllerFull.curve_addLiquidity.selector,                     ICurveFacet.addLiquidity.selector);
        wires[5]  = IEI.Wire(IControllerFull.curve_removeLiquidity.selector,                  ICurveFacet.removeLiquidity.selector);
        wires[6]  = IEI.Wire(IControllerFull.curve_getAggregateDepositRateLimitKey.selector,  ICurveFacet.getAggregateDepositRateLimitKey.selector);
        wires[7]  = IEI.Wire(IControllerFull.curve_getAssetDepositRateLimitKey.selector,      ICurveFacet.getAssetDepositRateLimitKey.selector);
        wires[8]  = IEI.Wire(IControllerFull.curve_getSwapRateLimitKey.selector,              ICurveFacet.getSwapRateLimitKey.selector);
        wires[9]  = IEI.Wire(IControllerFull.curve_getAggregateWithdrawRateLimitKey.selector, ICurveFacet.getAggregateWithdrawRateLimitKey.selector);
        wires[10] = IEI.Wire(IControllerFull.curve_getAssetWithdrawRateLimitKey.selector,     ICurveFacet.getAssetWithdrawRateLimitKey.selector);

        beacon.setIntegration("CURVE_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireDAIUSDSFacet() internal returns (address facet) {
        facet = address(new DAIUSDSFacet({
            dai_     : Ethereum.DAI,
            daiUSDS_ : Ethereum.DAI_USDS,
            usds_    : Ethereum.USDS
        }));

        IEI.Wire[] memory wires = new IEI.Wire[](8);

        wires[0] = IEI.Wire(IControllerFull.daiUSDS_VERSION.selector,                   IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.daiUSDS_dai.selector,                       IDAIUSDSFacet.dai.selector);
        wires[2] = IEI.Wire(IControllerFull.daiUSDS_daiUSDS.selector,                   IDAIUSDSFacet.daiUSDS.selector);
        wires[3] = IEI.Wire(IControllerFull.daiUSDS_usds.selector,                      IDAIUSDSFacet.usds.selector);
        wires[4] = IEI.Wire(IControllerFull.daiUSDS_swapUSDSToDAI.selector,             IDAIUSDSFacet.swapUSDSToDAI.selector);
        wires[5] = IEI.Wire(IControllerFull.daiUSDS_swapDAIToUSDS.selector,             IDAIUSDSFacet.swapDAIToUSDS.selector);
        wires[6] = IEI.Wire(IControllerFull.daiUSDS_daiToUSDSSwapRateLimitKey.selector, IDAIUSDSFacet.daiToUSDSSwapRateLimitKey.selector);
        wires[7] = IEI.Wire(IControllerFull.daiUSDS_usdsToDAISwapRateLimitKey.selector, IDAIUSDSFacet.usdsToDAISwapRateLimitKey.selector);

        beacon.setIntegration("DAIUSDS_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireERC4626Facet() internal returns (address facet) {
        facet = address(new ERC4626Facet());

        IEI.Wire[] memory wires = new IEI.Wire[](9);

        wires[0] = IEI.Wire(IControllerFull.erc4626_VERSION.selector,                 IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.erc4626_setMaxExchangeRate.selector,      IERC4626Facet.setMaxExchangeRate.selector);
        wires[2] = IEI.Wire(IControllerFull.erc4626_deposit.selector,                 IERC4626Facet.deposit.selector);
        wires[3] = IEI.Wire(IControllerFull.erc4626_withdraw.selector,                IERC4626Facet.withdraw.selector);
        wires[4] = IEI.Wire(IControllerFull.erc4626_redeem.selector,                  IERC4626Facet.redeem.selector);
        wires[5] = IEI.Wire(IControllerFull.erc4626_EXCHANGE_RATE_PRECISION.selector, IERC4626Facet.EXCHANGE_RATE_PRECISION.selector);
        wires[6] = IEI.Wire(IControllerFull.erc4626_getMaxExchangeRate.selector,      IERC4626Facet.getMaxExchangeRate.selector);
        wires[7] = IEI.Wire(IControllerFull.erc4626_getDepositRateLimitKey.selector,  IERC4626Facet.getDepositRateLimitKey.selector);
        wires[8] = IEI.Wire(IControllerFull.erc4626_getWithdrawRateLimitKey.selector, IERC4626Facet.getWithdrawRateLimitKey.selector);

        beacon.setIntegration("ERC4626_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireERC7540Facet() internal returns (address facet) {
        facet = address(new ERC7540Facet());

        IEI.Wire[] memory wires = new IEI.Wire[](9);

        wires[0] = IEI.Wire(IControllerFull.erc7540_VERSION.selector,                       IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.erc7540_requestDeposit.selector,                IERC7540Facet.requestDeposit.selector);
        wires[2] = IEI.Wire(IControllerFull.erc7540_claimDeposit.selector,                  IERC7540Facet.claimDeposit.selector);
        wires[3] = IEI.Wire(IControllerFull.erc7540_requestRedeem.selector,                 IERC7540Facet.requestRedeem.selector);
        wires[4] = IEI.Wire(IControllerFull.erc7540_claimRedeem.selector,                   IERC7540Facet.claimRedeem.selector);
        wires[5] = IEI.Wire(IControllerFull.erc7540_getRequestDepositRateLimitKey.selector, IERC7540Facet.getRequestDepositRateLimitKey.selector);
        wires[6] = IEI.Wire(IControllerFull.erc7540_getClaimDepositRateLimitKey.selector,   IERC7540Facet.getClaimDepositRateLimitKey.selector);
        wires[7] = IEI.Wire(IControllerFull.erc7540_getRequestRedeemRateLimitKey.selector,  IERC7540Facet.getRequestRedeemRateLimitKey.selector);
        wires[8] = IEI.Wire(IControllerFull.erc7540_getClaimRedeemRateLimitKey.selector,    IERC7540Facet.getClaimRedeemRateLimitKey.selector);

        beacon.setIntegration("ERC7540_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireEthenaFacet() internal returns (address facet) {
        facet = address(new EthenaFacet({
            minter_ : Ethereum.ETHENA_MINTER,
            susde_  : Ethereum.SUSDE,
            usdc_   : Ethereum.USDC,
            usde_   : Ethereum.USDE
        }));

        IEI.Wire[] memory wires = new IEI.Wire[](18);

        wires[0]  = IEI.Wire(IControllerFull.ethena_VERSION.selector,                           IFacet.VERSION.selector);
        wires[1]  = IEI.Wire(IControllerFull.ethena_minter.selector,                            IEthenaFacet.minter.selector);
        wires[2]  = IEI.Wire(IControllerFull.ethena_susde.selector,                             IEthenaFacet.susde.selector);
        wires[3]  = IEI.Wire(IControllerFull.ethena_usdc.selector,                              IEthenaFacet.usdc.selector);
        wires[4]  = IEI.Wire(IControllerFull.ethena_usde.selector,                              IEthenaFacet.usde.selector);
        wires[5]  = IEI.Wire(IControllerFull.ethena_setDelegatedSigner.selector,                IEthenaFacet.setDelegatedSigner.selector);
        wires[6]  = IEI.Wire(IControllerFull.ethena_removeDelegatedSigner.selector,             IEthenaFacet.removeDelegatedSigner.selector);
        wires[7]  = IEI.Wire(IControllerFull.ethena_prepareMint.selector,                       IEthenaFacet.prepareMint.selector);
        wires[8]  = IEI.Wire(IControllerFull.ethena_prepareBurn.selector,                       IEthenaFacet.prepareBurn.selector);
        wires[9]  = IEI.Wire(IControllerFull.ethena_cooldownAssets.selector,                    IEthenaFacet.cooldownAssets.selector);
        wires[10] = IEI.Wire(IControllerFull.ethena_cooldownShares.selector,                    IEthenaFacet.cooldownShares.selector);
        wires[11] = IEI.Wire(IControllerFull.ethena_unstake.selector,                           IEthenaFacet.unstake.selector);
        wires[12] = IEI.Wire(IControllerFull.ethena_setDelegatedSignerRateLimitKey.selector,    IEthenaFacet.setDelegatedSignerRateLimitKey.selector);
        wires[13] = IEI.Wire(IControllerFull.ethena_removeDelegatedSignerRateLimitKey.selector, IEthenaFacet.removeDelegatedSignerRateLimitKey.selector);
        wires[14] = IEI.Wire(IControllerFull.ethena_mintRateLimitKey.selector,                  IEthenaFacet.mintRateLimitKey.selector);
        wires[15] = IEI.Wire(IControllerFull.ethena_burnRateLimitKey.selector,                  IEthenaFacet.burnRateLimitKey.selector);
        wires[16] = IEI.Wire(IControllerFull.ethena_cooldownRateLimitKey.selector,              IEthenaFacet.cooldownRateLimitKey.selector);
        wires[17] = IEI.Wire(IControllerFull.ethena_unstakeRateLimitKey.selector,               IEthenaFacet.unstakeRateLimitKey.selector);

        beacon.setIntegration("ETHENA_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireFarmFacet() internal returns (address facet) {
        facet = address(new FarmFacet());

        IEI.Wire[] memory wires = new IEI.Wire[](7);

        wires[0] = IEI.Wire(IControllerFull.farm_VERSION.selector,                    IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.farm_deposit.selector,                    IFarmFacet.deposit.selector);
        wires[2] = IEI.Wire(IControllerFull.farm_claimReward.selector,                IFarmFacet.claimReward.selector);
        wires[3] = IEI.Wire(IControllerFull.farm_withdraw.selector,                   IFarmFacet.withdraw.selector);
        wires[4] = IEI.Wire(IControllerFull.farm_getClaimRewardRateLimitKey.selector, IFarmFacet.getClaimRewardRateLimitKey.selector);
        wires[5] = IEI.Wire(IControllerFull.farm_getDepositRateLimitKey.selector,     IFarmFacet.getDepositRateLimitKey.selector);
        wires[6] = IEI.Wire(IControllerFull.farm_getWithdrawRateLimitKey.selector,    IFarmFacet.getWithdrawRateLimitKey.selector);

        beacon.setIntegration("FARM_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireLayerZeroFacet() internal returns (address facet) {
        facet = address(new LayerZeroFacet());

        IEI.Wire[] memory wires = new IEI.Wire[](6);

        wires[0] = IEI.Wire(IControllerFull.layerZero_VERSION.selector,                 IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.layerZero_setRecipient.selector,            ILayerZeroFacet.setRecipient.selector);
        wires[2] = IEI.Wire(IControllerFull.layerZero_transfer.selector,                ILayerZeroFacet.transfer.selector);
        wires[3] = IEI.Wire(IControllerFull.layerZero_getRecipient.selector,            ILayerZeroFacet.getRecipient.selector);
        wires[4] = IEI.Wire(IControllerFull.layerZero_getTransferRateLimitKey.selector, ILayerZeroFacet.getTransferRateLimitKey.selector);
        wires[5] = IEI.Wire(IControllerFull.layerZero_quoteTransfer.selector,           ILayerZeroFacet.quoteTransfer.selector);

        beacon.setIntegration("LAYER_ZERO_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireMapleFacet() internal returns (address facet) {
        facet = address(new MapleFacet());

        IEI.Wire[] memory wires = new IEI.Wire[](5);

        wires[0] = IEI.Wire(IControllerFull.maple_VERSION.selector,                      IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.maple_requestRedemption.selector,            IMapleFacet.requestRedemption.selector);
        wires[2] = IEI.Wire(IControllerFull.maple_cancelRedemption.selector,             IMapleFacet.cancelRedemption.selector);
        wires[3] = IEI.Wire(IControllerFull.maple_getCancelRedeemRateLimitKey.selector,  IMapleFacet.getCancelRedeemRateLimitKey.selector);
        wires[4] = IEI.Wire(IControllerFull.maple_getRequestRedeemRateLimitKey.selector, IMapleFacet.getRequestRedeemRateLimitKey.selector);

        beacon.setIntegration("MAPLE_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireMerklFacet() internal returns (address facet) {
        facet = address(new MerklFacet());

        IEI.Wire[] memory wires = new IEI.Wire[](3);

        wires[0] = IEI.Wire(IControllerFull.merkl_VERSION.selector,                       IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.merkl_toggleOperator.selector,                IMerklFacet.toggleOperator.selector);
        wires[2] = IEI.Wire(IControllerFull.merkl_getToggleOperatorRateLimitKey.selector, IMerklFacet.getToggleOperatorRateLimitKey.selector);

        beacon.setIntegration("MERKL_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireOTCFacet() internal returns (address facet) {
        facet = address(new OTCFacet());

        IEI.Wire[] memory wires = new IEI.Wire[](14);

        wires[0]  = IEI.Wire(IControllerFull.otc_VERSION.selector,              IFacet.VERSION.selector);
        wires[1]  = IEI.Wire(IControllerFull.otc_setMaxSlippage.selector,       IOTCFacet.setMaxSlippage.selector);
        wires[2]  = IEI.Wire(IControllerFull.otc_setBuffer.selector,            IOTCFacet.setBuffer.selector);
        wires[3]  = IEI.Wire(IControllerFull.otc_setRechargeRate.selector,      IOTCFacet.setRechargeRate.selector);
        wires[4]  = IEI.Wire(IControllerFull.otc_send.selector,                 IOTCFacet.send.selector);
        wires[5]  = IEI.Wire(IControllerFull.otc_claim.selector,                IOTCFacet.claim.selector);
        wires[6]  = IEI.Wire(IControllerFull.otc_getBuffer.selector,            IOTCFacet.getBuffer.selector);
        wires[7]  = IEI.Wire(IControllerFull.otc_getMaxSlippage.selector,       IOTCFacet.getMaxSlippage.selector);
        wires[8]  = IEI.Wire(IControllerFull.otc_getRechargeRate.selector,      IOTCFacet.getRechargeRate.selector);
        wires[9]  = IEI.Wire(IControllerFull.otc_getState.selector,             IOTCFacet.getState.selector);
        wires[10] = IEI.Wire(IControllerFull.otc_getClaimWithRecharge.selector, IOTCFacet.getClaimWithRecharge.selector);
        wires[11] = IEI.Wire(IControllerFull.otc_getIsSwapReady.selector,       IOTCFacet.getIsSwapReady.selector);
        wires[12] = IEI.Wire(IControllerFull.otc_getSendRateLimitKey.selector,  IOTCFacet.getSendRateLimitKey.selector);
        wires[13] = IEI.Wire(IControllerFull.otc_getClaimRateLimitKey.selector, IOTCFacet.getClaimRateLimitKey.selector);

        beacon.setIntegration("OTC_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWirePendleFacet() internal returns (address facet) {
        facet = address(new PendleFacet({
            router_ : GroveEthereum.PENDLE_ROUTER
        }));

        IEI.Wire[] memory wires = new IEI.Wire[](4);

        wires[0] = IEI.Wire(IControllerFull.pendle_VERSION.selector,               IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.pendle_router.selector,                IPendleFacet.router.selector);
        wires[2] = IEI.Wire(IControllerFull.pendle_redeem.selector,                IPendleFacet.redeem.selector);
        wires[3] = IEI.Wire(IControllerFull.pendle_getRedeemRateLimitKey.selector, IPendleFacet.getRedeemRateLimitKey.selector);

        beacon.setIntegration("PENDLE_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWirePSMFacet() internal returns (address facet) {
        facet = address(new PSMFacet({
            dai_     : Ethereum.DAI,
            daiUSDS_ : Ethereum.DAI_USDS,
            psm_     : Ethereum.PSM,
            usdc_    : Ethereum.USDC,
            usds_    : Ethereum.USDS
        }));

        IEI.Wire[] memory wires = new IEI.Wire[](11);

        wires[0]  = IEI.Wire(IControllerFull.psm_VERSION.selector,                    IFacet.VERSION.selector);
        wires[1]  = IEI.Wire(IControllerFull.psm_dai.selector,                        IPSMFacet.dai.selector);
        wires[2]  = IEI.Wire(IControllerFull.psm_daiUSDS.selector,                    IPSMFacet.daiUSDS.selector);
        wires[3]  = IEI.Wire(IControllerFull.psm_psm.selector,                        IPSMFacet.psm.selector);
        wires[4]  = IEI.Wire(IControllerFull.psm_usdc.selector,                       IPSMFacet.usdc.selector);
        wires[5]  = IEI.Wire(IControllerFull.psm_usds.selector,                       IPSMFacet.usds.selector);
        wires[6]  = IEI.Wire(IControllerFull.psm_swapUSDSToUSDC.selector,             IPSMFacet.swapUSDSToUSDC.selector);
        wires[7]  = IEI.Wire(IControllerFull.psm_swapUSDCToUSDS.selector,             IPSMFacet.swapUSDCToUSDS.selector);
        wires[8]  = IEI.Wire(IControllerFull.psm_to18ConversionFactor.selector,       IPSMFacet.to18ConversionFactor.selector);
        wires[9]  = IEI.Wire(IControllerFull.psm_usdcToUSDSSwapRateLimitKey.selector, IPSMFacet.usdcToUSDSSwapRateLimitKey.selector);
        wires[10] = IEI.Wire(IControllerFull.psm_usdsToUSDCSwapRateLimitKey.selector, IPSMFacet.usdsToUSDCSwapRateLimitKey.selector);

        beacon.setIntegration("PSM_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireSparkVaultFacet() internal returns (address facet) {
        facet = address(new SparkVaultFacet());

        IEI.Wire[] memory wires = new IEI.Wire[](3);

        wires[0] = IEI.Wire(IControllerFull.sparkVault_VERSION.selector,             IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.sparkVault_take.selector,                ISparkVaultFacet.take.selector);
        wires[2] = IEI.Wire(IControllerFull.sparkVault_getTakeRateLimitKey.selector, ISparkVaultFacet.getTakeRateLimitKey.selector);

        beacon.setIntegration("SPARK_VAULT_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireSuperstateFacet() internal returns (address facet) {
        facet = address(new SuperstateFacet({
            usdc_ : Ethereum.USDC,
            ustb_ : Ethereum.USTB
        }));

        IEI.Wire[] memory wires = new IEI.Wire[](5);

        wires[0] = IEI.Wire(IControllerFull.superstate_VERSION.selector,               IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.superstate_usdc.selector,                  ISuperstateFacet.usdc.selector);
        wires[2] = IEI.Wire(IControllerFull.superstate_ustb.selector,                  ISuperstateFacet.ustb.selector);
        wires[3] = IEI.Wire(IControllerFull.superstate_subscribe.selector,             ISuperstateFacet.subscribe.selector);
        wires[4] = IEI.Wire(IControllerFull.superstate_subscribeRateLimitKey.selector, ISuperstateFacet.subscribeRateLimitKey.selector);

        beacon.setIntegration("SUPERSTATE_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireTransferAssetFacet() internal returns (address facet) {
        facet = address(new TransferAssetFacet());

        IEI.Wire[] memory wires = new IEI.Wire[](3);

        wires[0] = IEI.Wire(IControllerFull.transferAsset_VERSION.selector,                 IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.transferAsset_transfer.selector,                ITransferAssetFacet.transfer.selector);
        wires[2] = IEI.Wire(IControllerFull.transferAsset_getTransferRateLimitKey.selector, ITransferAssetFacet.getTransferRateLimitKey.selector);

        beacon.setIntegration("TRANSFER_ASSET_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireUniswapV3Facet() internal returns (address facet) {
        facet = address(new UniswapV3Facet({
            positionManager_ : _UNISWAP_V3_POSITION_MANAGER,
            router_          : _UNISWAP_V3_ROUTER
        }));

        IEI.Wire[] memory wires = new IEI.Wire[](23);

        wires[0]  = IEI.Wire(IControllerFull.uniswapV3_VERSION.selector,                          IFacet.VERSION.selector);
        wires[1]  = IEI.Wire(IControllerFull.uniswapV3_MAX_TICK_DELTA.selector,                   IUniswapV3Facet.MAX_TICK_DELTA.selector);
        wires[2]  = IEI.Wire(IControllerFull.uniswapV3_MIN_TICK.selector,                         IUniswapV3Facet.MIN_TICK.selector);
        wires[3]  = IEI.Wire(IControllerFull.uniswapV3_MAX_TICK.selector,                         IUniswapV3Facet.MAX_TICK.selector);
        wires[4]  = IEI.Wire(IControllerFull.uniswapV3_positionManager.selector,                  IUniswapV3Facet.positionManager.selector);
        wires[5]  = IEI.Wire(IControllerFull.uniswapV3_router.selector,                           IUniswapV3Facet.router.selector);
        wires[6]  = IEI.Wire(IControllerFull.uniswapV3_setMaxSlippage.selector,                   IUniswapV3Facet.setMaxSlippage.selector);
        wires[7]  = IEI.Wire(IControllerFull.uniswapV3_setMaxTickDelta.selector,                  IUniswapV3Facet.setMaxTickDelta.selector);
        wires[8]  = IEI.Wire(IControllerFull.uniswapV3_setLiquidityLowerTickBound.selector,       IUniswapV3Facet.setLiquidityLowerTickBound.selector);
        wires[9]  = IEI.Wire(IControllerFull.uniswapV3_setLiquidityUpperTickBound.selector,       IUniswapV3Facet.setLiquidityUpperTickBound.selector);
        wires[10] = IEI.Wire(IControllerFull.uniswapV3_setTWAPSecondsAgo.selector,                IUniswapV3Facet.setTWAPSecondsAgo.selector);
        wires[11] = IEI.Wire(IControllerFull.uniswapV3_swap.selector,                             IUniswapV3Facet.swap.selector);
        wires[12] = IEI.Wire(IControllerFull.uniswapV3_addLiquidity.selector,                     IUniswapV3Facet.addLiquidity.selector);
        wires[13] = IEI.Wire(IControllerFull.uniswapV3_removeLiquidity.selector,                  IUniswapV3Facet.removeLiquidity.selector);
        wires[14] = IEI.Wire(IControllerFull.uniswapV3_getAggregateDepositRateLimitKey.selector,  IUniswapV3Facet.getAggregateDepositRateLimitKey.selector);
        wires[15] = IEI.Wire(IControllerFull.uniswapV3_getAssetDepositRateLimitKey.selector,      IUniswapV3Facet.getAssetDepositRateLimitKey.selector);
        wires[16] = IEI.Wire(IControllerFull.uniswapV3_getLiquidityTickBounds.selector,           IUniswapV3Facet.getLiquidityTickBounds.selector);
        wires[17] = IEI.Wire(IControllerFull.uniswapV3_getMaxSlippage.selector,                   IUniswapV3Facet.getMaxSlippage.selector);
        wires[18] = IEI.Wire(IControllerFull.uniswapV3_getMaxTickDelta.selector,                  IUniswapV3Facet.getMaxTickDelta.selector);
        wires[19] = IEI.Wire(IControllerFull.uniswapV3_getSwapRateLimitKey.selector,              IUniswapV3Facet.getSwapRateLimitKey.selector);
        wires[20] = IEI.Wire(IControllerFull.uniswapV3_getTWAPSecondsAgo.selector,                IUniswapV3Facet.getTWAPSecondsAgo.selector);
        wires[21] = IEI.Wire(IControllerFull.uniswapV3_getAggregateWithdrawRateLimitKey.selector, IUniswapV3Facet.getAggregateWithdrawRateLimitKey.selector);
        wires[22] = IEI.Wire(IControllerFull.uniswapV3_getAssetWithdrawRateLimitKey.selector,     IUniswapV3Facet.getAssetWithdrawRateLimitKey.selector);

        beacon.setIntegration("UNISWAP_V3_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireUniswapV4Facet() internal returns (address facet) {
        facet = address(new UniswapV4Facet({
            permit2_         : _PERMIT2,
            positionManager_ : _UNISWAP_V4_POSITION_MANAGER,
            router_          : _UNISWAP_V4_ROUTER
        }));

        IEI.Wire[] memory wires = new IEI.Wire[](17);

        wires[0]  = IEI.Wire(IControllerFull.uniswapV4_VERSION.selector,                          IFacet.VERSION.selector);
        wires[1]  = IEI.Wire(IControllerFull.uniswapV4_permit2.selector,                          IUniswapV4Facet.permit2.selector);
        wires[2]  = IEI.Wire(IControllerFull.uniswapV4_positionManager.selector,                  IUniswapV4Facet.positionManager.selector);
        wires[3]  = IEI.Wire(IControllerFull.uniswapV4_router.selector,                           IUniswapV4Facet.router.selector);
        wires[4]  = IEI.Wire(IControllerFull.uniswapV4_setMaxSlippage.selector,                   IUniswapV4Facet.setMaxSlippage.selector);
        wires[5]  = IEI.Wire(IControllerFull.uniswapV4_setTickLimits.selector,                    IUniswapV4Facet.setTickLimits.selector);
        wires[6]  = IEI.Wire(IControllerFull.uniswapV4_mintPosition.selector,                     IUniswapV4Facet.mintPosition.selector);
        wires[7]  = IEI.Wire(IControllerFull.uniswapV4_increasePosition.selector,                 IUniswapV4Facet.increasePosition.selector);
        wires[8]  = IEI.Wire(IControllerFull.uniswapV4_decreasePosition.selector,                 IUniswapV4Facet.decreasePosition.selector);
        wires[9]  = IEI.Wire(IControllerFull.uniswapV4_swap.selector,                             IUniswapV4Facet.swap.selector);
        wires[10] = IEI.Wire(IControllerFull.uniswapV4_getAggregateDepositRateLimitKey.selector,  IUniswapV4Facet.getAggregateDepositRateLimitKey.selector);
        wires[11] = IEI.Wire(IControllerFull.uniswapV4_getAssetDepositRateLimitKey.selector,      IUniswapV4Facet.getAssetDepositRateLimitKey.selector);
        wires[12] = IEI.Wire(IControllerFull.uniswapV4_getMaxSlippage.selector,                   IUniswapV4Facet.getMaxSlippage.selector);
        wires[13] = IEI.Wire(IControllerFull.uniswapV4_getSwapRateLimitKey.selector,              IUniswapV4Facet.getSwapRateLimitKey.selector);
        wires[14] = IEI.Wire(IControllerFull.uniswapV4_getTickLimits.selector,                    IUniswapV4Facet.getTickLimits.selector);
        wires[15] = IEI.Wire(IControllerFull.uniswapV4_getAggregateWithdrawRateLimitKey.selector, IUniswapV4Facet.getAggregateWithdrawRateLimitKey.selector);
        wires[16] = IEI.Wire(IControllerFull.uniswapV4_getAssetWithdrawRateLimitKey.selector,     IUniswapV4Facet.getAssetWithdrawRateLimitKey.selector);

        beacon.setIntegration("UNISWAP_V4_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireUSDSFacet() internal returns (address facet) {
        facet = address(new USDSFacet({
            usds_ : Ethereum.USDS
        }));

        IEI.Wire[] memory wires = new IEI.Wire[](8);

        wires[0] = IEI.Wire(IControllerFull.usds_VERSION.selector,          IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.usds_usds.selector,             IUSDSFacet.usds.selector);
        wires[2] = IEI.Wire(IControllerFull.usds_setVault.selector,         IUSDSFacet.setVault.selector);
        wires[3] = IEI.Wire(IControllerFull.usds_mint.selector,             IUSDSFacet.mint.selector);
        wires[4] = IEI.Wire(IControllerFull.usds_burn.selector,             IUSDSFacet.burn.selector);
        wires[5] = IEI.Wire(IControllerFull.usds_vault.selector,            IUSDSFacet.vault.selector);
        wires[6] = IEI.Wire(IControllerFull.usds_mintRateLimitKey.selector, IUSDSFacet.mintRateLimitKey.selector);
        wires[7] = IEI.Wire(IControllerFull.usds_burnRateLimitKey.selector, IUSDSFacet.burnRateLimitKey.selector);

        beacon.setIntegration("USDS_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireWEETHFacet() internal returns (address facet) {
        facet = address(new WEETHFacet({
            weeth_ : Ethereum.WEETH,
            weth_  : Ethereum.WETH
        }));

        IEI.Wire[] memory wires = new IEI.Wire[](9);

        wires[0] = IEI.Wire(IControllerFull.weeth_VERSION.selector,                        IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.weeth_weeth.selector,                          IWEETHFacet.weeth.selector);
        wires[2] = IEI.Wire(IControllerFull.weeth_weth.selector,                           IWEETHFacet.weth.selector);
        wires[3] = IEI.Wire(IControllerFull.weeth_deposit.selector,                        IWEETHFacet.deposit.selector);
        wires[4] = IEI.Wire(IControllerFull.weeth_requestWithdraw.selector,                IWEETHFacet.requestWithdraw.selector);
        wires[5] = IEI.Wire(IControllerFull.weeth_claimWithdrawal.selector,                IWEETHFacet.claimWithdrawal.selector);
        wires[6] = IEI.Wire(IControllerFull.weeth_getDepositRateLimitKey.selector,         IWEETHFacet.getDepositRateLimitKey.selector);
        wires[7] = IEI.Wire(IControllerFull.weeth_getRequestWithdrawRateLimitKey.selector, IWEETHFacet.getRequestWithdrawRateLimitKey.selector);
        wires[8] = IEI.Wire(IControllerFull.weeth_getClaimWithdrawRateLimitKey.selector,   IWEETHFacet.getClaimWithdrawRateLimitKey.selector);

        beacon.setIntegration("WEETH_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireWrapProxyETHFacet() internal returns (address facet) {
        facet = address(new WrapProxyETHFacet({
            weth_ : Ethereum.WETH
        }));

        IEI.Wire[] memory wires = new IEI.Wire[](4);

        wires[0] = IEI.Wire(IControllerFull.wrapProxyETH_VERSION.selector,          IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.wrapProxyETH_weth.selector,             IWrapProxyETHFacet.weth.selector);
        wires[2] = IEI.Wire(IControllerFull.wrapProxyETH_wrapAll.selector,          IWrapProxyETHFacet.wrapAll.selector);
        wires[3] = IEI.Wire(IControllerFull.wrapProxyETH_wrapRateLimitKey.selector, IWrapProxyETHFacet.wrapRateLimitKey.selector);

        beacon.setIntegration("WRAP_PROXY_ETH_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireWSTETHFacet() internal returns (address facet) {
        facet = address(new WSTETHFacet({
            weth_          : Ethereum.WETH,
            withdrawQueue_ : Ethereum.WSTETH_WITHDRAW_QUEUE,
            wsteth_        : Ethereum.WSTETH
        }));

        IEI.Wire[] memory wires = new IEI.Wire[](10);

        wires[0] = IEI.Wire(IControllerFull.wsteth_VERSION.selector,                     IFacet.VERSION.selector);
        wires[1] = IEI.Wire(IControllerFull.wsteth_weth.selector,                        IWSTETHFacet.weth.selector);
        wires[2] = IEI.Wire(IControllerFull.wsteth_withdrawQueue.selector,               IWSTETHFacet.withdrawQueue.selector);
        wires[3] = IEI.Wire(IControllerFull.wsteth_wsteth.selector,                      IWSTETHFacet.wsteth.selector);
        wires[4] = IEI.Wire(IControllerFull.wsteth_deposit.selector,                     IWSTETHFacet.deposit.selector);
        wires[5] = IEI.Wire(IControllerFull.wsteth_requestWithdraw.selector,             IWSTETHFacet.requestWithdraw.selector);
        wires[6] = IEI.Wire(IControllerFull.wsteth_claimWithdrawal.selector,             IWSTETHFacet.claimWithdrawal.selector);
        wires[7] = IEI.Wire(IControllerFull.wsteth_depositRateLimitKey.selector,         IWSTETHFacet.depositRateLimitKey.selector);
        wires[8] = IEI.Wire(IControllerFull.wsteth_requestWithdrawRateLimitKey.selector, IWSTETHFacet.requestWithdrawRateLimitKey.selector);
        wires[9] = IEI.Wire(IControllerFull.wsteth_claimWithdrawRateLimitKey.selector,   IWSTETHFacet.claimWithdrawRateLimitKey.selector);

        beacon.setIntegration("WSTETH_FACET", IEI.Config({
            facet : facet,
            wires : wires
        }));
    }

}
