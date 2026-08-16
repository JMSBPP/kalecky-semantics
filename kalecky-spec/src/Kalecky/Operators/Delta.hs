-- | Deltas.
--
-- A 'Delta' is an oriented difference between two REALIZED
-- observations (before → after) — the realized-to-realized
-- counterpart of 'Kalecky.Operators.Gap' (which requires an
-- expectation side; user decision 2026-08-16). The CASO PRUEBA
-- Tasa→Tasa "+20 basis points" types as @Delta (GrowthRate x)@.
--
-- Constructor hidden; 'delta' is the only way in.
module Kalecky.Operators.Delta
  ( Delta
  , delta
  , deltaFrom
  , deltaTo
  , evalDelta
  ) where

import Kalecky.Operators.Gap (Diff, SignedDiff (..))

-- | An oriented realized-to-realized change.
data Delta x = Delta x x
  deriving (Eq, Show)

-- | @delta before after@.
delta :: x -> x -> Delta x
delta = undefined

-- | The earlier observation.
deltaFrom :: Delta x -> x
deltaFrom = undefined

-- | The later observation.
deltaTo :: Delta x -> x
deltaTo = undefined

-- | Signed exact evaluation: after − before.
evalDelta :: (SignedDiff x, Num (Diff x)) => Delta x -> Diff x
evalDelta = undefined
