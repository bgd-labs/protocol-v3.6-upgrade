import {IPool, DataTypes} from "aave-v3-origin/contracts/interfaces/IPool.sol";
import {IPoolConfigurator} from "aave-v3-origin/contracts/interfaces/IPoolConfigurator.sol";
import {EModeConfiguration} from "aave-v3-origin/contracts/protocol/libraries/configuration/EModeConfiguration.sol";
import {ReserveConfiguration} from "aave-v3-origin/contracts/protocol/libraries/configuration/ReserveConfiguration.sol";

// TODO: move to stewards repo
contract LtvZeroSteward {
  using EModeConfiguration for uint128;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  IPool immutable POOL;
  IPoolConfigurator immutable POOL_CONFIGURATOR;

  constructor(IPool pool, IPoolConfigurator poolConfigurator) {
    POOL = pool;
    POOL_CONFIGURATOR = poolConfigurator;
  }

  // method intended for non automated emergency actions, where gas does not matter
  function setLtvZero(address asset) external {
    DataTypes.ReserveDataLegacy memory data = POOL.getReserveData(asset);
    if (!data.configuration.getFrozen()) {
      POOL_CONFIGURATOR.setReserveFreeze(asset, true);
    }
    uint8 emptyCounter;
    uint128 collateralEnabledBitmap;
    for (uint8 i = 0; i < 255; i++) {
      collateralEnabledBitmap = POOL.getEModeCategoryCollateralBitmap(i);
      if (collateralEnabledBitmap.isReserveEnabledOnBitmap(data.id)) {
        POOL_CONFIGURATOR.setAssetLtvzeroInEMode(asset, i, true);
        if (emptyCounter != 0) emptyCounter = 0;
      }
      if (collateralEnabledBitmap == 0) {
        emptyCounter++;
      }
      if (emptyCounter >= 5) {
        break;
      }
    }
  }

  function setLtvZero(address asset, uint8[] calldata eModes) external {}
}
