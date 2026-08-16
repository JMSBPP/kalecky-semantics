-- | Indexation.
--
-- @
-- Indexation(target, reference)
--     └── Effect(
--           GrowthRate target,
--           GrowthRate reference
--         )
-- @
--
-- \(\operatorname{Indexation}(W, P) : \frac{\partial (\Delta W / W)}{\partial (\Delta P / P)}\)
--
-- The degree to which the target's growth is indexed to the
-- reference's growth — a newtype over 'Effect' between growth rates
-- (the notes' resolved design: the effect already contains the
-- scalar; no separate indexationRate field).
module Kalecky.Operators.Indexation
  ( Indexation
  , indexation
  , indexationDegree
  , applyIndexation
  ) where

import Kalecky.Operators.Effect (Effect, applyEffect, effect, effectValue)
import Kalecky.Operators.GrowthRate (GrowthRate, rate)

-- | Degree of indexation of @target@'s growth to @reference@'s growth.
newtype Indexation target reference
  = Indexation (Effect (GrowthRate target) (GrowthRate reference))
  deriving (Eq, Ord, Show)

indexation :: Rational -> Indexation t r
indexation = undefined

indexationDegree :: Indexation t r -> Rational
indexationDegree = undefined

-- | The contribution of the reference's growth to the target's growth:
-- degree × reference rate.
applyIndexation :: Indexation t r -> GrowthRate reference -> Rational
applyIndexation = undefined
