-- MUST NOT TYPE-CHECK: a LaborGroup key cannot index a CapitalGroup state vector.
{-# LANGUAGE DataKinds #-}
module GroupMix where

import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.Groups.Capital (CapitalGroup)
import Kalecky.Types.Groups.Labor (LaborGroup (..))
import Kalecky.Types.Stocks.StateVector (StateVector, component)
import Kalecky.Types.Units.MoneyUnit (MoneyBasis)
import Kalecky.Types.Units.Unit (Unit)

bad :: StateVector CapitalGroup (MoneyBasis COP) -> Unit (MoneyBasis COP)
bad v = component LF v
