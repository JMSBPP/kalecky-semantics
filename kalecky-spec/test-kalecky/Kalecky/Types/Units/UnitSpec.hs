-- | Co-designed Unit laws and examples (approved 2026-08-15).
--
-- Cross-kind products (unit Thousand 2 <> unit Worker 5) are a type
-- error by construction — enforced by the basis type parameter, not a
-- runtime check.
module Kalecky.Types.Units.UnitSpec (unitTests) where

import Data.Proxy (Proxy (..))
import Numeric.Natural (Natural)
import Test.QuickCheck (Arbitrary (..))
import Test.QuickCheck.Classes (Laws (..), semigroupLaws)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Types.Numerics (scaleFactor)
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Units.LaborUnit (WorkerBasis (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..))
import Kalecky.Types.Units.Unit (Unit, qty, scaleOf, unit, unitScale)

instance Arbitrary (Unit Denomination) where
  arbitrary = unit <$> arbitrary <*> arbitrary

lawsToTree :: Laws -> TestTree
lawsToTree (Laws cls props) =
  testGroup cls [testProperty name prop | (name, prop) <- props]

unitTests :: TestTree
unitTests =
  testGroup
    "Unit"
    [ testGroup
        "laws"
        [ lawsToTree (semigroupLaws (Proxy :: Proxy (Unit Denomination)))
        , testProperty "qty is multiplicative: qty (u <> v) == qty u * qty v" $
            \(u :: Unit Denomination) (v :: Unit Denomination) ->
              qty (u <> v) == qty u * qty v
        , testProperty "scale is multiplicative under (<>)" $
            \(u :: Unit Denomination) (v :: Unit Denomination) ->
              scaleFactor (unitScale (u <> v))
                == scaleFactor (unitScale u) * scaleFactor (unitScale v)
        , testProperty "scale positivity survives (<>)" $
            \(u :: Unit Denomination) (v :: Unit Denomination) ->
              scaleFactor (unitScale (u <> v)) >= 1
        , testProperty "construction: unit b k has qty k and scale (scaleOf b)" $
            \(b :: Denomination) (k :: Natural) ->
              qty (unit b k) == k && unitScale (unit b k) == scaleOf b
        ]
    , testGroup
        "examples"
        [ testCase "2 Thousand · 3 Thousand = 6 at scale 10^6" $ do
            let u = unit Thousand 2 <> unit Thousand 3
            qty u @?= 6
            scaleFactor (unitScale u) @?= 1_000_000
        , testCase "5 Worker · 4 Worker = 20 at scale 1" $ do
            let u = unit Worker 5 <> unit Worker 4
            qty u @?= 20
            scaleFactor (unitScale u) @?= 1
        ]
    ]
