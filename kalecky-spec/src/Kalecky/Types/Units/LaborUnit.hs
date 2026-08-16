-- | Labor units.
--
-- @WORKER_BASE = 1@, mirroring Draft.plk's @LaborScale@. Worker counts
-- and labor time are deliberately DISTINCT types (not constructors of
-- one enum): adding worker-counts to labor-hours has no canonical
-- conversion at the unit level, so mixing them must fail to compile.
module Kalecky.Types.Units.LaborUnit
  ( WorkerBasis (..)
  ) where

import Kalecky.Types.Numerics (scale)
import Kalecky.Types.Units.Unit (HasScale (..))

-- | Worker-count labor basis: @WORKER_BASE = 1@.
data WorkerBasis = Worker
  deriving (Eq, Ord, Show, Enum, Bounded)

instance HasScale WorkerBasis where
  scaleOf Worker = case scale 1 1 of
    Just s -> s
    Nothing -> error "unreachable: base 1 >= 1"
