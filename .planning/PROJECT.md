# Kalecky Semantics

## What This Is

A typed system for income distribution economics — a Haskell library of algebraic and semantic types (Gap, Conflict, Effect, GrowthRate, Indexation, dimensional units) that formalizes Kaleckian/Post-Keynesian income distribution theory, starting from the Blecker-Setterfield conflicting-claims wage dynamics. It is a research artifact: the type hierarchy itself is the deliverable, designed to be reusable across Kaleckian, Kaldorian, Minskyan, and fiscal modules without duplicating semantics.

## Core Value

Ill-formed economics must not type-check: the type system encodes the dimensional and semantic structure of income distribution so that the end-goal wage-growth equation can be expressed, compiled, and proven by tests.

## The End-Goal Test

v1 is done when this equation (marked "This is the end goal test" in `notes/INCOME_DISTRIBUTION.md`) is expressed in the types and its co-designed test suite passes:

```
ΔW/W = ResponseMultiplier(NominalWageGrowth, HouseholdRealWageExpectationGap)
         · Gap(E^H[W/P], W/P)
     + ResponseMultiplier(NominalWageGrowth, LaborProductivityGrowth)
         · GrowthRate(LaborProductivity)
     + Indexation(NominalWage, PriceLevel)
         · GrowthRate(PriceIndex)
```

## Requirements

### Validated

<!-- Existing capabilities inferred from codebase map -->

- ✓ v1.0 Wage Equation (all Active items below shipped 2026-08-16): dimensional kernel (Scale/Unit/Currency/CompoundUnit/Valuation/Price), algebraic operators (Expectation/Gap/Delta/GrowthRate/Effect), semantic refinements (Conflict family/ResponseMultiplier/Indexation), Wage vocabulary, three exact CASO PRUEBA scenarios, and the boxed wage-setting equation — 107 tests + 6 compile-fail boundaries green

- ✓ Specification of the income distribution model (`notes/INCOME_DISTRIBUTION.md`) — source of truth, existing

### Active (v2 backlog — define via /gsd:new-milestone)

- [x] State vectors, stocks, intensity (2026-08-16, feature/state-vectors): per-stock partition enums incl. Region, reconciled `StateVector`, role-tagged `Stock`, `intensity` → `Density` — spec + plan under `docs/superpowers/`

- [ ] RealWage: NominalWage deflated by a PriceLevel with numeric PriceIndex content
- [ ] Remaining refinements: Elasticity (+Normalization), DistributionalEffect/NetDistributionalEffect, Distributional/Bargaining Conflict constructors
- [ ] Functional income distribution matrix (ψ mechanisms, wage/profit shares, informal sector)

### Out of Scope

- Plank DSL port — DROPPED 2026-08-16 with the EVM direction (kalecky-plank/ removed; its scale/tradeable-base design is captured in the Haskell types)
- Solidity/EVM execution and hevm bridge — DROPPED 2026-08-16; the project is a plain Haskell library
- Functional income distribution matrix (ψ mechanisms, wage/profit shares, informal sector W_{L_I}) — the wage equation is the v1 end goal; the ψ object is a later milestone
- Colombia-specific mechanism taxonomy (taxes, transfers, subsidies with legal names) — notes TODO, explicitly "other agents' work" after ψ is formalized
- Lean/EvmYul proofs of Kalecky semantics — inherited infrastructure, not part of this milestone
- Autonomous implementation without test approval — every increment's test is co-designed and approved by the user first

## Context

- As of 2026-08-16 the repo is a plain root-level Stack project (`kalecky-semantics.cabal`, lts-23.28): `src/Kalecky/**` library, `test/**` suite, `notes/` spec. The original EvmYul/hevm/Foundry/Plank scaffolding was removed (recoverable from git history before tag v1.0's successor commit).
- Source of truth for the model: `notes/INCOME_DISTRIBUTION.md`, itself grounded in Blecker & Setterfield (2019), *Heterodox Macroeconomics*, p. 204 (conflicting-claims income distribution).
- The notes contain a worked type-design dialogue (Spanish/English) resolving key questions: Gap is algebraic and orientation-preserving; Conflict is a semantic newtype over Gap; Effect is the fundamental derivative object and refinements add meaning, not data; NominalWage is money/labor (not a price index); Expectation is indexed by agent (or Measure agent).
- `.planning/codebase/` maps the ORIGINAL three-stack repo (Lean/Haskell/Plank) and is historical only after the 2026-08-16 cut.
- Design language: algebraic structures know no economics (Gap, Effect); semantic refinements carry the economics (Conflict, ResponseMultiplier, Indexation). This separation is what makes the library reusable for Kaldor/Minsky/fiscal work.

### Current State (post v1.0)

Shipped 2026-08-16: ~1,000 LOC of Kalecky Haskell source + ~1,200 LOC tests as a root-level Stack project; `stack test` (107 tests) and `scripts/check-compile-fail.sh` (6 boundaries) both green on `main` (tag v1.0). v2 backlog: RealWage/deflation, Elasticity + Distributional/Bargaining refinements, ψ distribution matrix. (Plank port and hevm bridge dropped with the EVM direction, 2026-08-16.)

## Constraints

- **Process**: Test-first, collaboratively — each increment's test is co-designed with the user and approved before implementation. Not solo/YOLO work.
- **Tech stack**: Haskell, Stack lts-23.28 (GHC 9.8.4), base + QuickCheck/quickcheck-classes/tasty only.
- **Package location**: SUPERSEDED 2026-08-16 — the repo is now a plain root-level Stack project (`kalecky-semantics.cabal`, `src/Kalecky/**`); the hevm fork, EvmYul (Lean), Foundry/Plank tooling and all submodules were removed. No EVM bridge is planned.
- **Rigor over speed**: Research artifact — type correctness and semantic fidelity to the spec outrank delivery pace.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| v1 is pure Haskell; Plank/EVM/Solidity out of scope | Prove the types first; DSL/chain execution builds on a proven foundation | ✓ Good |
| Keep types inside kalecky-spec (hevm fork) | Preserves future bridge to hevm symbolic execution | ⚠️ Reversed 2026-08-16: EVM/hevm direction discarded; repo cut to a plain Stack project |
| Properties + examples per increment | QuickCheck laws for algebra (Gap orientation, dimensions) + CASO PRUEBA scenarios for economics | — Pending |
| One type per increment | Scale → Units → EconomicQuantity → Gap → Conflict → Effect → ... each test-approved before implementation | — Pending |
| End goal = boxed wage-growth equation | Explicitly marked in notes/INCOME_DISTRIBUTION.md as "the end goal test" | ✓ Good (passes: 277/900 exact) |
| Gap preserves orientation (positiveTerm/negativeTerm) | a − b ≠ b − a; household vs firm gaps have opposite orientation | — Pending |
| Effect is a newtype over Number; refinements add semantics not data | Avoids redundant scalars (ResponseMultiplier, Indexation store only the Effect) | — Pending |
| EconomicQuantity replaced by Price (amount lives in Unit; Price = valued Per-compound unit) | Tree notes in kalecky-spec/src/Kalecky/types/**: u_s(k) = k·s(b,i), Price p(u,v) := c_p(u,v); scale alignment by exact conversion, not rejection | — Pending |
| Phases 2-6 run as live in-session co-design; GSD reduced to bookkeeping (research/plan-check/verifier/nyquist off; one lean plan per phase) | Spec already written (notes + Draft.plk); the unknowns live in the type co-design dialogue with the user, not in discovery | ✓ Good (5 phases, 20 increments, one day) |

---
*Last updated: 2026-08-16 after v1.0 Wage Equation milestone*
