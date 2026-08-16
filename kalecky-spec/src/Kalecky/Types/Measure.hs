-- | Measures.
--
-- \(\mu\)
--
-- A 'Measure' names the probability measure under which an expectation
-- is taken — for now, the belief measure of an economic agent.
-- Promoted via DataKinds: expectations under different measures are
-- different TYPES (\(\mathbb{E}^{H}\) vs \(\mathbb{E}^{F}\)), so a slot
-- demanding a household expectation rejects a firm one at compile time.
module Kalecky.Types.Measure
  ( Agent (..)
  , Measure (..)
  , KnownMeasure (..)
  ) where

import Data.Proxy (Proxy)

-- | Economic agents whose beliefs define measures.
data Agent = Household | Firm | Government | FinancialSector
  deriving (Eq, Ord, Show, Enum, Bounded)

-- | The measure an expectation is taken under.
data Measure = AgentMeasure Agent
  deriving (Eq, Ord, Show)

-- | Singleton bridge from the type-level measure to its value.
class KnownMeasure (m :: Measure) where
  measureOf :: Proxy m -> Measure

instance KnownMeasure (AgentMeasure Household) where
  measureOf _ = undefined

instance KnownMeasure (AgentMeasure Firm) where
  measureOf _ = undefined

instance KnownMeasure (AgentMeasure Government) where
  measureOf _ = undefined

instance KnownMeasure (AgentMeasure FinancialSector) where
  measureOf _ = undefined
