-- \[
--   N =
--   \begin{bmatrix}
--     N_K \\ N_F \\ N_{LI} \\ N_{L} \\ N_{ML} \\ \sum N_i
--   \end{bmatrix}
-- \]
-- \[ \sum_{i \in G} N_i = N, \qquad N > 0 \]
-- \[ \sigma_i = \frac{N_i}{N}, \qquad \sum_{i \in G} \sigma_i = 1 \]
module Kalecky.Types.Stocks.StateVector
  ( StateVector
  , stateVector
  , component
  , total
  , share
  ) where

import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Ratio ((%))

import Kalecky.Types.Units.Unit (Unit, value)

data StateVector g b = StateVector (Map g (Unit b)) (Unit b)
  deriving (Eq, Show)

stateVector :: (Bounded g, Enum g, Ord g) => (g -> Unit b) -> Unit b -> Maybe (StateVector g b)
stateVector f tot
  | value tot > 0 && sum (map (value . f) gs) == value tot =
      Just (StateVector (Map.fromList [(g, f g) | g <- gs]) tot)
  | otherwise = Nothing
  where
    gs = [minBound .. maxBound]

component :: Ord g => g -> StateVector g b -> Unit b
component g (StateVector m _) = m Map.! g

total :: StateVector g b -> Unit b
total (StateVector _ t) = t

share :: Ord g => g -> StateVector g b -> Rational
share g v = toInteger (value (component g v)) % toInteger (value (total v))
