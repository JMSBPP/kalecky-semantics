-- | Valuation.
--
-- @Valuation = Nominal | Real PriceIndex@
--
-- Promoted via DataKinds: 'Price' carries a type-level @(v :: Valuation)@,
-- so combining a Nominal price with a Real one fails to COMPILE —
-- deflation is always explicit (user decision: no auto-deflate).
module Kalecky.Types.Valuation
  ( Valuation (..)
  , KnownValuation (..)
  ) where

import Data.Proxy (Proxy (..))

import Kalecky.Types.Prices.PriceIndex (KnownPriceIndex (..), PriceIndex)

-- | Nominal, or Real deflated by a named price index.
data Valuation = Nominal | Real PriceIndex
  deriving (Eq, Ord, Show)

-- | Singleton bridge from the type-level valuation tag to its value.
class KnownValuation (v :: Valuation) where
  valuationOf :: Proxy v -> Valuation

instance KnownValuation Nominal where
  valuationOf _ = Nominal

instance KnownPriceIndex p => KnownValuation ('Real p) where
  valuationOf _ = Real (priceIndexOf (Proxy :: Proxy p))
