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

import { IEnumerableIntegrations } from "../lib/diamond-pau/src/interfaces/IEnumerableIntegrations.sol";

import { IMainnetControllerFull } from "../lib/diamond-pau/test/interfaces/IMainnetControllerFull.sol";

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

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](6);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setAaveMaxSlippage.selector,
            IAaveFacet.setMaxSlippage.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getAaveMaxSlippage.selector,
            IAaveFacet.getMaxSlippage.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.depositAave.selector,
            IAaveFacet.deposit.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.withdrawAave.selector,
            IAaveFacet.withdraw.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getAaveDepositRateLimitKey.selector,
            IAaveFacet.getDepositRateLimitKey.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getAaveWithdrawRateLimitKey.selector,
            IAaveFacet.getWithdrawRateLimitKey.selector
        );

        beacon.setIntegration("AAVE_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireBasinFacet() internal returns (address facet) {
        facet = address(new BasinFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](4);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.depositBasin.selector,
            IBasinFacet.deposit.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.withdrawBasin.selector,
            IBasinFacet.withdraw.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getBasinDepositRateLimitKey.selector,
            IBasinFacet.getDepositRateLimitKey.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getBasinWithdrawRateLimitKey.selector,
            IBasinFacet.getWithdrawRateLimitKey.selector
        );

        beacon.setIntegration("BASIN_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireCCTPFacet() internal returns (address facet) {
        facet = address(new CCTPFacet({
            cctp_ : Ethereum.CCTP_TOKEN_MESSENGER,
            usdc_ : Ethereum.USDC
        }));

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](8);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setCCTPMaxFeeCap.selector,
            ICCTPFacet.setMaxFeeCap.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setCCTPMintRecipient.selector,
            ICCTPFacet.setMintRecipient.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.transferUSDCToCCTP.selector,
            ICCTPFacet.transfer.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.transferUSDCToCCTPWithFee.selector,
            ICCTPFacet.transferWithFee.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getCCTPMaxFeeCap.selector,
            ICCTPFacet.maxFeeCap.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.toCCTPRateLimitKey.selector,
            ICCTPFacet.toCCTPRateLimitKey.selector
        );
        wires[6] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getCCTPMintRecipient.selector,
            ICCTPFacet.getMintRecipient.selector
        );
        wires[7] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getCCTPToDomainRateLimitKey.selector,
            ICCTPFacet.getToDomainRateLimitKey.selector
        );

        beacon.setIntegration("CCTP_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireCentrifugeFacet() internal returns (address facet) {
        facet = address(new CentrifugeFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](12);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setCentrifugeRecipient.selector,
            ICentrifugeFacet.setRecipient.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.cancelCentrifugeDepositRequest.selector,
            ICentrifugeFacet.cancelDepositRequest.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.claimCentrifugeCancelDepositRequest.selector,
            ICentrifugeFacet.claimCancelDepositRequest.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.cancelCentrifugeRedeemRequest.selector,
            ICentrifugeFacet.cancelRedeemRequest.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.claimCentrifugeCancelRedeemRequest.selector,
            ICentrifugeFacet.claimCancelRedeemRequest.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.transferSharesCentrifuge.selector,
            ICentrifugeFacet.transferShares.selector
        );
        wires[6] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getCentrifugeRecipient.selector,
            ICentrifugeFacet.getRecipient.selector
        );
        wires[7] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getCentrifugeCancelDepositRateLimitKey.selector,
            ICentrifugeFacet.getCancelDepositRateLimitKey.selector
        );
        wires[8] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getCentrifugeClaimCancelDepositRateLimitKey.selector,
            ICentrifugeFacet.getClaimCancelDepositRateLimitKey.selector
        );
        wires[9] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getCentrifugeCancelRedeemRateLimitKey.selector,
            ICentrifugeFacet.getCancelRedeemRateLimitKey.selector
        );
        wires[10] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getCentrifugeClaimCancelRedeemRateLimitKey.selector,
            ICentrifugeFacet.getClaimCancelRedeemRateLimitKey.selector
        );
        wires[11] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getCentrifugeTransferRateLimitKey.selector,
            ICentrifugeFacet.getTransferRateLimitKey.selector
        );

        beacon.setIntegration("CENTRIFUGE_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireCurveFacet() internal returns (address facet) {
        facet = address(new CurveFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](9);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setCurveMaxSlippage.selector,
            ICurveFacet.setMaxSlippage.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getCurveMaxSlippage.selector,
            ICurveFacet.getMaxSlippage.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.swapCurve.selector,
            ICurveFacet.swap.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.addLiquidityCurve.selector,
            ICurveFacet.addLiquidity.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.removeLiquidityCurve.selector,
            ICurveFacet.removeLiquidity.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getCurveAggregateDepositRateLimitKey.selector,
            ICurveFacet.getAggregateDepositRateLimitKey.selector
        );
        wires[6] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getCurveAssetDepositRateLimitKey.selector,
            ICurveFacet.getAssetDepositRateLimitKey.selector
        );
        wires[7] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getCurveSwapRateLimitKey.selector,
            ICurveFacet.getSwapRateLimitKey.selector
        );
        wires[8] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getCurveWithdrawRateLimitKey.selector,
            ICurveFacet.getWithdrawRateLimitKey.selector
        );

        beacon.setIntegration("CURVE_FACET", IEnumerableIntegrations.Config({
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

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](2);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.swapUSDSToDAI.selector,
            IDAIUSDSFacet.swapUSDSToDAI.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.swapDAIToUSDS.selector,
            IDAIUSDSFacet.swapDAIToUSDS.selector
        );

        beacon.setIntegration("DAIUSDS_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireERC4626Facet() internal returns (address facet) {
        facet = address(new ERC4626Facet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](8);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setMaxExchangeRate.selector,
            IERC4626Facet.setMaxExchangeRate.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.depositERC4626.selector,
            IERC4626Facet.deposit.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.withdrawERC4626.selector,
            IERC4626Facet.withdraw.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.redeemERC4626.selector,
            IERC4626Facet.redeem.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.EXCHANGE_RATE_PRECISION.selector,
            IERC4626Facet.EXCHANGE_RATE_PRECISION.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.maxExchangeRates.selector,
            IERC4626Facet.getMaxExchangeRate.selector
        );
        wires[6] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getERC4626DepositRateLimitKey.selector,
            IERC4626Facet.getDepositRateLimitKey.selector
        );
        wires[7] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getERC4626WithdrawRateLimitKey.selector,
            IERC4626Facet.getWithdrawRateLimitKey.selector
        );

        beacon.setIntegration("ERC4626_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireERC7540Facet() internal returns (address facet) {
        facet = address(new ERC7540Facet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](8);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.requestDepositERC7540.selector,
            IERC7540Facet.requestDeposit.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.claimDepositERC7540.selector,
            IERC7540Facet.claimDeposit.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.requestRedeemERC7540.selector,
            IERC7540Facet.requestRedeem.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.claimRedeemERC7540.selector,
            IERC7540Facet.claimRedeem.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getERC7540RequestDepositRateLimitKey.selector,
            IERC7540Facet.getRequestDepositRateLimitKey.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getERC7540ClaimDepositRateLimitKey.selector,
            IERC7540Facet.getClaimDepositRateLimitKey.selector
        );
        wires[6] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getERC7540RequestRedeemRateLimitKey.selector,
            IERC7540Facet.getRequestRedeemRateLimitKey.selector
        );
        wires[7] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getERC7540ClaimRedeemRateLimitKey.selector,
            IERC7540Facet.getClaimRedeemRateLimitKey.selector
        );

        beacon.setIntegration("ERC7540_FACET", IEnumerableIntegrations.Config({
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

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](13);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setEthenaDelegatedSigner.selector,
            IEthenaFacet.setDelegatedSigner.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.removeEthenaDelegatedSigner.selector,
            IEthenaFacet.removeDelegatedSigner.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.prepareUSDeMint.selector,
            IEthenaFacet.prepareMint.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.prepareUSDeBurn.selector,
            IEthenaFacet.prepareBurn.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.cooldownAssetsSUSDe.selector,
            IEthenaFacet.cooldownAssets.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.cooldownSharesSUSDe.selector,
            IEthenaFacet.cooldownShares.selector
        );
        wires[6] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.unstakeSUSDe.selector,
            IEthenaFacet.unstake.selector
        );
        wires[7] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setEthenaDelegatedSignerRateLimitKey.selector,
            IEthenaFacet.setDelegatedSignerRateLimitKey.selector
        );
        wires[8] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.removeEthenaDelegatedSignerRateLimitKey.selector,
            IEthenaFacet.removeDelegatedSignerRateLimitKey.selector
        );
        wires[9] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.usdeMintRateLimitKey.selector,
            IEthenaFacet.mintRateLimitKey.selector
        );
        wires[10] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.usdeBurnRateLimitKey.selector,
            IEthenaFacet.burnRateLimitKey.selector
        );
        wires[11] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.usdeCooldownRateLimitKey.selector,
            IEthenaFacet.cooldownRateLimitKey.selector
        );
        wires[12] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.usdeUnstakeRateLimitKey.selector,
            IEthenaFacet.unstakeRateLimitKey.selector
        );

        beacon.setIntegration("USDE_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireFarmFacet() internal returns (address facet) {
        facet = address(new FarmFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](6);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.depositToFarm.selector,
            IFarmFacet.deposit.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.claimRewardFromFarm.selector,
            IFarmFacet.claimReward.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.withdrawFromFarm.selector,
            IFarmFacet.withdraw.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getFarmClaimRewardRateLimitKey.selector,
            IFarmFacet.getClaimRewardRateLimitKey.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getFarmDepositRateLimitKey.selector,
            IFarmFacet.getDepositRateLimitKey.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getFarmWithdrawRateLimitKey.selector,
            IFarmFacet.getWithdrawRateLimitKey.selector
        );

        beacon.setIntegration("FARM_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireLayerZeroFacet() internal returns (address facet) {
        facet = address(new LayerZeroFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](4);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setLayerZeroRecipient.selector,
            ILayerZeroFacet.setRecipient.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.transferTokenLayerZero.selector,
            ILayerZeroFacet.transfer.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.layerZeroRecipients.selector,
            ILayerZeroFacet.getRecipient.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getLayerZeroTransferRateLimitKey.selector,
            ILayerZeroFacet.getTransferRateLimitKey.selector
        );

        beacon.setIntegration("LAYER_ZERO_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireMapleFacet() internal returns (address facet) {
        facet = address(new MapleFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](4);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.requestMapleRedemption.selector,
            IMapleFacet.requestRedemption.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.cancelMapleRedemption.selector,
            IMapleFacet.cancelRedemption.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getMapleCancelRedeemRateLimitKey.selector,
            IMapleFacet.getCancelRedeemRateLimitKey.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getMapleRequestRedeemRateLimitKey.selector,
            IMapleFacet.getRequestRedeemRateLimitKey.selector
        );

        beacon.setIntegration("MAPLE_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireMerklFacet() internal returns (address facet) {
        facet = address(new MerklFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](2);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.toggleOperatorMerkl.selector,
            IMerklFacet.toggleOperator.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getMerklToggleOperatorRateLimitKey.selector,
            IMerklFacet.getToggleOperatorRateLimitKey.selector
        );

        beacon.setIntegration("MERKL_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireOTCFacet() internal returns (address facet) {
        facet = address(new OTCFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](14);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setOTCMaxSlippage.selector,
            IOTCFacet.setMaxSlippage.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setOTCBuffer.selector,
            IOTCFacet.setBuffer.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setOTCRechargeRate.selector,
            IOTCFacet.setRechargeRate.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setOTCWhitelistedAsset.selector,
            IOTCFacet.setIsWhitelisted.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.otcSend.selector,
            IOTCFacet.send.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.otcClaim.selector,
            IOTCFacet.claim.selector
        );
        wires[6] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getOTCBuffer.selector,
            IOTCFacet.getBuffer.selector
        );
        wires[7] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getOTCMaxSlippage.selector,
            IOTCFacet.getMaxSlippage.selector
        );
        wires[8] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getOTCRechargeRate.selector,
            IOTCFacet.getRechargeRate.selector
        );
        wires[9] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.otcWhitelistedAssets.selector,
            IOTCFacet.getIsWhitelisted.selector
        );
        wires[10] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.otcs.selector,
            IOTCFacet.getState.selector
        );
        wires[11] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getOtcClaimWithRecharge.selector,
            IOTCFacet.getClaimWithRecharge.selector
        );
        wires[12] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.isOtcSwapReady.selector,
            IOTCFacet.getIsSwapReady.selector
        );
        wires[13] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getOTCSwapRateLimitKey.selector,
            IOTCFacet.getSwapRateLimitKey.selector
        );

        beacon.setIntegration("OTC_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWirePendleFacet() internal returns (address facet) {
        facet = address(new PendleFacet({
            router_ : GroveEthereum.PENDLE_ROUTER
        }));

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](2);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.redeemPendlePT.selector,
            IPendleFacet.redeem.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getPendleRedeemRateLimitKey.selector,
            IPendleFacet.getRedeemRateLimitKey.selector
        );

        beacon.setIntegration("PENDLE_FACET", IEnumerableIntegrations.Config({
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

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](4);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.swapUSDSToUSDC.selector,
            IPSMFacet.swapUSDSToUSDC.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.swapUSDCToUSDS.selector,
            IPSMFacet.swapUSDCToUSDS.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.psmTo18ConversionFactor.selector,
            IPSMFacet.to18ConversionFactor.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.psmUSDSToUSDCSwapRateLimitKey.selector,
            IPSMFacet.usdsToUSDCSwapRateLimitKey.selector
        );

        beacon.setIntegration("PSM_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireSparkVaultFacet() internal returns (address facet) {
        facet = address(new SparkVaultFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](2);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.takeFromSparkVault.selector,
            ISparkVaultFacet.take.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getSparkVaultTakeRateLimitKey.selector,
            ISparkVaultFacet.getTakeRateLimitKey.selector
        );

        beacon.setIntegration("SPARK_VAULT_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireSuperstateFacet() internal returns (address facet) {
        facet = address(new SuperstateFacet({
            usdc_ : Ethereum.USDC,
            ustb_ : Ethereum.USTB
        }));

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](2);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.subscribeSuperstate.selector,
            ISuperstateFacet.subscribe.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.superstateSubscribeRateLimitKey.selector,
            ISuperstateFacet.subscribeRateLimitKey.selector
        );

        beacon.setIntegration("SUPERSTATE_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireTransferAssetFacet() internal returns (address facet) {
        facet = address(new TransferAssetFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](2);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.transferAsset.selector,
            ITransferAssetFacet.transfer.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getTransferAssetTransferRateLimitKey.selector,
            ITransferAssetFacet.getTransferRateLimitKey.selector
        );

        beacon.setIntegration("TRANSFER_ASSET_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireUniswapV3Facet() internal returns (address facet) {
        facet = address(new UniswapV3Facet({
            positionManager_ : _UNISWAP_V3_POSITION_MANAGER,
            router_          : _UNISWAP_V3_ROUTER
        }));

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](16);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setUniswapV3MaxSlippage.selector,
            IUniswapV3Facet.setMaxSlippage.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setUniswapV3PoolMaxTickDelta.selector,
            IUniswapV3Facet.setMaxTickDelta.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setUniswapV3AddLiquidityLowerTickBound.selector,
            IUniswapV3Facet.setLiquidityLowerTickBound.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setUniswapV3AddLiquidityUpperTickBound.selector,
            IUniswapV3Facet.setLiquidityUpperTickBound.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setUniswapV3TWAPSecondsAgo.selector,
            IUniswapV3Facet.setTWAPSecondsAgo.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.swapUniswapV3.selector,
            IUniswapV3Facet.swap.selector
        );
        wires[6] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.addLiquidityUniswapV3.selector,
            IUniswapV3Facet.addLiquidity.selector
        );
        wires[7] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.removeLiquidityUniswapV3.selector,
            IUniswapV3Facet.removeLiquidity.selector
        );
        wires[8] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getUniswapV3AggregateDepositRateLimitKey.selector,
            IUniswapV3Facet.getAggregateDepositRateLimitKey.selector
        );
        wires[9] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getUniswapV3AssetDepositRateLimitKey.selector,
            IUniswapV3Facet.getAssetDepositRateLimitKey.selector
        );
        wires[10] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getUniswapV3AddLiquidityTickBounds.selector,
            IUniswapV3Facet.getLiquidityTickBounds.selector
        );
        wires[11] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getUniswapV3MaxSlippage.selector,
            IUniswapV3Facet.getMaxSlippage.selector
        );
        wires[12] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getUniswapV3PoolMaxTickDelta.selector,
            IUniswapV3Facet.getMaxTickDelta.selector
        );
        wires[13] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getUniswapV3SwapRateLimitKey.selector,
            IUniswapV3Facet.getSwapRateLimitKey.selector
        );
        wires[14] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getUniswapV3TWAPSecondsAgo.selector,
            IUniswapV3Facet.getTWAPSecondsAgo.selector
        );
        wires[15] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getUniswapV3WithdrawRateLimitKey.selector,
            IUniswapV3Facet.getWithdrawRateLimitKey.selector
        );

        beacon.setIntegration("UNISWAP_V3_FACET", IEnumerableIntegrations.Config({
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

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](12);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setUniswapV4MaxSlippage.selector,
            IUniswapV4Facet.setMaxSlippage.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setUniswapV4TickLimits.selector,
            IUniswapV4Facet.setTickLimits.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.mintPositionUniswapV4.selector,
            IUniswapV4Facet.mintPosition.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.increaseLiquidityUniswapV4.selector,
            IUniswapV4Facet.increasePosition.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.decreaseLiquidityUniswapV4.selector,
            IUniswapV4Facet.decreasePosition.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.swapUniswapV4.selector,
            IUniswapV4Facet.swap.selector
        );
        wires[6] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getUniswapV4AggregateDepositRateLimitKey.selector,
            IUniswapV4Facet.getAggregateDepositRateLimitKey.selector
        );
        wires[7] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getUniswapV4AssetDepositRateLimitKey.selector,
            IUniswapV4Facet.getAssetDepositRateLimitKey.selector
        );
        wires[8] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.uniswapV4MaxSlippages.selector,
            IUniswapV4Facet.getMaxSlippage.selector
        );
        wires[9] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getUniswapV4SwapRateLimitKey.selector,
            IUniswapV4Facet.getSwapRateLimitKey.selector
        );
        wires[10] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.uniswapV4TickLimits.selector,
            IUniswapV4Facet.getTickLimits.selector
        );
        wires[11] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getUniswapV4WithdrawRateLimitKey.selector,
            IUniswapV4Facet.getWithdrawRateLimitKey.selector
        );

        beacon.setIntegration("UNISWAP_V4_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireUSDSFacet() internal returns (address facet) {
        facet = address(new USDSFacet({
            usds_ : Ethereum.USDS
        }));

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](6);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.setUSDSVault.selector,
            IUSDSFacet.setVault.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.mintUSDS.selector,
            IUSDSFacet.mint.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.burnUSDS.selector,
            IUSDSFacet.burn.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.usdsVault.selector,
            IUSDSFacet.vault.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.usdsMintRateLimitKey.selector,
            IUSDSFacet.mintRateLimitKey.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.usdsBurnRateLimitKey.selector,
            IUSDSFacet.burnRateLimitKey.selector
        );

        beacon.setIntegration("USDS_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireWEETHFacet() internal returns (address facet) {
        facet = address(new WEETHFacet({
            weeth_ : Ethereum.WEETH,
            weth_  : Ethereum.WETH
        }));

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](6);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.depositToWeETH.selector,
            IWEETHFacet.deposit.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.requestWithdrawFromWeETH.selector,
            IWEETHFacet.requestWithdraw.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.claimWithdrawalFromWeETH.selector,
            IWEETHFacet.claimWithdrawal.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getWEETHDepositRateLimitKey.selector,
            IWEETHFacet.getDepositRateLimitKey.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getWEETHRequestWithdrawRateLimitKey.selector,
            IWEETHFacet.getRequestWithdrawRateLimitKey.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.getWEETHClaimWithdrawRateLimitKey.selector,
            IWEETHFacet.getClaimWithdrawRateLimitKey.selector
        );

        beacon.setIntegration("WEETH_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireWrapProxyETHFacet() internal returns (address facet) {
        facet = address(new WrapProxyETHFacet({
            weth_ : Ethereum.WETH
        }));

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](2);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.wrapAllProxyETH.selector,
            IWrapProxyETHFacet.wrapAll.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.wrapAllProxyETHRateLimitKey.selector,
            IWrapProxyETHFacet.wrapRateLimitKey.selector
        );

        beacon.setIntegration("WRAP_PROXY_ETH_FACET", IEnumerableIntegrations.Config({
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

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](6);

        wires[0] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.depositToWstETH.selector,
            IWSTETHFacet.deposit.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.requestWithdrawFromWstETH.selector,
            IWSTETHFacet.requestWithdraw.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.claimWithdrawalFromWstETH.selector,
            IWSTETHFacet.claimWithdrawal.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.wstethDepositRateLimitKey.selector,
            IWSTETHFacet.depositRateLimitKey.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.wstethRequestWithdrawRateLimitKey.selector,
            IWSTETHFacet.requestWithdrawRateLimitKey.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IMainnetControllerFull.wstethClaimWithdrawRateLimitKey.selector,
            IWSTETHFacet.claimWithdrawRateLimitKey.selector
        );

        beacon.setIntegration("WSTETH_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

}
