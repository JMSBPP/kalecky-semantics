-- | Amount-carrying units.
--
-- \(u_s (k) = k \, \cdot s(b,i)\)
--
-- A unit carries its amount: there is no separate quantity wrapper
-- (PROJECT.md key decision — amount lives in the Unit). Units form a
-- semigroup under \((\cdot)\): amounts multiply and scales multiply.
-- The basis is a type parameter, so cross-kind arithmetic
-- (money · labor) is unexpressible here — cross-kind products arrive
-- only with @CompoundUnit@ ('Per' / 'Times').
--
-- The data constructor is hidden (UNIT-01: smart constructors only);
-- 'unit' is the only way in, and it takes the basis value so the
-- scale's provenance is always a per-basis scale function.
module Kalecky.Types.Units.Unit
  ( Unit
  , qty
  , unitScale
  , HasScale (..)
  , unit
  ) where

import Numeric.Natural (Natural)

import Kalecky.Types.Numerics
  ( Denomination
  , LaborBasis
  , Scale
  , TimeBasis
  , denominationScale
  , laborScale
  , timeScale
  )

-- | An amount @k@ at a scale @s@, tagged by its basis kind.
data Unit basis = Unit Natural Scale
  deriving (Eq, Show)

-- | The amount @k@ of @u_s(k)@.
qty :: Unit basis -> Natural
qty (Unit k _) = k

-- | The scale @s@ of @u_s(k)@.
unitScale :: Unit basis -> Scale
unitScale (Unit _ s) = s

-- | Bases whose scale comes from a per-basis scale function.
class HasScale basis where
  scaleOf :: basis -> Scale

instance HasScale Denomination where
  scaleOf = denominationScale

instance HasScale LaborBasis where
  scaleOf = laborScale

instance HasScale TimeBasis where
  scaleOf = timeScale

-- | Construct @u_{scaleOf b}(k)@ — the only way to build a 'Unit'.
unit :: HasScale basis => basis -> Natural -> Unit basis
unit b k = Unit k (scaleOf b)

-- | \((\cdot)\): amounts multiply, scales multiply.
instance Semigroup (Unit basis) where
  Unit k s <> Unit l h = Unit (k * l) (s <> h)
