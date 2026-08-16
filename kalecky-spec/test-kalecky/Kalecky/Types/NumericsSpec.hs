-- | Co-designed Scale laws (approved 2026-08-15), relocated to mirror
-- the src tree: this module now covers ONLY the Scale kernel.
-- Denomination laws live in MoneyUnitSpec; time and labor laws live in
-- TimeUnitSpec and LaborUnitSpec.
--
-- Shared test vocabulary ('SomeBasis', Arbitrary orphans) exported for
-- the sibling specs.
module Kalecky.Types.NumericsSpec
  ( scaleTests
  , SomeBasis (..)
  , someScale
  ) where

import Numeric.Natural (Natural)
import Test.QuickCheck (Arbitrary (..), arbitraryBoundedEnum, arbitrarySizedNatural, listOf1, oneof)
import Test.QuickCheck.Classes (Laws (..), semigroupLaws)
import Data.Proxy (Proxy (..))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Types.Numerics (Scale, scale, scaleFactor)
import Kalecky.Types.Units.LaborUnit (WorkerBasis (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..))
import Kalecky.Types.Units.TimeUnit (TimeBasis (..))
import Kalecky.Types.Units.Unit (HasScale (..))

-- | A basis of any unit kind, for laws quantified over every basis.
data SomeBasis
  = SomeDenomination Denomination
  | SomeWorker WorkerBasis
  | SomeTime TimeBasis
  deriving (Show)

-- | The scale of any basis, whatever its kind.
someScale :: SomeBasis -> Scale
someScale = \case
  SomeDenomination d -> scaleOf d
  SomeWorker w -> scaleOf w
  SomeTime t -> scaleOf t

-- Orphan: QuickCheck 2.14.3 ships no Arbitrary Natural.
instance Arbitrary Natural where
  arbitrary = arbitrarySizedNatural
  shrink = map fromInteger . filter (>= 0) . shrink . toInteger

instance Arbitrary Denomination where
  arbitrary = arbitraryBoundedEnum

instance Arbitrary WorkerBasis where
  arbitrary = arbitraryBoundedEnum

instance Arbitrary TimeBasis where
  arbitrary = arbitraryBoundedEnum

instance Arbitrary SomeBasis where
  arbitrary =
    oneof
      [ SomeDenomination <$> arbitrary
      , SomeWorker <$> arbitrary
      , SomeTime <$> arbitrary
      ]

instance Arbitrary Scale where
  arbitrary = do
    bs <- listOf1 arbitrary
    pure (foldr1 (<>) (map someScale bs))

lawsToTree :: Laws -> TestTree
lawsToTree (Laws cls props) =
  testGroup cls [testProperty name prop | (name, prop) <- props]

scaleTests :: TestTree
scaleTests =
  testGroup
    "Scale"
    [ testGroup
        "laws"
        [ lawsToTree (semigroupLaws (Proxy :: Proxy Scale))
        , testProperty "positivity: every scale factor >= 1" $
            \(b :: SomeBasis) -> scaleFactor (someScale b) >= 1
        , testProperty "s(b,i) = b^i for b >= 1; undefined for b == 0" $
            \(b :: Natural) (i :: Natural) ->
              (scaleFactor <$> scale b i)
                == if b >= 1 then Just (b ^ i) else Nothing
        ]
    ]
