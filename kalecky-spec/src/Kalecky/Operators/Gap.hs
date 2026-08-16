-- | Gaps.
--
-- Gap (X)
--
-- A 'Gap' is an ORIENTED difference between an EXPECTED value and a
-- REALIZED value — never between two realized values (user decision,
-- 2026-08-16; realized-to-realized differences are 'Kalecky.Operators.Delta').
-- The expectation side is enforced by the constructors: a Gap of two
-- realized values is unrepresentable.
--
-- Both economic orientations exist:
--
--   * 'gapER' — expected − realized (household wage gap \(\mathbb{E}^H[W/P] - W/P\))
--   * 'gapRE' — realized − expected (firm wage gap \(W/P - \mathbb{E}^F[W/P]\))
--
-- Evaluation is signed and exact via 'SignedDiff'; operand amounts stay
-- Natural — signedness exists only at evaluation.
module Kalecky.Operators.Gap
  ( SignedDiff (..)
  , Gap
  , gapER
  , gapRE
  , flipGap
  , evalGap
  ) where

import Data.Ratio ((%))

import Kalecky.Operators.Expectation (Expectation, expected)
import Kalecky.Types.Measure (Measure)
import Kalecky.Types.Prices.Price (Price, priceRatio)
import Kalecky.Types.Units.CompoundUnit (denominator, numerator)
import Kalecky.Types.Units.Unit (Unit, value)

-- | Carriers admitting a signed EXACT difference. The algebraic
-- subtraction requirement of ALG-02 lives here, not in 'Gap'.
class SignedDiff x where
  type Diff x
  sdiff :: x -> x -> Diff x

-- | Units difference by raw magnitude (qty · scale), exactly.
instance SignedDiff (Unit b) where
  type Diff (Unit b) = Integer
  sdiff = undefined

-- | Prices difference as exact rationals of their value-ratios.
instance SignedDiff (Price v a b) where
  type Diff (Price v a b) = Rational
  sdiff = undefined

-- | An oriented expectation-vs-realization difference under measure @m@.
data Gap (m :: Measure) x
  = GapER (Expectation m x) x
  | GapRE x (Expectation m x)
  deriving (Eq, Show)

-- | Expected − realized (household shape).
gapER :: Expectation m x -> x -> Gap m x
gapER = undefined

-- | Realized − expected (firm shape).
gapRE :: x -> Expectation m x -> Gap m x
gapRE = undefined

-- | Reverse orientation: @evalGap (flipGap g) == negate (evalGap g)@.
flipGap :: Gap m x -> Gap m x
flipGap = undefined

-- | Signed exact evaluation (lhs − rhs in the gap's orientation).
evalGap :: (SignedDiff x, Num (Diff x)) => Gap m x -> Diff x
evalGap = undefined
