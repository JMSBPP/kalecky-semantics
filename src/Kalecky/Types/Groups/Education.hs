-- \[ E = E_G \oplus E_{pr} \]
module Kalecky.Types.Groups.Education (EducationGroup (..)) where

data EducationGroup = EPublic | EPrivate
  deriving (Eq, Ord, Show, Enum, Bounded)
