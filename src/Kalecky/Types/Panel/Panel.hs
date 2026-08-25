-- \[ P : G \times T \to V \]
-- \[ \operatorname{dom}(P) = G \times T \]
module Kalecky.Types.Panel.Panel
  ( Panel
  , panel
  , window
  , cell
  , row
  , column
  , groups
  , periods
  ) where

import Data.List (nub)
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map

data Panel g t v = Panel [t] (Map (g, t) v)
  deriving (Eq, Show)

panel :: (Bounded g, Enum g, Ord g, Ord t) => [t] -> (g -> t -> v) -> Panel g t v
panel ts f =
  let ts' = nub ts
   in Panel ts' (Map.fromList [((g, t), f g t) | g <- [minBound .. maxBound], t <- ts'])

window :: (Bounded g, Enum g, Ord g, Ord t) => [t] -> [(g, t, v)] -> Maybe (Panel g t v)
window ts obs =
  let ts' = nub ts
      wanted = [(g, t) | g <- [minBound .. maxBound], t <- ts']
      inBlock = [((g, t), v) | (g, t, v) <- obs, t `elem` ts']
      keys = map fst inBlock
   in if length inBlock == length wanted
        && all (`elem` keys) wanted
        && length (nub keys) == length inBlock
        then Just (Panel ts' (Map.fromList inBlock))
        else Nothing

cell :: (Ord g, Ord t) => g -> t -> Panel g t v -> Maybe v
cell g t (Panel _ m) = Map.lookup (g, t) m

row :: (Ord g, Ord t) => g -> Panel g t v -> [(t, v)]
row g (Panel ts m) = [(t, v) | t <- ts, Just v <- [Map.lookup (g, t) m]]

column :: (Bounded g, Enum g, Ord g, Ord t) => t -> Panel g t v -> Maybe (g -> v)
column t (Panel ts m)
  | t `elem` ts = Just (\g -> m Map.! (g, t))
  | otherwise = Nothing

groups :: (Bounded g, Enum g) => Panel g t v -> [g]
groups _ = [minBound .. maxBound]

periods :: Panel g t v -> [t]
periods (Panel ts _) = ts
