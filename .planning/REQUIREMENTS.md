# Requirements: Kalecky Semantics

**Defined:** 2026-08-15
**Core Value:** Ill-formed economics must not type-check: the type system encodes the dimensional and semantic structure of income distribution so that the end-goal wage-growth equation can be expressed, compiled, and proven by tests.

**Process constraint (applies to every type requirement):** each increment's test is co-designed with the user and approved before implementation.

## v1 Requirements

Requirements for this milestone. Each maps to roadmap phases.

### Infrastructure

- [x] **INFRA-01**: All core project sources (`kalecky-spec/`, `kalecky-plank/`, `notes/`, `test/`, `foundry.toml`, `remappings.txt`) are tracked in git so every increment lands as a reviewable commit
- [x] **INFRA-02**: `Kalecky.*` modules build as a dedicated cabal component with its own test-suite, compilable and testable without rebuilding hevm's main library

### Units (dimensional foundation)

Design basis (from `kalecky-spec/src/Kalecky/types/**` notes): the amount lives in the Unit itself — `u_s(k) = k · s(b,i)` with `Scale s(b,i) := b^i`; there is no separate quantity wrapper. `Price p(u,v) := c_p(u,v)` is a valuation-parameterized Per-compound unit (this replaces the earlier `EconomicQuantity<valuation, unit>` design).

- [x] **UNIT-01**: Researcher can construct base vocabulary via smart constructors only — `Scale` (per-unit-kind bases as in `Draft.plk`: `denomination_scale`, `LaborScale`, `TimeScale`), `MoneyUnit`/`Currency` (`COP`, `USD`), `LaborUnit` (`Worker | LaborHour`), `TimeUnit` (Month, Hour) — hidden data constructors; a `Unit u_s(k)` carries its amount `k` as a Natural counting multiples of the per-currency `tradeable_base` (COP: 50) at scale `s`
- [x] **UNIT-02**: Units compose as a semigroup under `(·)`; `CompoundUnit` connectors `Per` (ρ: ratio) and `Times` (τ: tensor) compose two units, auto-aligning mismatched scales by exact conversion to a common scale (the `s = h` derivation rule)
- [x] **UNIT-03**: Researcher can construct `Price p(u,v)` as a valuation-parameterized `Per`-compound unit with `Valuation = Nominal | Real PriceIndex` threaded through the type; amounts remain Natural-backed (no fractional representation)
- [x] **UNIT-04**: Adding or subtracting units or prices with mismatched dimensions or valuations fails to compile — no `Num` instance; restricted same-dimension operators only
- [x] **UNIT-05**: `Per`/`Times` composition produces a correctly composed unit type; canceling dimensions yields a dimensionless ratio
- [x] **UNIT-06**: Scale conversion within one unit (e.g., COP Million ↔ COP Thousand, aligning toward the finer denomination) is exact Natural arithmetic — no rounding, no fractional loss

### Algebraic operators

- [ ] **ALG-01**: `Gap x` is an ORIENTED expectation-vs-realization difference — constructors require an `Expectation` on one side (two realized values are unrepresentable); both orientations exist (`gapER`, `gapRE`) with `evalGap (flip g) == negate (evalGap g)`; a property test proves orientation matters
- [ ] **ALG-02**: `Gap` is generic over its carrier `x` via a signed-exact-difference class (instanced by Unit/Price/GrowthRate); realized-to-realized differences are `Delta x` (`Operators/Delta.hs`), not Gap — Tasa→Tasa's +20bp types as `Delta (GrowthRate x)`
- [ ] **ALG-03**: `Expectation (μ :: Measure) x` (measure-indexed, Measure carries the agent) with type-level `Agent = Household | Firm | Government | FinancialSector`; `E^H[x]` and `E^F[x]` are distinct types for the same `x`
- [ ] **ALG-04**: `Effect responder perturband` is a newtype over exact signed `Rational` encoding ∂responder/∂perturband — no extra runtime data, no floats
- [ ] **ALG-05**: `GrowthRate x` is the dimensionless relative change Δx/x as an exact signed `Rational`, an independent primitive with a from-observations constructor (`Maybe` on zero base)
- [ ] **ALG-06**: `mkCommonGrowthRate` returns `Maybe (CommonGrowthRate a b)` — `Just` exactly when the two rates are numerically equal (balanced-growth witness)

### Semantic refinements (equation slice)

- [ ] **SEM-01**: `ExpectationsConflict agentA agentB x` is a newtype over `Gap x`, constructible only from two `Expectation`s of the same variable
- [ ] **SEM-02**: `ResponseMultiplier responder perturband` is a newtype over `Effect` — no redundant stored scalar
- [ ] **SEM-03**: `Indexation target reference` is a newtype over `Effect (GrowthRate target) (GrowthRate reference)`

### Domain instances

- [ ] **DOM-01**: `Wage` is a `Price` over `Per MoneyUnit LaborUnit`; `NominalWage` is a `Wage` with `Nominal` valuation — money per labor, not a price index
- [ ] **DOM-02**: `RealWage` is the `Wage` with valuation `Real PriceIndex` — `NominalWage` deflated by `PriceLevel`
- [ ] **DOM-03**: `LaborProductivity` is `Ratio Output LaborService` with `GrowthRate` definable on it
- [ ] **DOM-04**: Household and firm real-wage expectation gap constructors produce `Gap RealWage` values with opposite orientations

### Proof (validation)

- [x] **PROOF-01**: Every shipped type has QuickCheck law properties (via quickcheck-classes where applicable), co-designed and approved before implementation
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
| INFRA-01 | Phase 1 | Complete (01-05 — `./scripts/verify-repo-state.sh` exits 0, prints `INFRA-01: PASS`; all five checks green including the new remappings.txt resolution check; user approved the resulting git history shape) |
| INFRA-02 | Phase 1 | Complete (01-06 — `cd kalecky-spec && cabal test kalecky-test` passes 2/2 properties; `cabal build kalecky-test --dry-run` from a clean state lists only `lib:kalecky` + `test:kalecky-test`, no bare hevm main library; touch-test + negative control confirm hevm source changes do not rebuild the Kalecky suite) |
| UNIT-01 | Phase 2 | Complete |
| UNIT-02 | Phase 2 | Complete |
| UNIT-03 | Phase 2 | Complete |
| UNIT-04 | Phase 2 | Complete |
| UNIT-05 | Phase 2 | Complete |
| UNIT-06 | Phase 2 | Complete |
| PROOF-01 | Phase 2 | Complete |
| ALG-01 | Phase 3 | Pending |
| ALG-02 | Phase 3 | Pending |
| ALG-03 | Phase 3 | Pending |
| ALG-04 | Phase 3 | Pending |
| ALG-05 | Phase 3 | Pending |
| ALG-06 | Phase 3 | Pending |
| SEM-01 | Phase 4 | Pending |
| SEM-02 | Phase 4 | Pending |
| SEM-03 | Phase 4 | Pending |
| DOM-01 | Phase 5 | Pending |
| DOM-02 | Phase 5 | Pending |
| DOM-03 | Phase 5 | Pending |
| DOM-04 | Phase 5 | Pending |
| PROOF-02 | Phase 5 | Pending |
| PROOF-03 | Phase 5 | Pending |
| PROOF-04 | Phase 5 | Pending |
| PROOF-05 | Phase 6 | Pending |

**Coverage:**
- v1 requirements: 26 total
- Mapped to phases: 26
- Unmapped: 0 ✓

---
*Requirements defined: 2026-08-15*
*Last updated: 2026-08-15 after roadmap creation (6 phases, full coverage)*
