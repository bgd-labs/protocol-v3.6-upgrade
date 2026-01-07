// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {
  EthereumScript,
  PolygonScript,
  AvalancheScript,
  OptimismScript,
  ArbitrumScript,
  MetisScript,
  BaseScript,
  GnosisScript,
  ScrollScript,
  BNBScript,
  LineaScript,
  SonicScript,
  CeloScript,
  SoneiumScript,
  InkScript,
  PlasmaScript
} from "solidity-utils/contracts/utils/ScriptUtils.sol";

import {GovV3Helpers} from "aave-helpers/src/GovV3Helpers.sol";

import {AaveV3ConfigEngine, IAaveV3ConfigEngine, CapsEngine, BorrowEngine, CollateralEngine, RateEngine, PriceFeedEngine, EModeEngine, ListingEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/AaveV3ConfigEngine.sol';
import {Create2Utils} from 'aave-v3-origin/deployments/contracts/utilities/Create2Utils.sol';

import {PoolConfiguratorInstance} from "aave-v3-origin/contracts/instances/PoolConfiguratorInstance.sol";
import {PoolInstance} from "aave-v3-origin/contracts/instances/PoolInstance.sol";
import {L2PoolInstance} from "aave-v3-origin/contracts/instances/L2PoolInstance.sol";
import {ATokenInstance} from "aave-v3-origin/contracts/instances/ATokenInstance.sol";
import {VariableDebtTokenInstance} from "aave-v3-origin/contracts/instances/VariableDebtTokenInstance.sol";
import {ATokenWithDelegationInstance} from "aave-v3-origin/contracts/instances/ATokenWithDelegationInstance.sol";
import {
  VariableDebtTokenMainnetInstanceGHO
} from "aave-v3-origin/contracts/instances/VariableDebtTokenMainnetInstanceGHO.sol";

import {IPool} from "aave-v3-origin/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "aave-v3-origin/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPoolConfigurator} from "aave-v3-origin/contracts/interfaces/IPoolConfigurator.sol";
import {IAaveOracle} from "aave-v3-origin/contracts/interfaces/IAaveOracle.sol";

import {AaveV3Polygon, AaveV3PolygonAssets} from "aave-address-book/AaveV3Polygon.sol";
import {AaveV3Avalanche, AaveV3AvalancheAssets} from "aave-address-book/AaveV3Avalanche.sol";
import {AaveV3Optimism, AaveV3OptimismAssets} from "aave-address-book/AaveV3Optimism.sol";
import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from "aave-address-book/AaveV3Arbitrum.sol";
import {AaveV3Ethereum, AaveV3EthereumAssets} from "aave-address-book/AaveV3Ethereum.sol";
import {AaveV3BNB, AaveV3BNBAssets} from "aave-address-book/AaveV3BNB.sol";
import {AaveV3Gnosis, AaveV3GnosisAssets} from "aave-address-book/AaveV3Gnosis.sol";
import {AaveV3Scroll, AaveV3ScrollAssets} from "aave-address-book/AaveV3Scroll.sol";
import {AaveV3Base, AaveV3BaseAssets} from "aave-address-book/AaveV3Base.sol";
import {AaveV3Metis, AaveV3MetisAssets} from "aave-address-book/AaveV3Metis.sol";
import {AaveV3EthereumLido, AaveV3EthereumLidoAssets} from "aave-address-book/AaveV3EthereumLido.sol";
import {AaveV3EthereumEtherFi, AaveV3EthereumEtherFiAssets} from "aave-address-book/AaveV3EthereumEtherFi.sol";
import {AaveV3Linea, AaveV3LineaAssets} from "aave-address-book/AaveV3Linea.sol";
import {AaveV3Sonic, AaveV3SonicAssets} from "aave-address-book/AaveV3Sonic.sol";
import {AaveV3Celo, AaveV3CeloAssets} from "aave-address-book/AaveV3Celo.sol";
import {AaveV3Soneium, AaveV3SoneiumAssets} from "aave-address-book/AaveV3Soneium.sol";
import {AaveV3InkWhitelabel, AaveV3InkWhitelabelAssets} from "aave-address-book/AaveV3InkWhitelabel.sol";
import {AaveV3Plasma, AaveV3PlasmaAssets} from "aave-address-book/AaveV3Plasma.sol";

import {UpgradePayload} from "../src/UpgradePayload.sol";
import {UpgradePayloadMainnetCore} from "../src/UpgradePayloadMainnetCore.sol";

library DeploymentLibrary {
  struct DeployParameters {
    address poolAddressesProvider;
    address pool;
    address interestRateStrategy;
    address rewardsController;
    address treasury;
  }
  // rollups

  function _deployOptimism() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3Optimism.POOL_ADDRESSES_PROVIDER),
      address(AaveV3OptimismAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3Optimism.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3Optimism.COLLECTOR)
    );
  }

  function _deployBase() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3Base.POOL_ADDRESSES_PROVIDER),
      address(AaveV3BaseAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3Base.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3Base.COLLECTOR)
    );
  }

  function _deployArbitrum() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3Arbitrum.POOL_ADDRESSES_PROVIDER),
      address(AaveV3ArbitrumAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3Arbitrum.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3Arbitrum.COLLECTOR)
    );
  }

  function _deployInk() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3InkWhitelabel.POOL_ADDRESSES_PROVIDER),
      address(AaveV3InkWhitelabelAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3InkWhitelabel.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3InkWhitelabel.COLLECTOR)
    );
  }

  function _deployPlasma() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3Plasma.POOL_ADDRESSES_PROVIDER),
      address(AaveV3PlasmaAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3Plasma.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3Plasma.COLLECTOR)
    );
  }

  function _deployScroll() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3Scroll.POOL_ADDRESSES_PROVIDER),
      address(AaveV3ScrollAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3Scroll.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3Scroll.COLLECTOR)
    );
  }

  function _deployMetis() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3Metis.POOL_ADDRESSES_PROVIDER),
      address(AaveV3MetisAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3Metis.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3Metis.COLLECTOR)
    );
  }

  // L1s
  function _deployMainnetCore() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3Ethereum.POOL_ADDRESSES_PROVIDER),
      address(AaveV3EthereumAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3Ethereum.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3Ethereum.COLLECTOR)
    );
  }

  function _deployMainnetLido() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3EthereumLido.POOL_ADDRESSES_PROVIDER),
      address(AaveV3EthereumLidoAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3EthereumLido.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3EthereumLido.COLLECTOR)
    );
  }

  function _deployMainnetEtherfi() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3EthereumEtherFi.POOL_ADDRESSES_PROVIDER),
      address(AaveV3EthereumEtherFiAssets.FRAX_INTEREST_RATE_STRATEGY),
      AaveV3EthereumEtherFi.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3EthereumEtherFi.COLLECTOR)
    );
  }

  function _deployGnosis() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3Gnosis.POOL_ADDRESSES_PROVIDER),
      address(AaveV3GnosisAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3Gnosis.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3Gnosis.COLLECTOR)
    );
  }

  function _deployBNB() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3BNB.POOL_ADDRESSES_PROVIDER),
      address(AaveV3BNBAssets.ETH_INTEREST_RATE_STRATEGY),
      AaveV3BNB.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3BNB.COLLECTOR)
    );
  }

  function _deployAvalanche() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3Avalanche.POOL_ADDRESSES_PROVIDER),
      address(AaveV3AvalancheAssets.WETHe_INTEREST_RATE_STRATEGY),
      AaveV3Avalanche.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3Avalanche.COLLECTOR)
    );
  }

  function _deployPolygon() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3Polygon.POOL_ADDRESSES_PROVIDER),
      address(AaveV3PolygonAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3Polygon.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3Polygon.COLLECTOR)
    );
  }

  function _deployLinea() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3Linea.POOL_ADDRESSES_PROVIDER),
      address(AaveV3LineaAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3Linea.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3Linea.COLLECTOR)
    );
  }

  function _deploySonic() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3Sonic.POOL_ADDRESSES_PROVIDER),
      address(AaveV3SonicAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3Sonic.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3Sonic.COLLECTOR)
    );
  }

  function _deployCelo() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3Celo.POOL_ADDRESSES_PROVIDER),
      address(AaveV3CeloAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3Celo.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3Celo.COLLECTOR)
    );
  }

  function _deploySoneium() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3Soneium.POOL_ADDRESSES_PROVIDER),
      address(AaveV3SoneiumAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3Soneium.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3Soneium.COLLECTOR)
    );
  }

  function _deployL2(DeployParameters memory deployParams) internal returns (address) {
    UpgradePayload.ConstructorParams memory payloadParams;

    payloadParams.poolAddressesProvider = IPoolAddressesProvider(deployParams.poolAddressesProvider);
    payloadParams.poolImpl = GovV3Helpers.deployDeterministic(
      type(L2PoolInstance).creationCode,
      abi.encode(deployParams.poolAddressesProvider, deployParams.interestRateStrategy)
    );

    return _deployPayload(deployParams, payloadParams, false);
  }

  function _deployL1(DeployParameters memory deployParams) internal returns (address) {
    UpgradePayload.ConstructorParams memory payloadParams;

    payloadParams.poolAddressesProvider = IPoolAddressesProvider(deployParams.poolAddressesProvider);
    payloadParams.poolImpl = GovV3Helpers.deployDeterministic(
      type(PoolInstance).creationCode, abi.encode(deployParams.poolAddressesProvider, deployParams.interestRateStrategy)
    );

    return _deployPayload({deployParams: deployParams, payloadParams: payloadParams, isMainnetCore: false});
  }

  function _deployMainnetCore(DeployParameters memory deployParams) internal returns (address) {
    UpgradePayload.ConstructorParams memory payloadParams;

    payloadParams.poolAddressesProvider = IPoolAddressesProvider(deployParams.poolAddressesProvider);
    payloadParams.poolImpl = GovV3Helpers.deployDeterministic(
      type(PoolInstance).creationCode, abi.encode(deployParams.poolAddressesProvider, deployParams.interestRateStrategy)
    );

    return _deployPayload({deployParams: deployParams, payloadParams: payloadParams, isMainnetCore: true});
  }

  function _deployPayload(
    DeployParameters memory deployParams,
    UpgradePayload.ConstructorParams memory payloadParams,
    bool isMainnetCore
  ) private returns (address) {
    payloadParams.poolConfiguratorImpl = GovV3Helpers.deployDeterministic(type(PoolConfiguratorInstance).creationCode);

    payloadParams.aTokenImpl = GovV3Helpers.deployDeterministic(
      type(ATokenInstance).creationCode,
      abi.encode(deployParams.pool, deployParams.rewardsController, deployParams.treasury)
    );

    payloadParams.vTokenImpl = GovV3Helpers.deployDeterministic(
      type(VariableDebtTokenInstance).creationCode, abi.encode(deployParams.pool, deployParams.rewardsController)
    );

    if (isMainnetCore) {
      return _deployMainnetCore(payloadParams);
    } else {
      return GovV3Helpers.deployDeterministic(type(UpgradePayload).creationCode, abi.encode(payloadParams));
    }
  }

  function _deployMainnetCore(UpgradePayload.ConstructorParams memory params) private returns (address) {
    address vTokenImplGho = GovV3Helpers.deployDeterministic(
      type(VariableDebtTokenMainnetInstanceGHO).creationCode,
      abi.encode(AaveV3Ethereum.POOL, AaveV3Ethereum.DEFAULT_INCENTIVES_CONTROLLER)
    );

    address aTokenWithDelegationImpl = GovV3Helpers.deployDeterministic(
      type(ATokenWithDelegationInstance).creationCode,
      abi.encode(AaveV3Ethereum.POOL, AaveV3Ethereum.DEFAULT_INCENTIVES_CONTROLLER, AaveV3Ethereum.COLLECTOR)
    );

    return GovV3Helpers.deployDeterministic(
      type(UpgradePayloadMainnetCore).creationCode,
      abi.encode(
        UpgradePayloadMainnetCore.ConstructorMainnetParams({
          poolAddressesProvider: IPoolAddressesProvider(address(AaveV3Ethereum.POOL_ADDRESSES_PROVIDER)),
          poolImpl: params.poolImpl,
          poolConfiguratorImpl: params.poolConfiguratorImpl,
          aTokenImpl: params.aTokenImpl,
          vTokenImpl: params.vTokenImpl,
          vTokenGhoImpl: vTokenImplGho,
          aTokenWithDelegationImpl: aTokenWithDelegationImpl
        })
      )
    );
  }

  function _deployConfigEngine(
    address poolAddressesProvider,
    address rateStrategy,
    address rewardsController,
    address collector
  ) internal {
    IAaveV3ConfigEngine.EngineLibraries memory engineLibraries = IAaveV3ConfigEngine
      .EngineLibraries({
        listingEngine: Create2Utils._create2Deploy('v1', type(ListingEngine).creationCode),
        eModeEngine: Create2Utils._create2Deploy('v1', type(EModeEngine).creationCode),
        borrowEngine: Create2Utils._create2Deploy('v1', type(BorrowEngine).creationCode),
        collateralEngine: Create2Utils._create2Deploy('v1', type(CollateralEngine).creationCode),
        priceFeedEngine: Create2Utils._create2Deploy('v1', type(PriceFeedEngine).creationCode),
        rateEngine: Create2Utils._create2Deploy('v1', type(RateEngine).creationCode),
        capsEngine: Create2Utils._create2Deploy('v1', type(CapsEngine).creationCode)
      });

    address pool = IPoolAddressesProvider(poolAddressesProvider).getPool();
    IAaveV3ConfigEngine.EngineConstants memory engineConstants = IAaveV3ConfigEngine
      .EngineConstants({
        pool: IPool(pool),
        poolConfigurator: IPoolConfigurator(IPoolAddressesProvider(poolAddressesProvider).getPoolConfigurator()),
        defaultInterestRateStrategy: rateStrategy,
        oracle: IAaveOracle(IPoolAddressesProvider(poolAddressesProvider).getPriceOracle()),
        rewardsController: rewardsController,
        collector: collector
      });

    new AaveV3ConfigEngine(
      GovV3Helpers.deployDeterministic(
        type(ATokenInstance).creationCode,
        abi.encode(pool, rewardsController, collector)
      ), // aToken
      GovV3Helpers.deployDeterministic(
        type(VariableDebtTokenInstance).creationCode, abi.encode(pool, rewardsController)
      ), // vTokenImpl
      engineConstants, engineLibraries
    );
  }
}

contract Deploypolygon is PolygonScript {
  function run() external broadcast {
    DeploymentLibrary._deployPolygon();
  }
}

contract Deploygnosis is GnosisScript {
  function run() external broadcast {
    DeploymentLibrary._deployGnosis();
  }
}

contract Deployoptimism is OptimismScript {
  function run() external broadcast {
    DeploymentLibrary._deployOptimism();
  }
}

contract Deployarbitrum is ArbitrumScript {
  function run() external broadcast {
    DeploymentLibrary._deployArbitrum();
  }
}

contract Deployavalanche is AvalancheScript {
  function run() external broadcast {
    DeploymentLibrary._deployAvalanche();
  }
}

contract Deploybase is BaseScript {
  function run() external broadcast {
    DeploymentLibrary._deployBase();
  }
}

contract Deployscroll is ScrollScript {
  function run() external broadcast {
    DeploymentLibrary._deployScroll();
  }
}

contract Deploybnb is BNBScript {
  function run() external broadcast {
    DeploymentLibrary._deployBNB();
  }
}

// metis is broken
contract Deploymetis is MetisScript {
  function run() external broadcast {
    DeploymentLibrary._deployMetis();
  }
}

contract Deploymainnet is EthereumScript {
  function run() external broadcast {
    DeploymentLibrary._deployMainnetCore();
  }
}

contract Deploylido is EthereumScript {
  function run() external broadcast {
    DeploymentLibrary._deployMainnetLido();
  }
}

contract Deployetherfi is EthereumScript {
  function run() external broadcast {
    DeploymentLibrary._deployMainnetEtherfi();
  }
}

contract Deploylinea is LineaScript {
  function run() external broadcast {
    DeploymentLibrary._deployLinea();
  }
}

contract Deploysonic is SonicScript {
  function run() external broadcast {
    DeploymentLibrary._deploySonic();
  }
}

contract Deploycelo is CeloScript {
  function run() external broadcast {
    DeploymentLibrary._deployCelo();
  }
}

contract Deploysoneium is SoneiumScript {
  function run() external broadcast {
    DeploymentLibrary._deploySoneium();
  }
}

contract Deployink is InkScript {
  function run() external broadcast {
    DeploymentLibrary._deployInk();
  }
}

contract Deployplasma is PlasmaScript {
  function run() external broadcast {
    DeploymentLibrary._deployPlasma();
  }
}
