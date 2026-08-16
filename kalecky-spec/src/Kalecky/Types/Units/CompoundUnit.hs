-- | Compound units.
--
-- \(c \, (u_s (k), v_h (l)) := \frac{s = h}{\rho (u_s (k), v_h (l)) | \tau (u_s (k), v_h (l))}\)
--
-- @per := ρ@: \(\rho (u_s (k), v_h (l)) \equiv \frac{u_h (l)}{v_h (l)}\)
--
-- @times := τ@: \(\tau (u_s (k), v_h (l)) \equiv u_h (l) \otimes v_h (l)\)
--
-- Both connectors are STRUCTURE-PRESERVING: the operands stay whole
-- (no division performed) — 'Price' interprets the ratio later. The
-- @s = h@ alignment precondition applies within one kind only (user
-- decision 2026-08-15): cross-kind compounds (money per labor) carry
-- both scales; same-kind ratios can collapse via 'cancel'.
module Kalecky.Types.Units.CompoundUnit
  ( Per
  , per
  , numerator
  , denominator
  , Times
  , times
  , timesFactors
  , cancel
  ) where

import Numeric.Natural (Natural)

import Kalecky.Types.Units.Unit (Unit, value)

-- | ρ: a ratio of units, operands kept whole.
data Per a b = Per (Unit a) (Unit b)
  deriving (Eq, Show)

-- | τ: a tensor of units, operands kept whole.
data Times a b = Times (Unit a) (Unit b)
  deriving (Eq, Show)

per :: Unit a -> Unit b -> Per a b
per = Per

numerator :: Per a b -> Unit a
numerator (Per u _) = u

denominator :: Per a b -> Unit b
denominator (Per _ v) = v

times :: Unit a -> Unit b -> Times a b
times = Times

timesFactors :: Times a b -> (Unit a, Unit b)
timesFactors (Times u v) = (u, v)

-- | A same-kind ratio cancels to a dimensionless Natural (UNIT-05):
-- @Just n@ iff @value numerator == n · value denominator@ exactly,
-- with a non-zero denominator. Naturals only — no fractional result
-- exists, so inexact ratios are @Nothing@.
cancel :: Per b b -> Maybe Natural
cancel (Per u v)
  | dv > 0, nu `mod` dv == 0 = Just (nu `div` dv)
  | otherwise = Nothing
  where
    nu = value u
    dv = value v
