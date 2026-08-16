-- MUST NOT TYPE-CHECK (ALG-01, user decision 2026-08-16): a Gap of two
-- REALIZED values is unrepresentable — Gap requires an Expectation
-- side. Expected error: Couldn't match Unit ... with Expectation m ...
{-# LANGUAGE DataKinds #-}
module TwoRealized where

import Kalecky.Operators.Gap (Gap, gapER)
import Kalecky.Types.Measure (Agent (..), Measure (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..))
import Kalecky.Types.Units.Unit (Unit, unit)

bad :: Gap ('AgentMeasure 'Household) (Unit Denomination)
bad = gapER (unit Raw 5) (unit Raw 3)
