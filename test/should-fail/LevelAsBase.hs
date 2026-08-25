-- MUST NOT TYPE-CHECK: a Level stock cannot be the denominator (the inverse is not derivable).
{-# LANGUAGE DataKinds #-}
module LevelAsBase where

import Kalecky.Operators.Intensity (Intensity, intensity)
import Kalecky.Types.Groups.Region (Region)
import Kalecky.Types.Stocks.Stock (Role (..), Stock)
import Kalecky.Types.Units.LaborUnit (WorkerBasis)

bad :: Stock Level Region WorkerBasis -> Stock Level Region WorkerBasis -> Maybe (Intensity Region Region WorkerBasis WorkerBasis)
bad k n = intensity k n
