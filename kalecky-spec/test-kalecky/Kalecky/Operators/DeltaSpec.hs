-- | Co-designed Delta laws and examples (approved 2026-08-16).
module Kalecky.Operators.DeltaSpec (deltaTests) where

import Data.Maybe (fromJust)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Operators.Delta (delta, evalDelta)
import Kalecky.Operators.Gap (SignedDiff (..))
import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Units.MoneyUnit (Denomination (..), moneyUnit)
import Kalecky.Types.Units.Unit (Unit, unit)
import Kalecky.Types.Units.UnitSpec ()

deltaTests :: TestTree
deltaTests =
  testGroup
    "Delta"
    [ testGroup
        "laws"
        [ testProperty "evalDelta (delta a b) == sdiff b a (after - before)" $
            \(a :: Unit Denomination) (b :: Unit Denomination) ->
              evalDelta (delta a b) == sdiff b a
        , testProperty "no change is zero: evalDelta (delta a a) == 0" $
            \(a :: Unit Denomination) -> evalDelta (delta a a) == 0
        , testProperty "reversal negates: evalDelta (delta a b) == negate (evalDelta (delta b a))" $
            \(a :: Unit Denomination) (b :: Unit Denomination) ->
              evalDelta (delta a b) == negate (evalDelta (delta b a))
        ]
    , testGroup
        "examples"
        [ testCase "Nivel->Tasa precursor: 10 -> 12 money units evaluates to +2" $
            evalDelta (delta (unit Raw 10) (unit Raw 12)) @?= 2
        , testCase "wage rise: 20000 -> 22000 COP Raw evaluates to +2000" $
            evalDelta
              ( delta
                  (fromJust (moneyUnit @COP Raw 20000))
                  (fromJust (moneyUnit @COP Raw 22000))
              )
              @?= 2000
        ]
    ]
