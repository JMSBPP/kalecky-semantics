-- | The wage-setting equation — THE END GOAL TEST of this milestone
-- (notes/INCOME_DISTRIBUTION.md, boxed):
--
-- \[
-- \frac{\Delta W}{W}
--   = \underbrace{\frac{\partial(\Delta W/W)}{\partial(\mathbb{E}^H[w]-w)}}_{\text{ResponseMultiplier}}
--     \underbrace{(\mathbb{E}^H[w]-w)}_{\text{householdWageGap}}
--   + \underbrace{\frac{\partial(\Delta W/W)}{\partial g_{LP}}}_{\text{ResponseMultiplier}}
--     \underbrace{g_{LP}}_{\text{GrowthRate LaborProductivity}}
--   + \underbrace{\frac{\partial(\Delta W/W)}{\partial(\Delta P/P)}}_{\text{Indexation}}
--     \underbrace{\frac{\Delta P}{P}}_{\text{GrowthRate PriceLevel}}
-- \]
--
-- An equation links a quantity's growth to its components — hence
-- @Equations/@ (individual relations; @Models/@ will later collect
-- them). Named after the ACT of wage setting (cf. the user's Plank
-- vocabulary, @NominalWageSetter.plk@), not the resulting quantity.
--
-- NO AD-HOC GLUE: the body is exactly three shipped combinators summed
-- — 'applyResponse', 'applyResponse', 'applyIndexation' — wrapped by
-- 'growthRate'. Nothing else.
module Kalecky.Equations.WageSetting
  ( LaborProductivity
  , PriceLevel
  , nominalWageGrowthFrom
  ) where

import Kalecky.Operators.Gap (Gap, evalGap)
import Kalecky.Operators.GrowthRate (GrowthRate, growthRate, rate)
import Kalecky.Operators.Indexation (Indexation, applyIndexation)
import Kalecky.Operators.ResponseMultiplier (ResponseMultiplier, applyResponse)
import Kalecky.Types.Measure (Agent (..), Measure (..))
import Kalecky.Types.Prices.Wage (NominalWage)

-- | Phantom rate carrier: labor productivity is NOT formally defined
-- in v1 (user decision 2026-08-16) — it enters only as
-- @GrowthRate LaborProductivity@.
data LaborProductivity

-- | Phantom rate carrier: likewise, the price level enters only as
-- @GrowthRate PriceLevel@ (inflation).
data PriceLevel

-- | \(\Delta W / W\) from its three drivers.
nominalWageGrowthFrom ::
  ResponseMultiplier (GrowthRate (NominalWage c l)) (Gap (AgentMeasure Household) (NominalWage c l)) ->
  Gap (AgentMeasure Household) (NominalWage c l) ->
  ResponseMultiplier (GrowthRate (NominalWage c l)) (GrowthRate LaborProductivity) ->
  GrowthRate LaborProductivity ->
  Indexation (NominalWage c l) PriceLevel ->
  GrowthRate PriceLevel ->
  GrowthRate (NominalWage c l)
nominalWageGrowthFrom rm1 g rm2 gLP ind gP =
  growthRate
    ( applyResponse rm1 (evalGap g)
        + applyResponse rm2 (rate gLP)
        + applyIndexation ind gP
    )
