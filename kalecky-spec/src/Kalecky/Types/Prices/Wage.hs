-- | Wages.
--
-- "price is a CompoundUnit with per as the connector" — a wage is a
-- 'Price' whose ratio is money per labor (§7 of the notes: the nominal
-- wage is NOT a price index; \([W] = \text{moneda}/\text{trabajo}\)).
--
-- Valuation-parametric: 'NominalWage' fixes @v = Nominal@; Real wages
-- (deflation) are deferred to a later milestone (user decision,
-- 2026-08-16) — the gap constructors below are therefore
-- valuation-parametric too.
module Kalecky.Types.Prices.Wage
  ( Wage
  , NominalWage
  , wage
  , householdWageGap
  , firmWageGap
  ) where

import Numeric.Natural (Natural)

import Kalecky.Operators.Expectation (Expectation)
import Kalecky.Operators.Gap (Gap, gapER, gapRE)
import Kalecky.Types.Currency (Currency, KnownCurrency)
import Kalecky.Types.Measure (Agent (..), Measure (..))
import Kalecky.Types.Prices.Price (Price, price)
import Kalecky.Types.Units.CompoundUnit (per)
import Kalecky.Types.Units.MoneyUnit (Denomination, MoneyBasis, moneyUnit)
import Kalecky.Types.Units.Unit (Unit)
import Kalecky.Types.Valuation (Valuation (..))

-- | Money per labor, at a valuation.
type Wage (v :: Valuation) (c :: Currency) l = Price v (MoneyBasis c) l

-- | The Nominal-valued wage (DOM-01).
type NominalWage c l = Wage Nominal c l

-- | Construct a wage: the money side is quantized by the currency's
-- tradeable base ('moneyUnit'); 'Nothing' exactly when that rejects.
wage ::
  KnownCurrency c =>
  Denomination ->
  Natural ->
  Unit l ->
  Maybe (Wage v c l)
wage d k labor = do
  money <- moneyUnit d k
  pure (price (per money labor))

-- | Household shape (gapER): \(\mathbb{E}^H[w] - w\).
householdWageGap ::
  Expectation (AgentMeasure Household) (Wage v c l) ->
  Wage v c l ->
  Gap (AgentMeasure Household) (Wage v c l)
householdWageGap = gapER

-- | Firm shape (gapRE): \(w - \mathbb{E}^F[w]\).
firmWageGap ::
  Wage v c l ->
  Expectation (AgentMeasure Firm) (Wage v c l) ->
  Gap (AgentMeasure Firm) (Wage v c l)
firmWageGap = gapRE
