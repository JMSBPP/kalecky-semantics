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

import Data.Maybe (isJust)
import Kalecky.Types.Numerics (scaleFactor)
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Units.LaborUnit (WorkerBasis (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..))
import Kalecky.Types.Units.TimeUnit (TimeBasis (..))
import Kalecky.Types.Units.Unit (Unit, add, align, qty, scaleOf, unit, unitScale, value)

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
        "alignment (the s = h rule, within kind)"
        [ testProperty "align preserves value on both sides" $
            \(u :: Unit Denomination) (v :: Unit Denomination) ->
              case align u v of
                Nothing -> False
                Just (u', v') -> value u' == value u && value v' == value v
        , testProperty "align lands both operands on the same (finer) scale" $
            \(u :: Unit Denomination) (v :: Unit Denomination) ->
              case align u v of
                Nothing -> False
                Just (u', v') ->
                  unitScale u' == unitScale v'
                    && scaleFactor (unitScale u') == min (scaleFactor (unitScale u)) (scaleFactor (unitScale v))
        , testProperty "add is value-correct: value (add u v) == value u + value v" $
            \(u :: Unit Denomination) (v :: Unit Denomination) ->
              (value <$> add u v) == Just (value u + value v)
        , testProperty "add is commutative" $
            \(u :: Unit Denomination) (v :: Unit Denomination) ->
              (value <$> add u v) == (value <$> add v u)
        , testProperty "denomination alignment is always possible (exact-multiple family)" $
            \(u :: Unit Denomination) (v :: Unit Denomination) ->
              isJust (align u v)
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
        , testCase "2 Million COP + 500 Thousand COP = 2500 Thousand (aligned toward finer)" $ do
            let Just w = add (unit Million 2) (unit Thousand 500)
            qty w @?= 2500
            scaleFactor (unitScale w) @?= 1000
        , testCase "1 Month + 30 Hour = 750 Hour" $ do
            let Just t = add (unit Month 1) (unit Hour 30)
            qty t @?= 750
            scaleFactor (unitScale t) @?= 3600
        ]
    ]
