// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ZkSyncScript} from "solidity-utils/contracts/utils/ScriptUtils.sol";
import {AaveProtocolDataProvider, IPool} from "aave-v3-origin/contracts/helpers/AaveProtocolDataProvider.sol";
import {PoolConfiguratorInstance} from "aave-v3-origin/contracts/instances/PoolConfiguratorInstance.sol";
import {ATokenInstance} from "aave-v3-origin/contracts/instances/ATokenInstance.sol";
import {VariableDebtTokenInstance} from "aave-v3-origin/contracts/instances/VariableDebtTokenInstance.sol";
import {IPoolAddressesProvider, IReserveInterestRateStrategy} from "aave-address-book/AaveV3.sol";
import {AaveV3ZkSync, AaveV3ZkSyncAssets} from "aave-address-book/AaveV3ZkSync.sol";
import {GovernanceV3ZkSync} from "aave-address-book/GovernanceV3ZkSync.sol";
import {PoolInstance} from "aave-v3-origin/contracts/instances/PoolInstance.sol";

import {AaveV3ConfigEngine, IAaveV3ConfigEngine, CapsEngine, BorrowEngine, CollateralEngine, RateEngine, PriceFeedEngine, EModeEngine, ListingEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/AaveV3ConfigEngine.sol';
import {IPoolConfigurator} from "aave-v3-origin/contracts/interfaces/IPoolConfigurator.sol";
import {IAaveOracle} from "aave-v3-origin/contracts/interfaces/IAaveOracle.sol";

import {UpgradePayload} from "../../src/UpgradePayload.sol";

library DeploymentLibrary {
  struct DeployParameters {
    address poolAddressesProvider;
    address pool;
    address interestRateStrategy;
    address rewardsController;
    address treasury;
  }

  function _deployZKSync() internal returns (address) {
    _deployConfigEngine(
      address(AaveV3ZkSync.POOL_ADDRESSES_PROVIDER),
      address(AaveV3ZkSyncAssets.WETH_INTEREST_RATE_STRATEGY),
      AaveV3ZkSync.DEFAULT_INCENTIVES_CONTROLLER,
      address(AaveV3ZkSync.COLLECTOR)
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
      0x281aEbeEF96d324CdE817758Fa46E11167549B2d, // aToken
      0xa4D99aDF4EB2A2fc15eba5859cbF9163dBFACaF8, // vTokenImpl
      engineConstants, engineLibraries
    );
  }
}

library Create2Utils {
  function _create2Deploy(bytes32 salt, bytes memory bytecode) internal returns (address) {
    address deployedAt;
    assembly {
      deployedAt := create2(0, add(bytecode, 32), mload(bytecode), salt)
    }
    require(deployedAt != address(0), "Create2: Failed on deploy");
    return deployedAt;
  }
}

contract Deployzksync is ZkSyncScript {
  function run() external broadcast {
    DeploymentLibrary._deployZKSync();
  }
}
