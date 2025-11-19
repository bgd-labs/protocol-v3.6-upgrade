// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.10;

import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {IPool, DataTypes} from "aave-v3-origin/contracts/interfaces/IPool.sol";
import {IPoolConfigurator} from "aave-v3-origin/contracts/interfaces/IPoolConfigurator.sol";
import {IPoolAddressesProvider} from "aave-v3-origin/contracts/interfaces/IPoolAddressesProvider.sol";
import {ConfiguratorInputTypes} from "aave-v3-origin/contracts/protocol/libraries/types/ConfiguratorInputTypes.sol";
import {IncentivizedERC20} from "aave-v3-origin/contracts/protocol/tokenization/base/IncentivizedERC20.sol";
import {EModeConfiguration} from "aave-v3-origin/contracts/protocol/libraries/configuration/EModeConfiguration.sol";
import {ReserveConfiguration} from "aave-v3-origin/contracts/protocol/libraries/configuration/ReserveConfiguration.sol";

/**
 * @title UpgradePayload
 * @notice Upgrade payload to upgrade the Aave v3.5 to v3.6
 * @author BGD Labs
 */
contract UpgradePayload {
  using EModeConfiguration for uint128;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

  struct ConstructorParams {
    IPoolAddressesProvider poolAddressesProvider;
    address poolImpl;
    address poolConfiguratorImpl;
    address aTokenImpl;
    address vTokenImpl;
  }

  error WrongAddresses();

  IPoolAddressesProvider public immutable POOL_ADDRESSES_PROVIDER;
  IPool public immutable POOL;
  IPoolConfigurator public immutable POOL_CONFIGURATOR;

  address public immutable POOL_IMPL;
  address public immutable POOL_CONFIGURATOR_IMPL;
  address public immutable A_TOKEN_IMPL;
  address public immutable V_TOKEN_IMPL;

  constructor(ConstructorParams memory params) {
    POOL_ADDRESSES_PROVIDER = params.poolAddressesProvider;

    IPool pool = IPool(params.poolAddressesProvider.getPool());
    POOL = pool;
    POOL_CONFIGURATOR = IPoolConfigurator(params.poolAddressesProvider.getPoolConfigurator());

    if (IPool(params.poolImpl).ADDRESSES_PROVIDER() != params.poolAddressesProvider) {
      revert WrongAddresses();
    }
    POOL_IMPL = params.poolImpl;
    POOL_CONFIGURATOR_IMPL = params.poolConfiguratorImpl;

    if (IncentivizedERC20(params.aTokenImpl).POOL() != pool || IncentivizedERC20(params.vTokenImpl).POOL() != pool) {
      revert WrongAddresses();
    }
    A_TOKEN_IMPL = params.aTokenImpl;
    V_TOKEN_IMPL = params.vTokenImpl;
  }

  function execute() external virtual {
    _defaultUpgrade();
  }

  function _defaultUpgrade() internal {
    // 1. Upgrade `Pool` implementation.
    POOL_ADDRESSES_PROVIDER.setPoolImpl(POOL_IMPL);
    POOL_ADDRESSES_PROVIDER.setPoolConfiguratorImpl(POOL_CONFIGURATOR_IMPL);

    // 2. Update AToken and VariableDebtToken implementations for all reserves.
    address[] memory reserves = POOL.getReservesList();
    uint256 length = reserves.length;
    uint128 collateralEnabledBitmap;
    for (uint256 i = 0; i < length; i++) {
      address reserve = reserves[i];
      if (_needToUpdateReserveAToken(reserve)) {
        POOL_CONFIGURATOR.updateAToken(_prepareATokenUpdateInfo(reserve));
      }

      if (_needToUpdateReserveVToken(reserve)) {
        POOL_CONFIGURATOR.updateVariableDebtToken(_prepareVTokenUpdateInfo(reserve));
      }
      DataTypes.ReserveDataLegacy memory data = POOL.getReserveData(reserve);
      // We know that there are currently no gaps > 1, inside the eMode configs
      // as a precaution, we still assume gaps up to 10
      uint256 emptyCounter = 0;
      if (data.configuration.getLtv() == 0) {
        for (uint256 j = 1; j <= type(uint8).max; j++) {
          collateralEnabledBitmap = POOL.getEModeCategoryCollateralBitmap(uint8(j));
          if (collateralEnabledBitmap.isReserveEnabledOnBitmap(data.id)) {
            POOL_CONFIGURATOR.setAssetLtvzeroInEMode(reserve, uint8(j), true);
            if (emptyCounter != 0) emptyCounter = 0;
          }
          if (collateralEnabledBitmap == 0) {
            emptyCounter++;
          }
          if (emptyCounter >= 10) {
            break;
          }
        }
      }
    }
  }

  function _prepareATokenUpdateInfo(address underlyingToken)
    internal
    view
    returns (ConfiguratorInputTypes.UpdateATokenInput memory)
  {
    IERC20Metadata aToken = IERC20Metadata(POOL.getReserveAToken(underlyingToken));

    return ConfiguratorInputTypes.UpdateATokenInput({
      asset: underlyingToken, implementation: A_TOKEN_IMPL, params: "", name: aToken.name(), symbol: aToken.symbol()
    });
  }

  function _prepareVTokenUpdateInfo(address underlyingToken)
    internal
    view
    returns (ConfiguratorInputTypes.UpdateDebtTokenInput memory)
  {
    IERC20Metadata vToken = IERC20Metadata(POOL.getReserveVariableDebtToken(underlyingToken));

    return ConfiguratorInputTypes.UpdateDebtTokenInput({
      asset: underlyingToken, implementation: V_TOKEN_IMPL, params: "", name: vToken.name(), symbol: vToken.symbol()
    });
  }

  function _needToUpdateReserveAToken(address) internal view virtual returns (bool) {
    return true;
  }

  function _needToUpdateReserveVToken(address) internal view virtual returns (bool) {
    return true;
  }
}
