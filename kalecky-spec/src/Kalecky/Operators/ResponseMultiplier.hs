-- | Response multipliers.
--
-- \(\operatorname{ResponseMultiplier}(Y,X) : \frac{\partial Y}{\partial X}\)
--
-- A semantic refinement of 'Effect' adding meaning, not data (the
-- notes' resolved design: no redundant stored scalar — the effect IS
-- the number). Quantifies how much the responder moves per unit of
-- perturbation, e.g.
-- @ResponseMultiplier NominalWageGrowth HouseholdRealWageExpectationGap@.
module Kalecky.Operators.ResponseMultiplier
  ( ResponseMultiplier
  , responseMultiplier
  , responseValue
  , applyResponse
  ) where

import Kalecky.Operators.Effect (Effect, applyEffect, effect, effectValue)

-- | A named response coefficient — newtype over 'Effect', zero cost.
newtype ResponseMultiplier responder perturband
  = ResponseMultiplier (Effect responder perturband)
  deriving (Eq, Ord, Show)

responseMultiplier :: Rational -> ResponseMultiplier r p
responseMultiplier = ResponseMultiplier . effect

responseValue :: ResponseMultiplier r p -> Rational
responseValue (ResponseMultiplier e) = effectValue e

-- | Response to an evaluated perturbation (delegates to 'applyEffect').
applyResponse :: ResponseMultiplier r p -> Rational -> Rational
applyResponse (ResponseMultiplier e) = applyEffect e
