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

-- | Scale factor @s(b, i) = b ^ i@, restricted to non-negative exponents.
-- Negative exponents return 0 — a deliberate placeholder, not a design decision.
scaleFactor :: Integer -> Int -> Integer
scaleFactor b i
  | i < 0     = 0
  | otherwise = b ^ i
