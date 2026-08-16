-- MUST NOT TYPE-CHECK (UNIT-04): adding a Nominal price to a Real one.
-- Deflation is always explicit. Expected error: Couldn't match type
-- 'Nominal with 'Real 'CPI.
{-# LANGUAGE DataKinds #-}
module ValuationMix where

import Kalecky.Types.Prices.Price (Price, addPrice, price)
import Kalecky.Types.Prices.PriceIndex (PriceIndex (..))
import Kalecky.Types.Units.CompoundUnit (per)
import Kalecky.Types.Units.MoneyUnit (Denomination (..))
import Kalecky.Types.Units.Unit (unit)
import Kalecky.Types.Valuation (Valuation (..))

bad =
  addPrice
    (price (per (unit Raw 100) (unit Raw 2)) :: Price 'Nominal Denomination Denomination)
    (price (per (unit Raw 100) (unit Raw 2)) :: Price ('Real 'CPI) Denomination Denomination)
