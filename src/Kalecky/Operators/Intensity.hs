-- \[
--   \operatorname{Intensity} : \text{StateVector} \to \text{StateVector}
-- \]
-- \[
--   \begin{bmatrix} \frac{K}{N} \\ \frac{E}{N} \\ \cdots \end{bmatrix}
-- \]
-- \[ d = \frac{X}{B}, \qquad d_i = \frac{X_i}{B}, \qquad \sum_i d_i = d \]
-- \[ \frac{B}{X} \; \text{is not derivable} \]
module Kalecky.Operators.Intensity
  ( Density
  , densityRatio
  , densityValue
  , Intensity
  , intensity
  , totalDensity
  , groupDensity
  , matchedDensity
  ) where

import Data.Ratio ((%))

import Kalecky.Types.Panel.Period (Period)
import Kalecky.Types.Stocks.StateVector (component, total)
import Kalecky.Types.Stocks.Stock (Role (..), Stock, at, totals)
import Kalecky.Types.Units.CompoundUnit (Per, denominator, numerator, per)
import Kalecky.Types.Units.Unit (value)

newtype Density b c = Density (Per b c)
  deriving (Eq, Show)

densityRatio :: Density b c -> Per b c
densityRatio (Density r) = r

densityValue :: Density b c -> Rational
densityValue (Density r) =
  toInteger (value (numerator r)) % toInteger (value (denominator r))

data Intensity g h b c = Intensity (Stock Level g b) (Stock Base h c)

intensity :: Stock Level g b -> Stock Base h c -> Maybe (Intensity g h b c)
intensity x b
  | map fst (totals x) == map fst (totals b) = Just (Intensity x b)
  | otherwise = Nothing

totalDensity :: Period -> Intensity g h b c -> Maybe (Density b c)
totalDensity p (Intensity x b) = do
  vx <- at p x
  vb <- at p b
  pure (Density (per (total vx) (total vb)))

groupDensity :: Ord g => g -> Period -> Intensity g h b c -> Maybe (Density b c)
groupDensity g p (Intensity x b) = do
  vx <- at p x
  vb <- at p b
  pure (Density (per (component g vx) (total vb)))

matchedDensity :: Ord g => g -> Period -> Intensity g g b c -> Maybe (Density b c)
matchedDensity g p (Intensity x b) = do
  vx <- at p x
  vb <- at p b
  pure (Density (per (component g vx) (component g vb)))
