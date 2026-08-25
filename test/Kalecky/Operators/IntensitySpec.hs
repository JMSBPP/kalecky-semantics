module Kalecky.Operators.IntensitySpec (intensityTests) where

import Data.Maybe (fromJust, isNothing)
import Data.Ratio ((%))
import Numeric.Natural (Natural)
import Test.QuickCheck ((==>))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Operators.Intensity (densityValue, groupDensity, intensity, matchedDensity, totalDensity)
import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.Groups.Capital (CapitalGroup)
import Kalecky.Types.Groups.Region (Region (..))
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Panel.Period (Period, period)
import Kalecky.Types.Stocks.StateVector (StateVector, stateVector, total)
import Kalecky.Types.Stocks.Stock (Role (..), Stock, point)
import Kalecky.Types.Units.IndexUnit (IndexBasis (..))
import Kalecky.Types.Units.LaborUnit (WorkerBasis (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..), MoneyBasis, moneyUnit)
import Kalecky.Types.Units.TimeUnit (TimeBasis (..))
import Kalecky.Types.Units.Unit (unit, value)

pop :: Natural -> Natural -> StateVector Region WorkerBasis
pop c p = fromJust (stateVector (\r -> unit Worker (if r == Central then c else p)) (unit Worker (c + p)))

capital :: Natural -> Natural -> Natural -> StateVector CapitalGroup (MoneyBasis COP)
capital f k mc =
  fromJust
    ( stateVector
        (\g -> fromJust (moneyUnit @COP Thousand ([f, k, mc] !! fromEnum g)))
        (fromJust (moneyUnit @COP Thousand (f + k + mc)))
    )

m1 :: Period
m1 = period Month 1

intensityTests :: TestTree
intensityTests =
  testGroup
    "Intensity"
    [ testGroup
        "laws"
        [ testProperty "total density is the Per of the totals" $
            \(c :: Natural) (p :: Natural) (f :: Natural) (k :: Natural) (mc :: Natural) ->
              (c + p > 0 && f + k + mc > 0) ==>
                let n = point m1 (pop c p) :: Stock Base Region WorkerBasis
                    kap = point m1 (capital f k mc) :: Stock Level CapitalGroup (MoneyBasis COP)
                    i = fromJust (intensity kap n)
                 in fmap densityValue (totalDensity m1 i)
                      == Just (toInteger (value (total (capital f k mc))) % toInteger (c + p))
        , testProperty "group densities sum to the total density" $
            \(c :: Natural) (p :: Natural) (f :: Natural) (k :: Natural) (mc :: Natural) ->
              (c + p > 0 && f + k + mc > 0) ==>
                let n = point m1 (pop c p) :: Stock Base Region WorkerBasis
                    kap = point m1 (capital f k mc) :: Stock Level CapitalGroup (MoneyBasis COP)
                    i = fromJust (intensity kap n)
                 in sum [densityValue (fromJust (groupDensity g m1 i)) | g <- [minBound .. maxBound]]
                      == densityValue (fromJust (totalDensity m1 i))
        , testProperty "matched densities exist for equal partitions and divide region by region" $
            \(c :: Natural) (p :: Natural) (c' :: Natural) (p' :: Natural) ->
              (c > 0 && p > 0 && c' > 0 && p' > 0) ==>
                let n = point m1 (pop c p) :: Stock Base Region WorkerBasis
                    l = point m1 (pop c' p') :: Stock Level Region WorkerBasis
                    i = fromJust (intensity l n)
                 in fmap densityValue (matchedDensity Central m1 i) == Just (toInteger c' % toInteger c)
        , testProperty "period mismatch is Nothing" $
            \(c :: Natural) (p :: Natural) ->
              c + p > 0 ==>
                let n = point (period Month 1) (pop c p) :: Stock Base Region WorkerBasis
                    l = point (period Month 2) (pop c p) :: Stock Level Region WorkerBasis
                 in isNothing (intensity l n)
        ]
    , testGroup
        "examples"
        [ testCase "K/N: 400 Thousand COP over 200 workers is exactly 2000 COP per worker" $ do
            let n = point m1 (pop 120 80) :: Stock Base Region WorkerBasis
                kap = point m1 (capital 100 250 50) :: Stock Level CapitalGroup (MoneyBasis COP)
            fmap densityValue (totalDensity m1 (fromJust (intensity kap n))) @?= Just 2000
        , testCase "A/N with a dimensionless index cancels to a plain density" $ do
            let n = point m1 (pop 120 80) :: Stock Base Region WorkerBasis
                a = point m1 (fromJust (stateVector (\(_ :: Region) -> unit Index 50) (unit Index 100))) :: Stock Level Region IndexBasis
            fmap densityValue (totalDensity m1 (fromJust (intensity a n))) @?= Just (1 % 2)
        ]
    ]
