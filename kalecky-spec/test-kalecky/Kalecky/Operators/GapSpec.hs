-- | Co-designed Gap laws and examples (approved 2026-08-16).
--
-- The negative boundary (a Gap of two realized values; a Firm
-- expectation in a Household-typed gap) lives in
-- @test-kalecky/should-fail/TwoRealized.hs@ and @MeasureMix.hs@.
module Kalecky.Operators.GapSpec (gapTests) where

import Data.Maybe (fromJust)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Operators.Expectation (Expectation, expectation)
import Kalecky.Operators.ExpectationSpec ()
import Kalecky.Operators.Gap (SignedDiff (..), evalGap, flipGap, gapER, gapRE)
import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.Measure (Agent (..), Measure (..))
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Prices.Price (Price, price)
import Kalecky.Types.Units.CompoundUnit (per)
import Kalecky.Types.Units.LaborUnit (LaborHourBasis (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..), MoneyBasis, moneyUnit)
import Kalecky.Types.Units.Unit (Unit, unit)
import Kalecky.Types.Units.UnitSpec ()
import Kalecky.Types.Valuation (Valuation (..))

type H = 'AgentMeasure 'Household
type F = 'AgentMeasure 'Firm

cop :: Word -> Unit (MoneyBasis COP)
cop k = fromJust (moneyUnit @COP Raw (50 * fromIntegral k))

gapTests :: TestTree
gapTests =
  testGroup
    "Gap"
    [ testGroup
        "laws"
        [ testProperty "sdiff is antisymmetric: sdiff a b == negate (sdiff b a)" $
            \(a :: Unit Denomination) (b :: Unit Denomination) ->
              sdiff a b == negate (sdiff b a)
        , testProperty "sdiff self is zero: sdiff a a == 0" $
            \(a :: Unit Denomination) -> sdiff a a == 0
        , testProperty "orientation matters: evalGap (gapER e r) == negate (evalGap (gapRE r e))" $
            \(x :: Unit Denomination) (r :: Unit Denomination) ->
              let e = expectation x :: Expectation H (Unit Denomination)
               in evalGap (gapER e r) == negate (evalGap (gapRE r e))
        , testProperty "flip law: evalGap (flipGap g) == negate (evalGap g)" $
            \(x :: Unit Denomination) (r :: Unit Denomination) ->
              let g = gapER (expectation x :: Expectation H (Unit Denomination)) r
               in evalGap (flipGap g) == negate (evalGap g)
        ]
    , testGroup
        "examples"
        [ testCase "household shape: E^H = 22000, realized 20000 -> evalGap = +2000" $
            evalGap (gapER (expectation (cop 440) :: Expectation H (Unit (MoneyBasis COP))) (cop 400)) @?= 2000
        , testCase "firm shape: realized 20000, E^F = 22000 -> evalGap = -2000" $
            evalGap (gapRE (cop 400) (expectation (cop 440) :: Expectation F (Unit (MoneyBasis COP)))) @?= (-2000)
        , testCase "price gaps evaluate as exact Rationals (wage-shaped carrier)" $ do
            let wage k = price (per (cop k) (unit LaborHour 1)) :: Price Nominal (MoneyBasis COP) LaborHourBasis
                g = gapER (expectation (wage 440) :: Expectation H (Price Nominal (MoneyBasis COP) LaborHourBasis)) (wage 400)
            evalGap g @?= (22000 / 3600 - 20000 / 3600)
        ]
    ]
