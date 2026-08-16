-- | Dimensional kernel: 'Scale'.
--
-- \(s (b,i) := b^{i}\)
--
-- A 'Scale' is an exact positive multiplier. Its data constructor is
-- hidden (UNIT-01: smart constructors only): construct via 'scale'
-- (checked, @b >= 1@) or a per-basis scale function in the unit
-- modules ("Kalecky.Types.Units.MoneyUnit", "Kalecky.Types.Units.LaborUnit",
-- "Kalecky.Types.Units.TimeUnit").
module Kalecky.Types.Numerics
  ( Scale
  , scale
  , scaleFactor
  ) where

import Numeric.Natural (Natural)

-- | An exact positive multiplier attached to a unit basis.
newtype Scale = Scale Natural
  deriving (Eq, Ord, Show)

-- | Scales compose multiplicatively (the scale half of the unit
-- semigroup @u_s(k) · v_h(l)@). Positivity is preserved: a product of
-- factors @>= 1@ is @>= 1@.
instance Semigroup Scale where
  Scale a <> Scale b = Scale (a * b)

-- | \(s(b,i) = b^i\), defined only for base @b >= 1@ — positivity by
-- construction.
scale :: Natural -> Natural -> Maybe Scale
scale b i
  | b >= 1 = Just (Scale (b ^ i))
  | otherwise = Nothing

-- | Extract the Natural multiplier of a 'Scale'.
scaleFactor :: Scale -> Natural
scaleFactor (Scale n) = n
