-- MUST NOT TYPE-CHECK: matched densities require the SAME partition on both sides.
{-# LANGUAGE DataKinds #-}
module PartitionMix where

import Kalecky.Operators.Intensity (Density, Intensity, matchedDensity)
import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.Groups.Capital (CapitalGroup (..))
import Kalecky.Types.Groups.Region (Region)
import Kalecky.Types.Panel.Period (Period)
import Kalecky.Types.Units.LaborUnit (WorkerBasis)
import Kalecky.Types.Units.MoneyUnit (MoneyBasis)

bad :: Period -> Intensity CapitalGroup Region (MoneyBasis COP) WorkerBasis -> Maybe (Density (MoneyBasis COP) WorkerBasis)
bad p i = matchedDensity KF p i
