-- | Co-designed Valuation tests (approved 2026-08-15).
--
-- Thin by design: Valuation is a type-level tag; Nominal/Real
-- unmixability is proven by the compile-fail batch in the Price
-- increment. Here we pin the singleton bridges.
module Kalecky.Types.ValuationSpec (valuationTests) where

import Data.Proxy (Proxy (..))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertBool, testCase, (@?=))

import Kalecky.Types.Prices.PriceIndex (KnownPriceIndex (..), PriceIndex (..))
import Kalecky.Types.Valuation (KnownValuation (..), Valuation (..))

valuationTests :: TestTree
valuationTests =
  testGroup
    "Valuation"
    [ testGroup
        "examples"
        [ testCase "singleton coherence: valuationOf @Nominal == Nominal" $
            valuationOf (Proxy :: Proxy Nominal) @?= Nominal
        , testCase "singleton coherence: valuationOf @(Real CPI) == Real CPI" $
            valuationOf (Proxy :: Proxy ('Real CPI)) @?= Real CPI
        , testCase "Nominal /= Real CPI (value-level sanity)" $
            assertBool "expected inequality" (Nominal /= Real CPI)
        , testCase "priceIndexOf @CPI == CPI" $
            priceIndexOf (Proxy :: Proxy CPI) @?= CPI
        ]
    ]
