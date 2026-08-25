module Kalecky.Types.Panel.PeriodSpec (periodTests) where

import Numeric.Natural (Natural)
import Test.QuickCheck (Arbitrary (..))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Panel.Period (Period, compareP, granularity, next, ordinal, period)
import Kalecky.Types.Units.TimeUnit (TimeBasis (..))

instance Arbitrary Period where
  arbitrary = period <$> arbitrary <*> arbitrary

periodTests :: TestTree
periodTests =
  testGroup
    "Period"
    [ testGroup
        "laws"
        [ testProperty "next keeps granularity and increments the ordinal" $
            \(p :: Period) ->
              granularity (next p) == granularity p && ordinal (next p) == ordinal p + 1
        , testProperty "next is strictly later within a granularity" $
            \(p :: Period) -> compareP p (next p) == Just LT
        , testProperty "within a granularity, compareP agrees with ordinal order" $
            \(g :: TimeBasis) (a :: Natural) (b :: Natural) ->
              compareP (period g a) (period g b) == Just (compare a b)
        , testProperty "across granularities, compareP is Nothing" $
            \(a :: Natural) (b :: Natural) ->
              compareP (period Month a) (period Hour b) == Nothing
        ]
    , testGroup
        "examples"
        [ testCase "the 3rd month is Period Month 3" $ do
            granularity (period Month 3) @?= Month
            ordinal (period Month 3) @?= 3
        ]
    ]
