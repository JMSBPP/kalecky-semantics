# Phase 6: End-Goal Equation Composition - Context

**Gathered:** 2026-08-16 | **Status:** Ready (live co-design mode)

<domain>
## Phase Boundary
The boxed nominal wage growth equation composes from Phases 2-5 types with no ad-hoc glue, and its tests pass (PROOF-05). Milestone acceptance criterion.
</domain>

<decisions>
## Implementation Decisions
- **New `Kalecky/Equations/` subtree** (user): equations are individual relations; `Models/` (future) will collect related equations. First inhabitant: `Equations/WageSetting.hs` — name chosen to read as the LINKAGE (matches the user's Plank vocabulary: NominalWageSetter.plk), not the quantity.
- **Function-of-drivers form**: `nominalWageGrowthFrom rm1 householdGap rm2 productivityGrowth ind inflation :: GrowthRate (NominalWage c l)` — three additive terms via `applyResponse`/`applyResponse`/`applyIndexation` ONLY.
- **Phantom rate carriers `LaborProductivity` and `PriceLevel` declared in the equation module** (DOM-03 as amended; PriceLevel likewise not formally defined in v1).
- "No ad-hoc glue" criterion: implementation uses only shipped combinators (growthRate, applyResponse, applyIndexation, evalGap, rate); asserted structurally in module docs + zero-isolation property tests.

### Claude's Discretion
- Exact phantom-tag kinds and property formulations
</decisions>

<canonical_refs>
- `notes/INCOME_DISTRIBUTION.md` — the boxed equation ("This is the end goal test") + §nominalWageGrowth typed sketch
- `.planning/phases/05-*/05-01-SUMMARY.md` — Wage/gap constructors this composes
</canonical_refs>

<code_context>
- All inputs shipped: householdWageGap (Gap over Wage, Rational eval), ResponseMultiplier/applyResponse, Indexation/applyIndexation, GrowthRate/growthRate/rate
</code_context>

<deferred>
- Models/ subtree; RealWage variant of the equation; formal LaborProductivity/PriceLevel quantities — v2
</deferred>

---
*Phase: 06-end-goal-equation-composition — gathered 2026-08-16*
