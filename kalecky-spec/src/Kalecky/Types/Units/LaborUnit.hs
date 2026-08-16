-- | Labor units.
--
-- @WORKER_BASE = 1@, mirroring Draft.plk's @LaborScale@. Worker counts
-- and labor time are deliberately DISTINCT types (not constructors of
-- one enum): adding worker-counts to labor-hours has no canonical
-- conversion at the unit level, so mixing them must fail to compile.
module Kalecky.Types.Units.LaborUnit
  ( WorkerBasis (..)
  , LaborHourBasis (..)
  ) where

import Kalecky.Types.Numerics (scale)
import Kalecky.Types.Units.TimeUnit (TimeBasis (..), timeScale)
import Kalecky.Types.Units.Unit (HasScale (..))

-- | Worker-count labor basis: @WORKER_BASE = 1@.
data WorkerBasis = Worker
  deriving (Eq, Ord, Show, Enum, Bounded)

instance HasScale WorkerBasis where
  scaleOf Worker = case scale 1 1 of
    Just s -> s
    Nothing -> error "unreachable: base 1 >= 1"

-- | Labor-time basis, time-denominated (the notes' @LaborTimeUnit
-- { laborScale, timeUnit }@ coupling): its scale is the Hour time
-- scale. A separate TYPE from 'WorkerBasis' on purpose — adding
-- worker-counts to labor-hours has no canonical conversion, so mixing
-- them fails to compile (user decision, 2026-08-15).
data LaborHourBasis = LaborHour
  deriving (Eq, Ord, Show, Enum, Bounded)

instance HasScale LaborHourBasis where
  scaleOf LaborHour = timeScale Hour
