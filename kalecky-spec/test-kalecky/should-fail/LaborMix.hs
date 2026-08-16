-- MUST NOT TYPE-CHECK (UNIT-04 / user decision 2026-08-15): adding
-- worker counts to labor-hours — no canonical conversion exists.
-- Expected error: Couldn't match type WorkerBasis with LaborHourBasis.
module LaborMix where

import Kalecky.Types.Units.LaborUnit (LaborHourBasis (..), WorkerBasis (..))
import Kalecky.Types.Units.Unit (add, unit)

bad = add (unit Worker 1) (unit LaborHour 1)
