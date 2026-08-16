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
-- exact multiple of finer), like money denominations:
-- @MONTH_BASE = 720 × HOUR_BASE@ exactly.
data TimeBasis = Hour | Month
  deriving (Eq, Ord, Show, Enum, Bounded)

-- | @TimeScale@: @HOUR_BASE = 3600@ (seconds in an hour, user decision
-- 2026-08-15); @MONTH_BASE = 2592000@ (seconds in a 30-day month).
timeScale :: TimeBasis -> Scale
timeScale b = case b of
  Hour -> undefined
  Month -> known 2592000
  where
    known n = case scale n 1 of
      Just s -> s
      Nothing -> error "unreachable: time base >= 1"

instance HasScale TimeBasis where
  scaleOf = timeScale
