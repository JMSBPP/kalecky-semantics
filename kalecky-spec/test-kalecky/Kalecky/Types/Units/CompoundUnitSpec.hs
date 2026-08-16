-- | Co-designed CompoundUnit laws and examples (approved 2026-08-15).
--
-- per (ρ) and times (τ) are structure-preserving; cancel collapses a
-- same-kind ratio to a dimensionless Natural, exactly or not at all.
module Kalecky.Types.Units.CompoundUnitSpec (compoundUnitTests) where

import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Units.CompoundUnit
  ( cancel
  , denominator
  , numerator
  , per
  , times
  , timesFactors
  )
import Kalecky.Types.Units.LaborUnit (LaborHourBasis (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..))
import Kalecky.Types.Units.Unit (Unit, unit, value)
import Kalecky.Types.Units.UnitSpec ()

compoundUnitTests :: TestTree
compoundUnitTests =
  testGroup
    "CompoundUnit"
    [ testGroup
        "laws"
        [ testProperty "per preserves its operands" $
            \(u :: Unit Denomination) (v :: Unit Denomination) ->
              numerator (per u v) == u && denominator (per u v) == v
        , testProperty "times preserves its operands" $
            \(u :: Unit Denomination) (v :: Unit Denomination) ->
              timesFactors (times u v) == (u, v)
        , testProperty "cancel is exact or Nothing" $
            \(u :: Unit Denomination) (v :: Unit Denomination) ->
              case cancel (per u v) of
                Just n -> value v > 0 && value u == n * value v
                Nothing -> value v == 0 || value u `mod` value v /= 0
        ]
    , testGroup
        "examples"
        [ testCase "wage shape: per (20000 COP Raw) (1 LaborHour) keeps both operands whole" $ do
            let w = per (unit Raw 20000) (unit LaborHour 1)
            value (numerator w) @?= 20000
            value (denominator w) @?= 3600
        , testCase "cancel: 20000 COP Raw per 400 COP Raw = Just 50" $
            cancel (per (unit Raw 20000) (unit Raw 400)) @?= Just 50
        , testCase "cancel: 20 per 3 (same unit) = Nothing (no exact Natural ratio)" $
            cancel (per (unit Raw 20) (unit Raw 3)) @?= Nothing
        ]
    ]
