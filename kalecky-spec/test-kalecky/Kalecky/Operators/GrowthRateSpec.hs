-- | Co-designed GrowthRate laws and examples (approved 2026-08-16).
--
-- The Tasa→Tasa example IS the resolution of the flagged ambiguity:
-- "+20 basis points" types as Delta (GrowthRate x), evaluating to
-- exactly 1/500.
module Kalecky.Operators.GrowthRateSpec (growthRateTests) where

import Data.Maybe (isJust)
import Test.QuickCheck (Arbitrary (..), (==>))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Operators.Delta (delta, evalDelta)
import Kalecky.Operators.Gap (SignedDiff (..))
import Kalecky.Operators.GrowthRate
  ( CommonGrowthRate
  , GrowthRate
  , commonRate
  , growthFrom
  , growthRate
  , mkCommonGrowthRate
  , rate
  )
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Units.LaborUnit (WorkerBasis (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..))
import Kalecky.Types.Units.Unit (Unit, unit, value)
import Kalecky.Types.Units.UnitSpec ()

instance Arbitrary (GrowthRate x) where
  arbitrary = growthRate <$> arbitrary

magnitudeOf :: Unit Denomination -> Rational
magnitudeOf = fromIntegral . value

growthRateTests :: TestTree
growthRateTests =
  testGroup
    "GrowthRate"
    [ testGroup
        "laws"
        [ testProperty "growthFrom with zero base is Nothing" $
            \(a :: Unit Denomination) ->
              growthFrom (unit Raw 0) a == Nothing
        , testProperty "growthFrom is exact: rate == (m after - m before) / m before" $
            \(b :: Unit Denomination) (a :: Unit Denomination) ->
              value b /= 0 ==>
                (rate <$> growthFrom b a)
                  == Just ((magnitudeOf a - magnitudeOf b) / magnitudeOf b)
        , testProperty "mkCommonGrowthRate is Just iff rates are equal, with the shared rate" $
            \(r1 :: GrowthRate (Unit Denomination)) (r2 :: GrowthRate (Unit WorkerBasis)) ->
              case mkCommonGrowthRate r1 r2 of
                Just c -> rate r1 == rate r2 && commonRate c == rate r1
                Nothing -> rate r1 /= rate r2
        , testProperty "Delta of rates: evalDelta (delta r1 r2) == rate r2 - rate r1" $
            \(r1 :: GrowthRate (Unit Denomination)) (r2 :: GrowthRate (Unit Denomination)) ->
              evalDelta (delta r1 r2) == rate r2 - rate r1
        ]
    , testGroup
        "examples"
        [ testCase "CASO Nivel->Tasa: wage 10 -> 12 units is exactly +1/5 (+20pp)" $
            (rate <$> growthFrom (unit Raw 10) (unit Raw 12)) @?= Just (1 / 5)
        , testCase "CASO Tasa->Tasa: 5% -> 5.20% as Delta (GrowthRate x) = exactly +1/500 (+20bp)" $ do
            let r1 = growthRate (1 / 20) :: GrowthRate (Unit Denomination)
                r2 = growthRate (13 / 250)
            evalDelta (delta r1 r2) @?= 1 / 500
        , testCase "balanced growth: equal rates witness Just; unequal Nothing" $ do
            let ra = growthRate (1 / 20) :: GrowthRate (Unit Denomination)
                rb = growthRate (1 / 20) :: GrowthRate (Unit WorkerBasis)
                rc = growthRate (13 / 250) :: GrowthRate (Unit WorkerBasis)
            (commonRate <$> mkCommonGrowthRate ra rb) @?= Just (1 / 20)
            mkCommonGrowthRate ra rc @?= (Nothing :: Maybe (CommonGrowthRate (Unit Denomination) (Unit WorkerBasis)))
        ]
    ]
