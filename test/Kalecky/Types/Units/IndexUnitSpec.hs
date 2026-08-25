module Kalecky.Types.Units.IndexUnitSpec (indexUnitTests) where

import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Types.Numerics (scaleFactor)
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Units.IndexUnit (IndexBasis (..))
import Kalecky.Types.Units.Unit (scaleOf, unit, value)

indexUnitTests :: TestTree
indexUnitTests =
  testGroup
    "IndexUnit"
    [ testGroup
        "laws"
        [ testProperty "dimensionless: value (unit Index k) == k" $
            \k -> value (unit Index k) == k
        ]
    , testGroup
        "examples"
        [ testCase "scale of Index is exactly 1" $
            scaleFactor (scaleOf Index) @?= 1
        ]
    ]
