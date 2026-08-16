-- | PROOF-05 — the end-goal equation tests (approved 2026-08-16).
module Kalecky.Equations.WageSettingSpec (wageSettingTests) where

import Data.Maybe (fromJust)
import Numeric.Natural (Natural)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Equations.WageSetting (LaborProductivity, PriceLevel, nominalWageGrowthFrom)
import Kalecky.Operators.Expectation (expectation)
import Kalecky.Operators.Gap (Gap, evalGap)
import Kalecky.Operators.GrowthRate (GrowthRate, growthRate, rate)
import Kalecky.Operators.Indexation (applyIndexation, indexation)
import Kalecky.Operators.ResponseMultiplier (applyResponse, responseMultiplier)
import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.Measure (Agent (..), Measure (..))
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Prices.Wage (NominalWage, householdWageGap, wage)
import Kalecky.Types.Units.LaborUnit (LaborHourBasis (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..))
import Kalecky.Types.Units.Unit (unit)

type W = NominalWage COP LaborHourBasis

hourly :: Natural -> W
hourly k = fromJust (wage Raw (50 * k) (unit LaborHour 1))

mkGap :: Natural -> Natural -> Gap (AgentMeasure Household) W
mkGap kBelieved kRealized =
  householdWageGap (expectation (hourly kBelieved)) (hourly kRealized)

eq :: Rational -> Gap (AgentMeasure Household) W -> Rational -> Rational -> Rational -> Rational -> Rational
eq c1 g c2 glp d gp =
  rate
    ( nominalWageGrowthFrom
        (responseMultiplier c1)
        g
        (responseMultiplier c2)
        (growthRate glp :: GrowthRate LaborProductivity)
        (indexation d)
        (growthRate gp :: GrowthRate PriceLevel)
    )

wageSettingTests :: TestTree
wageSettingTests =
  testGroup
    "WageSetting (the end-goal equation)"
    [ testGroup
        "laws"
        [ testProperty "term isolation: only the gap term" $
            \(c1 :: Rational) (kb :: Natural) (kr :: Natural) ->
              eq c1 (mkGap kb kr) 0 1 0 1
                == applyResponse (responseMultiplier c1) (evalGap (mkGap kb kr))
        , testProperty "term isolation: only the productivity term" $
            \(c2 :: Rational) (glp :: Rational) ->
              eq 0 (mkGap 1 1) c2 glp 0 1 == c2 * glp
        , testProperty "term isolation: only the indexation term" $
            \(d :: Rational) (gp :: Rational) ->
              eq 0 (mkGap 1 1) 0 1 d gp
                == applyIndexation (indexation d) (growthRate gp :: GrowthRate PriceLevel)
        , testProperty "all coefficients zero -> zero wage growth" $
            \(kb :: Natural) (kr :: Natural) (glp :: Rational) (gp :: Rational) ->
              eq 0 (mkGap kb kr) 0 glp 0 gp == 0
        , testProperty "superposition: the equation is the sum of its three isolated terms" $
            \(c1 :: Rational) (c2 :: Rational) (d :: Rational) (kb :: Natural) (kr :: Natural) (glp :: Rational) (gp :: Rational) ->
              eq c1 (mkGap kb kr) c2 glp d gp
                == eq c1 (mkGap kb kr) 0 1 0 1
                  + eq 0 (mkGap 1 1) c2 glp 0 1
                  + eq 0 (mkGap 1 1) 0 1 d gp
        ]
    , testGroup
        "examples"
        [ testCase "THE BOXED EQUATION: 5/18 + 1/200 + 1/40 = exactly 277/900" $
            -- rm1 = 1/2 on the household gap (E^H 22000 vs 20000 COP/hr = 2000/3600 = 5/9)
            -- rm2 = 1/4 on productivity growth 1/50 (2%)
            -- indexation 1/2 of inflation 1/20 (5%)
            eq (1 / 2) (mkGap 440 400) (1 / 4) (1 / 50) (1 / 2) (1 / 20)
              @?= 277 / 900
        ]
    ]
