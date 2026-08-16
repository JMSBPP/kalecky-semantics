-- | Currencies and their tradeable bases.
--
-- 'Currency' is promoted via DataKinds to a type-level tag on money:
-- mixing currencies (COP + USD) is a compile error, never a runtime
-- check. The tradeable base (Draft.plk @tradeable_base@) is the
-- smallest tradable increment of a currency in raw currency units —
-- amounts are Naturals and only multiples of it are constructible.
module Kalecky.Types.Currency
  ( Currency (..)
  , tradeableBase
  , KnownCurrency (..)
  ) where

import Data.Proxy (Proxy)
import Numeric.Natural (Natural)

-- | Supported currencies. USD is a tag only for now: construction is
-- deferred until it has a tradeable base (user decision, 2026-08-15).
data Currency = COP | USD
  deriving (Eq, Ord, Show, Enum, Bounded)

-- | Smallest tradable increment, in raw currency units.
-- @COP -> Just 50@ (Draft.plk); @USD -> Nothing@ (deferred).
tradeableBase :: Currency -> Maybe Natural
tradeableBase = \case
  COP -> Just 50
  USD -> Nothing

-- | Singleton bridge from the type-level currency tag to its value.
class KnownCurrency (c :: Currency) where
  currencyOf :: Proxy c -> Currency

instance KnownCurrency COP where
  currencyOf _ = COP

instance KnownCurrency USD where
  currencyOf _ = USD
