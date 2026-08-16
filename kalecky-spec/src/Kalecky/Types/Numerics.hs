-- | Dimensional kernel: 'Scale' and the per-basis scale functions.
--
-- \(s (b,i) := b^{i}\)
--
-- A 'Scale' is obtainable ONLY through a per-basis scale function,
-- mirroring @Draft.plk@'s @Scale(ScaleFn, Basis) = ScaleFn(Basis)@:
-- money denominations via 'denominationScale', labor bases via
-- 'laborScale' (@WORKER_BASE@), time bases via 'timeScale'
-- (@MONTH_BASE = 0x278d00 = 2592000@, seconds in a 30-day month).
--
-- The data constructor of 'Scale' is deliberately hidden (UNIT-01:
-- smart constructors only).
module Kalecky.Types.Numerics
  ( Scale
  , scaleFactor
  , Denomination (..)
  , denominationExponent
  , denominationScale
  , LaborBasis (..)
  , laborScale
  , TimeBasis (..)
  , timeScale
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

-- | Extract the Natural multiplier of a 'Scale'.
scaleFactor :: Scale -> Natural
scaleFactor (Scale n) = n

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
denominationScale d = Scale (10 ^ denominationExponent d)

-- | Labor bases. 'LaborHour' arrives with the base-units increment.
data LaborBasis = Worker
  deriving (Eq, Ord, Show, Enum, Bounded)

-- | @LaborScale@: @WORKER_BASE = 1@.
laborScale :: LaborBasis -> Scale
laborScale Worker = Scale 1

-- | Time bases. 'Hour' arrives with the base-units increment (HOUR_BASE open question).
data TimeBasis = Month
  deriving (Eq, Ord, Show, Enum, Bounded)

-- | @TimeScale@: @MONTH_BASE = 2592000@ (seconds in a 30-day month).
timeScale :: TimeBasis -> Scale
timeScale Month = Scale 2592000
