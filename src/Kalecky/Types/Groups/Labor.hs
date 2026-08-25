-- \[ L = L_I \oplus L_F \oplus L_{ML} \]
module Kalecky.Types.Groups.Labor (LaborGroup (..)) where

data LaborGroup = LI | LF | LML
  deriving (Eq, Ord, Show, Enum, Bounded)
