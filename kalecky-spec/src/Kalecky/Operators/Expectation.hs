-- | Expectations.
--
-- \(\mathbb{E}^{\mu}\)
--
-- An expectation is a believed value of @x@ under a type-level
-- 'Measure' (the notes' @Expectation (Measure agent) x@ variant —
-- measure-indexed, "más fiel matemáticamente"). @E^H[x]@ and
-- @E^F[x]@ are distinct types for the same @x@ (ALG-03).
--
-- Constructor hidden; 'expectation' is the only way in.
module Kalecky.Operators.Expectation
  ( Expectation
  , expectation
  , expected
  ) where

import Kalecky.Types.Measure (Measure)

-- | A believed value of @x@ under measure @μ@.
newtype Expectation (m :: Measure) x = Expectation x
  deriving (Eq, Show)

-- | Form an expectation under measure @μ@ (pick @μ@ by type application
-- or annotation).
expectation :: x -> Expectation m x
expectation = Expectation

-- | The believed value.
expected :: Expectation m x -> x
expected (Expectation x) = x

-- | \(\mathbb{E}^{\mu}\) maps over its carrier.
instance Functor (Expectation m) where
  fmap f (Expectation x) = Expectation (f x)
