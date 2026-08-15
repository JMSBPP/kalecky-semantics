# Requirements: Kalecky Semantics

**Defined:** 2026-08-15
**Core Value:** Ill-formed economics must not type-check: the type system encodes the dimensional and semantic structure of income distribution so that the end-goal wage-growth equation can be expressed, compiled, and proven by tests.

**Process constraint (applies to every type requirement):** each increment's test is co-designed with the user and approved before implementation.

## v1 Requirements

Requirements for this milestone. Each maps to roadmap phases.

### Infrastructure

- [ ] **INFRA-01**: All core project sources (`kalecky-spec/`, `kalecky-plank/`, `notes/`, `test/`, `foundry.toml`, `remappings.txt`) are tracked in git so every increment lands as a reviewable commit
- [ ] **INFRA-02**: `Kalecky.*` modules build as a dedicated cabal component with its own test-suite, compilable and testable without rebuilding hevm's main library

### Units (dimensional foundation)

- [ ] **UNIT-01**: Researcher can construct base units via smart constructors only — `Scale`, `Currency` (`COP` with unit `Billion | Million | Thousand`, `USD`), `LaborUnit` (`Worker | LaborHour`), `TimeUnit` — hidden data constructors
- [ ] **UNIT-02**: Researcher can compose compound units with `Per` and `Times` (e.g., `Per MoneyUnit LaborUnit` for a wage)
- [ ] **UNIT-03**: Researcher can construct `EconomicQuantity<valuation, unit>` with Decimal-backed exact amounts and `Valuation = Nominal | Real PriceIndex` threaded through the type
- [ ] **UNIT-04**: Adding or subtracting `EconomicQuantity` values with mismatched units or valuations fails to compile — no `Num` instance; restricted same-unit operators only
- [ ] **UNIT-05**: Multiplying/dividing `EconomicQuantity` values produces a quantity whose unit type is correctly composed; canceling dimensions yields a dimensionless ratio
- [ ] **UNIT-06**: Researcher can convert between scales within one unit (e.g., COP Million ↔ COP Thousand) with exact Decimal arithmetic — no rounding drift

### Algebraic operators

- [ ] **ALG-01**: `Gap x` preserves orientation (`positiveTerm`/`negativeTerm`); a property test proves `Gap a b ≠ Gap b a`
- [ ] **ALG-02**: `Gap` is generic over any `x` admitting subtraction — it knows no economics and imports no domain modules
- [ ] **ALG-03**: `Expectation agent x` with `Agent = Household | Firm | Government | FinancialSector`; `E^H[x]` and `E^F[x]` are distinct types for the same `x`
- [ ] **ALG-04**: `Effect responder perturband` is a newtype over `Number` encoding ∂responder/∂perturband — no extra runtime data
- [ ] **ALG-05**: `GrowthRate x` is the dimensionless relative change Δx/x of an `EconomicQuantity`
- [ ] **ALG-06**: `mkCommonGrowthRate` returns `Maybe (CommonGrowthRate a b)` — `Just` only when the two growth rates share a common base

### Semantic refinements (equation slice)

- [ ] **SEM-01**: `ExpectationsConflict agentA agentB x` is a newtype over `Gap x`, constructible only from two `Expectation`s of the same variable
- [ ] **SEM-02**: `ResponseMultiplier responder perturband` is a newtype over `Effect` — no redundant stored scalar
- [ ] **SEM-03**: `Indexation target reference` is a newtype over `Effect (GrowthRate target) (GrowthRate reference)`

### Domain instances

- [ ] **DOM-01**: `NominalWage :: EconomicQuantity Nominal (Per MoneyUnit LaborUnit)` — money per labor, not a price index
- [ ] **DOM-02**: `RealWage` is `NominalWage` deflated by `PriceLevel`, with valuation `Real`
- [ ] **DOM-03**: `LaborProductivity` is `Ratio Output LaborService` with `GrowthRate` definable on it
- [ ] **DOM-04**: Household and firm real-wage expectation gap constructors produce `Gap RealWage` values with opposite orientations

### Proof (validation)

- [ ] **PROOF-01**: Every shipped type has QuickCheck law properties (via quickcheck-classes where applicable), co-designed and approved before implementation
- [ ] **PROOF-02**: CASO PRUEBA Nivel→Nivel passes: "minimum wage of 20000 COP per hour" constructs and asserts exactly
- [ ] **PROOF-03**: CASO PRUEBA Nivel→Tasa passes: wage 10 → 12 money units per labor unit is exactly a +20 percentage-point growth
- [ ] **PROOF-04**: CASO PRUEBA Tasa→Tasa passes: growth 5% → 5.20% is exactly +20 basis points — with the Gap-of-a-rate vs rate-of-a-rate ambiguity resolved in that increment's co-designed test
- [ ] **PROOF-05**: End-goal test passes: the boxed nominal wage growth equation (ResponseMultiplier·Gap + ResponseMultiplier·productivity growth + Indexation·inflation) type-checks, composes across its three additive terms without ad-hoc glue, and its property + example tests pass

## v2 Requirements

Deferred to future milestones. Tracked but not in current roadmap.

### Refinement family completion

- **SEM-04**: `Elasticity responder perturband` with `Normalization` type
- **SEM-05**: `DistributionalEffect` / `NetDistributionalEffect` refinements
- **SEM-06**: `DistributionalConflict` and `BargainingConflict` variants
- **SEM-07**: `Measure agent` probabilistic-measure refinement of `Expectation`

### Distribution structure

- **DIST-01**: Functional income distribution matrix (ψ mechanisms, wage/profit shares, informal sector W_{L_I})

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Plank DSL port (`kalecky-plank/`) | Prove the Haskell types first; Draft.plk stays a draft until then |
| Solidity/EVM execution tests of Kalecky types | v1 is pure Haskell; hevm bridge comes after types stabilize |
| Lean/EvmYul proofs of Kalecky semantics | Inherited infrastructure, separate verification track |
| Colombia-specific mechanism taxonomy | Notes mark it "other agents' work" after ψ is formalized |
| Runtime unit checking | Contradicts core value — errors must be compile-time |
| Symbolic differentiation / CAS for Effect | Effect is an opaque estimated scalar by resolved design |
| General equilibrium / macro simulation | Different engineering problem; future milestone atop proven types |
| Full SI units or currency zoo | Only COP/USD, Worker/LaborHour, TimeUnit needed; borrow patterns, not breadth |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| (populated by roadmap) | | |

**Coverage:**
- v1 requirements: 26 total
- Mapped to phases: 0
- Unmapped: 26 ⚠️

---
*Requirements defined: 2026-08-15*
*Last updated: 2026-08-15 after initial definition*
