-- | Time-basis laws and examples (approved 2026-08-15, relocated from
-- NumericsSpec to mirror the src tree).
module Kalecky.Types.Units.TimeUnitSpec (timeUnitTests) where

import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))

import Kalecky.Types.Numerics (scaleFactor)
import Kalecky.Types.Units.TimeUnit (TimeBasis (..), timeScale)

timeUnitTests :: TestTree
timeUnitTests =
  testGroup
    "TimeUnit"
    [ testGroup
        "examples"
        [ testCase "MONTH_BASE = 2_592_000" $
            scaleFactor (timeScale Month) @?= 2_592_000
        ]
    ]
