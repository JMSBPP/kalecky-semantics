-- \[ s(1,1) = 1^{1} = 1 \]
-- \[ u_{1}(k) = k \]
module Kalecky.Types.Units.IndexUnit
  ( IndexBasis (..)
  ) where

import Kalecky.Types.Numerics (scale)
import Kalecky.Types.Units.Unit (HasScale (..))

data IndexBasis = Index
  deriving (Eq, Ord, Show, Enum, Bounded)

instance HasScale IndexBasis where
  scaleOf Index = case scale 1 1 of
    Just s -> s
    Nothing -> error "unreachable: base 1 >= 1"
