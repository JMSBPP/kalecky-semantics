-- | Co-designed Scale laws and examples (approved 2026-08-15).
--
-- Laws:
--   1. Positivity: every scale factor is >= 1.
--   2. Denomination scales are exact powers of ten with exponents 0/3/6/9.
--   3. Denomination scales are strictly monotone Raw < Thousand < Million < Billion.
--   4. Coarser denominations are exact multiples of finer ones
--      (the law that makes s = h alignment lossless downstream).
module Kalecky.Types.NumericsSpec
  ( scaleTests
  , SomeBasis (..)
  , someScale
  ) where

import Numeric.Natural (Natural)
import Test.QuickCheck (Arbitrary (..), arbitraryBoundedEnum, arbitrarySizedNatural, oneof, (==>))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Types.Numerics

-- | A basis of any unit kind, for laws quantified over every basis.
data SomeBasis
  = SomeDenomination Denomination
  | SomeLabor LaborBasis
  | SomeTime TimeBasis
  deriving (Show)

-- | The scale of any basis, whatever its kind.
someScale :: SomeBasis -> Scale
someScale = \case
  SomeDenomination d -> denominationScale d
  SomeLabor l -> laborScale l
  SomeTime t -> timeScale t

scaleFactorOf :: SomeBasis -> Natural
scaleFactorOf = scaleFactor . someScale

-- Orphan: QuickCheck 2.14.3 ships no Arbitrary Natural.
instance Arbitrary Natural where
  arbitrary = arbitrarySizedNatural
  shrink = map fromInteger . filter (>= 0) . shrink . toInteger

instance Arbitrary Denomination where
  arbitrary = arbitraryBoundedEnum

instance Arbitrary LaborBasis where
  arbitrary = arbitraryBoundedEnum

instance Arbitrary TimeBasis where
  arbitrary = arbitraryBoundedEnum

instance Arbitrary SomeBasis where
  arbitrary =
    oneof
      [ SomeDenomination <$> arbitrary
      , SomeLabor <$> arbitrary
      , SomeTime <$> arbitrary
      ]

scaleTests :: TestTree
scaleTests =
  testGroup
    "Scale"
    [ testGroup
        "laws"
        [ testProperty "positivity: every scale factor >= 1" $
            \(b :: SomeBasis) -> scaleFactorOf b >= 1
        , testProperty "denomination scales are exact powers of ten (0,3,6,9)" $
            \(d :: Denomination) ->
              scaleFactor (denominationScale d) == 10 ^ denominationExponent d
        , testProperty "denomination scales strictly monotone Raw<Thousand<Million<Billion" $
            \(d1 :: Denomination) (d2 :: Denomination) ->
              (d1 < d2) == (scaleFactor (denominationScale d1) < scaleFactor (denominationScale d2))
        , testProperty "coarser denominations are exact multiples of finer ones" $
            \(d1 :: Denomination) (d2 :: Denomination) ->
              d1 <= d2 ==>
                scaleFactor (denominationScale d2) `mod` scaleFactor (denominationScale d1) == 0
        ]
    , testGroup
        "examples"
        [ testCase "Million = 1_000_000" $
            scaleFactor (denominationScale Million) @?= 1_000_000
        , testCase "MONTH_BASE = 2_592_000" $
            scaleFactor (timeScale Month) @?= 2_592_000
        , testCase "WORKER_BASE = 1" $
            scaleFactor (laborScale Worker) @?= 1
        ]
    ]
