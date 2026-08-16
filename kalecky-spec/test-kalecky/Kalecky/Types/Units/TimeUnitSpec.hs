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
        "laws"
        [ testCase "time bases exactly alignable: MONTH_BASE mod HOUR_BASE == 0" $
            scaleFactor (timeScale Month) `mod` scaleFactor (timeScale Hour) @?= 0
        ]
    , testGroup
        "examples"
        [ testCase "MONTH_BASE = 2_592_000" $
            scaleFactor (timeScale Month) @?= 2_592_000
        , testCase "HOUR_BASE = 3600" $
            scaleFactor (timeScale Hour) @?= 3600
        , testCase "Month = 720 hours" $
            scaleFactor (timeScale Month) `div` scaleFactor (timeScale Hour) @?= 720
        ]
    ]
