-- | Labor-basis laws and examples (approved 2026-08-15, relocated from
-- NumericsSpec to mirror the src tree).
module Kalecky.Types.Units.LaborUnitSpec (laborUnitTests) where

import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))

import Kalecky.Types.Numerics (scaleFactor)
import Kalecky.Types.Units.LaborUnit (WorkerBasis (..))
import Kalecky.Types.Units.Unit (scaleOf)

laborUnitTests :: TestTree
laborUnitTests =
  testGroup
    "LaborUnit"
    [ testGroup
        "examples"
        [ testCase "WORKER_BASE = 1" $
            scaleFactor (scaleOf Worker) @?= 1
        ]
    ]
