-- \[ t = (g, n), \qquad g \in \{\text{Hour}, \text{Month}\}, \; n \in \mathbb{N} \]
-- \[ \operatorname{next}(g, n) = (g, n + 1) \]
-- \[ (g, n) \prec (g, m) \iff n < m ; \qquad (g, n) \not\sim (g', m) \text{ for } g \neq g' \]
module Kalecky.Types.Panel.Period
  ( Period
  , period
  , granularity
  , ordinal
  , next
  , compareP
  ) where

import Numeric.Natural (Natural)

import Kalecky.Types.Units.TimeUnit (TimeBasis)

data Period = Period TimeBasis Natural
  deriving (Eq, Ord, Show)

period :: TimeBasis -> Natural -> Period
period = Period

granularity :: Period -> TimeBasis
granularity (Period g _) = g

ordinal :: Period -> Natural
ordinal (Period _ n) = n

next :: Period -> Period
next (Period g n) = Period g (n + 1)

compareP :: Period -> Period -> Maybe Ordering
compareP (Period g n) (Period h m)
  | g == h = Just (compare n m)
  | otherwise = Nothing
