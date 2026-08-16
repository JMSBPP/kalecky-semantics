-- | Time units.
--
-- Time bases are second-denominated: @MONTH_BASE = 0x278d00 = 2592000@
-- (seconds in a 30-day month), mirroring Draft.plk's @TimeScale@.
module Kalecky.Types.Units.TimeUnit
  ( TimeBasis (..)
  , timeScale
  ) where

import Kalecky.Types.Numerics (Scale, scale)
import Kalecky.Types.Units.Unit (HasScale (..))

-- | Time bases. Bases of one kind are exactly alignable (coarser is an
-- exact multiple of finer), like money denominations.
data TimeBasis = Month
  deriving (Eq, Ord, Show, Enum, Bounded)

-- | @TimeScale@: @MONTH_BASE = 2592000@ (seconds in a 30-day month).
timeScale :: TimeBasis -> Scale
timeScale b = case b of
  Month -> known 2592000
  where
    known n = case scale n 1 of
      Just s -> s
      Nothing -> error "unreachable: time base >= 1"

instance HasScale TimeBasis where
  scaleOf = timeScale
