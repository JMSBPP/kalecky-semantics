# Stack Research

**Domain:** Dimensionally-typed, algebraically-lawful economic modeling library (Haskell, inside an existing hevm fork package)
**Researched:** 2026-08-15
**Confidence:** HIGH (versions verified live against the actual LTS-23.28 Stackage snapshot; extension semantics verified against the GHC2021 proposal spec)

## Context Established Before Recommending Anything

The package already exists and is pinned: `kalecky-spec/stack.yaml` resolves `lts-23.28` (**GHC 9.8.4**, verified via Stackage snapshot page). `kalecky-spec.cabal`'s `common shared` stanza already sets:

```
default-language: GHC2021
default-extensions:
  DuplicateRecordFields, LambdaCase, NoFieldSelectors, OverloadedRecordDot,
  OverloadedStrings, OverloadedLabels, RecordWildCards, TypeFamilies,
  ViewPatterns, DataKinds
```

Everything below is scoped to **add to this existing foundation**, not replace it. All Kalecky draft modules (`kalecky-spec/src/Kalecky/**`) are currently comment-only stubs with broken import capitalization (`Kalecky.types.Units.Unit` vs `Kalecky.Types.Units.Unit`) — this needs fixing as part of implementation, not stack research, but it means there is no existing code the stack choices need to be backward-compatible with.

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| GHC | 9.8.4 (via `lts-23.28`) | Compiler | Already pinned by `kalecky-spec/stack.yaml`; not a choice, a constraint. All extension/library recommendations below are checked against it. |
| GHC2021 language edition | — | Extension baseline | Already the package's `default-language`. Verified (GHC proposal #0380) it already provides `MultiParamTypeClasses`, `FlexibleInstances`, `FlexibleContexts`, `RankNTypes`, `PolyKinds`, `TypeApplications`, `KindSignatures`, `StandaloneKindSignatures`, `GADTSyntax`, `ExistentialQuantification`, `TypeOperators`, `ConstraintKinds`, `ScopedTypeVariables`, `GeneralisedNewtypeDeriving`, `StandaloneDeriving`. This is why the type designs in `notes/INCOME_DISTRIBUTION.md` (multi-param type constructors like `Expectation agent x`, `Effect responder perturband`) need almost no new extensions to *declare* — only to fully exploit (see extensions table below). |
| `Decimal` | 0.5.2 (already bounded `>=0.5.1 && <0.6` in `kalecky-spec.cabal`) | Exact decimal arithmetic for the `Number`/money-amount representation underlying `EconomicQuantity`, `Effect`, `GrowthRate` | Already a transitive dependency of hevm's own codebase (used for `Decimal`-typed values). Reuse it as the numeric backbone for economic quantities instead of `Double`: money/wage amounts (COP, USD, growth rates in basis points) must not accumulate float error, and `Decimal` gives exact base-10 arithmetic with an explicit precision/rounding story — critical for the CASO PRUEBA scenarios (`5% -> 5.20%`, `10 -> 12` COP/hour) which are stated as exact decimal figures, not approximations. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `quickcheck-classes` | 0.6.5.0 (confirmed present in `lts-23.28`; depends on `QuickCheck >=2.10`, no upper bound — compatible with the package's existing `QuickCheck >=2.13.2 && <2.16` bound and the snapshot's pinned `QuickCheck-2.14.3`) | Off-the-shelf law-checkers (`semigroupLaws`, `monoidLaws`, `eqLaws`, `ordLaws`, `showReadLaws`, `commutativeSemigroupLaws`, etc.) wired directly into a `TestTree` | Use for every algebraic newtype the spec defines with implicit laws: `Gap` (orientation makes it *not* commutative — good, `commutativeSemigroupLaws` should *fail*, which is itself a regression test that the orientation-preservation property holds), `Effect`/`GrowthRate`/`Number`-wrapping newtypes once they get `Num`/`Semigroup` instances, and `CommonGrowthRate`'s `Maybe`-returning smart constructor (`eqLaws`/`ordLaws` on the `Maybe` result). This directly serves the roadmap requirement "properties + example tests co-designed per increment" — it replaces hand-written `associativity`/`identity` QuickCheck properties with maintained, standard ones. |
| `tasty-quickcheck` | 0.11.1 (already in `test-suite test`'s `build-depends`; requires `tasty >=1.5 && <1.6`, satisfied) | Wires QuickCheck properties (including `quickcheck-classes`' `Laws` values) into the existing Tasty tree | Already present; the only change needed is exposing a new test-suite (or test module) for `Kalecky.*` types alongside the existing hevm `EVM.*` test modules. `quickcheck-classes` ships a small adapter pattern (`Laws -> TestTree` via `testProperty` per law) that composes directly with `tasty`. |
| `refined` | 0.8.2 (confirmed present in `lts-23.28`) | Predicate-refined types (e.g. enforce `Bounds{min,max}` at the type level) | **Optional, do not adopt yet.** The spec's own design for bounded/partial construction is a `Maybe`-returning smart constructor (`mkCommonGrowthRate :: GrowthRate a -> GrowthRate b -> Maybe (CommonGrowthRate a b)`), which is simpler, has zero extra dependency surface, and matches the project's stated preference for explicit algebraic types over generic refinement-type machinery. Reconsider only if `Bounds` constraints need to compose across many types (e.g. a `Positive Number` predicate reused in a dozen unrelated modules) — at that point `refined`'s `Refined p x` avoids re-deriving smart-constructor boilerplate everywhere. |
| `deriving-compat` | 0.6.7 (confirmed present in `lts-23.28`) | Backport of `DeriveFoldable`/`DeriveFunctor`-style TH derivers for one-off cases stock deriving can't reach | Low priority — GHC2021 already ships `DeriveFunctor`/`DeriveFoldable`/`DeriveTraversable`/`DeriveGeneric` natively; only reach for this if a specific newtype-wrapped GADT needs a derived instance stock/GND can't produce. Don't add preemptively. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| HLS (Haskell Language Server) | Editor support, already listed in the codebase's stack map | No change needed; confirm `kalecky-spec/hie.yaml` picks up new `Kalecky.*` modules once they're added to `exposed-modules`/`other-modules` in the cabal file. |
| HLint (`.hlint.yaml` already present) | Linting | Extend with a rule discouraging bare `Double` in new `Kalecky.*` modules (steer contributors toward `Decimal`), since HLint custom rules can flag specific type usage patterns. |
| `cabal-fmt` / `stylish-haskell` (not currently in repo) | Formatting for new modules | Optional — not currently configured anywhere in the repo (confirmed no `.stylish-haskell.yaml` present); skip unless the user wants formatting consistency enforced from day one. |

## GHC Extensions the Type Designs in `notes/INCOME_DISTRIBUTION.md` Require

Cross-checked against GHC2021's actual extension list (GHC proposal #0380) — GHC2021 does **not** include `DataKinds`, `GADTs` (only `GADTSyntax`), `DerivingVia`, `DerivingStrategies`, or `UndecidableInstances`.

| Extension | Already have? | Needed for | Tradeoff |
|-----------|---------------|-------------|----------|
| `DataKinds` | Yes (explicit in `kalecky-spec.cabal`) | Promoting `Agent` (`Household \| Firm \| Government \| FinancialSector`), `ConflictKind`, `Currency` (`COP \| USD`), `LaborBasis` (`Worker \| LaborHour`), `ValuationKind` to the type level so `Expectation agentA x`, `ExpectationsConflict agentA agentB x`, `EconomicQuantity valuation unit`, `NominalWage :: EconomicQuantity Nominal (CompoundUnit MoneyUnit LaborUnit)` are compile-time distinguishable — this is the mechanism that makes "ill-formed economics must not type-check" (PROJECT.md's Core Value) enforceable. | None significant; already adopted project-wide. |
| `GADTs` (full, not just `GADTSyntax`) | **No — GHC2021 only gives `GADTSyntax`, which allows the `where`-syntax but not type refinement on pattern match.** | `Valuation = Nominal \| Real PriceIndex` needs the `Real` constructor to *carry* a `PriceIndex` only when the phantom valuation tag is `'RealK`, and `CompoundUnit numerator denominator = Per numerator denominator \| Times a b` benefits from GADT-style return-type refinement so pattern-matching on `Per`/`Times` narrows what the caller knows about the unit shape. `GADTSyntax` alone (already in GHC2021) lets you *write* `data Foo where ...` but every constructor still returns the same, unrefined type — it cannot express "this constructor is only inhabited when the phantom parameter equals X". **Add `GADTs` explicitly to `default-extensions`.** | Slightly increases what HLint/reviewers need to understand about pattern-match exhaustiveness with equality constraints; negligible cost for the payoff of encoding valuation/unit correctness in constructors rather than smart-constructor discipline alone. |
| `DerivingStrategies` + `DerivingVia` | No (neither is in GHC2021) | The design is newtype-heavy by explicit decision ("Effect is a newtype over Number; refinements add semantics not data" — Key Decision in PROJECT.md): `Effect`, `ResponseMultiplier`, `Elasticity`, `Indexation`, `GrowthRate`, `NetDistributionalEffect` are all `newtype`s wrapping either `Number`/`Decimal` or another `Effect`. `DerivingVia` lets each of these derive `Num`/`Eq`/`Ord` *through* the wrapped `Decimal` explicitly (`deriving (Num) via Decimal`) instead of relying on `GeneralizedNewtypeDeriving`'s implicit coercion, which is easy to get right once but easy to silently break if the newtype's representation changes. `DerivingStrategies` disambiguates when both GND and stock deriving are in scope for the same class, which will happen constantly with this many stacked newtypes. | Purely additive safety; no known downside on GHC 9.8.4. **Add both explicitly.** |
| `UndecidableInstances` | No | Flag as **likely, not certain**, needed once `CompoundUnit`'s type family for unit simplification/reduction (e.g. a closed type family computing what `Per (Per a b) c` reduces to) is written — GHC's termination checker frequently rejects otherwise-terminating type family instances involving nested type constructors without this pragma. | **MEDIUM confidence — do not add preemptively.** Add only when the compiler actually demands it for a specific `TypeFamilies` instance; adding it blindly can mask genuinely non-terminating type-level computation, which matters more here than in a typical project because "ill-formed economics must not type-check" depends on the type checker actually terminating with a rejection, not looping or accepting nonsense. |
| `TypeFamilies` | Yes (explicit) | Already adopted; needed for `CompoundUnit`'s numerator/denominator algebra and for any `Ratio`/`Normalization` type-level division (`Normalization perturband responder` representing `perturband / responder`). | None; already adopted. |
| `PolyKinds`, `KindSignatures`, `StandaloneKindSignatures`, `TypeOperators`, `RankNTypes`, `MultiParamTypeClasses`, `FlexibleInstances`/`FlexibleContexts`, `ScopedTypeVariables`, `TypeApplications` | Yes (all via GHC2021) | Multi-parameter type constructors (`Effect responder perturband`, `Expectation agent x`, `Normalization numerator denominator`), kind-polymorphic phantom parameters, and explicit type application in smart constructors (`mkCommonGrowthRate @a @b`). | None; free from the existing GHC2021 baseline — this is precisely why GHC2021 was a good baseline choice for this kind of type-level-heavy library, worth stating explicitly for the roadmap since it removes a whole category of "do we need extension X" churn per phase. |

## Installation

```bash
# From kalecky-spec/kalecky-spec.cabal, add to the `library` build-depends list
# (versions match what's already pinned by lts-23.28; no extra-deps entries needed
# since all of these resolve from the Stackage snapshot already in stack.yaml):

  quickcheck-classes                >= 0.6.5   && < 0.7,

# Add to `common shared`'s default-extensions in kalecky-spec.cabal:
#   GADTs
#   DerivingStrategies
#   DerivingVia
# (UndecidableInstances: add later, only when a specific type family instance requires it)
```

No new `stack.yaml` `extra-deps` entries are required — `quickcheck-classes-0.6.5.0`, `refined-0.8.2`, and `deriving-compat-0.6.7` all resolve directly from the `lts-23.28` snapshot already pinned in `kalecky-spec/stack.yaml`. `Decimal` is already an active dependency; no version bump needed.

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|--------------------------|
| Hand-rolled type-level unit system (`DataKinds` + `GADTs` + `TypeFamilies`, following the `CompoundUnit`/`EconomicQuantity` shapes already sketched in `notes/INCOME_DISTRIBUTION.md`) | `units` package (`units-2.4.1.5`, confirmed present in `lts-23.28`) | Only if the project later needs a *general-purpose*, arbitrarily-extensible dimensional system reused across many unrelated dimension sets. `units` genuinely supports custom, non-SI dimensions (verified: "units and dimensions defined are fully extensible, and need not relate to physical properties" per its Hackage docs) unlike `dimensional`. But its last real code release was January 2022 (tested only up to GHC 9.2.1 per its own docs, with only a metadata-bump revision in 2024), and it leans on Template Haskell/singleton-style machinery for its extensibility — heavy compile-time cost and an extra abstraction layer for a system that here only needs ~3 base dimensions (Money, Labor, Time) plus a project-specific `Valuation` (Nominal/Real) axis that no generic physical-units library models anyway. |
| Same (hand-rolled) | `dimensional` package (`dimensional-1.6.1`, confirmed present in `lts-23.28`) | Never, for this project. Verified its `Dimension` type is `data Dimension = Dim TypeInt TypeInt TypeInt TypeInt TypeInt TypeInt TypeInt` — a **fixed 7-slot SI base-dimension vector** (length, mass, time, current, temperature, amount, luminosity). It is not extensible to arbitrary custom base dimensions like "Money" or "Labor" without modifying the library itself. It's the wrong tool: this project isn't doing physical-unit dimensional analysis, it's doing *economic* dimensional analysis with a semantic `Valuation` axis (Nominal vs Real-relative-to-a-PriceIndex) that has no physical analogue. |
| `Decimal` (already a dependency) for the `Number`/amount type | `scientific` (already a transitive dependency via `aeson`) | If arbitrary-precision floating display/serialization matters more than exact decimal arithmetic semantics — e.g. if `Number` values need to round-trip through JSON with `aeson` frequently. Not the primary need here (internal algebra dominates); keep `Decimal` as the base type and add `scientific`-based `ToJSON`/`FromJSON` conversions only if/when a serialization boundary is actually built. |
| Maybe-returning smart constructors (already the notes' own design, e.g. `mkCommonGrowthRate`) | `refined` (`refined-0.8.2`) | If bound/predicate checks (e.g. `Bounds{min,max}`) end up duplicated across many unrelated types instead of being local to 1-2 constructors — `refined`'s `Refined p x` centralizes that logic. Premature to adopt now. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|--------------|
| `dimensional` (or any SI-base-dimension library) as the foundation for `CompoundUnit`/`EconomicQuantity` | Verified its dimension representation is hardcoded to 7 SI base dimensions; cannot express Money/Labor/Time/Valuation without forking the library. Adopting it would mean fighting the library's own type family closed-instance set rather than encoding the economics. | The project's own `CompoundUnit numerator denominator = Per numerator denominator \| Times a b` + `EconomicQuantity <valuation, unit>` design, already sketched in `notes/INCOME_DISTRIBUTION.md`, implemented with `DataKinds`/`GADTs`/`TypeFamilies`. |
| `units`/`units-defs` for the same reason plus staleness | Fully extensible in principle, but stale (real code frozen since Jan 2022, tested only to GHC 9.2.1) and pulls in TH/singleton-style machinery disproportionate to a 3-dimension economic type system. Adding a barely-maintained, heavy dependency to a research artifact whose whole point is legibility of the type hierarchy (PROJECT.md: "the type hierarchy itself is the deliverable") works against the goal. | Same as above — hand-rolled, small, legible. |
| `singletons` (TH-based type/term reflection library) | Not needed: the only place term-level reflection of a type-level tag would come up is recovering e.g. `Agent` from `Expectation agent x`, which is solvable with a small hand-written typeclass (`class KnownAgent agent where agentVal :: Proxy agent -> Agent`) in the same spirit as `base`'s own `KnownSymbol`/`KnownNat`. `singletons`' TH code generation is a large compile-time and complexity cost for one or two reflection points. | Hand-written `KnownX`-style typeclasses (pattern already established in `base`, no new dependency). |
| `groups` / `semigroupoids` (abstract-algebra typeclass hierarchies: `Group`, `Groupoid`, etc.) | The design language explicitly separates "algebraic structures that know no economics" (`Gap`, `Effect`) from "semantic refinements that carry the economics" (`Conflict`, `ResponseMultiplier`, `Indexation`) — but this is expressed as *concrete newtypes with hand-written operations* (`Gap`'s `positiveTerm`/`negativeTerm`, orientation-preserving so explicitly **not** commutative), not as instances of a generic `Group` typeclass. Forcing `Gap`/`Effect` into `groups`' abstractions would fight the orientation-preservation property the spec calls out as load-bearing (`a - b ≠ b - a`), since generic group laws assume commutativity/invertibility that don't hold here by design. | Hand-written `Semigroup`/custom operations per type, law-tested individually with `quickcheck-classes` (which lets you test *only* the laws that should hold, e.g. skip `commutativeSemigroupLaws` for `Gap` on purpose). |
| Bare `Double` for any `Number`/money/growth-rate representation | Standard float-accumulation-error pitfall, made concrete by this project's own CASO PRUEBA test scenarios which use exact decimal figures (`20000 COP/hour`, `10 -> 12`, `5% -> 5.20%`) — `Double` arithmetic risks these tests becoming flaky or requiring epsilon-comparisons that mask real bugs in the type-level algebra. | `Decimal` (already a pinned dependency, `>=0.5.1 && <0.6`). |
| LiquidHaskell or other refinement-type/SMT-backed verification layered on top of the Haskell types | Out of scope per PROJECT.md itself ("Lean/EvmYul proofs of Kalecky semantics — inherited infrastructure, not part of this milestone") and per the Constraints section ("v1 is pure Haskell... test-first"). It would also duplicate effort: the repo already has a Lean 4 formal-verification track (`EvmYul/`) and hevm's own SMT bridge (Z3/cvc5/Bitwuzla via `kalecky-spec/flake.nix`) is explicitly deferred ("once the types mature" — Context section of PROJECT.md). Introducing LiquidHaskell now would open a second, premature verification front before the type-and-test discipline this milestone is scoped to even exists. | QuickCheck properties + `quickcheck-classes` law-checking + Tasty example tests (CASO PRUEBA scenarios), exactly as PROJECT.md's Key Decisions table specifies ("Properties + examples per increment"). |

## Stack Patterns by Variant

**If a new test-suite is added for `Kalecky.*` types (recommended, rather than folding into the existing `test-suite test` which is organized around `EVM.*` modules):**
- Add a `test-suite kalecky-test` stanza to `kalecky-spec.cabal`, `import: test-common`, with its own `main-is` and `other-modules` listing only `Kalecky.*` test modules.
- Because: keeps the hevm test suite's build graph and runtime untouched while iterating on Kalecky types, and matches the project's own "one type per increment" process — each increment's test-suite additions stay scoped to the type being added that increment.

**If/when `EconomicQuantity`'s `amount` field needs to round-trip through JSON (e.g. for a future CLI or Plank bridge):**
- Use `aeson` (already a dependency, `>=2.0.0 && < 2.3`) with a manual `ToJSON`/`FromJSON` for `Decimal`-backed `Number`, not `scientific`'s automatic instances directly on the wrapped type.
- Because: automatic `Decimal <-> scientific` conversions can silently lose or misrepresent precision at serialization boundaries; a manual instance makes the precision/rounding policy an explicit, reviewable decision rather than a library default.

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|------------------|-------|
| `quickcheck-classes-0.6.5.0` | `QuickCheck-2.14.3` (pinned by `lts-23.28`), and `kalecky-spec.cabal`'s existing `QuickCheck >=2.13.2 && <2.16` bound | `quickcheck-classes` only requires `QuickCheck >=2.10`, no upper bound — no conflict. Verified both package pages live against `lts-23.28`. |
| `tasty-quickcheck-0.11.1` | `tasty >=1.5 && <1.6` | Already satisfied by the existing `test-suite test` dependency graph; adding `quickcheck-classes`-derived `TestTree`s doesn't change this. |
| `Decimal-0.5.2` | `kalecky-spec.cabal`'s existing `Decimal >=0.5.1 && <0.6` bound | Exact match, no change needed. |
| `dimensional-1.6.1` / `units-2.4.1.5` | N/A (not recommended for adoption) | Both confirmed present in `lts-23.28` and would resolve without conflict if ever adopted later, but rejected on design-fit and (for `units`) staleness grounds above — this is a fit problem, not a version problem. |
| GHC2021 + `GADTs` + `DerivingVia` + `DerivingStrategies` | GHC 9.8.4 | All four extensions are long-stable in GHC by 9.8; no known interaction issues with the other `default-extensions` already in `common shared` (`DuplicateRecordFields`, `NoFieldSelectors`, `OverloadedRecordDot` interact with GADT record syntax without conflict — these are orthogonal feature areas). |

## Sources

- `https://www.stackage.org/lts-23.28` — confirmed GHC 9.8.4, `Decimal-0.5.2`, `containers-0.6.8`, `dimensional-1.6.1`, `deriving-compat-0.6.7` (HIGH confidence, live snapshot fetch)
- `https://www.stackage.org/lts-23.28/package/quickcheck-classes` — confirmed `quickcheck-classes-0.6.5.0` present in this exact snapshot (HIGH confidence, live HTML fetch, grepped version string)
- `https://www.stackage.org/lts-23.28/package/QuickCheck` — confirmed pinned `QuickCheck-2.14.3` (HIGH confidence)
- `https://www.stackage.org/lts-23.28/package/tasty-quickcheck` — confirmed `tasty-quickcheck-0.11.1`, `tasty >=1.5 && <1.6` (HIGH confidence)
- `https://www.stackage.org/lts-23.28/package/{groups,semigroupoids,refined,newtype-generics,exact-pi,numtype-dk,units,units-defs}` — confirmed presence/versions via live fetch (HIGH confidence)
- `https://hackage.haskell.org/package/dimensional-1.6.1/docs/Numeric-Units-Dimensional.html` — confirmed fixed 7-slot SI `Dimension` type, not extensible to custom base dimensions (HIGH confidence, official docs)
- `https://hackage.haskell.org/package/units` — confirmed extensibility to custom dimensions, confirmed last real release Jan 2022 / tested to GHC 9.2.1 (MEDIUM-HIGH confidence, official Hackage page)
- GHC Proposal #0380 (GHC2021) — confirmed exact extension set included in GHC2021 vs. what needs explicit opt-in (`DataKinds`, `GADTs`, `DerivingVia`, `DerivingStrategies`, `UndecidableInstances` all absent from GHC2021 baseline) (HIGH confidence, official GHC proposal text via WebSearch synthesis, cross-checked against `ghc-proposals.readthedocs.io`)
- `/home/jmsbpp/learning/kalecky-semantics/kalecky-spec/kalecky-spec.cabal`, `kalecky-spec/stack.yaml` — direct inspection of pinned resolver and existing `default-extensions`/`build-depends` (HIGH confidence, primary source)
- `/home/jmsbpp/learning/kalecky-semantics/notes/INCOME_DISTRIBUTION.md` — direct inspection of the type-design dialogue driving extension/library requirements (HIGH confidence, primary source)

---
*Stack research for: Kalecky income-distribution type system (Haskell, inside `kalecky-spec`)*
*Researched: 2026-08-15*
