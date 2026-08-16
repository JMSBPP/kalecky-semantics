# Roadmap: Kalecky Semantics

## Overview

The journey runs from an untracked, un-isolated codebase to a proven Haskell type hierarchy that makes ill-formed income-distribution economics fail to compile, culminating in the boxed nominal-wage-growth equation type-checking and passing its co-designed test suite. Phases follow the structural dependency chain confirmed by research: infrastructure hygiene first (a bisectable git history and an isolated, fast-building cabal component), then a strict layered type stack — dimensional foundation (units, Price) → economics-agnostic algebraic operators (Gap, Expectation, Effect, GrowthRate) → economics-aware semantic refinements (Conflict, ResponseMultiplier, Indexation) → concrete domain vocabulary validated against the three CASO PRUEBA scenarios — ending with the end-goal equation composed purely from types already proven in earlier phases. Every type-bearing increment within a phase is test-co-designed and approved with the user before implementation; no phase authorizes solo/YOLO implementation.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Project Hygiene & Build Isolation** - Untracked core work is committed to git and `Kalecky.*` builds as an isolated, fast cabal component (completed 2026-08-15)
- [x] **Phase 2: Numeric & Dimensional Foundation** - Base units and `Price` exist with dimensional correctness enforced at compile time (completed 2026-08-16)
- [x] **Phase 3: Algebraic Operators** - Economics-agnostic `Gap`, `Expectation`, `Effect`, `GrowthRate` exist, generic and orientation-correct (completed 2026-08-16)
- [x] **Phase 4: Semantic Refinements** - Economics-aware `Conflict`, `ResponseMultiplier`, `Indexation` refinements exist as zero-cost newtypes (completed 2026-08-16)
- [x] **Phase 5: Domain Vocabulary & CASO PRUEBA Validation** - Concrete economic types exist and the three CASO PRUEBA scenarios pass exactly (completed 2026-08-16)
- [x] **Phase 6: End-Goal Equation Composition** - The boxed nominal wage growth equation composes and its test suite passes (completed 2026-08-16)

## Phase Details

### Phase 1: Project Hygiene & Build Isolation
**Goal**: Two non-negotiable prerequisites are resolved before any type work begins — a bisectable git history for the sole deliverable, and a `Kalecky.*` cabal component isolated from hevm's main build graph so the test-first increment loop stays fast.
**Depends on**: Nothing (first phase)
**Requirements**: INFRA-01, INFRA-02
**Success Criteria** (what must be TRUE):
  1. `git status` shows `kalecky-spec/`, `kalecky-plank/`, `notes/`, `test/`, `foundry.toml`, `remappings.txt` as tracked, not untracked
  2. `kalecky-spec.cabal` defines a dedicated `Kalecky.*` library and test-suite stanza, buildable and testable independently of hevm's main library
  3. Running the `Kalecky` test-suite does not trigger a full hevm rebuild
  4. Every subsequent increment lands as a reviewable git commit
**Plans**: 6 plans (sequential, waves 1-6)
- [ ] 01-01-PLAN.md — Phase branch, artifact ignore rules, INFRA-01 repo-state verifier (RED oracle)
- [ ] 01-02-PLAN.md — Absorb `kalecky-spec/.git`, vendor import commit, track all core sources
- [ ] 01-03-PLAN.md — Convert `lib/forge-std` and `lib/plank-foundry-deployer` to verified pinned submodules
- [ ] 01-04-PLAN.md — Measure `lib/plank-monorepo` upstream drift; user decision checkpoint
- [ ] 01-05-PLAN.md — Execute the plank-monorepo decision; close the INFRA-01 gate; history legibility checkpoint
- [ ] 01-06-PLAN.md — `Kalecky.Types` casing/import hygiene, isolated `kalecky` sublibrary + `kalecky-test` smoke suite, isolation proof

### Phase 2: Numeric & Dimensional Foundation
**Goal**: The dimensional kernel (units + `Price`) exists so mismatched-dimension or mismatched-valuation arithmetic is a compile error, while mismatched-scale arithmetic within the same dimension auto-aligns by exact conversion — never at runtime.
**Depends on**: Phase 1
**Requirements**: UNIT-01, UNIT-02, UNIT-03, UNIT-04, UNIT-05, UNIT-06, PROOF-01
**Success Criteria** (what must be TRUE):
  1. Base units (`Scale` with `s(b,i) = b^i`, `Currency` with `COP`/`USD`, `LaborUnit`, `TimeUnit`) are constructible only via smart constructors — direct data-constructor use fails to compile; a `Unit u_s(k)` carries its Decimal-backed amount `k` at scale `s`
  2. Units compose as a semigroup under `(·)`; `CompoundUnit` connectors `Per` (ρ: ratio) and `Times` (τ: tensor) compose two units and type-check, auto-aligning mismatched scales by exact conversion to a common scale (the `s = h` derivation rule)
  3. `Price p(u,v)` is a valuation-parameterized `Per`-compound unit with `Valuation = Nominal | Real PriceIndex` threaded through the type
  4. Adding/subtracting units or prices with mismatched dimensions or valuations fails to compile — no `Num` instance; restricted same-dimension operators only, while same-dimension add/sub succeeds; multiplying/dividing composes units correctly, including canceling to a dimensionless ratio
  5. Scale conversion within one unit (e.g., COP Million ↔ Thousand via `b^i` exponents) is exact with Decimal arithmetic and no rounding drift; each type shipped in this phase has QuickCheck law properties (via quickcheck-classes where applicable), test co-designed and approved with the user before implementation — establishing the pattern honored in every later phase
**Plans**: TBD

### Phase 3: Algebraic Operators
**Goal**: The economics-agnostic algebra that every later refinement and domain type composes from exists, generic over `x` and provably orientation-correct.
**Depends on**: Phase 2
**Requirements**: ALG-01, ALG-02, ALG-03, ALG-04, ALG-05, ALG-06
**Success Criteria** (what must be TRUE):
  1. `Gap x` preserves orientation: a property test proves `Gap a b ≠ Gap b a` (distinct `positiveTerm`/`negativeTerm`)
  2. `Gap` is generic over any `x` admitting subtraction and imports no domain/economics modules
  3. `Expectation agent x` with `Agent = Household | Firm | Government | FinancialSector` makes `E^H[x]` and `E^F[x]` distinct types for the same `x`
  4. `Effect responder perturband` is a newtype over `Number` encoding ∂responder/∂perturband, carrying no extra runtime data
  5. `GrowthRate x` computes the dimensionless relative change Δx/x of an amount-carrying `Unit` or `Price`; `mkCommonGrowthRate` returns `Maybe (CommonGrowthRate a b)`, `Just` only when the two growth rates share a common base
**Plans**: TBD

### Phase 4: Semantic Refinements
**Goal**: Only the economics-aware refinements the end-goal wage equation actually consumes exist, layered as zero-cost newtypes over the Phase 3 algebra.
**Depends on**: Phase 3
**Requirements**: SEM-01, SEM-02, SEM-03
**Success Criteria** (what must be TRUE):
  1. `ExpectationsConflict agentA agentB x` is a newtype over `Gap x`, constructible only from two `Expectation`s of the same variable
  2. `ResponseMultiplier responder perturband` is a newtype over `Effect` with no redundant stored scalar
  3. `Indexation target reference` is a newtype over `Effect (GrowthRate target) (GrowthRate reference)`
**Plans**: TBD

### Phase 5: Domain Vocabulary & CASO PRUEBA Validation
**Goal**: Concrete economic vocabulary is defined on top of the proven algebra, and the three worked scenarios from `notes/INCOME_DISTRIBUTION.md` pass with exact numeric assertions.
**Depends on**: Phase 4
**Requirements**: DOM-01, DOM-02, DOM-03, DOM-04, PROOF-02, PROOF-03, PROOF-04
**Success Criteria** (what must be TRUE):
  1. `Wage` is a `Price` over `Per MoneyUnit LaborUnit`; `NominalWage` is the `Wage` with `Nominal` valuation — money per labor, not a price index
  2. `RealWage` is the `Wage` with valuation `Real PriceIndex` — `NominalWage` deflated by `PriceLevel`; `LaborProductivity` is `Ratio Output LaborService` with `GrowthRate` definable on it
  3. Household and firm real-wage expectation gap constructors produce `Gap RealWage` values with opposite orientations
  4. CASO PRUEBA Nivel→Nivel passes: "minimum wage of 20000 COP per hour" constructs and asserts exactly
  5. CASO PRUEBA Nivel→Tasa and Tasa→Tasa pass: wage 10 → 12 money units per labor unit is exactly +20 percentage-points growth; growth 5% → 5.20% is exactly +20 basis points, with the Gap-of-a-rate vs. rate-of-a-rate ambiguity resolved in that increment's co-designed test
**Plans**: TBD

### Phase 6: End-Goal Equation Composition
**Goal**: The milestone's acceptance criterion — the boxed nominal wage growth equation from `notes/INCOME_DISTRIBUTION.md` — composes from types already proven in Phases 2-5 and its test suite passes.
**Depends on**: Phase 5
**Requirements**: PROOF-05
**Success Criteria** (what must be TRUE):
  1. `ΔW/W = ResponseMultiplier·Gap(E^H[W/P], W/P) + ResponseMultiplier·GrowthRate(LaborProductivity) + Indexation·GrowthRate(PriceIndex)` type-checks and compiles using only types from Phases 2-5, without ad-hoc glue code
  2. All three additive terms compose without introducing new algebraic machinery beyond what Phases 3-4 already defined
  3. Both property tests (QuickCheck laws) and example tests (concrete numeric assertions) for the composed equation pass
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Project Hygiene & Build Isolation | 6/6 | Complete    | 2026-08-15 |
| 2. Numeric & Dimensional Foundation | 0/TBD | Complete    | 2026-08-16 |
| 3. Algebraic Operators | 0/TBD | Complete    | 2026-08-16 |
| 4. Semantic Refinements | 0/TBD | Complete    | 2026-08-16 |
| 5. Domain Vocabulary & CASO PRUEBA Validation | 0/TBD | Complete    | 2026-08-16 |
| 6. End-Goal Equation Composition | 0/TBD | Complete    | 2026-08-16 |
