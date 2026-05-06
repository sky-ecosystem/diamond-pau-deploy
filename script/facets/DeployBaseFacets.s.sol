// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.34;

import { Script, stdJson, console } from "../../lib/forge-std/src/Script.sol";

import { ScriptTools } from "../../lib/dss-test/src/ScriptTools.sol";

import { Base }                  from "../../lib/diamond-pau/lib/spark-address-registry/src/Base.sol";
import { Base as GroveBase }     from "../../lib/diamond-pau/lib/grove-address-registry/src/Base.sol";

import { AaveFacet }          from "../../lib/diamond-pau/src/facets/aave/AaveFacet.sol";
import { CurveFacet }         from "../../lib/diamond-pau/src/facets/curve/CurveFacet.sol";
import { ERC4626Facet }       from "../../lib/diamond-pau/src/facets/erc4626/ERC4626Facet.sol";
import { MerklFacet }         from "../../lib/diamond-pau/src/facets/merkl/MerklFacet.sol";
import { PendleFacet }        from "../../lib/diamond-pau/src/facets/pendle/PendleFacet.sol";
import { PSM3Facet }          from "../../lib/diamond-pau/src/facets/psm3/PSM3Facet.sol";
import { SparkVaultFacet }    from "../../lib/diamond-pau/src/facets/spark-vault/SparkVaultFacet.sol";
import { TransferAssetFacet } from "../../lib/diamond-pau/src/facets/transfer-asset/TransferAssetFacet.sol";
import { UniswapV3Facet }     from "../../lib/diamond-pau/src/facets/uniswap-v3/UniswapV3Facet.sol";

import { IAaveFacet }          from "../../lib/diamond-pau/src/facets/aave/IAaveFacet.sol";
import { ICurveFacet }         from "../../lib/diamond-pau/src/facets/curve/ICurveFacet.sol";
import { IERC4626Facet }       from "../../lib/diamond-pau/src/facets/erc4626/IERC4626Facet.sol";
import { IMerklFacet }         from "../../lib/diamond-pau/src/facets/merkl/IMerklFacet.sol";
import { IPendleFacet }        from "../../lib/diamond-pau/src/facets/pendle/IPendleFacet.sol";
import { IPSM3Facet }          from "../../lib/diamond-pau/src/facets/psm3/IPSM3Facet.sol";
import { ISparkVaultFacet }    from "../../lib/diamond-pau/src/facets/spark-vault/ISparkVaultFacet.sol";
import { ITransferAssetFacet } from "../../lib/diamond-pau/src/facets/transfer-asset/ITransferAssetFacet.sol";
import { IUniswapV3Facet }     from "../../lib/diamond-pau/src/facets/uniswap-v3/IUniswapV3Facet.sol";

import { IEnumerableIntegrations } from "../../lib/diamond-pau/src/interfaces/IEnumerableIntegrations.sol";

import { Beacon } from "../../lib/diamond-pau/src/Beacon.sol";

import { IForeignControllerFull } from "../../lib/diamond-pau/test/interfaces/IForeignControllerFull.sol";

contract DeployBaseFacets is Script {

    using stdJson for string;

    /**********************************************************************************************/
    /*** Structs                                                                                ***/
    /**********************************************************************************************/

    struct BaseFacetAddresses {
        address aaveFacet;
        address curveFacet;
        address erc4626Facet;
        address merklFacet;
        address pendleFacet;
        address psm3Facet;
        address sparkVaultFacet;
        address transferAssetFacet;
        address uniswapV3Facet;
    }

    /**********************************************************************************************/
    /*** Constants                                                                              ***/
    /**********************************************************************************************/

    // NOTE: From https://docs.uniswap.org/contracts/v3/reference/deployments/base-deployments.
    address internal constant _UNISWAP_V3_POSITION_MANAGER = 0x03a520b32C04BF3bEEf7BEb72E919cf822Ed34f1;
    address internal constant _UNISWAP_V3_ROUTER           = 0x2626664c2603336E57B271c5C0b26F421741e481;

    /**********************************************************************************************/
    /*** State variables                                                                        ***/
    /**********************************************************************************************/

    Beacon internal beacon;

    /**********************************************************************************************/
    /*** Run function                                                                           ***/
    /**********************************************************************************************/

    function run() external {
        string memory env = vm.envString("ENV");

        vm.createSelectFork(getChain("base").rpcUrl);

        vm.setEnv("FOUNDRY_ROOT_CHAINID",             vm.toString(block.chainid));
        vm.setEnv("FOUNDRY_EXPORTS_OVERWRITE_LATEST", "true");

        string memory fileSlug = string(abi.encodePacked("facets-base-", env));
        string memory config   = ScriptTools.loadConfig(fileSlug);

        beacon = Beacon(config.readAddress(".beacon"));

        console.log("Deploying PAU facets...\n  Chain: Base\n  Env: %s", env);

        vm.startBroadcast();

        BaseFacetAddresses memory facets = _deployAndWireFacets();

        vm.stopBroadcast();

        _exportFacets(facets, fileSlug);
    }

    /**********************************************************************************************/
    /*** Deploy + wire orchestration                                                            ***/
    /**********************************************************************************************/

    function _deployAndWireFacets() internal returns (BaseFacetAddresses memory facets) {
        facets.aaveFacet          = _deployAndWireAaveFacet();
        facets.curveFacet         = _deployAndWireCurveFacet();
        facets.erc4626Facet       = _deployAndWireERC4626Facet();
        facets.merklFacet         = _deployAndWireMerklFacet();
        facets.pendleFacet        = _deployAndWirePendleFacet();
        facets.psm3Facet          = _deployAndWirePSM3Facet();
        facets.sparkVaultFacet    = _deployAndWireSparkVaultFacet();
        facets.transferAssetFacet = _deployAndWireTransferAssetFacet();
        facets.uniswapV3Facet     = _deployAndWireUniswapV3Facet();
    }

    function _exportFacets(BaseFacetAddresses memory facets, string memory fileSlug) internal {
        ScriptTools.exportContract(fileSlug, "aaveFacet",          facets.aaveFacet);
        ScriptTools.exportContract(fileSlug, "curveFacet",         facets.curveFacet);
        ScriptTools.exportContract(fileSlug, "erc4626Facet",       facets.erc4626Facet);
        ScriptTools.exportContract(fileSlug, "merklFacet",         facets.merklFacet);
        ScriptTools.exportContract(fileSlug, "pendleFacet",        facets.pendleFacet);
        ScriptTools.exportContract(fileSlug, "psm3Facet",          facets.psm3Facet);
        ScriptTools.exportContract(fileSlug, "sparkVaultFacet",    facets.sparkVaultFacet);
        ScriptTools.exportContract(fileSlug, "transferAssetFacet", facets.transferAssetFacet);
        ScriptTools.exportContract(fileSlug, "uniswapV3Facet",     facets.uniswapV3Facet);
    }

    /**********************************************************************************************/
    /*** Per-facet deploy + wire helpers                                                        ***/
    /**********************************************************************************************/

    function _deployAndWireAaveFacet() internal returns (address facet) {
        facet = address(new AaveFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](6);

        wires[0] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.setAaveMaxSlippage.selector,
            IAaveFacet.setMaxSlippage.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getAaveMaxSlippage.selector,
            IAaveFacet.getMaxSlippage.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.depositAave.selector,
            IAaveFacet.deposit.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.withdrawAave.selector,
            IAaveFacet.withdraw.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getAaveDepositRateLimitKey.selector,
            IAaveFacet.getDepositRateLimitKey.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getAaveWithdrawRateLimitKey.selector,
            IAaveFacet.getWithdrawRateLimitKey.selector
        );

        beacon.setIntegration("AAVE_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireCurveFacet() internal returns (address facet) {
        facet = address(new CurveFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](9);

        wires[0] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.setCurveMaxSlippage.selector,
            ICurveFacet.setMaxSlippage.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getCurveMaxSlippage.selector,
            ICurveFacet.getMaxSlippage.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.swapCurve.selector,
            ICurveFacet.swap.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.addLiquidityCurve.selector,
            ICurveFacet.addLiquidity.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.removeLiquidityCurve.selector,
            ICurveFacet.removeLiquidity.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getCurveAggregateDepositRateLimitKey.selector,
            ICurveFacet.getAggregateDepositRateLimitKey.selector
        );
        wires[6] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getCurveAssetDepositRateLimitKey.selector,
            ICurveFacet.getAssetDepositRateLimitKey.selector
        );
        wires[7] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getCurveSwapRateLimitKey.selector,
            ICurveFacet.getSwapRateLimitKey.selector
        );
        wires[8] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getCurveWithdrawRateLimitKey.selector,
            ICurveFacet.getWithdrawRateLimitKey.selector
        );

        beacon.setIntegration("CURVE_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireERC4626Facet() internal returns (address facet) {
        facet = address(new ERC4626Facet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](8);

        wires[0] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.setMaxExchangeRate.selector,
            IERC4626Facet.setMaxExchangeRate.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.depositERC4626.selector,
            IERC4626Facet.deposit.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.withdrawERC4626.selector,
            IERC4626Facet.withdraw.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.redeemERC4626.selector,
            IERC4626Facet.redeem.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.EXCHANGE_RATE_PRECISION.selector,
            IERC4626Facet.EXCHANGE_RATE_PRECISION.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.maxExchangeRates.selector,
            IERC4626Facet.getMaxExchangeRate.selector
        );
        wires[6] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getERC4626DepositRateLimitKey.selector,
            IERC4626Facet.getDepositRateLimitKey.selector
        );
        wires[7] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getERC4626WithdrawRateLimitKey.selector,
            IERC4626Facet.getWithdrawRateLimitKey.selector
        );

        beacon.setIntegration("ERC4626_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireMerklFacet() internal returns (address facet) {
        facet = address(new MerklFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](2);

        wires[0] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.toggleOperatorMerkl.selector,
            IMerklFacet.toggleOperator.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getMerklToggleOperatorRateLimitKey.selector,
            IMerklFacet.getToggleOperatorRateLimitKey.selector
        );

        beacon.setIntegration("MERKL_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWirePendleFacet() internal returns (address facet) {
        facet = address(new PendleFacet({
            router_ : GroveBase.PENDLE_ROUTER
        }));

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](2);

        wires[0] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.redeemPendlePT.selector,
            IPendleFacet.redeem.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getPendleRedeemRateLimitKey.selector,
            IPendleFacet.getRedeemRateLimitKey.selector
        );

        beacon.setIntegration("PENDLE_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWirePSM3Facet() internal returns (address facet) {
        facet = address(new PSM3Facet({
            psm_ : Base.PSM3
        }));

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](4);

        wires[0] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.depositPSM.selector,
            IPSM3Facet.deposit.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.withdrawPSM.selector,
            IPSM3Facet.withdraw.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getPSMDepositRateLimitKey.selector,
            IPSM3Facet.getDepositRateLimitKey.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getPSMWithdrawRateLimitKey.selector,
            IPSM3Facet.getWithdrawRateLimitKey.selector
        );

        beacon.setIntegration("PSM3_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireSparkVaultFacet() internal returns (address facet) {
        facet = address(new SparkVaultFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](2);

        wires[0] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.takeFromSparkVault.selector,
            ISparkVaultFacet.take.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getSparkVaultTakeRateLimitKey.selector,
            ISparkVaultFacet.getTakeRateLimitKey.selector
        );

        beacon.setIntegration("SPARK_VAULT_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

    function _deployAndWireTransferAssetFacet() internal returns (address facet) {
        facet = address(new TransferAssetFacet());

        IEnumerableIntegrations.Wire[] memory wires = new IEnumerableIntegrations.Wire[](2);

        wires[0] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.transferAsset.selector,
            ITransferAssetFacet.transfer.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getTransferAssetTransferRateLimitKey.selector,
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
            IForeignControllerFull.setUniswapV3MaxSlippage.selector,
            IUniswapV3Facet.setMaxSlippage.selector
        );
        wires[1] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.setUniswapV3PoolMaxTickDelta.selector,
            IUniswapV3Facet.setMaxTickDelta.selector
        );
        wires[2] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.setUniswapV3AddLiquidityLowerTickBound.selector,
            IUniswapV3Facet.setLiquidityLowerTickBound.selector
        );
        wires[3] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.setUniswapV3AddLiquidityUpperTickBound.selector,
            IUniswapV3Facet.setLiquidityUpperTickBound.selector
        );
        wires[4] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.setUniswapV3TWAPSecondsAgo.selector,
            IUniswapV3Facet.setTWAPSecondsAgo.selector
        );
        wires[5] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.swapUniswapV3.selector,
            IUniswapV3Facet.swap.selector
        );
        wires[6] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.addLiquidityUniswapV3.selector,
            IUniswapV3Facet.addLiquidity.selector
        );
        wires[7] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.removeLiquidityUniswapV3.selector,
            IUniswapV3Facet.removeLiquidity.selector
        );
        wires[8] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getUniswapV3MaxSlippage.selector,
            IUniswapV3Facet.getMaxSlippage.selector
        );
        wires[9] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getUniswapV3PoolMaxTickDelta.selector,
            IUniswapV3Facet.getMaxTickDelta.selector
        );
        wires[10] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getUniswapV3AddLiquidityTickBounds.selector,
            IUniswapV3Facet.getLiquidityTickBounds.selector
        );
        wires[11] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getUniswapV3TWAPSecondsAgo.selector,
            IUniswapV3Facet.getTWAPSecondsAgo.selector
        );
        wires[12] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getUniswapV3AggregateDepositRateLimitKey.selector,
            IUniswapV3Facet.getAggregateDepositRateLimitKey.selector
        );
        wires[13] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getUniswapV3AssetDepositRateLimitKey.selector,
            IUniswapV3Facet.getAssetDepositRateLimitKey.selector
        );
        wires[14] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getUniswapV3SwapRateLimitKey.selector,
            IUniswapV3Facet.getSwapRateLimitKey.selector
        );
        wires[15] = IEnumerableIntegrations.Wire(
            IForeignControllerFull.getUniswapV3WithdrawRateLimitKey.selector,
            IUniswapV3Facet.getWithdrawRateLimitKey.selector
        );

        beacon.setIntegration("UNISWAP_V3_FACET", IEnumerableIntegrations.Config({
            facet : facet,
            wires : wires
        }));
    }

}
