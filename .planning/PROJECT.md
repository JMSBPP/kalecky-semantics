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

- ✓ hevm fork builds and executes EVM bytecode in Haskell (`kalecky-spec/`, Stack/Cabal/Nix builds, QuickCheck + Tasty test infrastructure) — existing
- ✓ Foundry/Plank test harness runs Solidity tests against Plank-compiled contracts (`foundry.toml`, `test/kalecky-plank/`) — existing
- ✓ Draft specification of the income distribution model with type hierarchy exists (`notes/INCOME_DISTRIBUTION.md`) — existing
- ✓ Skeletal Kalecky Haskell modules exist as drafts (`kalecky-spec/src/Kalecky/` — Gap, Conflict, Effect, Units, Valuation) — existing, unproven

### Active

<!-- One type per increment; each increment = test co-designed with user, approved, then implemented -->

- [ ] Dimensional foundation types: Scale (s(b,i) = b^i), Valuation (Nominal | Real PriceIndex), MoneyUnit/Currency (COP, USD), LaborUnit (Worker, LaborHour), TimeUnit; a Unit u_s(k) carries its amount k at scale s and units form a semigroup under (·)
- [ ] CompoundUnit connectors Per (ρ) and Times (τ) with scale alignment by exact conversion; Price p(u,v) as valuation-parameterized Per-compound unit (replaces the earlier EconomicQuantity design; e.g., NominalWage is a Nominal-valued Price over Per MoneyUnit LaborUnit)
- [ ] Gap x — orientation-preserving algebraic difference (positiveTerm/negativeTerm), requires subtraction in x
- [ ] Expectation agent x with Agent (Household | Firm | Government | FinancialSector) — E^H[W/P], E^F[W/P]
- [ ] Conflict as semantic refinement of Gap: ExpectationsConflict agentA agentB x, DistributionalConflict, BargainingConflict
- [ ] Effect responder perturband ≡ ∂responder/∂perturband, with refinements: ResponseMultiplier, Elasticity (with Normalization), DistributionalEffect / NetDistributionalEffect
- [ ] GrowthRate x and CommonGrowthRate a b (smart constructor returning Maybe)
- [ ] Indexation target reference ≡ Effect (GrowthRate target) (GrowthRate reference)
- [ ] Derived quantities: RealWage (NominalWage / PriceLevel), LaborProductivity (Ratio Output LaborService)
- [ ] CASO PRUEBA scenario tests pass: Nivel→Nivel (minimum wage 20000 COP/hour), Nivel→Tasa (wage 10→12 units, +20pp), Tasa→Tasa (growth 5%→5.20%, +20bp)
- [ ] End-goal test: nominal wage growth equation composed from the above types, property + example tests pass

### Out of Scope

- Plank DSL port of the type system (`kalecky-plank/`) — deferred until the Haskell types are proven; Draft.plk stays a draft
- Solidity/EVM execution tests of Kalecky types — v1 is pure Haskell; the hevm bridge comes after the types stabilize
- Functional income distribution matrix (ψ mechanisms, wage/profit shares, informal sector W_{L_I}) — the wage equation is the v1 end goal; the ψ object is a later milestone
- Colombia-specific mechanism taxonomy (taxes, transfers, subsidies with legal names) — notes TODO, explicitly "other agents' work" after ψ is formalized
- Lean/EvmYul proofs of Kalecky semantics — inherited infrastructure, not part of this milestone
- Autonomous implementation without test approval — every increment's test is co-designed and approved by the user first

## Context

- Repo is a fork/extension of Nethermind's EvmYul (Lean 4 EVM semantics) with an untracked hevm Haskell fork in `kalecky-spec/` and a Plank DSL monorepo in `lib/plank-monorepo/`.
- The Kalecky types live inside the hevm fork at `kalecky-spec/src/Kalecky/` — deliberately kept there (user decision) to preserve the eventual bridge to hevm's symbolic execution (Z3/SMT) once the types mature.
- Source of truth for the model: `notes/INCOME_DISTRIBUTION.md`, itself grounded in Blecker & Setterfield (2019), *Heterodox Macroeconomics*, p. 204 (conflicting-claims income distribution).
- The notes contain a worked type-design dialogue (Spanish/English) resolving key questions: Gap is algebraic and orientation-preserving; Conflict is a semantic newtype over Gap; Effect is the fundamental derivative object and refinements add meaning, not data; NominalWage is money/labor (not a price index); Expectation is indexed by agent (or Measure agent).
- Codebase map in `.planning/codebase/` documents the three-stack situation (Lean, Haskell, Plank/Rust) and its concerns — notably that core work is untracked in git and `Draft.plk` has blocking TODOs.
- Design language: algebraic structures know no economics (Gap, Effect); semantic refinements carry the economics (Conflict, ResponseMultiplier, Indexation). This separation is what makes the library reusable for Kaldor/Minsky/fiscal work.

## Constraints

- **Process**: Test-first, collaboratively — each increment's test is co-designed with the user and approved before implementation. Not solo/YOLO work.
- **Tech stack**: Haskell (GHC via kalecky-spec's Stack/Cabal/Nix setup), QuickCheck + Tasty already in the package's dependencies.
- **Package location**: Types stay inside `kalecky-spec` (the hevm fork) — accept slower builds to keep the symbolic-execution bridge available.
- **Rigor over speed**: Research artifact — type correctness and semantic fidelity to the spec outrank delivery pace.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| v1 is pure Haskell; Plank/EVM/Solidity out of scope | Prove the types first; DSL/chain execution builds on a proven foundation | — Pending |
| Keep types inside kalecky-spec (hevm fork) | Preserves future bridge to hevm symbolic execution | — Pending |
| Properties + examples per increment | QuickCheck laws for algebra (Gap orientation, dimensions) + CASO PRUEBA scenarios for economics | — Pending |
| One type per increment | Scale → Units → EconomicQuantity → Gap → Conflict → Effect → ... each test-approved before implementation | — Pending |
| End goal = boxed wage-growth equation | Explicitly marked in notes/INCOME_DISTRIBUTION.md as "the end goal test" | — Pending |
| Gap preserves orientation (positiveTerm/negativeTerm) | a − b ≠ b − a; household vs firm gaps have opposite orientation | — Pending |
| Effect is a newtype over Number; refinements add semantics not data | Avoids redundant scalars (ResponseMultiplier, Indexation store only the Effect) | — Pending |
| EconomicQuantity replaced by Price (amount lives in Unit; Price = valued Per-compound unit) | Tree notes in kalecky-spec/src/Kalecky/types/**: u_s(k) = k·s(b,i), Price p(u,v) := c_p(u,v); scale alignment by exact conversion, not rejection | — Pending |

---
*Last updated: 2026-08-15 after initialization*
