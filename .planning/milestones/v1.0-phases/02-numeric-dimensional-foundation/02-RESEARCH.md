# Phase 2: Numeric & Dimensional Foundation - Research

**Researched:** 2026-08-15
**Domain:** Type-level dimensional analysis in Haskell (GADTs/DataKinds), exact Natural-number scaled arithmetic
**Confidence:** MEDIUM-HIGH (encoding recommendation HIGH confidence — basic nominal typing, not exotic; several concrete semantic gaps in the source notes are flagged LOW/open, not glossed over)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Test co-design cadence (the PROOF-01 standing pattern)**
- Two-stage co-design per increment: (1) the laws for each type are discussed live with the user before/while planning that increment; (2) during execution, the executor drafts the actual property/example test code and STOPS at a checkpoint showing the test code — the user approves or amends BEFORE any implementation is written. Both stages, not either/or.
- Increment order is bottom-up: Scale → Unit (amount@scale) → base units (Money/Labor/Time) → CompoundUnit (Per/Times + alignment) → Valuation → Price.
- Approval bar: each increment's approval covers both QuickCheck law properties AND at least one concrete example with real numbers (e.g., a COP scale conversion).
- If an approved test proves wrong mid-implementation (law can't hold, spec contradiction): stop and surface with evidence; get the revised test approved before continuing. No silent test amendment.
- Commit rhythm: test-then-impl pairs (`test(kalecky): …` RED → `feat(kalecky): …` GREEN), per Phase 1's standing decision.

**Scale semantics (grounded in kalecky-plank/Draft.plk — the canonical pattern)**
- Base is per unit kind, not universal: each unit family fixes its own scale constants as per-basis functions, mirroring Draft.plk exactly — `denomination_scale` (Raw=1, Thousand=10³, Million=10⁶, Billion=10⁹) for money, `LaborScale` (WORKER_BASE=1) for labor, `TimeScale` (MONTH_BASE=2592000, seconds in a 30-day month) for time.
- Amounts are Natural numbers counting multiples of the per-currency `tradeable_base` (COP: 50 — the smallest tradable increment; no fractional representation exists at all). This mirrors Draft.plk's `qty: u256` + `tradeable_base(COP) = 50`. This supersedes the earlier "Decimal-backed amounts" decision — REQUIREMENTS.md UNIT-01/03/06 wording amended accordingly. Exactness comes from naturals, not Decimal.
- Scale mechanism is uniform across money/labor/time — thousands of workers and millions of hours use the same `Scale` machinery as money denominations.
- TimeUnit is minimal: just Month and Hour bases so COP/month and COP/hour wages type-check; richer time algebra deferred.

**Compile-time boundary (UNIT-04 exact semantics)**
- COP + USD → compile error (currencies are distinct types).
- Money + labor (any cross-dimension add/sub) → compile error.
- Nominal + Real (same unit) → compile error; deflation is always explicit.
- COP Million + COP Thousand (same currency, different denomination) → auto-convert exactly to a common denomination (the `s = h` alignment-by-conversion rule; align toward the finer denomination so naturals stay exact).

**API surface**
- Composition via named functions: `per`, `times` (mirroring ρ/τ in the notes and Draft.plk's Per/Times). No custom infix operators in Phase 2.
- Smart constructors use bare names (`scale`, `moneyUnit`, `wage` …), relying on module qualification — NOT the mk- prefix (note: this diverges from the notes' `mkCommonGrowthRate` sketch; apply bare naming consistently in later phases too unless the user revisits).
- Construction failures return Maybe (e.g., amount not a multiple of the tradeable base). Partiality only where economically real.
- `Bounds { min, max }` from the notes is deferred — not needed by Phase 2 requirements or CASO PRUEBA.

### Claude's Discretion
- Exact type-level encoding (DataKinds/GADTs/type families shape) achieving the compile-time boundary
- Auto-alignment mechanics (aligning to finer denomination; where conversion lives)
- Module layout within `Kalecky.Types.*` (respect the existing tree; wire modules into the `kalecky` sublibrary as they become real)
- Whether `quickcheck-classes` is used per law or plain tasty-quickcheck properties suffice

### Deferred Ideas (OUT OF SCOPE)
- `Bounds { min :: Maybe, max :: Maybe }` validation on quantities — not needed for Phase 2 or CASO PRUEBA; revisit when a requirement demands it
- Richer time algebra (hour↔month conversion factors, more time bases) — beyond the minimal Month/Hour needed for wages
- Infix operator synonyms for `per`/`times`/semigroup composition — named functions first; sugar later if wanted
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-------------------|
| UNIT-01 | Smart-constructor-only base vocabulary: `Scale`, `MoneyUnit`/`Currency`, `LaborUnit`, `TimeUnit`; `Unit u_s(k)` carries Natural amount `k` | See "Standard Stack", "Recommended Type Encoding", candidate 2 (nominal per-kind types); module list in "Architecture Patterns" |
| UNIT-02 | Semigroup under `(·)`; `Per`/`Times` auto-align mismatched scales via exact conversion (`s = h` rule) | See "CompoundUnit / Per / Times", "Alignment Mechanics"; flagged open question on cross-kind alignment scope |
| UNIT-03 | `Price p(u,v)` as valuation-parameterized `Per`-compound; `Valuation = Nominal \| Real PriceIndex` threaded through the type | See "Valuation and Price Encoding"; open question on `PriceIndex` definition |
| UNIT-04 | Mismatched dimension/valuation add/sub fails to compile; no `Num` instance, restricted same-dimension operators only | See "Recommended Type Encoding" (nominal typing gives this largely for free) and "Compile-Time Rejection Testing" |
| UNIT-05 | `Per`/`Times` composition produces correctly composed type; canceling dimensions yield dimensionless ratio | See "CompoundUnit / Per / Times"; open question on cancellation mechanism |
| UNIT-06 | Scale conversion within one unit (COP Million ↔ Thousand) is exact Natural arithmetic, aligning toward the finer denomination | See "Natural + Tradeable-Base Arithmetic", worked COP example, alignment law derivations |
| PROOF-01 | Every shipped type has co-designed, approved-before-implementation QuickCheck law properties | See "Validation Architecture", "Test Design" |
</phase_requirements>

## Summary

Phase 2 builds a dimensional kernel where the Haskell *type checker*, not a runtime check, rejects mismatched-currency, mismatched-dimension, and mismatched-valuation arithmetic, while still letting same-currency amounts at different denominations (Million vs Thousand) auto-convert exactly. The canonical shape is fully specified in `kalecky-plank/Draft.plk` (a Zig comptime-dispatch draft) and cross-referenced in `notes/INCOME_DISTRIBUTION.md`; Phase 2's job is a faithful, statically-checked Haskell translation, not a redesign.

The central design insight is that **UNIT-04's compile-time rejection is mostly free from ordinary Haskell nominal typing** — if `MoneyUnit`, `LaborUnit`, and `TimeUnit` are three distinct type constructors (no shared `Num`/generic-addition class), then `moneyVal + laborVal` is already ill-typed with zero extra machinery. `DataKinds`/GADTs are needed for exactly two things in this phase: (1) making `Currency` a type-level tag on `MoneyUnit` so `COP` vs `USD` are different types (not different runtime values of one type), and (2) making `Valuation` a type-level tag on `Price` so `Nominal` vs `Real PriceIndex` are different types. Everything else — `Per`/`Times` composition, the Scale/amount pair, denomination alignment — is achieved with ordinary parametric polymorphism over concrete unit types, which also gives the "recursive `EconomicUnit`" shape Draft.plk's comment wants (`Per`/`Times` parametrized directly by their operand *types*, recursing for free) without needing a closed, promoted `EconomicUnit` kind enumeration. Over-engineering risk in this phase is real and specific: reaching for a single unified promoted-kind hierarchy (mirroring Draft.plk's aspirational flat `EconomicUnit` sum literally) would re-introduce the runtime-dispatch character Draft.plk itself apologizes for ("this combinatorically scales too much").

Several concrete semantic gaps exist in the source material that this research surfaces rather than silently resolves: the exact `Hour` time-base constant (only `MONTH_BASE` is given), whether `LaborUnit` gets a `Denomination` axis like `MoneyUnit` ("thousands of workers" is prose, not a locked spec), what `PriceIndex` actually is, and whether the `s = h` alignment precondition in the `CompoundUnit` stub note applies across different unit kinds or only within one. These are exactly the kind of question the two-stage co-design cadence is built to resolve — they should be raised explicitly at the relevant increment's Stage 1 conversation, not assumed by the planner.

**Primary recommendation:** Use plain nominal Haskell types (`newtype`/`data`, hidden constructors, one type per unit-kind) for the bulk of the kernel; reserve `DataKinds`+`GADTs` narrowly for `Currency` (on `MoneyUnit`) and `Valuation` (on `Price`); implement `Scale`/alignment entirely at the value level as `Natural` arithmetic with "convert toward the finer denomination" as the one alignment rule; slice the six locked increments into roughly six plans, one checkpoint each.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|---------------|
| `base` (`Numeric.Natural`) | ships with GHC 9.8.4 | `Natural`-backed amounts, scale factors, exponents | CONTEXT.md locks "amounts are Natural numbers" — supersedes the earlier `Decimal` plan recorded in `.planning/research/STACK.md`. No extra dependency: `Natural` is in `base` already declared as a dependency of `library kalecky`. |
| `QuickCheck` | 2.14.3 (pinned by `lts-23.28`, already bounded `>=2.13.2 && <2.16` in `kalecky-spec.cabal`) | Property tests, `Arbitrary` instances | Already wired into `test-suite kalecky-test` via `tasty-quickcheck`. |
| `tasty` / `tasty-quickcheck` | already in `test-suite kalecky-test`'s `build-depends` | Test runner, QuickCheck-Tasty bridge | No change needed — Phase 1 already proved the ~10s `cabal test kalecky-test` loop works from this exact stanza. |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `quickcheck-classes` | 0.6.5.0, confirmed present in `lts-23.28` (verified in Phase-1-era `.planning/research/STACK.md`, re-confirmed here) | Off-the-shelf `semigroupLaws :: (Semigroup a, Eq a, Arbitrary a, Show a) => Proxy a -> Laws` | Use for the `Semigroup` instance UNIT-02 requires on `CompoundUnit`/`Unit` composition under `(·)`. Not yet added to `kalecky-spec.cabal`'s `build-depends` for `library kalecky`/`test-suite kalecky-test` — this phase must add it. |
| `should-not-typecheck` | 2.1.0, confirmed present in the current Stackage snapshot family (`base`, `deepseq >=1.3`, `HUnit >=1.2` only — no conflicts with existing bounds) | `shouldNotTypecheck` via `-fdefer-type-errors` + runtime exception catch, for asserting "this expression must not typecheck" inside an actual test run | **Conditional recommendation, not default** — see "Compile-Time Rejection Testing" below; conflicts with the project's existing `-Werror` CI flag unless scoped carefully. Primary recommendation is a simpler excluded-source-file convention (no new dependency). |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Nominal per-kind types + narrow `DataKinds`/GADTs (recommended) | Single promoted `EconomicUnit` kind with GADT indices for every dimension (Money/Labor/Time/Per/Times all as one closed kind) | More "textbook type-level dimensional analysis," but reintroduces a closed-world dispatch shape close to what Draft.plk explicitly apologizes for ("this combinatorically scales too much... I think is a recursive type"); harder to extend per-kind (e.g. adding a new `LaborBasis` constructor requires touching the shared promoted kind); not needed to satisfy any locked requirement. Reject for Phase 2; revisit only if a later phase needs uniform dispatch over "any EconomicUnit." |
| `should-not-typecheck` for compile-fail tests | Excluded-source-file convention (`.hs` files never added to `exposed-modules`/`other-modules`, verified by direct `ghc -c` invocation in a script, not part of the normal test run) | `should-not-typecheck` gives an automated, in-suite assertion but requires `-fdefer-type-errors` scoped in a way that survives the project's `-Werror` CI flag (see below); the excluded-file convention has zero extra dependency and cannot silently regress into "passes even though the type error stopped existing" the way a deferred-type-error test can if the module-scoping is wrong. |
| Natural-only `Scale` (recommended) | `refined`'s `Refined p Natural` for scale/amount validity | `refined` was already rejected in `.planning/research/STACK.md` in favor of `Maybe`-returning smart constructors; CONTEXT.md's locked "Construction failures return Maybe" reconfirms this. No reason to introduce it in Phase 2. |

**Installation:**
```bash
# kalecky-spec/kalecky-spec.cabal — add to library kalecky's and test-suite kalecky-test's build-depends:
  quickcheck-classes  >= 0.6.5   && < 0.7,

# common shared's default-extensions — add:
#   GADTs
#   DerivingStrategies
#   DerivingVia
```

**Version verification:** `quickcheck-classes-0.6.5.0` and `QuickCheck-2.14.3` were verified live against the `lts-23.28` Stackage snapshot during Phase 1's stack research (`.planning/research/STACK.md`, dated 2026-08-15, same day) and re-confirmed by WebSearch during this research pass (no version drift expected across same-day research). `should-not-typecheck-2.1.0` was verified live against the current Stackage snapshot family via WebFetch during this research pass (2026-08-15) — HIGH confidence for presence, MEDIUM confidence for the exact `lts-23.28` pin specifically (Stackage's page did not disambiguate the snapshot-specific version string in the fetched excerpt; the package has had no major version bump reported near this period, so drift risk is low). `Natural` requires no version check — it ships with `base`, already a `build-depends` entry.

## Architecture Patterns

### Recommended Project Structure
```
kalecky-spec/src/Kalecky/Types/
├── Numerics.hs              # Scale (UNIT-01, increment 1)
├── Units/
│   ├── Unit.hs               # generic Unit (amount @ scale) (UNIT-01, increment 2)
│   ├── Currency.hs           # NEW — Currency tag (COP | USD), promoted via DataKinds
│   ├── Denomination.hs       # NEW — Raw | Thousand | Million | Billion (shared scale table)
│   ├── MoneyUnit.hs           # MoneyUnit (Currency-tagged), tradeable_base (increment 3)
│   ├── LaborUnit.hs           # LaborBasis (Worker | LaborHour), LaborUnit (increment 4)
│   ├── TimeUnit.hs             # NEW — TimeBasis (Month | Hour), TimeUnit (increment 4)
│   └── CompoundUnit.hs        # Per/Times, alignment, Semigroup instance (increment 5)
├── Valuation.hs               # Nominal | Real PriceIndex (increment 6, paired with Price)
└── Prices/
    ├── Price.hs                # Price = valuation-tagged Per-compound (increment 6)
    └── Wage.hs                 # NOT this phase's requirement (DOM-01 is Phase 5) — leave stub
```
`Currency.hs`, `Denomination.hs`, and `TimeUnit.hs` are net-new modules (no existing stub); `MoneyUnit.hs` already carries a `TODO(Phase 2, UNIT-01)` pointing at the missing `Currency` module.

### Pattern 1: Nominal per-kind types get UNIT-04 (cross-dimension rejection) for free
**What:** Do not define a shared `Num`/generic-addition typeclass across `MoneyUnit`, `LaborUnit`, `TimeUnit`. Give each its own restricted addition operator (or a typeclass method specialized per concrete type, never polymorphic across kinds).
**When to use:** Always, for same-vs-cross-dimension arithmetic in this phase.
**Example (recommended shape, not yet in the codebase — Phase 2 to author):**
```haskell
-- Kalecky.Types.Units.MoneyUnit
newtype MoneyUnit (c :: Currency) = MoneyUnit { unMoneyUnit :: (Denomination, Natural) }
  -- hidden constructor; only `moneyUnit` (Maybe-returning smart constructor) creates values

addMoney :: MoneyUnit c -> MoneyUnit c -> MoneyUnit c
addMoney a b = ... -- align to finer denomination, sum Naturals, no Num instance

-- Kalecky.Types.Units.LaborUnit has its own addLabor, unrelated to addMoney.
-- moneyVal `addMoney` laborVal is a compile error simply because
-- laborVal :: LaborUnit b is not a MoneyUnit c — no GADTs/DataKinds needed for this part.
```
This is verified against basic Haskell nominal-typing semantics (HIGH confidence, no external source needed — this is how the type checker unifies argument types) and is the load-bearing simplification for the whole phase.

### Pattern 2: DataKinds phantom tag exactly where the requirement demands cross-value-of-same-type rejection
**What:** `Currency` and `Valuation` are cases where two *values that would otherwise be the same Haskell type* (e.g. two `MoneyUnit` values, one COP one USD) must be statically distinguished. This is what `DataKinds` phantom parameters are for.
**When to use:** `MoneyUnit (c :: Currency)`, `Price (v :: ValuationKind)` (or similar) — nowhere else in this phase.
**Example:**
```haskell
{-# LANGUAGE DataKinds, KindSignatures #-}
data Currency = COP | USD   -- promoted via DataKinds (already a default-extension)

newtype MoneyUnit (c :: Currency) = MoneyUnit (Denomination, Natural)

-- addMoney :: MoneyUnit c -> MoneyUnit c -> MoneyUnit c
-- unifies `c` across both arguments — COP+USD is then a compile error
-- because unification fails ('COP ~ 'USD is not derivable), not because
-- of any explicit type family or class constraint.
```
Source: standard DataKinds phantom-parameter pattern (Wikibooks "Haskell/GADT", HaskellWiki "GADTs for dummies" — MEDIUM confidence, general pattern knowledge cross-checked against two independent tutorial sources, not project-specific).

### Pattern 3: `Per`/`Times` as ordinary parametric types recover the "recursive EconomicUnit" Draft.plk wants
**What:** `data CompoundUnit a b = Per a b | Times a b` (or two separate types `newtype Per a b`, `newtype Times a b`, per UNIT-05's wording "Per/Times composition produces a correctly composed unit type" — either shape satisfies the requirement; a single `CompoundUnit` sum with two constructors most directly matches the stub note's `c(u,v) := ... ⊢ ρ|τ` derivation rule, which frames Per/Times as the two possible outcomes of one composition operation).
**When to use:** UNIT-02, UNIT-03 (`Price` is specifically a `Per`, never a `Times`), UNIT-05.
**Example:**
```haskell
-- Kalecky.Types.Units.CompoundUnit
data CompoundUnit a b
  = Per   a b   -- ρ: ratio connector
  | Times a b   -- τ: tensor connector

per, times :: a -> b -> CompoundUnit a b   -- named functions per CONTEXT.md's API surface decision
per   = Per
times = Times

-- a, b can themselves be CompoundUnit x y — ordinary Haskell polymorphic
-- recursion gives the recursive shape Draft.plk's comment (lines 99-107) wants,
-- with no promoted-kind machinery.
```
This directly satisfies Draft.plk's own stated preference ("desired: ... | Per EconomicUnit EconomicUnit | Times EconomicUnit EconomicUnit") without adopting its "closed-world dispatch" apology.

### Anti-Patterns to Avoid
- **A single promoted `EconomicUnit` kind enumerating every dimension:** re-derives Draft.plk's own regretted design ("This combinatorically scales too much and the function ends up being too responsible... I think is a recursive type") in Haskell form. The phase description explicitly flags over-engineering as a pitfall — this is the concrete shape that pitfall would take here.
- **A shared `Num` instance on any unit-kind newtype:** UNIT-04 explicitly forbids this ("no `Num` instance"); it would also silently permit `fromInteger`-based literal confusion across currencies if the phantom tag isn't threaded through correctly.
- **Storing `Scale` as `(base, exponent)` and re-deriving the factor on every operation without memoizing/caching:** not a correctness bug, but be aware `Natural ^ Natural` is computed, not looked up — for the small fixed exponents in this domain (0,3,6,9 for money; 1 for time) this is a non-issue, flagged only so a planner doesn't over-invest in a lookup-table micro-optimization that isn't needed.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|--------------|-----|
| Semigroup/Monoid law verification for `CompoundUnit`/`Unit` composition | Hand-written `associativity`/`identity` QuickCheck properties | `quickcheck-classes`' `semigroupLaws :: (Semigroup a, Eq a, Arbitrary a, Show a) => Proxy a -> Laws` wired into `tasty` via `testProperty` per law | Maintained, standard law set; PROOF-01 explicitly names `quickcheck-classes` as the mechanism "where applicable." Hand-rolling risks missing an edge case (e.g. forgetting to test associativity with three *different* concrete scale/denomination combinations, not just three equal ones). |
| `Natural` `Arbitrary` generation | A hand-rolled `Gen Natural` sized generator from scratch | `arbitrarySizedNatural :: Integral a => Gen a` (ships with `QuickCheck`, confirmed present in `QuickCheck-2.14.3`'s `Test.QuickCheck.Arbitrary` module) wrapped as `instance Arbitrary Natural where arbitrary = arbitrarySizedNatural` (needs a local orphan instance or a `newtype` wrapper, since `QuickCheck-2.14.3` does **not** ship a built-in `Arbitrary Natural` instance — verified absent from the module's instance list) | Correct, size-scaling generator already exists; reinventing it risks a biased/degenerate distribution (e.g. always generating 0, or never generating large amounts needed to exercise Million/Billion denominations). |
| "This expression must not typecheck" test infrastructure | A bespoke `TemplateHaskell`-based typecheck-and-catch harness | `should-not-typecheck` (if the team wants an automated in-suite assertion) or the excluded-source-file convention (recommended default) | `should-not-typecheck` already exists, is tiny (3 dependencies), and solves exactly this. Writing a custom TH-based harness for one phase's compile-fail tests would be a disproportionate investment relative to the two off-the-shelf options below. |

**Key insight:** Every "don't hand-roll" item above is small and already resolved by an existing, already-adjacent (same Stackage snapshot) library or a documented convention — this phase's actual novel work is the *domain type design* (Scale/Unit/CompoundUnit/Price shapes), not test-infrastructure plumbing.

## Common Pitfalls

### Pitfall 1: `-fdefer-type-errors` vs. the project's existing `-Werror` CI flag
**What goes wrong:** `should-not-typecheck`'s whole mechanism is turning a type error into a runtime-catchable warning via `-fdefer-type-errors`. `kalecky-spec.cabal`'s `common shared` stanza already sets `-Werror` when `flag(ci)` is enabled (verified directly, lines 53-56). Under `-Werror`, the deferred-type-error *warning* itself becomes a compile error — the test module would fail to build in CI even though it's working exactly as designed.
**Why it happens:** `-Werror` and `-fdefer-type-errors` are fundamentally in tension: one turns warnings into errors, the other turns errors into warnings, and CI runs with the former on.
**How to avoid:** Either (a) skip `should-not-typecheck` entirely and use the excluded-source-file convention (recommended default — verified zero-dependency, zero CI-flag interaction), or (b) if the team wants `should-not-typecheck` anyway, scope `-Wwarn=deferred-type-errors` (or disable `-Werror` specifically) on the one test module/component that hosts these assertions, and verify it explicitly under `cabal build --flags=ci` before relying on it.
**Warning signs:** A `should-not-typecheck`-based test module that builds fine locally (no `ci` flag) but breaks CI — this is the exact failure mode to check for if that path is chosen.

### Pitfall 2: Conflating "align to finer denomination" with "always divide-free" for every operation
**What goes wrong:** UNIT-06's exactness proof only holds for the *specific* alignment direction chosen (coarser→finer via multiplication). If a later operation (e.g. displaying an amount "in Millions" for a human-readable summary) implicitly does the reverse conversion (finer→coarser via division), that operation is **not** generally exact for arbitrary Natural amounts (e.g. 1,500,000 raw COP does not divide evenly into whole Millions) and must return `Maybe`/be explicitly partial, not silently truncate.
**Why it happens:** The locked rule ("align toward the finer denomination") is stated as the rule for arithmetic (`+`/`-`/alignment inside `Per`/`Times`), but is easy to misapply as a blanket "conversion is always exact" belief when a different operation (coarsening) is introduced later.
**How to avoid:** Scope UNIT-06's "exact, no rounding" guarantee explicitly to the finer-direction conversion in its own law/test; if any coarsening conversion is added in this phase (not currently required), give it its own `Maybe`-returning smart constructor and law (`toCoarser x = Just y` iff `x` is an exact multiple of the coarsening factor).
**Warning signs:** Any function typed `Unit -> Unit` (total, not `Maybe`) that converts toward a coarser denomination.

### Pitfall 3: Assuming `LaborUnit`/`TimeUnit` need the same `Currency`-style DataKinds treatment as `MoneyUnit`
**What goes wrong:** Reflexively promoting `LaborBasis`/`TimeBasis` to type-level tags "for consistency" with `MoneyUnit`'s `Currency` tag, when the actual requirement (UNIT-04) only names Money+labor cross-dimension and COP/USD same-dimension-different-currency as the two compile-fail cases. `LaborUnit` and `TimeUnit` are already distinct Haskell types from `MoneyUnit` and from each other (Pattern 1 above) — no further type-level machinery is needed for the *stated* requirements.
**Why it happens:** Pattern-matching on "MoneyUnit got a DataKinds tag" and assuming the same treatment must apply uniformly across all three unit kinds.
**How to avoid:** Only add a DataKinds tag where two values that would otherwise be indistinguishable at the type level must be rejected — that's a design decision to make explicitly per family, not a rule to apply uniformly. Whether `LaborBasis` (`Worker | LaborHour`) itself needs this treatment (should worker-count and labor-hours be additively incompatible, like COP/USD?) is an **open question**, not settled by REQUIREMENTS.md or CONTEXT.md — flag at the base-units increment's Stage 1 conversation.
**Warning signs:** A `LaborUnit (b :: LaborBasis)` phantom-tagged design being written before the user has confirmed Worker/LaborHour cross-addition should actually be rejected (as opposed to simply never being called, or being a legitimate operation the design hasn't needed yet).

## Code Examples

Verified patterns from official sources and direct project inspection:

### Semigroup law-checking via quickcheck-classes (pattern, not yet in codebase)
```haskell
-- Source: quickcheck-classes / Test.QuickCheck.Classes (Hackage docs, WebSearch-verified signature)
-- semigroupLaws :: (Semigroup a, Eq a, Arbitrary a, Show a) => Proxy a -> Laws
import Test.QuickCheck.Classes (semigroupLaws, lawsCheck)
import Data.Proxy (Proxy(..))

-- wiring one Laws value into a Tasty TestTree (adapter pattern; quickcheck-classes
-- ships Laws -> [(String, Property)] via `lawsProperties`, composed with `testProperty`)
```

### Natural exponentiation for Scale (pattern, matches existing Smoke.hs style exactly)
```haskell
-- Existing project precedent, Kalecky.Smoke (Phase 1 placeholder, to be superseded):
scaleFactor :: Integer -> Int -> Integer
scaleFactor b i
  | i < 0     = 0
  | otherwise = b ^ i

-- Phase 2 Scale (recommended): same shape, Natural-typed, hidden constructor,
-- smart constructor named `scale` per CONTEXT.md's locked bare-name convention:
newtype Scale = Scale Natural   -- hidden constructor

scale :: Natural -> Natural -> Scale
scale b i = Scale (b ^ i)
```
Source: `kalecky-spec/src/Kalecky/Smoke.hs` (direct project inspection — this is explicitly a Phase 1 placeholder "to be deleted or superseded when the co-designed Scale increment lands," but its arithmetic shape is the right template).

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|---------------|-------------------|---------------|--------|
| `Decimal`-backed amounts (`.planning/research/STACK.md`'s original recommendation) | `Natural`-backed amounts counting multiples of `tradeable_base` | Superseded by CONTEXT.md's locked decision, same day as the original stack research (2026-08-15) | Every REQUIREMENTS.md UNIT-01/03/06 wording referencing "Decimal" is stale; this phase's implementation must use `Numeric.Natural`, not `Data.Decimal`. `Decimal` remains a project dependency for other purposes (hevm) but should not be reached for in `Kalecky.Types.*` amounts. |
| Draft.plk's flat, closed-world `EconomicUnit` dispatch function (explicitly apologized for in its own comments) | Recursive `Per`/`Times`-parametrized types via ordinary Haskell polymorphism (this research's recommendation) | N/A — Draft.plk is Zig/comptime, not Haskell; the "current approach" here is a translation decision, not a library version change | Confirms the phase description's instruction to mirror Draft.plk's *scale/tradeable-base* semantics exactly while implementing the "desired" recursive sum type from its comment block, not its literal closed-world `if` chain. |

**Deprecated/outdated:** None at the library-version level for this phase — `QuickCheck-2.14.3`, `quickcheck-classes-0.6.5.0`, and GHC 9.8.4 are all current within the pinned `lts-23.28` snapshot with no newer-snapshot breaking changes identified during this research pass.

## Open Questions

1. **What is `HOUR_BASE` for `TimeUnit`'s `Hour` basis?**
   - What we know: `MONTH_BASE = 2,592,000` (seconds in a 30-day month) is given explicitly in both Draft.plk and CONTEXT.md. CONTEXT.md says TimeUnit needs "just Month and Hour bases so COP/month and COP/hour wages type-check" and separately notes "TimeUnit... second-denominated," but no `HOUR_BASE` constant appears anywhere in Draft.plk, the notes, or CONTEXT.md.
   - What's unclear: The natural candidate is `HOUR_BASE = 3600` (seconds in an hour — the literal SI second-denomination, and it divides `MONTH_BASE` exactly: 2,592,000 / 3,600 = 720, an exact integer, which would make Month↔Hour conversion exact under the same "align toward finer" rule if that conversion is ever needed).
   - Recommendation: Confirm `HOUR_BASE = 3600` explicitly at the TimeUnit increment's Stage 1 co-design conversation before drafting its Scale test/example — do not assume it silently.

2. **Does `LaborUnit` get a `Denomination` axis (like `MoneyUnit`'s `Currency`+`Denomination` pair), enabling "thousands of workers"?**
   - What we know: Draft.plk's literal code gives `LaborScale(Worker) = WORKER_BASE = 1` with no denomination parameter — `WorkerUnit = Unit(LaborScale, Worker)` takes only one basis argument. CONTEXT.md's prose separately says "thousands of workers and millions of hours use the same Scale machinery as money denominations," which reads as wanting `Denomination`-style scaling for Labor/Time too.
   - What's unclear: Whether this is a literal requirement to add a second `Denomination` parameter to `LaborUnit` (and by extension `TimeUnit`, contradicted by CONTEXT's separate "TimeUnit is minimal... just Month and Hour bases" framing which suggests Time does *not* get this) in Phase 2, or just a description of "the same kind of mechanism, not literally the same type parameter."
   - Recommendation: Resolve explicitly at the base-units increment's Stage 1 conversation. This directly affects `LaborUnit`'s arity/shape and should not be decided unilaterally during implementation — it changes whether "thousands of workers" round-trips through the same `denominationScale`/alignment code as money, or needs its own analogous-but-separate mechanism.

3. **What is `PriceIndex`?**
   - What we know: `Valuation = Nominal | Real PriceIndex` is stated in both the stub (`Valuation.hs`) and the notes, and UNIT-03 requires it threaded through `Price`'s type. No definition of `PriceIndex` (its representation, construction, or relationship to `Scale`/`Denomination`) appears anywhere in Draft.plk, the notes, or CONTEXT.md.
   - What's unclear: Whether `PriceIndex` is in-scope to define in Phase 2 at all (UNIT-03 only requires it be *threaded through the type*, which could mean a placeholder/abstract type is sufficient for Phase 2, with real construction deferred), or whether Phase 2 must give it a real Natural/Scale-backed representation.
   - Recommendation: Given Phase 2's success criteria list "Price with Valuation threaded through the type" (not "PriceIndex fully modeled"), the minimal-scope reading is: `PriceIndex` can be an opaque/minimal placeholder type in Phase 2 (e.g. `newtype PriceIndex = PriceIndex Natural`, unconstructed beyond that) sufficient to make `Real PriceIndex` type-check and be distinguishable from `Nominal`, with richer `PriceIndex` semantics deferred to whichever phase actually computes real wages (DOM-02, Phase 5). Confirm this scope reading at the Valuation/Price increment's Stage 1 conversation.

4. **Does the `s = h` alignment precondition in the `CompoundUnit` stub note apply across different unit kinds (Money vs Labor) or only within one kind (Money-Raw vs Money-Thousand)?**
   - What we know: UNIT-02's own wording ("auto-aligning mismatched scales by exact conversion to a common scale") and UNIT-06 (Money-only Million↔Thousand example) both describe alignment strictly within one currency/kind. The `CompoundUnit.hs` stub's derivation rule notation (`c(u_s(k), v_h(l)) := (s=h) ⊢ ρ|τ`) is ambiguous about whether it's a precondition on *composing* (forming `Per`/`Times`, which by design crosses kinds — e.g. `Wage = Per MoneyUnit LaborUnit`) or a precondition on *combining same-kind* operands.
   - What's unclear: If `s = h` is read as a strict precondition on every `per`/`times` call, `Wage` construction (Money per Labor) would be impossible, since Money's `Scale` (denomination-based) and Labor's `Scale` (basis-based) are never literally "the same scale" in any meaningful sense — this would contradict UNIT-03's requirement that Price/Wage be constructible at all.
   - Recommendation: The reading consistent with all locked requirements is that alignment applies only when composing/combining operands of the *same underlying kind and scale family* (e.g., two `MoneyUnit COP` values at different denominations); `per`/`times` across genuinely different kinds (Money, Labor) do not need or attempt alignment — they simply pair the two operand types. Confirm this reading explicitly at the CompoundUnit increment's Stage 1 conversation, since it determines whether `per`/`times` are total functions (recommended: yes) or need a `Maybe`/alignment-failure case.

5. **Should `Worker` and `LaborHour` (both constructors of `LaborBasis`) be additively incompatible, the way COP/USD are?**
   - What we know: UNIT-04 explicitly locks Money+Labor and COP+USD as compile-fail cases. It does not mention Worker+LaborHour.
   - What's unclear: Economically, adding a worker-count to a labor-hour-count is likely as meaningless as adding COP to USD, but this hasn't been stated as a requirement.
   - Recommendation: Flag at the base-units increment's Stage 1 conversation; if confirmed, `LaborBasis` needs the same DataKinds-phantom-tag treatment as `Currency` (Pattern 2 above) rather than being an ordinary field.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Tasty 1.5.x + tasty-quickcheck 0.11.1 + QuickCheck 2.14.3 (all already wired) |
| Config file | `kalecky-spec/kalecky-spec.cabal` — `test-suite kalecky-test` stanza (line ~434) |
| Quick run command | `cd kalecky-spec && cabal test kalecky-test` (proven ~10s loop, Phase 1 `01-VALIDATION.md`) |
| Full suite command | Same — Phase 2 has one test-suite target, no split between quick/full expected at this size |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|--------------------|--------------|
| UNIT-01 | `scale`, `moneyUnit`, per-basis smart constructors reject invalid input (Maybe), hidden constructors prevent bypass | unit/property | `cabal test kalecky-test` | ❌ Wave 0 — needs `test-kalecky/` modules per new `Kalecky.Types.*` module |
| UNIT-02 | `Per`/`Times`/`Unit` Semigroup laws hold; alignment on construction is exact | property (quickcheck-classes `semigroupLaws`) | `cabal test kalecky-test` | ❌ Wave 0 |
| UNIT-03 | `Price` constructs with `Nominal`/`Real PriceIndex`, both distinguishable at the type level | unit/example | `cabal test kalecky-test` | ❌ Wave 0 |
| UNIT-04 | Mismatched currency/dimension/valuation add/sub fails to compile | compile-fail (excluded-source-file or `should-not-typecheck`) | manual `ghc -c` invocation on excluded file (recommended) or in-suite `should-not-typecheck` assertion | ❌ Wave 0 — no such harness exists yet |
| UNIT-05 | `Per`/`Times` composed type is correct; dimensionless-ratio cancellation (if implemented this phase) | property/example | `cabal test kalecky-test` | ❌ Wave 0 — cancellation mechanism itself is not yet designed (see Pattern 3 caveats) |
| UNIT-06 | COP Million ↔ Thousand conversion is exact, no rounding | property (custom alignment-roundtrip law) + example (concrete COP figures) | `cabal test kalecky-test` | ❌ Wave 0 |
| PROOF-01 | Every shipped type in this phase has co-designed, approved QuickCheck laws | process requirement, verified by checkpoint transcript + test file presence, not a single automated command | N/A (process gate, checked per increment) | N/A |

### Sampling Rate
- **Per task commit:** `cd kalecky-spec && cabal test kalecky-test` (quick run, ~10s per Phase 1's proven loop)
- **Per wave/increment merge:** Same command — the suite is small enough in this phase that quick and full run are identical; revisit if the suite grows past ~30s
- **Phase gate:** Full suite green before `/gsd:verify-work`, plus explicit manual confirmation of at least one UNIT-04 compile-fail case (since a passing `cabal test` run does not, by itself, prove a *different* file fails to compile — that evidence must be captured separately, e.g. pasted `ghc` error output in the increment's checkpoint or `01`-style `VALIDATION.md`)

### Wave 0 Gaps
- [ ] `kalecky-spec/test-kalecky/Main.hs` needs new `testGroup`s per type as each increment lands (currently only `smoke`)
- [ ] `quickcheck-classes` needs adding to `build-depends` for `library kalecky` and `test-suite kalecky-test` in `kalecky-spec.cabal`
- [ ] `GADTs`, `DerivingStrategies`, `DerivingVia` need adding to `common shared`'s `default-extensions` in `kalecky-spec.cabal` (not yet present — verified by direct inspection; only `DuplicateRecordFields, LambdaCase, NoFieldSelectors, OverloadedRecordDot, OverloadedStrings, OverloadedLabels, RecordWildCards, TypeFamilies, ViewPatterns, DataKinds` are currently listed)
- [ ] An `Arbitrary Natural` instance (or a `newtype` wrapper with one) needs writing — not provided by `QuickCheck-2.14.3` — before any property test can generate Natural amounts/scales
- [ ] A decision-and-mechanism for compile-fail testing (excluded-source-file convention vs. `should-not-typecheck`) needs to be made and set up before UNIT-04's test can be drafted at its checkpoint
- [ ] `Currency.hs`, `Denomination.hs`, `TimeUnit.hs` — net-new modules with no existing stub, need creating and wiring into `library kalecky`'s `exposed-modules`

## Sources

### Primary (HIGH confidence)
- `/home/jmsbpp/learning/kalecky-semantics/kalecky-plank/Draft.plk` — direct inspection, canonical scale/tradeable-base/CompoundUnit design
- `/home/jmsbpp/learning/kalecky-semantics/notes/INCOME_DISTRIBUTION.md` — direct inspection, type-design dialogue and CASO PRUEBA scenarios
- `/home/jmsbpp/learning/kalecky-semantics/kalecky-spec/src/Kalecky/Types/**` — direct inspection of all 9 design-note stub files
- `/home/jmsbpp/learning/kalecky-semantics/kalecky-spec/kalecky-spec.cabal` — direct inspection of `common shared`, `library kalecky`, `test-suite kalecky-test` stanzas (confirmed current `default-extensions`, confirmed `-Werror` under `flag(ci)`, confirmed no `quickcheck-classes` dependency yet)
- `/home/jmsbpp/learning/kalecky-semantics/kalecky-spec/src/Kalecky/Smoke.hs` and `test-kalecky/Main.hs` — direct inspection, existing test-loop template
- `/home/jmsbpp/learning/kalecky-semantics/.planning/phases/02-numeric-dimensional-foundation/02-CONTEXT.md` — locked decisions, verbatim
- `/home/jmsbpp/learning/kalecky-semantics/.planning/REQUIREMENTS.md`, `.planning/STATE.md` — requirement wording and project history
- `/home/jmsbpp/learning/kalecky-semantics/.planning/research/STACK.md` — Phase 1-era stack research (GHC 9.8.4/`lts-23.28` facts, `quickcheck-classes` presence, GHC2021 extension gap analysis)
- Direct shell verification: `ghc --version` (9.10.3 default toolchain) and `cabal.project`'s `with-compiler: ghc-9.8.4` (project-pinned, confirmed installed via `ghcup list`)

### Secondary (MEDIUM confidence)
- `should-not-typecheck` package facts (version 2.1.0, dependency bounds) — WebFetch of Stackage package page, confirmed present in the current snapshot family but not disambiguated to `lts-23.28` specifically in the fetched excerpt
- `quickcheck-classes`' `semigroupLaws` signature — WebSearch-synthesized from Hackage documentation search results, not a direct WebFetch of the type signature page
- DataKinds phantom-type pattern (Pattern 2) — WebSearch synthesis of Wikibooks/HaskellWiki tutorial content, general Haskell knowledge cross-checked against two independent sources, not project-specific verification

### Tertiary (LOW confidence, flagged for validation)
- `HOUR_BASE = 3600` — not stated anywhere in the source material; this is a recommendation derived by analogy to `MONTH_BASE`'s seconds-denomination, not a verified fact. Flagged as Open Question 1.
- Whether `QuickCheck-2.14.3` truly lacks a built-in `Arbitrary Natural` instance — based on a WebFetch summary of the Hackage docs page rather than a full instance-list grep; worth a quick empirical check (`ghci> :i Natural` with QuickCheck imported, or attempt to compile `arbitrary :: Gen Natural` without a custom instance) at the start of implementation rather than trusted blindly.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all core/supporting libraries already resolve from the pinned `lts-23.28` snapshot per Phase 1's own research; no new external dependency risk beyond `should-not-typecheck` (conditional, not default)
- Architecture (type encoding): HIGH for the "nominal typing gives UNIT-04 mostly for free" insight (basic Haskell semantics, not exotic); MEDIUM for the specific DataKinds phantom-tag pattern (general tutorial-verified, not project-tested); LOW/open for the specific Labor-Denomination and cross-kind-alignment questions (genuinely underspecified in source material, correctly left open rather than asserted)
- Pitfalls: HIGH for the `-Werror`/`-fdefer-type-errors` conflict (verified directly against the project's own cabal file, not inferred)

**Research date:** 2026-08-15
**Valid until:** ~30 days for library/version facts (stable Stackage snapshot); the open design questions (Sections 1-5 under "Open Questions") do not expire — they need explicit resolution during planning/execution regardless of elapsed time
