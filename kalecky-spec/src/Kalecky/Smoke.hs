-- | Phase 1 placeholder. Exists solely to prove that the isolated
-- @kalecky@ sublibrary and @kalecky-test@ test-suite build and run
-- without touching hevm's main library.
--
-- This is NOT the Phase 2 @Scale@ type (UNIT-01). It carries no
-- Decimal arithmetic, no smart constructors and no scale conversion,
-- and must be deleted or superseded when the co-designed @Scale@
-- increment lands.
module Kalecky.Smoke
  ( scaleFactor
  ) where

-- | RED placeholder: deliberately wrong, proves the smoke properties fail.
scaleFactor :: Integer -> Int -> Integer
scaleFactor _ _ = 0
