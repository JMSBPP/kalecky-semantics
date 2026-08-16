-- | Prices.
--
-- \(p (u,v) := c_p(u,v)\)
--
-- A price IS a Per-compound unit carrying a type-level valuation:
-- @Price (v :: Valuation) a b@ wraps @Per a b@. Nominal and Real
-- prices are different TYPES, so mixing them fails to compile —
-- deflation is always explicit.
--
-- Restricted arithmetic: 'addPrice' exists only for prices of the
-- same valuation, numerator kind and denominator kind (anything else
-- is a type error — see @test-kalecky/should-fail/@). It is exact
-- rational addition over Naturals: n/d + n'/d' = (n·d' + n'·d)/(d·d').
-- No normalization is performed; 'cancel' reduces same-kind ratios.
module Kalecky.Types.Prices.Price
  ( Price
  , price
  , priceRatio
  , addPrice
  ) where

import Kalecky.Types.Units.CompoundUnit (Per, denominator, numerator, per)
import Kalecky.Types.Units.Unit (add, scaleBy, value)
import Kalecky.Types.Valuation (Valuation)

-- | A valued ratio of units. Constructor hidden (UNIT-01 discipline).
newtype Price (v :: Valuation) a b = Price (Per a b)
  deriving (Eq, Show)

-- | Wrap a unit ratio as a price at a (type-level) valuation.
price :: Per a b -> Price v a b
price = Price

-- | The underlying unit ratio.
priceRatio :: Price v a b -> Per a b
priceRatio = undefined

-- | Exact rational addition: n/d + n'/d' = (n·d' + n'·d)/(d·d').
-- The numerator combination aligns within its kind ('add'), hence
-- Maybe — always Just for the current scale families.
addPrice :: Price v a b -> Price v a b -> Maybe (Price v a b)
addPrice = undefined
