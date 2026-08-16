-- | Co-designed Expectation laws and examples (approved 2026-08-16).
--
-- Type distinctness (E^H vs E^F rejected where a specific measure is
-- demanded) is proven by a compile-fail file landing with the Gap
-- increment, where a slot first requires a fixed measure.
module Kalecky.Operators.ExpectationSpec (expectationTests) where

import Data.Maybe (fromJust)
import Data.Proxy (Proxy (..))
import Test.QuickCheck (Arbitrary (..))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Operators.Expectation (Expectation, expectation, expected)
import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.Measure (Agent (..), KnownMeasure (..), Measure (..))
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Units.MoneyUnit (Denomination (..), MoneyBasis, moneyUnit)
import Kalecky.Types.Units.Unit (Unit)
import Kalecky.Types.Units.UnitSpec ()

type H = 'AgentMeasure 'Household

instance Arbitrary x => Arbitrary (Expectation H x) where
  arbitrary = expectation <$> arbitrary

expectationTests :: TestTree
expectationTests =
  testGroup
    "Expectation"
    [ testGroup
        "laws"
        [ testProperty "roundtrip: expected (expectation x) == x" $
            \(u :: Unit Denomination) ->
              expected (expectation u :: Expectation H (Unit Denomination)) == u
        , testProperty "functor identity: fmap id e == e" $
            \(e :: Expectation H Integer) -> fmap id e == e
        , testProperty "functor composition: fmap (f . g) == fmap f . fmap g" $
            \(e :: Expectation H Integer) ->
              fmap ((+ 1) . (* 2)) e == (fmap (+ 1) . fmap (* 2)) e
        ]
    , testGroup
        "examples"
        [ testCase "singleton: measureOf @(AgentMeasure Firm) == AgentMeasure Firm" $
            measureOf (Proxy :: Proxy ('AgentMeasure 'Firm)) @?= AgentMeasure Firm
        , testCase "E^H[20000 COP Raw] carries its value" $ do
            let m = fromJust (moneyUnit @COP Raw 20000)
            expected (expectation m :: Expectation H (Unit (MoneyBasis COP))) @?= m
        ]
    ]
