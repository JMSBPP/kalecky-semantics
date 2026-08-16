-- | Labor-basis laws and examples (approved 2026-08-15, relocated from
-- NumericsSpec to mirror the src tree).
module Kalecky.Types.Units.LaborUnitSpec (laborUnitTests) where

import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))

import Kalecky.Types.Numerics (scaleFactor)
import Kalecky.Types.Units.LaborUnit (LaborHourBasis (..), WorkerBasis (..))
import Kalecky.Types.Units.TimeUnit (TimeBasis (..), timeScale)
import Kalecky.Types.Units.Unit (scaleOf)

-- NOTE (compile-time boundary): @unit Worker 5 <> unit LaborHour 3@ is
-- a TYPE ERROR — WorkerBasis and LaborHourBasis are distinct types by
-- design. The excluded-source compile-fail file lands with the Price
-- increment's rejection batch.
laborUnitTests :: TestTree
laborUnitTests =
  testGroup
    "LaborUnit"
    [ testGroup
        "laws"
        [ testCase "labor-hours are time-denominated: scaleOf LaborHour == timeScale Hour" $
            scaleFactor (scaleOf LaborHour) @?= scaleFactor (timeScale Hour)
        ]
    , testGroup
        "examples"
        [ testCase "WORKER_BASE = 1" $
            scaleFactor (scaleOf Worker) @?= 1
        ]
    ]
