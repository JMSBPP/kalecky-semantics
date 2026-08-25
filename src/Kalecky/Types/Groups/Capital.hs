-- \[ K = K_F \oplus K_K \oplus K_{MC} \]
module Kalecky.Types.Groups.Capital (CapitalGroup (..)) where

data CapitalGroup = KF | KK | KMC
  deriving (Eq, Ord, Show, Enum, Bounded)
