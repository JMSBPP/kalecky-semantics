-- | Growth rates.
--
-- @
-- GrowthRate(x)
-- │
-- └── CommonGrowthRate(x, y)
-- @
--
-- A 'GrowthRate' is the dimensionless relative change \(\Delta x / x\)
-- as an EXACT signed 'Rational' (5% ≡ 1/20) — an independent
-- primitive, not derived from Gap or Delta. 'growthFrom' builds one
-- from two realized observations; @Delta (GrowthRate x)@ carries
-- absolute rate changes (the CASO PRUEBA Tasa→Tasa "+20bp" ≡ 1/500).
--
-- 'CommonGrowthRate' witnesses balanced growth: two variables growing
-- at the SAME rate ('mkCommonGrowthRate' is 'Just' exactly on equal
-- rates — decidable because rates are exact Rationals).
module Kalecky.Operators.GrowthRate
  ( GrowthRate
  , growthRate
  , rate
  , HasMagnitude (..)
  , growthFrom
  , CommonGrowthRate
  , mkCommonGrowthRate
  , commonRate
  ) where

import Data.Ratio ((%))

import Kalecky.Operators.Gap (SignedDiff (..))
import Kalecky.Types.Prices.Price (Price, priceRatio)
import Kalecky.Types.Units.CompoundUnit (denominator, numerator)
import Kalecky.Types.Units.Unit (Unit, value)

-- | The exact relative change of @x@.
newtype GrowthRate x = GrowthRate Rational
  deriving (Eq, Ord, Show)

-- | Rates may also arrive as estimates — direct exact construction.
growthRate :: Rational -> GrowthRate x
growthRate = undefined

-- | The rate as an exact Rational.
rate :: GrowthRate x -> Rational
rate = undefined

-- | Carriers with an exact Rational magnitude.
class HasMagnitude x where
  magnitude :: x -> Rational

instance HasMagnitude (Unit b) where
  magnitude = undefined

instance HasMagnitude (Price v a b) where
  magnitude = undefined

-- | \((m_{after} - m_{before}) / m_{before}\), exactly; 'Nothing' on a
-- zero base.
growthFrom :: HasMagnitude x => x -> x -> Maybe (GrowthRate x)
growthFrom = undefined

-- | Rates admit signed exact differences — @Delta (GrowthRate x)@ is
-- the absolute rate-change carrier (+20bp ≡ 1/500).
instance SignedDiff (GrowthRate x) where
  type Diff (GrowthRate x) = Rational
  sdiff = undefined

-- | Witness that @a@ and @b@ grow at the same rate.
newtype CommonGrowthRate a b = CommonGrowthRate Rational
  deriving (Eq, Show)

-- | 'Just' exactly when the two rates are equal.
mkCommonGrowthRate :: GrowthRate a -> GrowthRate b -> Maybe (CommonGrowthRate a b)
mkCommonGrowthRate = undefined

-- | The shared rate.
commonRate :: CommonGrowthRate a b -> Rational
commonRate = undefined
