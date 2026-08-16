-- MUST NOT TYPE-CHECK (UNIT-04): adding money to worker counts.
-- Expected error: Couldn't match type MoneyBasis 'COP with WorkerBasis.
{-# LANGUAGE DataKinds, TypeApplications #-}
module DimensionMix where

import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.Units.LaborUnit (WorkerBasis (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..), moneyUnit)
import Kalecky.Types.Units.Unit (add, unit)

bad = do
  u <- moneyUnit @COP Raw 50
  add u (unit Worker 5)
