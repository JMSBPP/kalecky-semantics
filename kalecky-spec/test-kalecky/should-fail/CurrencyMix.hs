-- MUST NOT TYPE-CHECK (UNIT-04): adding COP money to USD money.
-- Expected error: Couldn't match type 'COP with 'USD.
{-# LANGUAGE DataKinds, TypeApplications #-}
module CurrencyMix where

import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..), moneyUnit)
import Kalecky.Types.Units.Unit (Unit, add)

bad = do
  u <- moneyUnit @COP Raw 50
  v <- moneyUnit @USD Raw 50
  add u v
