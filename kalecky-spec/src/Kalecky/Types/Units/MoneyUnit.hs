-- | Money units.
--
-- @MoneyUnit = MoneyUnit { currency :: Currency, unit :: Unit }@ —
-- money denominations ('Raw' | 'Thousand' | 'Million' | 'Billion',
-- Draft.plk's @denomination_scale@) and, once the currency tag lands,
-- currency-tagged money construction quantized by the tradeable base.
module Kalecky.Types.Units.MoneyUnit
  ( Denomination (..)
  , denominationExponent
  , denominationScale
  ) where

import Numeric.Natural (Natural)

import Kalecky.Types.Numerics (Scale, scale)
import Kalecky.Types.Units.Unit (HasScale (..))

-- | Money denominations. Ordering reflects coarseness: 'Raw' is finest.
data Denomination = Raw | Thousand | Million | Billion
  deriving (Eq, Ord, Show, Enum, Bounded)

-- | Power-of-ten exponent per denomination: 0, 3, 6, 9.
denominationExponent :: Denomination -> Natural
denominationExponent = \case
  Raw -> 0
  Thousand -> 3
  Million -> 6
  Billion -> 9

-- | @denomination_scale@: Raw=1, Thousand=10^3, Million=10^6, Billion=10^9.
denominationScale :: Denomination -> Scale
denominationScale d = case scale 10 (denominationExponent d) of
  Just s -> s
  Nothing -> error "unreachable: base 10 >= 1"

instance HasScale Denomination where
  scaleOf = denominationScale
