-- | Co-designed Price laws and examples (approved 2026-08-15).
--
-- The negative side of UNIT-04 (currency/dimension/valuation mixing
-- fails to compile) lives in @test-kalecky/should-fail/@ checked by
-- @scripts/check-compile-fail.sh@ — not runnable tests by definition.
module Kalecky.Types.Prices.PriceSpec (priceTests) where

import Data.Maybe (fromJust, isJust)
import Numeric.Natural (Natural)
import Test.QuickCheck (Arbitrary (..))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertBool, testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Prices.Price (Price, addPrice, price, priceRatio)
import Kalecky.Types.Prices.PriceIndex (PriceIndex (..))
import Kalecky.Types.Units.CompoundUnit (Per, denominator, numerator, per)
import Kalecky.Types.Units.LaborUnit (LaborHourBasis (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..), MoneyBasis, moneyUnit)
import Kalecky.Types.Units.Unit (Unit, scaleBy, unit, value)
import Kalecky.Types.Units.UnitSpec ()
import Kalecky.Types.Valuation (Valuation (..))

instance Arbitrary (Per Denomination Denomination) where
  arbitrary = per <$> arbitrary <*> arbitrary

vals :: Price v a b -> (Natural, Natural)
vals p = (value (numerator (priceRatio p)), value (denominator (priceRatio p)))

priceTests :: TestTree
priceTests =
  testGroup
    "Price"
    [ testGroup
        "laws"
        [ testProperty "scaleBy is the scalar action: value (scaleBy n u) == n * value u" $
            \(n :: Natural) (u :: Unit Denomination) ->
              value (scaleBy n u) == n * value u
        , testProperty "price/priceRatio roundtrip" $
            \(p :: Per Denomination Denomination) ->
              priceRatio (price p :: Price Nominal Denomination Denomination) == p
        , testProperty "addPrice is exact rational addition on values" $
            \(p :: Per Denomination Denomination) (q :: Per Denomination Denomination) ->
              let pp = price p :: Price Nominal Denomination Denomination
                  qq = price q
                  (n1, d1) = vals pp
                  (n2, d2) = vals qq
               in case addPrice pp qq of
                    Nothing -> False
                    Just r -> vals r == (n1 * d2 + n2 * d1, d1 * d2)
        , testProperty "addPrice is commutative in value terms" $
            \(p :: Per Denomination Denomination) (q :: Per Denomination Denomination) ->
              let pp = price p :: Price Nominal Denomination Denomination
               in (vals <$> addPrice pp (price q)) == (vals <$> addPrice (price q) pp)
        ]
    , testGroup
        "examples"
        [ testCase "nominal hourly wage shape: 20000 COP Raw per 1 LaborHour (UNIT-03)" $ do
            let num = fromJust (moneyUnit @COP Raw 20000)
                w = price (per num (unit LaborHour 1)) :: Price Nominal (MoneyBasis COP) LaborHourBasis
            vals w @?= (20000, 3600)
        , testCase "20000 COP/hr + 5000 COP/hr has the value-ratio of 25000 COP/hr" $ do
            let mk k =
                  price (per (fromJust (moneyUnit @COP Raw k)) (unit LaborHour 1)) ::
                    Price Nominal (MoneyBasis COP) LaborHourBasis
                r = fromJust (addPrice (mk 20000) (mk 5000))
                (n, d) = vals r
            n @?= 90_000_000
            d @?= 12_960_000
            assertBool "value-ratio equals 25000/3600" (n * 3600 == 25000 * d)
        , testCase "addPrice always constructs for current scale families" $
            assertBool
              "expected Just"
              ( isJust
                  ( addPrice
                      (price (per (unit Raw 20) (unit Thousand 3)) :: Price ('Real CPI) Denomination Denomination)
                      (price (per (unit Million 1) (unit Raw 7)))
                  )
              )
        ]
    ]
