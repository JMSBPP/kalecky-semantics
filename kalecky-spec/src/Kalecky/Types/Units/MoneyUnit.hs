-- | Money units.
--
-- @MoneyUnit = MoneyUnit { currency :: Currency, unit :: Unit }@ —
-- money denominations ('Raw' | 'Thousand' | 'Million' | 'Billion',
-- Draft.plk's @denomination_scale@) and, once the currency tag lands,
-- currency-tagged money construction quantized by the tradeable base.
module Kalecky.Types.Units.MoneyUnit
  ( Denomination (..)
  , denominationExponent
  , denominationScale
  , MoneyBasis
  , moneyBasis
  , moneyUnit
  ) where

import Data.Proxy (Proxy (..))
import Numeric.Natural (Natural)

import Kalecky.Types.Currency (Currency, KnownCurrency (..), tradeableBase)
import Kalecky.Types.Numerics (Scale, scale, scaleFactor)
import Kalecky.Types.Units.Unit (HasScale (..), Unit, unit)

-- | Money denominations. Ordering reflects coarseness: 'Raw' is finest.
data Denomination = Raw | Thousand | Million | Billion
  deriving (Eq, Ord, Show, Enum, Bounded)

-- | Power-of-ten exponent per denomination: 0, 3, 6, 9.
denominationExponent :: Denomination -> Natural
denominationExponent = \case
  Raw -> 0
  Thousand -> 3
  Million -> 6
  Billion -> 9

-- | @denomination_scale@: Raw=1, Thousand=10^3, Million=10^6, Billion=10^9.
denominationScale :: Denomination -> Scale
denominationScale d = case scale 10 (denominationExponent d) of
  Just s -> s
  Nothing -> error "unreachable: base 10 >= 1"

instance HasScale Denomination where
  scaleOf = denominationScale

-- | The basis of a money unit: a denomination tagged by a type-level
-- currency (@MoneyUnit = MoneyUnit { currency, unit }@ with the
-- currency lifted to the type level so cross-currency arithmetic fails
-- to compile).
newtype MoneyBasis (c :: Currency) = MoneyBasis Denomination
  deriving (Eq, Show)

-- | Basis constructor (the denomination is the only runtime data).
moneyBasis :: Denomination -> MoneyBasis c
moneyBasis = MoneyBasis

instance HasScale (MoneyBasis c) where
  scaleOf (MoneyBasis d) = denominationScale d

-- | Construct money: @Just@ iff @qty · denominationScale@ is a
-- multiple of the currency's tradeable base. Currencies without a
-- tradeable base (USD, deferred) never construct.
moneyUnit ::
  forall c.
  KnownCurrency c =>
  Denomination ->
  Natural ->
  Maybe (Unit (MoneyBasis c))
moneyUnit d k = do
  base <- tradeableBase (currencyOf (Proxy :: Proxy c))
  if (k * scaleFactor (denominationScale d)) `mod` base == 0
    then Just (unit (MoneyBasis d :: MoneyBasis c) k)
    else Nothing
