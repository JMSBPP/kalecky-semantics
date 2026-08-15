# Feature Research

**Domain:** Typed dimensional-analysis / units-of-measure library, specialized for research-grade Post-Keynesian income-distribution economics
**Researched:** 2026-08-15
**Confidence:** MEDIUM-HIGH (table stakes verified against Hackage docs for `dimensional`, `units`/`Data.Metrology`, `safe-money`, `refined`, `vector-space`; differentiators are HIGH confidence for design *validity* against those patterns but LOW-MEDIUM confidence on exact API shape since no direct prior-art library exists for economic semantics specifically)

## Ecosystem Survey

No library combining typed dimensional analysis with Post-Keynesian/Kaleckian economic semantics exists (verified: WebSearch found no Haskell/F#/Python prior art for "typed economic modeling" beyond generic finance/physical-units libraries; stock-flow-consistent agent-based modeling literature explicitly complains that SFC-ABM models are "intransparent" and rely on "custom-built data structures" with no type-safety approach — Caiani/Godin benchmark papers, sfctools JOSS paper). This confirms the project's differentiators are genuinely novel in this domain, not reinventions.

Prior art surveyed, by category:

- **Physical units-of-measure (Haskell):** `dimensional` (Quantity d a, restricted operators, SI-focused), `units`/`Data.Metrology` (goldfirere — Dimension vs Unit separation, LCSU polymorphism, fully extensible to non-physical domains), `uom-plugin` (GHC typechecker plugin solving unit equality automatically — flagged experimental/unsound edge cases by its own docs)
- **Typed currency (Haskell):** `safe-money` (Dense/Discrete distinction to avoid float rounding, ExchangeRate as a first-class type, currency as a type-level tag)
- **Refinement/semantic wrapper pattern (Haskell):** `refined` (Refined p x — predicate-tagged newtype with smart-constructor-only construction), LiquidHaskell (SMT-backed refinement types — heavier machinery, not needed here)
- **Affine/orientation-preserving subtraction (Haskell):** `vector-space`'s `AffineSpace` class (`.-.` for point-minus-point returning a `Diff` vector; distinguishes "points" from "vectors" — directly analogous to the Gap `positiveTerm`/`negativeTerm` design, though Gap's requirement is stronger: it must expose sign information, not collapse to a vector)
- **F# units of measure** (Kennedy, "Types for Units-of-Measure: Theory and Practice") — the paper referenced by `uom-prototype`; establishes the theoretical foundation most Haskell unit libraries build on
- **Economics-specific formal modeling:** none found with type-level dimensional guarantees. SFC/ABM economics tooling (sfctools, Caiani-Godin benchmark) is Python/numeric, not typed.

## Feature Landscape

### Table Stakes (Users Expect These)

These are the capabilities every dimensional-analysis / units-of-measure library provides. Missing any of them means the library doesn't do its basic job of "ill-formed dimensional arithmetic must not type-check."

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Compile-time dimension/unit mismatch rejection | Core promise of the domain — `dimensional`, `units`, `uom-plugin` all reject e.g. `1*~meter + 1*~second` as a type error | MEDIUM | Achieved via phantom types / DataKinds on `EconomicQuantity<valuation, unit>`; no GADT-per-combination needed if unit composition is type-level (Per/Times) |
| Restricted, NOT full, arithmetic (`Num` is the wrong abstraction) | Verified from `dimensional` docs: `(+)`/`(-)` require identical dimension; `(*)`/`(/)` change the dimension type (`d1*d2`, `d1/d2`) — this is structurally incompatible with `Num`'s `(*) :: a -> a -> a` signature | MEDIUM | Deriving `Num` naively for `EconomicQuantity` would let USD add to COP or Currency add to LaborUnit — must hand-write `qAdd`/`qSub` (same-unit only) and let `*`/`/` produce a *different* `EconomicQuantity` type via `CompoundUnit` |
| Smart constructors combining raw value + unit tag | Universal pattern (`(*~)` in `dimensional`, `quOf`/`(%)` in `units`, `refine` in `refined`) — prevents constructing a quantity by grabbing the newtype constructor directly | LOW | `EconomicQuantity{amount, valuation, unit}` — constructor should validate `Bounds` (min/max) from the spec's `Bounds` type |
| Value extraction / unit conversion operators | `(/~)` in `dimensional`, `numIn`/`(#)` in `units` — converting between compatible units (e.g. COP Million ↔ COP Thousand, or Worker ↔ LaborHour under a conversion factor) | LOW-MEDIUM | `Scale` and `COP{unit, base=50}` in the spec are exactly this — scale conversion within one `Currency`/`LaborUnit` |
| `Show`/`Eq`/`Ord` on quantities and derived semantic types | Table stakes for any usable Haskell type — needed for QuickCheck property output, test assertions, debugging | LOW | Straightforward `deriving` where safe; watch for `Ord` on `Gap` (orientation matters, don't derive naively) |
| Compound/derived unit composition (Per, Times) | `units` package's `(:\*)`/`(:/)` type-level combinators are the direct precedent for the spec's `CompoundUnit numerator denominator = Per n d \| Times a b` | MEDIUM-HIGH | This is the load-bearing table-stakes feature — `NominalWage :: EconomicQuantity Nominal (Per MoneyUnit LaborUnit)` requires this to exist before anything else builds |
| Dimensionless / ratio results from division | `units`/`dimensional` support producing a plain-number result when numerator and denominator dimensions cancel (e.g. `RealWage = NominalWage / PriceLevel`, `LaborProductivity = Output / LaborService`) | MEDIUM | Needed for `RealWage`, `LaborProductivity`, and ultimately `GrowthRate` (a relative-change ratio) |
| Precision-safe numeric representation for currency | `safe-money`'s `Dense`/`Discrete` split exists specifically because naive `Double` currency math loses cents and misrepresents exact rational amounts | LOW-MEDIUM | Spec already uses `Number` as an abstract placeholder — decide once (Rational vs Double vs fixed-point) and keep it consistent; don't let float rounding silently break `CommonGrowthRate` equality checks |

### Differentiators (Competitive Advantage)

These are what make this a *research-grade economics* library rather than a generic units library. They align directly with the Core Value in PROJECT.md: "Ill-formed economics must not type-check," which is a stronger and more specific claim than "ill-formed dimensions must not type-check."

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Orientation-preserving `Gap` (`positiveTerm`/`negativeTerm`, not a collapsed vector diff) | Generic dimensional libraries and `vector-space`'s `AffineSpace` (`.-.`) collapse `a - b` to a `Diff` vector that discards *which side was which*. Economics needs the asymmetry: household gap `E^H[W/P] - W/P` and firm gap `W/P - E^F[W/P]` are semantically opposite and must not be conflated even though both are "gaps" of the same dimension | MEDIUM | This is a genuine departure from the affine-space precedent, not a reuse of it — worth flagging in ARCHITECTURE.md as the one place where the design deliberately diverges from the closest prior-art pattern |
| Semantic refinement layers with zero added data (`Conflict` over `Gap`, `ResponseMultiplier`/`Elasticity`/`Indexation` over `Effect`) | Mirrors the `refined` library's "predicate-tagged newtype, no extra runtime data" discipline, but applies it to *economic meaning* rather than a boolean predicate — `Gap` "doesn't know economics"; `ExpectationsConflict` "does." This is what makes the same algebra reusable across Kaleckian/Kaldorian/Minskyan/fiscal modules without duplicating semantics (explicitly named as the differentiator in PROJECT.md) | MEDIUM | Enforce via `newtype` (not `data`) wherever the refinement adds no new field, exactly as the spec's own iterative design notes conclude (`Indexation`, `ResponseMultiplier`, `ExpectationsConflict` all collapsed to newtypes over `Effect`/`Gap` after redundancy was found) |
| Agent-indexed `Expectation` (`Expectation agent x`, with `Agent = Household \| Firm \| Government \| FinancialSector`) | No generic units library has a notion of "who is measuring/believing this quantity" — this is a measure-theoretic concept (E^H[·] vs E^F[·] as different probability measures) encoded as a type index, not a runtime value | MEDIUM | Optional stronger form noted in the spec: `Expectation (Measure agent) x` if the probabilistic-measure interpretation needs to be type-visible later |
| `Effect` as THE fundamental derivative object, with refinements adding meaning not data | Avoids the common anti-pattern (present in the spec's own draft history) of storing a scalar *and* a semantic wrapper redundantly — `ResponseMultiplier`/`Elasticity`/`Indexation` all resolve to `newtype X = X (Effect responder perturband)` | MEDIUM | This is a purity/non-redundancy discipline, verified as good practice by the `refined`/newtype-wrapper precedent, but it's an economic-semantics decision with no direct library analog |
| Growth-rate composition laws (`GrowthRate`, `CommonGrowthRate` as a partial `Maybe`-returning smart constructor) | Encodes the economic fact that two growth rates are only comparable/combinable when they share a common base dimension — a genuine partiality that generic unit libraries don't model (they assume compatible dimensions are always addable) | MEDIUM-HIGH | `mkCommonGrowthRate :: GrowthRate a -> GrowthRate b -> Maybe (CommonGrowthRate a b)` — the `Maybe` is itself the differentiating design choice (fails gracefully rather than requiring a type-level proof of compatibility) |
| Valuation duality threaded through the type (`Nominal \| Real PriceIndex`) | Distinguishes nominal vs. real economic quantities at the type level — a domain-specific axis orthogonal to physical dimension that no generic units library needs | MEDIUM | Cross-cuts `EconomicQuantity<valuation, unit>` — every derived quantity (RealWage, GrowthRate) must propagate or transform this correctly (deflating a Nominal quantity by a PriceIndex should yield `Real` valuation) |
| Property-based + scenario-based test co-design per type (QuickCheck laws + CASO PRUEBA) | Not a "library feature" per se, but a differentiating *methodology* feature: each type ships with algebraic laws (Gap orientation: `a - b ≠ b - a`; dimension-preservation under CompoundUnit) AND concrete economic scenarios (Nivel→Nivel, Nivel→Tasa, Tasa→Tasa) as living documentation of intended behavior | LOW (process, not code) | This is what makes the library "research-grade" — verifiable both algebraically and against worked economic examples |
| End-goal equation composability (the boxed wage-growth equation type-checks and its test suite passes) | This is the acceptance criterion for the entire milestone — proves the algebra (Effect/Gap/GrowthRate) and the semantics (ResponseMultiplier/Indexation/Conflict) compose across three additive terms without ad-hoc glue code | HIGH | Depends on every other feature above being correctly composable; this is the integration test, not a standalone feature |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|------------------|-------------|
| Runtime unit checking (dynamic dimension errors, e.g. throwing exceptions on mismatched add) | Feels easier to implement than type-level machinery; some libraries (early prototypes, dynamically-typed unit tools) do this | Directly contradicts the Core Value ("Ill-formed economics must not type-check") — defers errors from compile time to runtime, exactly what this project exists to prevent. `uom-plugin`'s own docs flag typechecker-plugin approaches as "experimental" and warn of soundness bugs — even the type-level frontier has caution here; a runtime approach would be a regression | Phantom types / DataKinds enforced at compile time, as in `dimensional`/`units`; use `Maybe`-returning smart constructors (like `CommonGrowthRate`) only where partiality is *economically* real, not as a crutch for missing type-level checks |
| Full computer algebra system (symbolic differentiation, automatic derivation of `Effect` from a model) | Tempting once you have `Effect ≡ ∂responder/∂perturband` typed — "why not derive it symbolically instead of storing a scalar?" | Massive scope increase (CAS implementation is its own multi-year research project); the spec explicitly resolved `Effect` to be a stored `newtype Effect responder perturband = Effect Number`, not a symbolic derivative — the type encodes *what* the derivative measures, not *how* to compute it | Keep `Effect` as an opaque calibrated/estimated scalar (matches how these coefficients are actually used in Post-Keynesian empirical models — estimated via econometrics, not derived symbolically) |
| General equilibrium / macro simulation solving (running the model forward, solving for equilibrium Y, P, W) | Natural next step once quantities and equations are typed — "now let's simulate it" | Out of scope per PROJECT.md ("functional income distribution matrix," "ψ mechanisms" are explicitly deferred to a later milestone); conflates "prove the types can express the equation" with "build a macro simulator," which is a different, much larger engineering problem (numerical solvers, convergence, calibration data) | Ship the type system and the single end-goal equation test; simulation/solving is a separate future milestone building on top of proven types |
| Full generic SI/physical unit system support (importing `units-defs` style breadth — meters, joules, moles, etc.) | `units`/`dimensional` libraries are built for full physical-science generality, and it's tempting to reuse that breadth "for free" | Adds irrelevant unit domains and dependency weight; the project only needs `Currency (COP\|USD)`, `LaborUnit (Worker\|LaborHour)`, `TimeUnit`, and `CompoundUnit` combinators — pulling in a general-purpose physics unit library couples the semantic layer to concepts (mass, luminosity) it will never use | Build a minimal, purpose-built unit hierarchy scoped exactly to the spec's `Scale`/`Currency`/`LaborUnit`/`TimeUnit`/`CompoundUnit`, borrowing *design patterns* (not code) from `dimensional`/`units` |
| Full multi-currency/crypto/precious-metals ledger (safe-money's full currency zoo, live FX rates) | `safe-money` supports every ISO currency plus crypto and precious metals with `ExchangeRate` — looks reusable | Overkill: spec needs exactly `COP \| USD` with a specific scale/base=50 structure, not a live-FX-rate system or IO-dependent exchange lookups | Borrow `safe-money`'s Dense/Discrete precision-safety *lesson* (avoid float rounding) without adopting its full currency enumeration or exchange-rate machinery |
| Autonomous/solo implementation of increments without per-type test approval | Faster iteration, avoids the coordination overhead of pausing for each type | Directly contradicts the Process constraint in PROJECT.md: "each increment's test is co-designed with the user and approved before implementation. Not solo/YOLO work" — for a research artifact where "type correctness and semantic fidelity to the spec outrank delivery pace," skipping approval risks building a technically-valid but semantically-wrong type (the spec's own draft history shows several early designs were revised after dialogue, e.g. `NominalWage` was initially miscast as a `PriceIndex`) | One type per increment, test co-designed and approved first, exactly as PROJECT.md's Constraints section already mandates |
| Colombia-specific legal mechanism taxonomy (named taxes/transfers/subsidies) inside this milestone | Natural extension once `ψ` distribution mechanisms are on the table | Explicitly marked in `notes/INCOME_DISTRIBUTION.md` as "other agents' work" after the `ψ` object is formalized — it's a downstream application of the type system, not part of proving the type system itself | Defer entirely; this milestone's scope stops at the wage-growth equation |

## Feature Dependencies

```
Scale
  └──requires──> (nothing; foundational)

Currency / LaborUnit / TimeUnit  ──requires──> Scale
CompoundUnit (Per, Times)         ──requires──> Currency, LaborUnit, TimeUnit (as numerator/denominator types)

EconomicQuantity<valuation, unit> ──requires──> Valuation (Nominal | Real PriceIndex), CompoundUnit
    └──restricted arithmetic (qAdd/qSub same-unit; *//÷ change unit)──> table-stakes Num-alternative

Gap x                             ──requires──> EconomicQuantity (or any x admitting subtraction)
    └──orientation (positiveTerm/negativeTerm)

Expectation agent x               ──requires──> Agent kind, EconomicQuantity
    └──enhances──> Gap (produces the Household/Firm real-wage gaps)

Conflict (semantic refinement of Gap)  ──requires──> Gap
ExpectationsConflict agentA agentB x   ──requires──> Conflict, Expectation (two Expectations of same x)
DistributionalConflict / BargainingConflict ──requires──> Conflict

Effect responder perturband       ──requires──> (nothing beyond responder/perturband types existing; independent primitive)
ResponseMultiplier responder perturband ──requires──> Effect
Elasticity responder perturband   ──requires──> Effect, Normalization (perturband/responder ratio)
DistributionalEffect responder distributionVariable ──requires──> Effect
    └── NetDistributionalEffect ──requires──> DistributionalEffect

GrowthRate x                      ──requires──> EconomicQuantity x (relative-change ratio, dimensionless result)
CommonGrowthRate a b               ──requires──> GrowthRate a, GrowthRate b (Maybe-returning smart constructor)
Indexation target reference        ──requires──> Effect (GrowthRate target) (GrowthRate reference)

RealWage                          ──requires──> EconomicQuantity (NominalWage / PriceLevel)
LaborProductivity                 ──requires──> EconomicQuantity (Output / LaborService, Ratio type)

CASO PRUEBA scenario tests        ──requires──> EconomicQuantity, GrowthRate, CommonGrowthRate (Nivel/Tasa cases)

End-goal wage-growth equation     ──requires──> ResponseMultiplier, Gap, GrowthRate, Indexation, RealWage, LaborProductivity
                                       (all prior types compose across 3 additive terms)

Anti-feature: Runtime unit checking ──conflicts──> Compile-time dimension rejection (table stakes)
Anti-feature: Full CAS symbolic differentiation ──conflicts──> Effect as opaque stored scalar (differentiator)
Anti-feature: ψ distribution matrix / Colombia taxonomy ──enhances (future milestone only)──> Conflict/DistributionalConflict, but is explicitly out of this milestone's scope
```

### Dependency Notes

- **`CompoundUnit` requires `Currency`/`LaborUnit`/`TimeUnit`:** the spec's `NominalWage :: EconomicQuantity Nominal (CompoundUnit MoneyUnit LaborUnit)` cannot type-check until both the compound-unit combinator and its operand unit types exist — this fixes the build order Scale → base units → CompoundUnit → EconomicQuantity, which matches PROJECT.md's Active requirements ordering exactly.
- **`Gap` requires subtraction on its parameter, but doesn't require economics:** it should be written generically (`Gap x` where `x` supports `(-)` or an equivalent), so that `Conflict` and its sub-refinements can be added later without modifying `Gap` itself — this is the load-bearing decision enabling reuse across Kaldor/Minsky/fiscal modules.
- **`Effect` is independent of `Gap`/`Conflict`:** it's a separate primitive (∂responder/∂perturband) that happens to take a `Gap`-typed value as its perturband in the wage equation (`ResponseMultiplier NominalWageGrowth HouseholdRealWageExpectationGap`), but `Effect` itself has no dependency on `Gap` — don't couple them structurally.
- **`GrowthRate` requires `EconomicQuantity`, not `Gap`:** growth rate is `Δx/x` (relative change of one quantity over time), a different algebraic shape than `Gap` (`a - b`, two quantities at one time). Keep these as sibling primitives, not one derived from the other.
- **`CommonGrowthRate` is `Maybe`-partial by design:** this is the one place a smart constructor should return `Maybe` rather than being total — two growth rates are only "common" (combinable/comparable) when their underlying dimensions match, and that's a genuine runtime-checkable (or type-checkable, if fully resolved at compile time) partiality, not a design smell.
- **Anti-feature conflicts are the load-bearing negative constraints:** "runtime unit checking" and "compile-time dimension rejection" are mutually exclusive design philosophies — picking the table-stakes column commits the project away from the anti-feature column for the whole codebase, not just one type.

## MVP Definition

### Launch With (v1 — this milestone, per PROJECT.md Active requirements)

Minimum viable product — the full type hierarchy needed for the boxed end-goal equation to type-check and its test suite to pass. This list intentionally mirrors PROJECT.md's Active requirements; FEATURES.md exists to justify *why* each is non-negotiable, not to re-derive the list independently.

- [ ] `Scale`, `Valuation`, `MoneyUnit`/`Currency`, `LaborUnit`, `TimeUnit`, `CompoundUnit (Per, Times)` — foundational dimensional vocabulary; nothing else can be typed without it
- [ ] `EconomicQuantity<valuation, unit>` with compile-time-enforced dimensional correctness — the table-stakes core; every derived economic type is built from this
- [ ] `Gap x` with orientation preservation (`positiveTerm`/`negativeTerm`) — the differentiator that distinguishes this from a generic affine-space diff
- [ ] `Expectation agent x` with `Agent` sum type — needed before `ExpectationsConflict` or the household/firm real-wage gaps can be expressed
- [ ] `Conflict` as semantic refinement of `Gap` (`ExpectationsConflict`, `DistributionalConflict`, `BargainingConflict`) — proves the "algebra vs semantics" separation that's the project's central design thesis
- [ ] `Effect responder perturband` with refinements `ResponseMultiplier`, `Elasticity` (+`Normalization`), `DistributionalEffect`/`NetDistributionalEffect` — the fundamental derivative object every coefficient in the wage equation is built from
- [ ] `GrowthRate x`, `CommonGrowthRate a b` (`Maybe`-returning smart constructor) — needed for both productivity growth and price-index growth terms
- [ ] `Indexation target reference` as `Effect (GrowthRate target) (GrowthRate reference)` — the third additive term's coefficient
- [ ] Derived quantities: `RealWage`, `LaborProductivity` — needed operands for the equation's Gap and GrowthRate terms
- [ ] CASO PRUEBA scenario tests (Nivel→Nivel, Nivel→Tasa, Tasa→Tasa) — validates the type hierarchy against concrete worked economic examples, not just abstract laws
- [ ] End-goal test: the boxed nominal wage growth equation composes and passes — the actual acceptance criterion for v1

### Add After Validation (v1.x — deferred but named in PROJECT.md scope)

- [ ] Functional income distribution matrix (ψ mechanisms, wage/profit shares, informal sector `W_{L_I}`) — trigger: the wage-growth equation type system is proven and stable; ψ is explicitly "a later milestone" per PROJECT.md Out of Scope
- [ ] Colombia-specific distribution mechanism taxonomy (named taxes/transfers/subsidies) — trigger: ψ object is formalized; explicitly "other agents' work" per the spec notes
- [ ] Additional `Agent` kinds or `Measure agent` probabilistic-measure refinement — trigger: if Kaldor/Minsky modules need agent distinctions beyond Household/Firm/Government/FinancialSector

### Future Consideration (v2+)

- [ ] Plank DSL port of the type system (`kalecky-plank/`) — deferred until Haskell types are proven; explicitly out of scope for this milestone
- [ ] hevm/Z3 symbolic-execution bridge for Kalecky types — the reason the types live inside `kalecky-spec` at all, but not exercised until the type hierarchy stabilizes
- [ ] Solidity/EVM execution tests of Kalecky types — v1 is pure Haskell per PROJECT.md
- [ ] Broader currency/unit generality (more currencies, more labor-time units) — defer until concrete new scenarios require it; resist speculative generality (anti-feature: full SI/currency-zoo breadth)

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Dimensional units foundation (Scale/Currency/LaborUnit/TimeUnit/CompoundUnit) | HIGH | MEDIUM | P1 |
| `EconomicQuantity<valuation, unit>` with restricted arithmetic | HIGH | MEDIUM | P1 |
| Orientation-preserving `Gap` | HIGH | MEDIUM | P1 |
| Agent-indexed `Expectation` | HIGH | LOW-MEDIUM | P1 |
| `Conflict` semantic refinement layer | HIGH | LOW (newtype wrapping) | P1 |
| `Effect` + `ResponseMultiplier`/`Elasticity`/`Indexation` | HIGH | MEDIUM | P1 |
| `GrowthRate` + `CommonGrowthRate` | HIGH | MEDIUM | P1 |
| Derived quantities (`RealWage`, `LaborProductivity`) | HIGH | LOW-MEDIUM | P1 |
| CASO PRUEBA scenario tests | HIGH (validation) | LOW | P1 |
| End-goal equation composition test | HIGH (acceptance criterion) | HIGH (integration) | P1 |
| ψ functional distribution matrix | MEDIUM (future) | HIGH | P3 |
| Colombia mechanism taxonomy | LOW (future, domain-specific) | MEDIUM | P3 |
| Plank DSL port | MEDIUM (future) | HIGH | P3 |
| hevm/Z3 symbolic bridge | MEDIUM (future, research value) | HIGH | P3 |

**Priority key:**
- P1: Must have for this milestone (all of it — the milestone is scoped tightly to exactly the Active requirements list)
- P2: (none identified — this milestone has no "should have, add when possible" middle tier; it's P1 or deferred to a future milestone as P3)
- P3: Future milestone, explicitly out of scope for now

## Competitor Feature Analysis

"Competitors" here are the closest analog libraries — the ones whose design patterns this project borrows from or deliberately diverges from.

| Feature | `dimensional` / `units` (physical units) | `safe-money` (currency) | `refined` (refinement types) | Our Approach |
|---------|-------------------------------------------|--------------------------|-------------------------------|--------------|
| Dimension-mismatch rejection | Type-level phantom Dimension/Unit, compile-time | Type-level currency tag on `Dense`/`Discrete` | N/A (predicate-based, not dimension-based) | Same pattern, scoped to `Currency`/`LaborUnit`/`TimeUnit`/`CompoundUnit` only |
| Arithmetic | Restricted operators (`+`/`-` same-dimension; `*`/`/` change dimension type) — explicitly NOT full `Num` | Dense supports `+`/scalar `*`; Discrete avoids float rounding | N/A | Same restricted-operator philosophy for `EconomicQuantity`; avoid naive `deriving Num` |
| Orientation/sign preservation on subtraction | Not addressed (no domain need — `meter - meter` is symmetric) | Not addressed | N/A | `Gap` deliberately preserves `positiveTerm`/`negativeTerm` — closest analog is `AffineSpace`'s `Diff`, but we go further by keeping sign semantics visible in the type |
| Semantic refinement without added data | Not addressed (units don't have "meaning" refinements) | Not addressed | Core pattern: `Refined p x`, newtype-only construction | Reused directly for `Conflict`/`ResponseMultiplier`/`Elasticity`/`Indexation` as newtypes over `Gap`/`Effect` |
| Partial/Maybe-returning construction | Not typically needed (dimension compatibility usually resolved at compile time) | `discreteFromDense` takes an `Approximation` strategy (lossy conversion, not failure) | `refine` returns `Either`/`Maybe` on predicate failure | `CommonGrowthRate`'s `Maybe`-returning smart constructor is closest to `refined`'s runtime-check pattern, applied to dimension compatibility between two growth rates |
| Agent/measure indexing | Not present in any surveyed library | Not present | Not present | Novel to this project — `Expectation agent x` |

## Sources

- [Numeric.Units.Dimensional — Hackage](https://hackage-content.haskell.org/package/dimensional-1.6.2/docs/Numeric-Units-Dimensional.html) — HIGH confidence, official docs, verified restricted-arithmetic pattern
- [dimensional — Hackage package page](https://hackage.haskell.org/package/dimensional) — HIGH confidence
- [units (Data.Metrology.Poly) — Hackage](https://hackage.haskell.org/package/units/docs/Data-Metrology-Poly.html) — HIGH confidence, official docs, verified compound-unit combinators
- [goldfirere/units — GitHub](https://github.com/goldfirere/units) — MEDIUM confidence (README excerpt limited)
- [uom-plugin — Hackage](https://hackage.haskell.org/package/uom-plugin) — MEDIUM confidence (own docs flag experimental/unsound edge cases)
- [safe-money — Hackage](https://hackage.haskell.org/package/safe-money) — MEDIUM-HIGH confidence, verified Dense/Discrete/ExchangeRate pattern via search + source excerpt
- [refined — Hackage / GitHub](https://github.com/nikita-volkov/refined) — HIGH confidence, verified newtype-only-construction pattern
- [vector-space (Data.AffineSpace) — Hackage](https://hackage.haskell.org/package/vector-space) — HIGH confidence, verified `.-.`/`Diff` pattern, used as contrast case for Gap's orientation preservation
- Agent-based stock-flow-consistent modeling literature (Caiani/Godin benchmark paper via Semantic Scholar/ScienceDirect; sfctools JOSS paper) — MEDIUM confidence, used only to confirm absence of typed prior art in this exact niche, not for feature details
- `notes/INCOME_DISTRIBUTION.md` — primary source of truth for the target type hierarchy (project-internal, not external research, but the basis against which all external patterns were compared)
- `.planning/PROJECT.md` — milestone scope and Active requirements list

---
*Feature research for: typed dimensional-analysis / economic-semantics Haskell library (Kalecky Semantics)*
*Researched: 2026-08-15*
