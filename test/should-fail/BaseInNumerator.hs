-- MUST NOT TYPE-CHECK: a Base stock cannot be the numerator of an intensity.
{-# LANGUAGE DataKinds #-}
module BaseInNumerator where

import Kalecky.Operators.Intensity (Intensity, intensity)
import Kalecky.Types.Groups.Region (Region)
import Kalecky.Types.Stocks.Stock (Role (..), Stock)
import Kalecky.Types.Units.LaborUnit (WorkerBasis)

bad :: Stock Base Region WorkerBasis -> Stock Base Region WorkerBasis -> Maybe (Intensity Region Region WorkerBasis WorkerBasis)
bad n k = intensity n k
