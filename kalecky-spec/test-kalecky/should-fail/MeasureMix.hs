-- MUST NOT TYPE-CHECK (ALG-03): a Firm expectation cannot fill a
-- Household-typed gap slot. Expected error: Couldn't match
-- 'AgentMeasure 'Firm with 'AgentMeasure 'Household.
{-# LANGUAGE DataKinds #-}
module MeasureMix where

import Kalecky.Operators.Expectation (Expectation, expectation)
import Kalecky.Operators.Gap (Gap, gapER)
import Kalecky.Types.Measure (Agent (..), Measure (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..))
import Kalecky.Types.Units.Unit (Unit, unit)

firmView :: Expectation ('AgentMeasure 'Firm) (Unit Denomination)
firmView = expectation (unit Raw 100)

bad :: Gap ('AgentMeasure 'Household) (Unit Denomination)
bad = gapER firmView (unit Raw 3)
