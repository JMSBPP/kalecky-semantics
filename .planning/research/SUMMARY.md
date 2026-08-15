# Project Research Summary

**Project:** Kalecky Semantics — dimensionally-typed, algebraically-lawful economic modeling library (Haskell, inside the existing `kalecky-spec` hevm fork)
**Domain:** Typed dimensional-analysis / units-of-measure library, specialized for research-grade Post-Keynesian (Kaleckian) income-distribution economics
**Researched:** 2026-08-15
**Confidence:** MEDIUM-HIGH

## Executive Summary

This is a research-grade type-system library, not an application: the deliverable is a Haskell type hierarchy (inside `kalecky-spec`, on GHC 9.8.4 / `lts-23.28`) that makes "ill-formed economics" a compile-time error, culminating in one boxed nominal-wage-growth equation that must type-check and pass a test suite built from concrete worked examples (the CASO PRUEBA scenarios). No comparable prior art exists — generic Haskell dimensional-analysis libraries (`dimensional`, `units`/`Data.Metrology`) and currency libraries (`safe-money`) supply the *architectural pattern* (a physics/economics-agnostic kernel with concrete vocabulary layered on top, constructors hidden behind smart constructors) but none of them model economics-specific concepts like orientation-preserving `Gap`, agent-indexed `Expectation`, or `Effect`-as-derivative refinements. The project's own `notes/INCOME_DISTRIBUTION.md` is the primary source of truth for the target design and has already resolved the hardest semantic questions (Gap orientation, Effect-as-newtype, valuation duality).

The recommended approach is layered and incremental: a strict L0→L6 dependency stack (Numeric base → Unit/Dimension kernel → EconomicQuantity → economics-agnostic algebraic operators (Gap/Effect/GrowthRate/Expectation) → economics-aware semantic refinements (Conflict/ResponseMultiplier/Indexation) → concrete domain vocabulary (NominalWage/RealWage/...) → the composed end-goal equation), built one type per increment with a user-approved, co-designed test before each implementation. The stack itself needs almost no new dependencies — `Decimal` (already pinned) as the numeric backbone instead of `Double`, plus `quickcheck-classes` for off-the-shelf algebraic law-checking, and `GADTs`/`DerivingVia`/`DerivingStrategies` added to the existing GHC2021 extension baseline. Scope must stay ruthlessly tied to the boxed wage equation and the three CASO PRUEBA scenarios (Nivel→Nivel, Nivel→Tasa, Tasa→Tasa) — the notes present a much richer hierarchy (full Conflict/Effect tree, and an even larger ψ functional-distribution matrix) that is explicitly out of scope for v1 and exists only as a target architecture, not a build checklist.

The dominant risks are semantic, not merely technical, and research converges on the same handful of failure modes: giving dimensioned quantities a `Num` instance (silently allowing e.g. `NominalWage + LaborProductivity` to typecheck); losing `Gap`'s orientation (`positiveTerm`/`negativeTerm`) so household vs. firm sign conventions get silently swapped; conflating ratio/percentage/percentage-point-delta/basis-point-delta representations (the whole reason the Tasa→Tasa CASO PRUEBA scenario exists); over-engineering type-level unit algebra (`DataKinds`/`TypeFamilies`) before a concrete increment's test demands it; and building ahead of the wage equation into the unused parts of the Conflict/Effect hierarchy or the ψ matrix. Two non-domain risks are equally load-bearing and must be resolved before any type work begins: `kalecky-spec/`, `notes/`, and related files are currently untracked in git (no bisectable safety net for a project whose entire deliverable is the code itself), and adding `Kalecky.*` modules to hevm's existing 2000+-file library stanza (instead of a dedicated internal library/test-suite) would make every tiny increment pay a full-package rebuild cost, undermining the fast test-approve-implement loop the project's process depends on.

## Key Findings

### Recommended Stack

The stack is almost entirely already pinned by the existing `kalecky-spec` package (GHC 9.8.4 via `lts-23.28`, GHC2021 extension baseline) — research is scoped to additions, not replacement. The single most consequential decision is representation: use the already-dependency `Decimal` (not `Double`) as the numeric backbone for `Number`/money amounts, because the CASO PRUEBA scenarios are stated as exact decimal figures and float accumulation error would make equality tests flaky or mask real bugs. `GADTs`, `DerivingVia`, and `DerivingStrategies` need to be added explicitly to `default-extensions` (GHC2021 does not include them) to support the design's GADT-refined `Valuation`/`CompoundUnit` constructors and its newtype-heavy `Effect`/`GrowthRate`/refinement hierarchy. `quickcheck-classes` (already resolvable from the pinned Stackage snapshot) provides off-the-shelf `Semigroup`/`Eq`/`Ord` law-checkers that wire directly into the existing Tasty test tree — notably useful as a *negative* test for `Gap` (its non-commutativity should deliberately fail `commutativeSemigroupLaws`).

**Core technologies:**
- GHC 9.8.4 / GHC2021 (already pinned) — extension baseline requires only 3 explicit additions (`GADTs`, `DerivingVia`, `DerivingStrategies`) to support the target type designs
- `Decimal` 0.5.2 (already a dependency) — exact decimal arithmetic for `Number`/money amounts, avoiding float-precision pitfalls in exact-decimal CASO PRUEBA tests
- `quickcheck-classes` 0.6.5.0 (new, resolves from existing snapshot) — standard algebraic law-checkers wired into the existing Tasty tree, including deliberate law-failure tests for non-commutative types like `Gap`

**Explicitly rejected:** `units`/`dimensional` (SI-based, not extensible to Money/Labor/Valuation axes, and `units` is stale since Jan 2022), `refined` (premature — the spec's own `Maybe`-returning smart constructors suffice), `singletons`, `groups`/`semigroupoids`, and any LiquidHaskell/SMT verification layer (explicitly deferred per PROJECT.md).

### Expected Features

No prior art combines typed dimensional analysis with Post-Keynesian economic semantics — this space is genuinely novel, confirmed by an ecosystem survey finding SFC/agent-based-modeling literature explicitly complains about the *absence* of type-safety approaches in this domain. Table stakes come from the closest analog libraries (`dimensional`, `units`, `safe-money`, `refined`): compile-time dimension-mismatch rejection, restricted (non-`Num`) arithmetic, smart constructors, unit conversion, `Show`/`Eq`/`Ord`, compound-unit composition (Per/Times), dimensionless ratio results, and precision-safe numeric representation. The differentiators are what make this research-grade rather than generic: orientation-preserving `Gap` (a genuine departure from `vector-space`'s `AffineSpace`, which collapses subtraction into a sign-blind `Diff`), semantic refinement layers with zero added data (`Conflict` over `Gap`, `ResponseMultiplier`/`Elasticity`/`Indexation` over `Effect`), agent-indexed `Expectation`, and `Maybe`-partial `CommonGrowthRate` construction.

**Must have (table stakes):**
- Compile-time dimension/unit mismatch rejection via `EconomicQuantity<valuation, unit>` phantom types
- Restricted arithmetic (no naive `Num`; hand-written same-unit `qAdd`/`qSub`, unit-changing `*`/`/`)
- Compound unit composition (`Per`, `Times`) — load-bearing, needed before `NominalWage` can even be declared

**Should have (differentiators):**
- Orientation-preserving `Gap` (`positiveTerm`/`negativeTerm`)
- Agent-indexed `Expectation agent x`
- Zero-cost newtype semantic refinements (`Conflict`, `ResponseMultiplier`, `Indexation`)
- `Maybe`-returning `CommonGrowthRate` smart constructor

**Defer (v2+):**
- ψ functional income-distribution matrix and Colombia-specific mechanism taxonomy (explicitly a later milestone)
- Additional `Agent` kinds / `Measure agent` probabilistic refinement
- Plank DSL port, hevm/Z3 symbolic-execution bridge, broader currency/unit generality

### Architecture Approach

The codebase should converge on a strict L0–L6 layered stack matching the pattern both `dimensional` and `units` use in practice (economics/physics-agnostic kernel at the bottom, concrete vocabulary layered on top, constructors hidden behind smart constructors): L0 Numeric base → L1 Unit/Dimension kernel (Scale, Valuation, CompoundUnit, Currency, LaborUnit, TimeUnit — no economics knowledge) → L2 `EconomicQuantity` (binds a Number to a valuation+unit) → L3 economics-agnostic algebraic operators (`Gap`, `Effect`, `GrowthRate`, `Expectation` — must be typeclass-bounded, not concrete-type-bound, so `GrowthRate` can recurse onto itself for the Tasa→Tasa scenario) → L4 economics-aware semantic refinements (`Conflict`, `ResponseMultiplier`, `Indexation` — zero-cost newtypes, no new data) → L5 concrete domain vocabulary (`NominalWage`, `RealWage`, `LaborProductivity`) → L6 the composed end-goal equation. The current draft tree under `kalecky-spec/src/Kalecky/` has the right intent but mixes layers (L3/L4 co-located in flat `Operators/`, casing bugs in imports) — this should be resolved as each file gets its first real implementation, not as a separate cleanup pass.

**Major components:**
1. `Units/` kernel (L0-L1) — economics-agnostic dimensional bookkeeping; nothing here should ever import from `Semantics/`, `Domain/`, or `Equations/`
2. `Operators/` (L3) — generic algebraic operators parametrized over `x` via typeclass constraints, reusable across future Kaldor/Minsky/fiscal modules
3. `Semantics/` (L4, split out from the current flat `Operators/`) — newtype refinements adding economic meaning, one-directional dependency on L3 only
4. `Domain/` (L5) and `Equations/` (L6) — concrete economic vocabulary and the composed boxed wage-growth equation, the actual acceptance criterion

### Critical Pitfalls

1. **`Num` instance abuse on dimensioned quantities** — never give `EconomicQuantity`/`Gap`/`Effect` a `Num` instance; write named operations (`addQuantity`, `scaleQuantity`) instead, since `Num` silently allows adding incompatible units.
2. **Orientation/sign errors in `Gap`** — keep `positiveTerm`/`negativeTerm` field names (not `lhs`/`rhs`), and test orientation-antisymmetry explicitly (`evalGap (Gap a b) == negate (evalGap (Gap b a))`), not just magnitude.
3. **Percentage-points vs. basis-points vs. ratio confusion** — the entire reason the CASO PRUEBA scenarios exist; require distinct types/explicit conversion functions and pin exact cross-representation numbers in example tests, never rely on a single unlabeled `Double`.
4. **Type-level over-engineering before value delivery** — default to value-level unit tags with smart constructors; reserve `DataKinds`/type families for cases a specific approved test literally cannot express otherwise.
5. **Untracked core work in git / shared cabal component build cost** — `kalecky-spec/`, `notes/` are currently untracked (no bisectable safety net for the sole deliverable), and `Kalecky.*` modules must live in a dedicated internal library/test-suite stanza, not hevm's main library, or every increment pays a full rebuild — both must be resolved in increment zero, before any type work begins.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 0: Project Hygiene & Build Isolation
**Rationale:** Two non-negotiable prerequisites block the entire test-first increment loop and are cheap to fix now, catastrophically expensive to fix later (Pitfalls 8 & 9).
**Delivers:** `git add`/commit of all currently-untracked project files (`kalecky-spec/`, `notes/`, `foundry.toml`, `remappings.txt`); a dedicated `library kalecky-core` + `test-suite kalecky-test` internal-library stanza in `kalecky-spec.cabal`, isolated from hevm's main build graph; confirmation that `cabal test kalecky-test` runs fast without triggering a full hevm rebuild.
**Addresses:** No FEATURES.md item directly — this is process/infrastructure.
**Avoids:** Pitfall 8 (slow builds from shared cabal component), Pitfall 9 (untracked core work, no bisectable history).

### Phase 1: Numeric & Dimensional Foundation (L0-L2)
**Rationale:** Everything else in the type hierarchy depends on `Number`'s representation and the unit/dimension kernel; this is also where the two most disruptive-to-retrofit decisions (Decimal vs Double, no-Num-instance) must be locked in.
**Delivers:** `Number` (backed by `Decimal`, not `Double`), `Scale`, `Valuation` (Nominal|Real), `Unit`/`CompoundUnit` (Per/Times), `Currency`, `MoneyUnit`, `LaborUnit`, `TimeUnit`, `EconomicQuantity<valuation, unit>` with restricted (non-`Num`) arithmetic.
**Addresses:** FEATURES.md table stakes (compile-time mismatch rejection, restricted arithmetic, compound unit composition, precision-safe numerics).
**Avoids:** Pitfall 1 (Num abuse), Pitfall 4 (type-level over-engineering), Pitfall 7 (floating-point representation).

### Phase 2: Algebraic Operators (L3) — Gap, Expectation, Effect, GrowthRate
**Rationale:** These are economics-agnostic operators that everything in L4-L6 composes from; `Gap` must be first and independently proven (orientation bugs propagate silently through every later refinement), and `GrowthRate` must be typeclass-bounded from the start to support the Tasa→Tasa self-composition scenario.
**Delivers:** `Gap x` (orientation-preserving), `Expectation agent x` + `Agent` enum, `Effect responder perturband`, `GrowthRate x` + `CommonGrowthRate` (`Maybe`-returning smart constructor).
**Uses:** `quickcheck-classes` for law-checking (deliberately failing `commutativeSemigroupLaws` on `Gap`); GHC2021 + added `GADTs`/`DerivingVia`/`DerivingStrategies`.
**Implements:** Architecture L3 — typeclass-bounded recursion pattern (Pattern 3 in ARCHITECTURE.md).
**Avoids:** Pitfall 2 (orientation/sign errors), Pitfall 3 (pp/bp/ratio confusion — must be resolved here, in `GrowthRate`).

### Phase 3: Semantic Refinements (L4) — Conflict, ResponseMultiplier, Elasticity, Indexation
**Rationale:** Only the refinements the boxed wage equation actually consumes should be built here — the notes sketch a much richer Conflict/Effect hierarchy (BargainingConflict, DistributionalEffect, NetDistributionalEffect) that is explicitly out of scope for v1.
**Delivers:** `Conflict`/`ExpectationsConflict` (needs `Gap`+`Expectation`), `ResponseMultiplier` (needs `Effect`), `Indexation` (needs `Effect`+`GrowthRate`) — as zero-cost newtypes.
**Addresses:** FEATURES.md differentiators (semantic refinement layers with zero added data).
**Avoids:** Pitfall 5 (premature abstraction of the algebra — build only what the wage equation needs), Pitfall 10 (ψ-matrix scope creep — `Agent` must not grow beyond Household/Firm/Government/FinancialSector without a term in the wage equation requiring it).

### Phase 4: Domain Vocabulary & CASO PRUEBA Validation (L5)
**Rationale:** Should be sequenced after L3 is proven so CASO PRUEBA tests exercise real operators against real domain types, not synthetic `x`.
**Delivers:** `NominalWage`, `RealWage`, `LaborProductivity`, `PriceLevel`, `Output`; the three CASO PRUEBA example tests (Nivel→Nivel, Nivel→Tasa, Tasa→Tasa) with exact cross-representation numeric assertions.
**Addresses:** FEATURES.md "property-based + scenario-based test co-design" differentiator — this is the acceptance-grade validation layer.
**Avoids:** Pitfall 3 (pp/bp/ratio confusion, pinned exactly here), Pitfall 6 (vacuous QuickCheck properties — pair every law with a concrete example test).

### Phase 5: End-Goal Equation Composition (L6)
**Rationale:** The actual milestone acceptance criterion; should require no new algebra if L3-L5 were correctly factored — if it does, that's a signal L4 was under-specified.
**Delivers:** `Equations/NominalWageGrowth.hs` — the boxed nominal wage growth equation composing `ResponseMultiplier·Gap + ResponseMultiplier·GrowthRate + Indexation·GrowthRate`, and its passing test suite.
**Addresses:** FEATURES.md "end-goal equation composability" — the whole milestone's acceptance criterion.
**Avoids:** Pitfall 10 (resist scope creep toward ψ matrix at exactly this point, where "not really done" pressure is highest).

### Phase Ordering Rationale

- Dependencies form a strict DAG (L0→L6) confirmed independently by both ARCHITECTURE.md's build-order section and FEATURES.md's feature-dependency graph — this order is not a judgment call, it's structurally forced (e.g. `CompoundUnit` cannot exist before `Currency`/`LaborUnit`/`TimeUnit`, `EconomicQuantity` cannot exist before `CompoundUnit`).
- Phase 0 is unusual (infrastructure, not a type) but is placed first because two PITFALLS.md findings (untracked git, shared cabal build) are rated as blocking the safety net for the entire subsequent test-first process — cheap now, "VERY HIGH" cost if lost later.
- `Gap` is placed at the start of Phase 2 (not bundled with `Effect`/`GrowthRate` arbitrarily) because orientation bugs are the pitfall most likely to propagate silently through everything built on top of it.
- Phase 4 (domain vocabulary) is deliberately sequenced *after* Phase 2 (operators), even though L5 technically only depends on L1/L2, so CASO PRUEBA tests exercise proven operators against real types rather than synthetic ones — this matches ARCHITECTURE.md's explicit recommendation.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2 (GrowthRate self-composition):** ARCHITECTURE.md flags the Tasa→Tasa scenario as genuinely ambiguous in the source prose ("+20 puntos básicos" could be read as `Gap (GrowthRate x)` or `GrowthRate (GrowthRate x)` — these are arithmetically different) — this needs to be resolved via the co-designed test, not assumed, before implementation.
- **Phase 1 (`UndecidableInstances` question):** STACK.md flags this as MEDIUM confidence — only add if the compiler actually demands it for a specific `CompoundUnit` type-family instance; worth a quick research check if it comes up.

Phases with standard patterns (skip research-phase):
- **Phase 0:** Cabal internal-library setup is a well-documented, mechanical pattern (multiple Sources in PITFALLS.md/STACK.md cite official Cabal docs and Discourse threads).
- **Phase 3 (semantic refinements):** The newtype-wrapping pattern is already fully resolved in `notes/INCOME_DISTRIBUTION.md` and cross-validated against the `refined` library's design precedent — implementation is mechanical once Phase 2 is proven.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Versions verified live against the actual `lts-23.28` Stackage snapshot; GHC2021 extension set verified against the official GHC proposal text |
| Features | MEDIUM-HIGH | Table stakes verified against real Hackage docs (`dimensional`, `units`, `safe-money`, `refined`, `vector-space`); differentiators are validated as *sound design* against those patterns but have no direct prior-art API to check exact shape against, since no comparable economics-typed library exists |
| Architecture | MEDIUM | Verified against two real Hackage dimensional-analysis libraries' documented module conventions; the economics-specific layer boundaries are a direct translation of the project's own already-resolved design dialogue (`notes/INCOME_DISTRIBUTION.md`), not an independently-verified external source |
| Pitfalls | MEDIUM-HIGH | Haskell type-level/dimensional-analysis pitfalls (Num abuse, type-family over-engineering, float precision) are well-documented via Hackage/community sources; economics-specific pitfalls (Gap orientation, pp/bp confusion) are inferred from the project's own notes and general economic-software conventions, so treat those specific findings as MEDIUM |

**Overall confidence:** MEDIUM-HIGH

### Gaps to Address

- **Tasa→Tasa semantics (Gap-of-rate vs. rate-of-rate):** The source prose is ambiguous between `Gap (GrowthRate x)` and `GrowthRate (GrowthRate x)` — must be resolved in the Phase 2 co-designed test, not assumed from the notes' prose alone.
- **`UndecidableInstances` necessity:** Unknown until `CompoundUnit`'s type-family reduction is actually written in Phase 1 — add only if the compiler demands it, per STACK.md's explicit caution against adding it preemptively.
- **Exact API shape of differentiator types:** No prior-art library exists for `Gap`/`Expectation`/`Indexation`-style economics typing, so while the design's *validity* is well-supported, the precise smart-constructor signatures will need to be worked out per-increment during the co-designed test-approval process rather than assumed from research.
- **Kalecky-Plank / Lean formal-verification integration:** Explicitly out of scope for this milestone per all four research files; no roadmap phase should touch it, but worth flagging that CONCERNS.md (referenced in PITFALLS.md) notes unclear build orchestration across the Lean/Haskell/Plank layers — a future milestone concern, not this one's.

## Sources

### Primary (HIGH confidence)
- `https://www.stackage.org/lts-23.28` and package-specific Stackage pages (`quickcheck-classes`, `QuickCheck`, `tasty-quickcheck`, `Decimal`, `dimensional`, `units`) — live snapshot fetches confirming exact pinned versions
- GHC Proposal #0380 (GHC2021 extension set) — official proposal text, cross-checked against `ghc-proposals.readthedocs.io`
- `kalecky-spec/kalecky-spec.cabal`, `kalecky-spec/stack.yaml` — direct inspection of pinned resolver, existing extensions/dependencies
- `notes/INCOME_DISTRIBUTION.md` — primary source of truth for the target type hierarchy, Gap orientation resolution, CASO PRUEBA scenarios, boxed end-goal equation
- `.planning/PROJECT.md` — milestone scope, Active requirements, Out-of-Scope decisions, Key Decisions (one-type-per-increment process)
- `https://hackage.haskell.org/package/dimensional-1.6.1/docs/Numeric-Units-Dimensional.html`, `https://hackage.haskell.org/package/units/docs/Data-Metrology-Poly.html` — official docs confirming restricted-arithmetic and kernel/vocabulary-split patterns

### Secondary (MEDIUM confidence)
- `https://github.com/goldfirere/units` — package-split rationale (generic machinery vs. concrete unit vocabulary)
- `https://hackage.haskell.org/package/safe-money`, `https://hackage.haskell.org/package/refined`, `https://hackage.haskell.org/package/vector-space` — differentiator design-pattern validation (Dense/Discrete, refinement newtypes, AffineSpace contrast)
- `https://wiki.haskell.org/Smart_constructors`, Roman Cheplyaka's module-system article — general Haskell library-design conventions
- `.planning/codebase/CONCERNS.md` — untracked-files finding, cabal build-graph concern, `Draft.plk` combinatorial-scaling TODO

### Tertiary (LOW confidence)
- Agent-based stock-flow-consistent modeling literature (Caiani/Godin, sfctools JOSS paper) — used only to confirm absence of typed prior art in this niche, not for feature-detail specifics; needs no further validation since it's a negative-existence claim, not a design source

---
*Research completed: 2026-08-15*
*Ready for roadmap: yes*
