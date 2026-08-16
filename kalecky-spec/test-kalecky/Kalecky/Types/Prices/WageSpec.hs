-- | Co-designed Wage laws and examples (approved 2026-08-16).
module Kalecky.Types.Prices.WageSpec (wageTests) where

import Data.Maybe (fromJust, isJust)
import Numeric.Natural (Natural)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Operators.Expectation (expectation)
import Kalecky.Operators.ExpectationSpec ()
import Kalecky.Operators.Gap (evalGap)
import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Prices.Price (priceRatio)
import Kalecky.Types.Prices.Wage (NominalWage, firmWageGap, householdWageGap, wage)
import Kalecky.Types.Units.CompoundUnit (denominator, numerator)
import Kalecky.Types.Units.LaborUnit (LaborHourBasis (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..), moneyUnit)
import Kalecky.Types.Units.Unit (unit, value)
import Kalecky.Types.Units.UnitSpec ()

hourly :: Natural -> Maybe (NominalWage COP LaborHourBasis)
hourly k = wage Raw k (unit LaborHour 1)

wageTests :: TestTree
wageTests =
  testGroup
    "Wage"
    [ testGroup
        "laws"
        [ testProperty "wage constructs iff moneyUnit accepts the money side" $
            \(d :: Denomination) (k :: Natural) ->
              isJust (wage @COP d k (unit LaborHour 1) :: Maybe (NominalWage COP LaborHourBasis))
                == isJust (moneyUnit @COP d k)
        , testProperty "opposite orientations for the same believed wage" $
            \(kBelieved :: Natural) (kRealized :: Natural) ->
              let believed = fromJust (hourly (50 * (kBelieved + 1)))
                  realized = fromJust (hourly (50 * (kRealized + 1)))
               in evalGap (householdWageGap (expectation believed) realized)
                    == negate (evalGap (firmWageGap realized (expectation believed)))
        ]
    , testGroup
        "examples"
        [ testCase "DOM-01 shape: 20000 COP per LaborHour is a NominalWage (20000/3600)" $ do
            let w = fromJust (hourly 20000)
            value (numerator (priceRatio w)) @?= 20000
            value (denominator (priceRatio w)) @?= 3600
        , testCase "household gap positive when E^H above realized; firm gap mirrors" $ do
            let expct = fromJust (hourly 22000)
                realzd = fromJust (hourly 20000)
            evalGap (householdWageGap (expectation expct) realzd) @?= (22000 / 3600 - 20000 / 3600)
            evalGap (firmWageGap realzd (expectation expct)) @?= (20000 / 3600 - 22000 / 3600)
        ]
    ]
