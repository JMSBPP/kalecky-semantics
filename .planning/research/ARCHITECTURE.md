# Architecture Research

**Domain:** Dimensionally-typed economic modeling library (Haskell), embedded inside an existing EVM/hevm fork
**Researched:** 2026-08-15
**Confidence:** MEDIUM (verified against two real Hackage dimensional-analysis libraries + Haskell module-system conventions; the economics-specific layering is a direct translation of the design dialogue already resolved in `notes/INCOME_DISTRIBUTION.md`, not an external source)

## Standard Architecture

Haskell libraries that do compile-time dimensional/unit analysis converge on the same layering, confirmed by inspecting two real packages on Hackage:

- **`dimensional`** (`Numeric.Units.Dimensional.*`) — hides its core `Dimensional`/`Quantity`/`Unit` constructors in an `Internal` module, exposes only smart constructors and typed arithmetic from the public `Numeric.Units.Dimensional` module, keeps SI/unit *definitions* in separate modules from the dimension *arithmetic*, and provides a `Prelude` module purely for convenience re-exports. Source: Hackage `dimensional-1.6.1` docs.
- **`units`** — is split into two *packages*, not just modules: `units` implements the type-level machinery for dimensional analysis and is "completely agnostic to the actual system of units used," while `units-defs` (which depends on `units`) supplies the concrete SI unit vocabulary. Source: [goldfirere/units](https://github.com/goldfirere/units), [Hackage `units`](https://hackage.haskell.org/package/units).

The pattern in both: **a generic, economics/physics-agnostic kernel at the bottom, concrete vocabulary layered on top, and constructors hidden behind smart constructors so invariants can't be bypassed** (confirmed generically for Haskell library design — [HaskellWiki: Smart constructors](https://wiki.haskell.org/Smart_constructors), [Roman Cheplyaka: Surprises of the Haskell module system](https://ro-che.info/articles/2019-01-26-haskell-module-system-p2)).

This is exactly the split notes/INCOME_DISTRIBUTION.md already reasons through by hand: *"`Gap` no sabe economía; `Conflict` sí. `Effect` no sabe por qué ocurre la derivada; sus refinamientos sí."* (line 1072-1073). Kalecky is, structurally, a `units`-style library where the "unit system" is income-distribution economics instead of SI.

### System Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│ L6  EQUATION COMPOSITION                                              │
│     NominalWageGrowth = ResponseMultiplier·Gap + ResponseMultiplier·  │
│     GrowthRate + Indexation·GrowthRate           (the end-goal test)  │
├──────────────────────────────────────────────────────────────────────┤
│ L5  DOMAIN INSTANCES  (economics vocabulary, concrete types)          │
│     NominalWage · RealWage · LaborProductivity · PriceLevel · Output  │
├──────────────────────────────────────────────────────────────────────┤
│ L4  SEMANTIC REFINEMENTS  (newtypes over L3, add meaning not data)    │
│  ┌───────────────┐ ┌────────────────────────┐ ┌────────────────────┐ │
│  │ Conflict       │ │ ResponseMultiplier /    │ │ Indexation          │ │
│  │ ExpectationsC. │ │ Elasticity /            │ │ (Effect over        │ │
│  │ Distributional │ │ DistributionalEffect    │ │  GrowthRates)       │ │
│  └───────────────┘ └────────────────────────┘ └────────────────────┘ │
├──────────────────────────────────────────────────────────────────────┤
│ L3  ALGEBRAIC OPERATORS  (generic over any x with the right typeclass,│
│     ZERO economics knowledge — reusable in Kaldor/Minsky/fiscal too)  │
│     Gap x · Effect responder perturband · GrowthRate x · Expectation  │
├──────────────────────────────────────────────────────────────────────┤
│ L2  ECONOMIC QUANTITY  (binds a Number to a Valuation + a Unit)       │
│     EconomicQuantity valuation unit = { amount, valuation, unit }     │
├──────────────────────────────────────────────────────────────────────┤
│ L1  DIMENSION / UNIT KERNEL  (agnostic to economics — pure type-level │
│     bookkeeping of what can combine with what)                        │
│     Scale · Valuation (Nominal|Real) · Unit · CompoundUnit(Per,Times) │
│     · Currency (COP,USD) · MoneyUnit · LaborUnit (Worker,LaborHour)   │
│     · TimeUnit                                                        │
├──────────────────────────────────────────────────────────────────────┤
│ L0  NUMERIC BASE  (the underlying scalar; no dimensional meaning)     │
│     Number                                                             │
└──────────────────────────────────────────────────────────────────────┘
```

Two things are non-obvious about this stack and worth stating explicitly for roadmap purposes:

1. **L3 must be recursively composable, not economics-shaped.** The CASO PRUEBA "Tasa → Tasa" scenario (a growth rate changing by +20 basis points, i.e. 5% → 5.20%) requires `GrowthRate` to be applicable to a `GrowthRate` — a rate-of-a-rate. If `GrowthRate x` is written against a concrete `EconomicQuantity`-shaped `x`, it cannot recurse onto itself. `Gap`, `Effect`, and `GrowthRate` must therefore be defined against a typeclass constraint (something with subtraction/division), not against `EconomicQuantity` directly. This is what "Gap no sabe economía" cashes out to structurally — L3 depends on L2 only through a typeclass boundary, never on concrete L5 domain types.
2. **L4 refinements are zero-cost newtypes, not new data.** Confirmed twice independently in the notes' own resolution (`ResponseMultiplier`, `Indexation`, `DistributionalEffect` were each reduced from "extra field" designs to pure `newtype … = … (Effect …)` wrappers, explicitly to avoid "redundant scalars"). This means L4 adds *only* type-level meaning; the roadmap should not budget implementation time for new algebra at L4, only for smart constructors and the invariants they encode.

### Component Responsibilities

| Component | Layer | Responsibility | Depends on | Economics-aware? |
|-----------|-------|-----------------|------------|-------------------|
| `Number`, `Scale` | L0 | Base scalar and scale (`s(b,i) := b^i`) representation | Haskell `Num`/`Fractional` | No |
| `Valuation` (Nominal \| Real PriceIndex) | L1 | Tags a quantity as nominal or real-deflated | L0 | No (generic accounting concept) |
| `Unit`, `CompoundUnit` (Per, Times) | L1 | Type-level composition rules for units (ratio, product) | L0 | No |
| `Currency`, `MoneyUnit` | L1 | Concrete monetary unit vocabulary (COP, USD + denomination) | `Unit` | No |
| `LaborUnit` (Worker \| LaborHour), `TimeUnit` | L1 | Concrete labor-quantity vocabulary | `Unit` | No |
| `EconomicQuantity valuation unit` | L2 | Binds an amount to a valuation and a unit; the one place raw `Number` becomes "an economic value" | L0, L1 | No (still domain-agnostic container) |
| `Gap x` | L3 | Orientation-preserving algebraic difference (`positiveTerm`/`negativeTerm`), requires subtraction in `x` | typeclass on `x` | No |
| `Effect responder perturband` | L3 | The fundamental derivative object, `newtype Effect = Effect Number` | L0 | No |
| `GrowthRate x`, `CommonGrowthRate` | L3 | Relative rate of change of `x`; must be self-composable | typeclass on `x` | No |
| `Expectation agent x` / `Measure agent` | L3 | Indexes a value by the agent/probability measure under which it's evaluated | `Agent`, typeclass on `x` | Borderline — `Agent` enum is the only economics leak, isolated to this module |
| `Conflict`, `ExpectationsConflict`, `DistributionalConflict`, `BargainingConflict` | L4 | Semantic refinement: *this* `Gap` represents an economic conflict | `Gap` | Yes |
| `ResponseMultiplier`, `Elasticity`, `Normalization`, `DistributionalEffect`, `NetDistributionalEffect` | L4 | Semantic refinement: *this* `Effect` is a behavioral response coefficient | `Effect` | Yes |
| `Indexation target reference` | L4 | Semantic refinement: `Effect (GrowthRate target) (GrowthRate reference)` — a rate tracking another rate | `Effect`, `GrowthRate` | Yes |
| `NominalWage`, `RealWage`, `LaborProductivity`, `PriceLevel` | L5 | Concrete economic quantities built from `EconomicQuantity` + derived ratios | L2, L1 | Yes — the vocabulary itself |
| `NominalWageGrowth` equation | L6 | Composes L4 refinements over L5 instances into the boxed end-goal equation | L4, L5 | Yes — the deliverable |

## Recommended Project Structure

The current draft tree under `kalecky-spec/src/Kalecky/` already has the right *intent* (an `Operators/` split from `types/`) but not the right *layering* — `Operators/` currently mixes L3 (economics-agnostic) with L4 (economics-aware) content in flat files, and `types/` mixes L1 (unit kernel) with L5 (domain instances) with inconsistent casing (`Kalecky.types.Units.Unit` vs `Kalecky.Types.Units.Unit` — these are different module paths on a case-sensitive filesystem and at least one existing import, `Wage.hs`'s `Kalecky.types.Units.Per`, points at a module that doesn't exist under that name; it should be `CompoundUnit`). This is expected for draft-stage stubs and should be resolved when each file gets its first real implementation, not as a separate cleanup pass.

```
kalecky-spec/src/Kalecky/
├── Numerics/                    # L0 — base scalar, no dimensional meaning
│   └── Number.hs                #   Number newtype, Num/Fractional instances
├── Units/                       # L1 — dimension/unit kernel, economics-agnostic
│   ├── Scale.hs                 #   Scale (s(b,i) := b^i)
│   ├── Unit.hs                  #   Unit class / kind
│   ├── CompoundUnit.hs          #   CompoundUnit = Per a b | Times a b (semigroup)
│   ├── Currency.hs              #   Currency = COP | USD, denomination (Billion|Million|Thousand)
│   ├── MoneyUnit.hs             #   MoneyUnit { currency, unit }
│   ├── LaborUnit.hs             #   LaborUnit = Worker | LaborHour (+ scale)
│   └── TimeUnit.hs              #   TimeUnit (hour, month, year — needed for /hour, /month wages)
├── Valuation.hs                 # L1 — Valuation = Nominal | Real PriceIndex
├── Quantity/                    # L2 — the one container that turns Number into "an economic value"
│   └── EconomicQuantity.hs      #   EconomicQuantity valuation unit = { amount, valuation, unit }
├── Operators/                   # L3 — algebraic, economics-agnostic (Gap "no sabe economía")
│   ├── Gap.hs                   #   Gap x { positiveTerm, negativeTerm }, smart constructor gap
│   ├── Effect.hs                #   newtype Effect responder perturband = Effect Number
│   ├── GrowthRate.hs            #   GrowthRate x, CommonGrowthRate, mkCommonGrowthRate :: Maybe
│   └── Expectation.hs           #   Expectation agent x, Agent enum, Measure agent
├── Semantics/                   # L4 — refinements, economics-aware (renamed from flat Operators/)
│   ├── Conflict.hs              #   Conflict, ExpectationsConflict, DistributionalConflict, BargainingConflict
│   ├── Effect/
│   │   ├── ResponseMultiplier.hs
│   │   ├── Elasticity.hs        #   + Normalization numerator denominator
│   │   └── DistributionalEffect.hs  # + NetDistributionalEffect
│   └── Indexation.hs            #   Indexation target reference = Effect (GrowthRate t) (GrowthRate r)
├── Domain/                      # L5 — concrete economic vocabulary (was types/Prices/)
│   ├── NominalWage.hs           #   EconomicQuantity Nominal (CompoundUnit MoneyUnit LaborUnit)
│   ├── RealWage.hs              #   NominalWage / PriceLevel
│   ├── PriceLevel.hs            #   PriceIndex-valued quantity
│   ├── LaborProductivity.hs     #   Ratio Output LaborService
│   └── Output.hs
└── Equations/                   # L6 — composed equations (the "end goal test" lives here)
    └── NominalWageGrowth.hs
```

### Structure Rationale

- **`Numerics/`, `Units/`, `Valuation.hs` (L0-L1) are the reusable kernel.** Nothing in these modules imports anything from `Semantics/`, `Domain/`, or `Equations/`. This is the boundary that lets the same kernel later back a Kaldor, Minsky, or fiscal module (stated explicitly as the reuse goal in the notes) — those modules would add their own `Semantics/` and `Domain/` trees on top of the same `Units/`/`Quantity/` kernel.
- **`Operators/` (L3) stays flat and generic** — each file is parametrized over `x` with a typeclass constraint, never over a named domain type. This is the layer most at risk of "economics leaking in" during implementation (e.g. writing `Gap NominalWage` directly instead of `Gap x` with `NominalWage` instantiating `x` later) — worth flagging as a review checkpoint per increment.
- **`Semantics/` is a new top-level split from the current flat `Operators/`.** The current draft co-locates `Conflict.hs` (L4) with `Gap.hs` (L3) inside one `Operators/` directory; separating them makes the "algebraic vs semantic" distinction from the notes *visible in the file tree*, not just in developer memory — directly useful when a future contributor adds a Kaldor-specific semantic refinement and needs to know where it goes.
- **`Domain/` replaces `types/Prices/`.** "Prices" undersells what lives here (wages, productivity, output are not prices); `Domain/` matches the L5 role of "concrete economic vocabulary built from the kernel."
- **`Equations/` is new** — nothing in the current draft holds a composed equation. This is where the end-goal test's boxed formula (notes line 992-1039) gets expressed once L4/L5 are proven.
- **Internal/smart-constructor pattern applies at L1-L4.** Each type whose invariant matters (`Gap`'s orientation, `Currency`'s unsupported-currency guard, `Effect`'s "don't hand-construct a derivative") should hide its raw constructor and export only a smart constructor, mirroring how `dimensional` hides `Dimensional`/`Quantity` behind an `Internal` module ([Hackage `dimensional-1.6.1`](https://hackage.haskell.org/package/dimensional-1.6.1/docs/Numeric-Units-Dimensional.html)) and the general Haskell abstract-datatype convention ([HaskellWiki: Smart constructors](https://wiki.haskell.org/Smart_constructors)).

## Architectural Patterns

### Pattern 1: Kernel/Vocabulary Split (economics-agnostic core, economics-aware vocabulary on top)

**What:** The dimension/unit machinery (L0-L2) is written with zero knowledge of income distribution; the algebraic operators (L3) are written with zero knowledge of *which* economic variables they'll be applied to; only L4 (refinements) and L5 (domain instances) know this is a wage-growth model.
**When to use:** Whenever a type is reused verbatim across future modules (Kaldor, Minsky, fiscal) — if a type mentions `Wage`, `Firm`, or `Household` in its own definition, it does not belong below L4.
**Trade-offs:** Costs extra indirection (an economist reading `Gap x` must mentally substitute `x = RealWage` to see the concrete meaning) in exchange for genuine reuse and for making "Gap no sabe economía" a compiler-checked fact rather than a design intention.

**Example (target shape for `Operators/Gap.hs`):**
```haskell
module Kalecky.Operators.Gap (Gap, gap, positiveTerm, negativeTerm, evalGap) where

data Gap x = Gap { positiveTerm :: x, negativeTerm :: x }

gap :: x -> x -> Gap x
gap = Gap

evalGap :: Num x => Gap x -> x
evalGap (Gap p n) = p - n
```

### Pattern 2: Newtype Refinement Chain (semantics add meaning, not data)

**What:** Each L4 type is `newtype T = T (L3 thing)` with no extra fields — the notes explicitly reject adding an `indexationRate :: Number` field alongside `indexationEffect :: Effect ...` because it duplicates the scalar the `Effect` already carries.
**When to use:** Any time a new economic concept is "an existing algebraic object, but specifically meaning X" (a `Conflict` is specifically a `Gap` between two agents' expectations; an `Indexation` is specifically an `Effect` between two growth rates).
**Trade-offs:** Keeps the algebra single-sourced (no risk of the wrapped value and the "rate" field disagreeing) but means every refinement needs its own smart constructor if it wants to enforce extra preconditions (e.g. `mkExpectationsConflict` requiring two *different* agents).

**Example:**
```haskell
newtype Indexation target reference =
  Indexation (Effect (GrowthRate target) (GrowthRate reference))
```

### Pattern 3: Typeclass-Bounded Recursion for Self-Composable Operators

**What:** `GrowthRate x` and `Gap x` must be able to take `x = GrowthRate y` (needed by the "Tasa → Tasa" CASO PRUEBA: a growth rate itself grows by +20bp) and `x = EconomicQuantity v u` (needed by "Nivel → Tasa"). The only way both instantiations type-check without duplicating the operator is a typeclass constraint (e.g. `Fractional x => GrowthRate x` or a custom `HasDelta` class) rather than hardcoding `x` to a concrete record.
**When to use:** Any L3 operator that the CASO PRUEBA scenarios apply at more than one "level" (raw quantity vs. rate vs. rate-of-rate).
**Trade-offs:** A generic typeclass constraint is weaker than a concrete field type — GHC won't stop you from writing `GrowthRate Currency` (nonsensical) unless the typeclass itself is scoped to only the types that should support it. This is the main design risk to resolve during the `GrowthRate` increment, and is worth a co-designed test before implementation (per the project's stated process).

## Data Flow

### CASO PRUEBA walkthrough (from `notes/INCOME_DISTRIBUTION.md`)

**Nivel → Nivel — "20000 COP/hour minimum wage":**
```
Currency COP, denomination Thousand
    → MoneyUnit { currency = COP, unit = Thousand }         [L1]
TimeUnit Hour
    → LaborUnit LaborHour { time = Hour }                    [L1]
CompoundUnit (Per MoneyUnit LaborUnit)                       [L1]
    → EconomicQuantity { amount = 20000
                        , valuation = Nominal
                        , unit = Per MoneyUnit LaborUnit }   [L2]
    → NominalWage (a Domain/ alias over the above)           [L5]
```
No L3/L4 involvement — this is a pure "level" instance and is the minimal scenario that exercises L0 through L5 without touching operators. It is the natural first end-to-end test once `EconomicQuantity` and one `Domain/` instance exist.

**Nivel → Tasa — "wage 10 → 12 units, i.e. +20 percentage points":**
```
NominalWage_{t-1} :: EconomicQuantity Nominal (Per MoneyUnit LaborUnit)   [L2/L5, amount=10]
NominalWage_{t}   :: EconomicQuantity Nominal (Per MoneyUnit LaborUnit)   [L2/L5, amount=12]
    → GrowthRate NominalWage                                              [L3]
        (evalGrowthRate = (12-10)/10 = 0.20 = "+20pp")
```
This is the first scenario that exercises L3 and confirms `GrowthRate x` works when `x` is a concrete `EconomicQuantity`-shaped domain instance.

**Tasa → Tasa — "growth rate 5% → 5.20%, i.e. +20 basis points":**
```
GrowthRate_{t-1} :: GrowthRate NominalWage   [amount=0.05]
GrowthRate_{t}   :: GrowthRate NominalWage   [amount=0.0520]
    → GrowthRate (GrowthRate NominalWage)    [L3, applied to itself]
        (evalGrowthRate = (0.052-0.05)/0.05 = 0.04 -- as a RATE; the "+20bp" reading is the
         *level* difference 0.0520 - 0.0500 = Gap on the rate itself, not a GrowthRate of it)
```
This is the scenario that forces the typeclass-bounded recursion decision in Pattern 3 above — note it also exposes that "Tasa → Tasa, +20bp" is arithmetically a `Gap (GrowthRate x)` (a level-difference *of* a rate), not a `GrowthRate (GrowthRate x)` (a rate-of-a-rate). This distinction should be nailed down in the co-designed test for this increment, since the notes' prose ("20 puntos basicos") is ambiguous between the two and the roadmap should not assume either without the test confirming it.

### End-goal equation flow (L6)

```
NominalWage(t-1), NominalWage(t)                     [L5]
  → Gap RealWage  (household expectation vs realized)  [L3, refined to L4 via ResponseMultiplier context]
  → ResponseMultiplier NominalWageGrowth HouseholdRealWageExpectationGap   [L4]
  → × Gap RealWage                                     [L3 value]
  ⊕ ResponseMultiplier NominalWageGrowth LaborProductivityGrowth × GrowthRate LaborProductivity  [L4×L3]
  ⊕ Indexation NominalWage PriceLevel × GrowthRate PriceLevel                                     [L4×L3]
  = GrowthRate NominalWage                             [L6 result — the boxed end-goal test]
```
Every arrow above only ever composes L3/L4 objects that are themselves built from L5 domain instances — nothing in this chain reaches back down into L1/L2 directly, which is the concrete, checkable version of "the type system encodes the dimensional and semantic structure" from `.planning/PROJECT.md`'s Core Value statement.

## Build Order

The dependency graph is a strict DAG matching the layers above, and it matches the "one type per increment" constraint already recorded in `.planning/PROJECT.md`'s Key Decisions:

1. **L0-L1 kernel** — `Number`, `Scale`, `Valuation`, `Unit`, `CompoundUnit`, `Currency`, `MoneyUnit`, `LaborUnit`, `TimeUnit`. Tests here are pure algebraic laws (QuickCheck): `Per`/`Times` associativity, `Scale` exponent laws, unsupported-currency compile errors.
2. **L2** — `EconomicQuantity valuation unit`. Tests: construction round-trips, dimensional mismatches rejected at compile time (type-level, so tested via a `should-not-compile` style test or just by the type signatures used elsewhere never needing a runtime check).
3. **L3 operators, in the order the notes present them** — `Gap` → `Expectation`/`Agent` → `Effect` → `GrowthRate`/`CommonGrowthRate`. `Gap` first because `Conflict` (L4) and the wage-gap term both need it immediately; `Effect` before `GrowthRate` is not a hard dependency (they're independent) but `GrowthRate` is needed sooner because two of the three CASO PRUEBA scenarios exercise it. Tests: property tests for orientation (`gap a b ≠ gap b a` when `a ≠ b`), `mkCommonGrowthRate`'s `Maybe`-returning failure case.
4. **L4 refinements** — `Conflict`/`ExpectationsConflict` (needs `Gap`+`Expectation`), `ResponseMultiplier`/`Elasticity`/`DistributionalEffect` (needs `Effect`), `Indexation` (needs `Effect`+`GrowthRate`). These can be built in parallel with each other once their L3 dependency exists. Tests: smart-constructor invariants (e.g. `mkExpectationsConflict` rejecting `agentA == agentB`), and the CASO PRUEBA Nivel→Tasa/Tasa→Tasa scenarios once `GrowthRate` and `Gap` are proven.
5. **L5 domain instances** — `NominalWage`, `RealWage`, `LaborProductivity`, `PriceLevel`, `Output`. Depends only on L1/L2, can technically be built early, but should be sequenced *after* L3 is proven so the CASO PRUEBA tests can exercise real operators against real domain types rather than synthetic `x`. Tests: the three CASO PRUEBA scenarios as example-based tests.
6. **L6 equation** — `NominalWageGrowth`, composed last, is the end-goal test. It is a pure composition and should require no new algebra if L3-L5 are correctly factored — if implementing it *does* require new algebra, that is a signal L4 was under-specified and worth revisiting before declaring v1 done.

This order also matches the milestone's stated decision to keep types inside `kalecky-spec` for a future hevm symbolic-execution bridge: L1-L3 (kernel + generic operators) are the layer most likely to be reused as-is if/when Kalecky types are bridged into hevm's Z3-backed symbolic execution, so getting their typeclass boundaries right early has outsized leverage.

## Anti-Patterns

### Anti-Pattern 1: Naming an economic concept inside an L3 operator's own definition

**What people do:** Write `data Gap = WageGap Number | InflationGap Number` instead of `data Gap x = Gap { positiveTerm :: x, negativeTerm :: x }`, because it's tempting to special-case the first concrete use.
**Why it's wrong:** It collapses L3 and L4/L5 into one layer, defeating the entire "reusable across Kaleckian, Kaldorian, Minskyan, and fiscal modules" goal stated in `.planning/PROJECT.md`, and makes `Conflict`/`ExpectationsConflict` impossible to express as a clean newtype wrapper.
**Do this instead:** Keep `Gap x` polymorphic; let `Domain/` types instantiate `x`.

### Anti-Pattern 2: Storing a derived scalar alongside the thing it's derived from

**What people do:** `data Indexation target reference = Indexation { indexationEffect :: Effect ..., indexationRate :: Number }` — this is literally what the notes' own design dialogue caught and rejected (notes lines 566-597).
**Why it's wrong:** Two sources of truth for the same number; nothing stops them from drifting apart, and it silently reintroduces the "extra field" pattern the refinement layer exists to avoid.
**Do this instead:** `newtype Indexation target reference = Indexation (Effect (GrowthRate target) (GrowthRate reference))` — derive the rate from the wrapped `Effect` via a function, don't store it twice.

### Anti-Pattern 3: Hand-constructing `Effect` values instead of deriving them

**What people do:** Exposing `Effect`'s raw constructor so callers can write `Effect 0.35 :: Effect NominalWageGrowth SomeGap` directly wherever they need a coefficient.
**Why it's wrong:** `Effect` is defined as ∂responder/∂perturband — a derivative — and hand-supplying a number with no computation behind it makes the type carry no more guarantee than a bare `Double` would. This is fine for CASO PRUEBA scenarios (which *do* supply exogenous coefficients as test fixtures), but should go through a clearly-named smart constructor (e.g. `exogenousEffect :: Number -> Effect responder perturband`) so it's visible in code review that the value wasn't derived, only asserted.
**Do this instead:** Hide the raw `Effect` constructor; provide both a `deriveEffect` (computed) and an explicitly-named `exogenousEffect`/`assumedEffect` (test-fixture) smart constructor, so the two cases are never visually indistinguishable.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| hevm symbolic execution (Z3) | Deferred — not part of this milestone | The stated reason Kalecky types live inside `kalecky-spec` rather than a standalone package is to keep this bridge open; nothing in L0-L6 should import from `EVM/` yet, and no test in this milestone should depend on `hevm test`/Z3. |
| Plank DSL (`kalecky-plank/Draft.plk`) | Deferred — out of scope per `.planning/PROJECT.md` | The Plank draft already sketches `Scale`, `CompoundUnit`, and `NominalWage` shapes that roughly mirror L1/L2/L5 here; when the Plank port resumes, the Haskell module boundaries documented above are the intended source of truth to port from, in the same build order. |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| L1/L2 kernel ↔ L3 operators | Typeclass constraints only (no concrete-type imports downward) | This is the boundary that most needs enforcing by convention/review since Haskell's module system won't stop L3 from importing a concrete L5 type if a developer does it by accident — worth a lint/review checkpoint per increment rather than assuming the type signatures alone will catch it. |
| L3 operators ↔ L4 refinements | `newtype` wrapping, one direction only (L4 imports L3, never reverse) | Matches the existing `Operators/Conflict.hs` comment block's own tree diagram. |
| L4/L5 ↔ L6 equations | Pure composition (`+`, `*` on the algebra) | No new types should be needed at L6 if L3-L5 are factored correctly — treat any new type introduced while writing `Equations/NominalWageGrowth.hs` as a signal to revisit L4. |
| `notes/INCOME_DISTRIBUTION.md` ↔ `kalecky-spec/src/Kalecky/` | One-directional, notes are source of truth | Every module above cites a specific line range in the notes; if implementation diverges from the notes' resolved design (e.g. `Gap` orientation, `Effect` as bare `newtype Number`), that divergence should be re-litigated in the notes first, since the notes are the co-design record the user already approved parts of. |

## Sources

- [dimensional-1.6.1 on Hackage](https://hackage.haskell.org/package/dimensional-1.6.1/docs/Numeric-Units-Dimensional.html) — MEDIUM confidence (WebFetch summary of official docs), confirms Internal-module constructor hiding and kernel/unit-definitions split
- [goldfirere/units on GitHub](https://github.com/goldfirere/units) — MEDIUM confidence (WebSearch, official repo), confirms two-package split (generic machinery vs. concrete unit vocabulary)
- [units on Hackage](https://hackage.haskell.org/package/units) — MEDIUM confidence, same finding as above
- [HaskellWiki: Smart constructors](https://wiki.haskell.org/Smart_constructors) — MEDIUM confidence (community wiki, long-standing convention), confirms hide-constructor/expose-smart-constructor pattern
- [Roman Cheplyaka: Surprises of the Haskell module system (part 2)](https://ro-che.info/articles/2019-01-26-haskell-module-system-p2) — MEDIUM confidence, module-export-list mechanics
- `notes/INCOME_DISTRIBUTION.md` (this repo) — HIGH confidence, primary source for all economics-specific layering decisions (Gap/Conflict/Effect/refinement hierarchy, CASO PRUEBA scenarios, end-goal equation)
- `.planning/PROJECT.md`, `.planning/codebase/ARCHITECTURE.md` (this repo) — HIGH confidence, project context and existing (draft-stage) module tree
- `kalecky-spec/src/Kalecky/**/*.hs` (this repo, read directly) — HIGH confidence for "current state" claims; all files are comment-only stubs as of this research, confirming `.planning/PROJECT.md`'s "existing, unproven" status

---
*Architecture research for: Dimensionally-typed economic modeling library (Haskell)*
*Researched: 2026-08-15*
