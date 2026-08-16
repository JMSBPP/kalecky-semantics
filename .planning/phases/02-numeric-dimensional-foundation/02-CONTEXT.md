# Phase 2: Numeric & Dimensional Foundation - Context

**Gathered:** 2026-08-15
**Status:** Ready for planning

<domain>
## Phase Boundary

The dimensional kernel exists so mismatched-unit or mismatched-valuation arithmetic is a compile error: `Scale`, base units (Money/Labor/Time), amount-carrying `Unit u_s(k)`, `CompoundUnit` (`Per`/`Times` with scale alignment by exact conversion), `Valuation`, and `Price p(u,v)`. This phase also establishes the PROOF-01 co-designed test pattern every later phase follows. Requirements: UNIT-01..06, PROOF-01. Algebraic operators (Gap, Effect, …) are Phase 3; domain vocabulary (Wage, RealWage) is Phase 5.

</domain>

<decisions>
## Implementation Decisions

### Test co-design cadence (the PROOF-01 standing pattern)
- **Two-stage co-design per increment**: (1) the laws for each type are discussed live with the user before/while planning that increment; (2) during execution, the executor drafts the actual property/example test code and STOPS at a checkpoint showing the test code — the user approves or amends BEFORE any implementation is written. Both stages, not either/or.
- Increment order is **bottom-up**: Scale → Unit (amount@scale) → base units (Money/Labor/Time) → CompoundUnit (Per/Times + alignment) → Valuation → Price.
- Approval bar: each increment's approval covers **both** QuickCheck law properties AND at least one concrete example with real numbers (e.g., a COP scale conversion).
- If an approved test proves wrong mid-implementation (law can't hold, spec contradiction): **stop and surface** with evidence; get the revised test approved before continuing. No silent test amendment.
- Commit rhythm: test-then-impl pairs (`test(kalecky): …` RED → `feat(kalecky): …` GREEN), per Phase 1's standing decision.

### Scale semantics (grounded in kalecky-plank/Draft.plk — the canonical pattern)
- **Base is per unit kind**, not universal: each unit family fixes its own scale constants as per-basis functions, mirroring Draft.plk exactly — `denomination_scale` (Raw=1, Thousand=10³, Million=10⁶, Billion=10⁹) for money, `LaborScale` (WORKER_BASE=1) for labor, `TimeScale` (MONTH_BASE=2592000, seconds in a 30-day month) for time.
- **Amounts are Natural numbers counting multiples of the per-currency `tradeable_base`** (COP: 50 — the smallest tradable increment; no fractional representation exists at all). This mirrors Draft.plk's `qty: u256` + `tradeable_base(COP) = 50`. **This supersedes the earlier "Decimal-backed amounts" decision** — REQUIREMENTS.md UNIT-01/03/06 wording amended accordingly. Exactness comes from naturals, not Decimal.
- Scale mechanism is **uniform across money/labor/time** — thousands of workers and millions of hours use the same `Scale` machinery as money denominations.
- TimeUnit is **minimal**: just Month and Hour bases so COP/month and COP/hour wages type-check; richer time algebra deferred.

### Compile-time boundary (UNIT-04 exact semantics)
- COP + USD → **compile error** (currencies are distinct types).
- Money + labor (any cross-dimension add/sub) → **compile error**.
- Nominal + Real (same unit) → **compile error**; deflation is always explicit.
- COP Million + COP Thousand (same currency, different denomination) → **auto-convert exactly** to a common denomination (the `s = h` alignment-by-conversion rule; align toward the finer denomination so naturals stay exact).

### API surface
- Composition via **named functions**: `per`, `times` (mirroring ρ/τ in the notes and Draft.plk's Per/Times). No custom infix operators in Phase 2.
- Smart constructors use **bare names** (`scale`, `moneyUnit`, `wage` …), relying on module qualification — NOT the mk- prefix (note: this diverges from the notes' `mkCommonGrowthRate` sketch; apply bare naming consistently in later phases too unless the user revisits).
- Construction failures return **Maybe** (e.g., amount not a multiple of the tradeable base). Partiality only where economically real.
- `Bounds { min, max }` from the notes is **deferred** — not needed by Phase 2 requirements or CASO PRUEBA.

### Claude's Discretion
- Exact type-level encoding (DataKinds/GADTs/type families shape) achieving the compile-time boundary
- Auto-alignment mechanics (aligning to finer denomination; where conversion lives)
- Module layout within `Kalecky.Types.*` (respect the existing tree; wire modules into the `kalecky` sublibrary as they become real)
- Whether `quickcheck-classes` is used per law or plain tasty-quickcheck properties suffice

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Design source of truth
- `kalecky-plank/Draft.plk` — THE canonical pattern for this phase: per-basis scale functions (`denomination_scale`, `LaborScale`, `TimeScale`), `tradeable_base(COP) = 50`, `Unit(ScaleFn, Basis)` with qty, `MoneyUnit(Currency, Denomination)`, `Per`/`Times`/`CompoundUnit`, and the desired recursive `EconomicUnit` sum type (comment block lines 99-107)
- `notes/INCOME_DISTRIBUTION.md` — type-design dialogue and CASO PRUEBA scenarios (§ CASO PRUEBA: Nivel→Nivel 20000 COP/hour, Nivel→Tasa, Tasa→Tasa); TYPES section
- `kalecky-spec/src/Kalecky/Types/**` — design-note stubs preserved from the rename (Unit semigroup note, CompoundUnit ρ/τ derivation rule, Price/Wage notes); these comments are spec, the files are not yet wired code

### Project planning
- `.planning/PROJECT.md` — key decisions (Price replaces EconomicQuantity; amount lives in Unit)
- `.planning/REQUIREMENTS.md` — UNIT-01..06, PROOF-01 (amended: Natural + tradeable_base supersedes Decimal)
- `.planning/ROADMAP.md` — Phase 2 success criteria
- `.planning/phases/01-project-hygiene-build-isolation/01-CONTEXT.md` — standing workflow decisions (branch-per-phase, test-then-impl commits, cabal loop)
- `.planning/phases/01-project-hygiene-build-isolation/01-VALIDATION.md` — the proven `cabal test kalecky-test` loop and isolation evidence
- `.planning/research/STACK.md` — GHC extensions available/needed (GADTs, DerivingStrategies, DerivingVia); LTS 23.28 package facts

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `library kalecky` + `test-suite kalecky-test` in `kalecky-spec/kalecky-spec.cabal` — the isolated ~10s loop (`cd kalecky-spec && cabal test kalecky-test`); new modules get added to the sublibrary's exposed-modules as they become real
- `kalecky-spec/src/Kalecky/Smoke.hs` + `kalecky-spec/test-kalecky/Main.hs` — existing Tasty main to extend with per-type test groups
- Design-note stubs under `kalecky-spec/src/Kalecky/Types/` — headers/imports partially fixed in Phase 1; `MoneyUnit.hs` carries `TODO(Phase 2, UNIT-01)` for the missing `Kalecky.Types.Currency` module

### Established Patterns
- Phase 1 commit conventions: `test(kalecky):` RED → `feat(kalecky):` GREEN pairs; conventional prefixes throughout
- Stop-and-surface checkpoint pattern (Phase 1's drift decision) — reuse for test contradictions
- cabal (never stack) for the increment loop; `cabal.project` pins ghc-9.8.4

### Integration Points
- New modules wire into `library kalecky` exposed-modules (currently only `Kalecky.Smoke`)
- The stub draft tree becomes real module-by-module in this phase's bottom-up order; do not wire a stub before its increment
- Phase branch: create `phase/02-foundation` off main after merging `phase/01-hygiene` (branch-per-phase standing decision; Phase 1 branch is complete but unmerged — surface this at execution start)

</code_context>

<specifics>
## Specific Ideas

- "Use the pattern in the Plank draft that already encodes the intention" — Draft.plk is the reference implementation for scale/tradeable-base semantics; the Haskell types should be recognizably the same design (with the desired recursive sum type from its comment block, not the closed-world dispatch it apologizes for)
- Amounts: natural numbers only — "it doesn't include decimals"; the tradable base (COP: 50) is the quantization step
- MONTH_BASE = 0x278d00 = 2,592,000 = seconds in a 30-day month — time scales are second-denominated

</specifics>

<deferred>
## Deferred Ideas

- `Bounds { min :: Maybe, max :: Maybe }` validation on quantities — not needed for Phase 2 or CASO PRUEBA; revisit when a requirement demands it
- Richer time algebra (hour↔month conversion factors, more time bases) — beyond the minimal Month/Hour needed for wages
- Infix operator synonyms for `per`/`times`/semigroup composition — named functions first; sugar later if wanted

</deferred>

---

*Phase: 02-numeric-dimensional-foundation*
*Context gathered: 2026-08-15*
