-- \[ X = X_{C} \oplus X_{P} \]
module Kalecky.Types.Groups.Region (Region (..)) where

data Region = Central | Periphery
  deriving (Eq, Ord, Show, Enum, Bounded)
