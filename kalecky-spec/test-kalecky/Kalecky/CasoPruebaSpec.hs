-- | CASO PRUEBA — the worked scenarios from notes/INCOME_DISTRIBUTION.md,
-- asserted at the domain level (approved 2026-08-16).
--
-- Pure validation: all machinery shipped in Phases 2-5; these tests
-- prove the prose scenarios fall out of the types exactly.
--
-- Nivel→Tasa is typed at the Thousand denomination ("10 unidades
-- monetarias" = 10 Thousand COP) to respect COP's tradeable-base
-- quantization while keeping the prose arithmetic exact.
module Kalecky.CasoPruebaSpec (casoPruebaTests) where

import Data.Maybe (fromJust, isNothing)
import Numeric.Natural (Natural)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertBool, testCase, (@?=))

import Kalecky.Operators.Delta (delta, evalDelta)
import Kalecky.Operators.GrowthRate (GrowthRate, growthFrom, growthRate, rate)
import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.Prices.Price (priceRatio)
import Kalecky.Types.Prices.Wage (NominalWage, wage)
import Kalecky.Types.Units.CompoundUnit (denominator, numerator)
import Kalecky.Types.Units.LaborUnit (LaborHourBasis (..), WorkerBasis (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..))
import Kalecky.Types.Units.Unit (unit, value)

hourly :: Natural -> Maybe (NominalWage COP LaborHourBasis)
hourly k = wage Raw k (unit LaborHour 1)

perWorker :: Natural -> Maybe (NominalWage COP WorkerBasis)
perWorker k = wage Thousand k (unit Worker 1)

casoPruebaTests :: TestTree
casoPruebaTests =
  testGroup
    "CASO PRUEBA"
    [ testCase "Nivel->Nivel (PROOF-02): minimum wage fixed at 20000 COP per hour" $ do
        let w = fromJust (hourly 20000)
        value (numerator (priceRatio w)) @?= 20000
        value (denominator (priceRatio w)) @?= 3600
        assertBool "20025 COP/hour rejected (tradeable base 50)" (isNothing (hourly 20025))
    , testCase "Nivel->Tasa (PROOF-03): wage 10 -> 12 money units per worker = exactly +1/5" $ do
        let w0 = fromJust (perWorker 10)
            w1 = fromJust (perWorker 12)
        (rate <$> growthFrom w0 w1) @?= Just (1 / 5)
    , testCase "Tasa->Tasa (PROOF-04): wage growth 5% -> 5.20% = Delta of exactly +1/500" $ do
        let r0 = growthRate (1 / 20) :: GrowthRate (NominalWage COP WorkerBasis)
            r1 = growthRate (13 / 250)
        evalDelta (delta r0 r1) @?= 1 / 500
    ]
