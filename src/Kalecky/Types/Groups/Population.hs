-- \[
--   N =
--   \begin{bmatrix}
--     N_K \\ N_F \\ N_{LI} \\ N_{L} \\ N_{ML} \\ \sum N_i
--   \end{bmatrix}
-- \]
module Kalecky.Types.Groups.Population (PopulationGroup (..)) where

data PopulationGroup = NK | NF | NLI | NL | NML
  deriving (Eq, Ord, Show, Enum, Bounded)
