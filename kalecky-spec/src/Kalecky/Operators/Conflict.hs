-- | Conflicts.
--
-- @
-- Conflict(a, b)
-- │
-- ├── ExpectationsConflict(agentA, agentB, x)
-- ├── DistributionalConflict(x)     (v2 — kind exists, no constructor yet)
-- └── BargainingConflict(x)         (v2 — kind exists, no constructor yet)
-- @
--
-- A 'Conflict' is two agents' opposed views of the SAME variable —
-- a kind-indexed operator family ORTHOGONAL to the Effect family
-- (difference-shaped, not derivative-shaped) but built on the same
-- parent-plus-specializations pattern. 'Expectations' is the v1
-- specialization: \(\mathbb{E}^{a}[x] - \mathbb{E}^{b}[x]\).
--
-- NOT a Gap wrapper: 'Kalecky.Operators.Gap' requires a REALIZED side;
-- a conflict compares two expectations (user decisions, 2026-08-16).
module Kalecky.Operators.Conflict
  ( ConflictKind (..)
  , Conflict
  , ExpectationsConflict
  , expectationsConflict
  , conflictViews
  , evalConflict
  ) where

import Kalecky.Operators.Expectation (Expectation, expected)
import Kalecky.Operators.Gap (Diff, SignedDiff (..))
import Kalecky.Types.Measure (Measure)

-- | The kinds of economic conflict. Promoted; only 'Expectations' is
-- constructible in v1.
data ConflictKind = Expectations | Distributional | Bargaining
  deriving (Eq, Ord, Show, Enum, Bounded)

-- | Two agents' opposed views of one variable, oriented a-then-b.
data Conflict (k :: ConflictKind) (a :: Measure) (b :: Measure) x where
  ExpectationsC ::
    Expectation a x ->
    Expectation b x ->
    Conflict Expectations a b x

deriving instance Eq x => Eq (Conflict k a b x)
deriving instance Show x => Show (Conflict k a b x)

-- | The Expectations specialization of 'Conflict'.
type ExpectationsConflict a b x = Conflict Expectations a b x

-- | The only v1 constructor: both sides are expectations of the same
-- variable (enforced by the shared @x@).
expectationsConflict ::
  Expectation a x ->
  Expectation b x ->
  ExpectationsConflict a b x
expectationsConflict = undefined

-- | The two views, in orientation order.
conflictViews :: ExpectationsConflict a b x -> (x, x)
conflictViews = undefined

-- | Signed exact evaluation: a's view − b's view.
evalConflict :: SignedDiff x => Conflict k a b x -> Diff x
evalConflict = undefined
