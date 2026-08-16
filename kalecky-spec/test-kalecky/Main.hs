module Main (main) where

import Test.Tasty (TestTree, defaultMain, testGroup)

import Kalecky.Operators.ConflictSpec (conflictTests)
import Kalecky.Operators.DeltaSpec (deltaTests)
import Kalecky.Operators.EffectSpec (effectTests)
import Kalecky.Operators.ExpectationSpec (expectationTests)
import Kalecky.Operators.GapSpec (gapTests)
import Kalecky.Operators.GrowthRateSpec (growthRateTests)
import Kalecky.Types.NumericsSpec (scaleTests)
import Kalecky.Types.Prices.PriceSpec (priceTests)
import Kalecky.Types.Units.CompoundUnitSpec (compoundUnitTests)
import Kalecky.Types.ValuationSpec (valuationTests)
import Kalecky.Types.Units.LaborUnitSpec (laborUnitTests)
import Kalecky.Types.Units.MoneyUnitSpec (moneyUnitTests)
import Kalecky.Types.Units.TimeUnitSpec (timeUnitTests)
import Kalecky.Types.Units.UnitSpec (unitTests)

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests =
  testGroup "kalecky"
    [ scaleTests
    , unitTests
    , moneyUnitTests
    , laborUnitTests
    , timeUnitTests
    , compoundUnitTests
    , valuationTests
    , priceTests
    , expectationTests
    , gapTests
    , deltaTests
    , growthRateTests
    , effectTests
    , conflictTests
    ]
