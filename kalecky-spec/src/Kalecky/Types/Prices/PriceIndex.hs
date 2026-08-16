-- | Price indices.
--
-- Opaque index identifiers for now: a 'PriceIndex' names WHICH index a
-- Real valuation deflates by. Numeric index content (base period,
-- index values) arrives with deflation in the domain-vocabulary phase
-- (RealWage = NominalWage / PriceLevel).
module Kalecky.Types.Prices.PriceIndex
  ( PriceIndex (..)
  , KnownPriceIndex (..)
  ) where

import Data.Proxy (Proxy)

-- | Known price indices. Promoted via DataKinds to type-level tags.
data PriceIndex = CPI
  deriving (Eq, Ord, Show, Enum, Bounded)

-- | Singleton bridge from the type-level index tag to its value.
class KnownPriceIndex (p :: PriceIndex) where
  priceIndexOf :: Proxy p -> PriceIndex

instance KnownPriceIndex CPI where
  priceIndexOf _ = undefined
