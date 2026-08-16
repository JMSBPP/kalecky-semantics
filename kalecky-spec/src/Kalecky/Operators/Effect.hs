-- | Effects.
--
-- @
-- Effect(responder, perturband)
-- │
-- ├── ResponseMultiplier(responder, perturband)
-- │
-- ├── Elasticity(responder, perturband)
-- └── DistributionalEffect(responder, distributionVariable)
--     └── NetDistributionalEffect
-- @
--
-- \(\operatorname{Effect}(Y,X) \equiv \frac{\partial Y}{\partial X}\)
--
-- The fundamental derivative object: an opaque estimated coefficient
-- (exact signed 'Rational' — these arrive from calibration, not
-- symbolic differentiation) tagged by WHAT responds to WHAT. The
-- refinements in the comment tree add meaning, not data (Phase 4).
module Kalecky.Operators.Effect
  ( Effect
  , effect
  , effectValue
  , applyEffect
  ) where

-- | \(\partial\,\text{responder} / \partial\,\text{perturband}\).
newtype Effect responder perturband = Effect Rational
  deriving (Eq, Ord, Show)

-- | Estimated coefficients enter as exact rationals.
effect :: Rational -> Effect r p
effect = undefined

-- | The coefficient.
effectValue :: Effect r p -> Rational
effectValue = undefined

-- | Linear action: response to an evaluated perturbation
-- (coefficient × perturbation) — the composition primitive of the
-- wage-growth equation's additive terms.
applyEffect :: Effect r p -> Rational -> Rational
applyEffect = undefined
