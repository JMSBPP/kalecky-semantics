-- | Co-designed Conflict laws and examples (approved 2026-08-16).
--
-- "Same variable" is enforced by the shared carrier type; the kind
-- restriction (only Expectations constructible in v1) is structural —
-- no constructor exists to misuse for the other kinds.
module Kalecky.Operators.ConflictSpec (conflictTests) where

import Data.Maybe (fromJust)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Operators.Conflict (evalConflict, expectationsConflict)
import Kalecky.Operators.Expectation (Expectation, expectation)
import Kalecky.Operators.ExpectationSpec ()
import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.Measure (Agent (..), Measure (..))
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Prices.Price (Price, price)
import Kalecky.Types.Units.CompoundUnit (per)
import Kalecky.Types.Units.LaborUnit (LaborHourBasis (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..), MoneyBasis, moneyUnit)
import Kalecky.Types.Units.Unit (Unit, unit, value)
import Kalecky.Types.Units.UnitSpec ()
import Kalecky.Types.Valuation (Valuation (..))

type H = 'AgentMeasure 'Household
type F = 'AgentMeasure 'Firm

eH :: x -> Expectation H x
eH = expectation

eF :: x -> Expectation F x
eF = expectation

cop :: Word -> Unit (MoneyBasis COP)
cop k = fromJust (moneyUnit @COP Raw (50 * fromIntegral k))

conflictTests :: TestTree
conflictTests =
  testGroup
    "Conflict"
    [ testGroup
        "laws"
        [ testProperty "evaluation is the signed difference of the two views" $
            \(a :: Unit Denomination) (b :: Unit Denomination) ->
              evalConflict (expectationsConflict (eH a) (eF b))
                == (fromIntegral (value a) - fromIntegral (value b) :: Integer)
        , testProperty "self-conflict is zero" $
            \(a :: Unit Denomination) ->
              evalConflict (expectationsConflict (eH a) (eF a)) == (0 :: Integer)
        , testProperty "swapping agents negates" $
            \(a :: Unit Denomination) (b :: Unit Denomination) ->
              evalConflict (expectationsConflict (eH a) (eF b))
                == negate (evalConflict (expectationsConflict (eF b) (eH a)))
        ]
    , testGroup
        "examples"
        [ testCase "wage bargaining: E^H = 22000, E^F = 20000 COP -> +2000" $
            evalConflict (expectationsConflict (eH (cop 440)) (eF (cop 400))) @?= 2000
        , testCase "agreement: both expect 20000 -> 0" $
            evalConflict (expectationsConflict (eH (cop 400)) (eF (cop 400))) @?= 0
        , testCase "price-carrier conflict evaluates as exact Rational" $ do
            let wage k = price (per (cop k) (unit LaborHour 1)) :: Price Nominal (MoneyBasis COP) LaborHourBasis
            evalConflict (expectationsConflict (eH (wage 440)) (eF (wage 400)))
              @?= (22000 / 3600 - 20000 / 3600)
        ]
    ]
