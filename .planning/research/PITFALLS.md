# Pitfalls Research

**Domain:** Typed economic-semantics library in Haskell — dimensional analysis + algebraic types for Kaleckian income distribution, built incrementally inside an existing 2000+ file hevm fork
**Researched:** 2026-08-15
**Confidence:** MEDIUM-HIGH (Haskell type-level and dimensional-analysis pitfalls are well-documented via Hackage/community sources; economics-specific type-design pitfalls are inferred from `notes/INCOME_DISTRIBUTION.md` and general economic-software post-mortems, so treat those as MEDIUM)

## Critical Pitfalls

### Pitfall 1: Num instance abuse on dimensioned quantities

**What goes wrong:**
`EconomicQuantity`, `NominalWage`, `RealWage`, `Gap x`, etc. get a `Num` instance "for convenience" so `+`/`-`/`*` work out of the box. This silently allows `NominalWage + LaborProductivity` to typecheck (both reduce to the same underlying `Number`), defeats the entire purpose of the dimensional type system, and forces nonsensical methods (`abs`, `signum`, `fromInteger`, `negate`) on quantities where they are economically meaningless (what is `signum` of a wage gap, or `fromInteger 5 :: NominalWage` — 5 what, in what currency?).

**Why it happens:**
`Num` is the path of least resistance in Haskell — deriving it or writing a quick instance makes `+`/`*` "just work" and avoids writing `addWage`, `gapDifference`, etc. It's especially tempting under time pressure to make CASO PRUEBA arithmetic (10 → 12 units, 5% → 5.20%) "look like normal math."

**How to avoid:**
- Never give `EconomicQuantity`, `Gap`, `Effect`, or any unit-carrying newtype a `Num` instance. Define named operations instead: `addQuantity :: EconomicQuantity v u -> EconomicQuantity v u -> EconomicQuantity v u` (same valuation/unit only), `scaleQuantity :: Number -> EconomicQuantity v u -> EconomicQuantity v u`.
- If ergonomic `+`/`*` syntax is wanted, define a project-local `VectorSpace`/`AdditiveGroup`-style class (following the `dimensional`/`units` package precedent — see Sources) with typed multiplication that changes units/dimension rather than a `Num` instance that collapses them.
- `Effect responder perturband` is dimensionally a derivative (`d responder / d perturband`) — multiplying an `Effect` by a `perturband` value must return a `responder`, not the same type; this is exactly the composition rule the end-goal wage equation depends on and cannot be expressed through `Num`.

**Warning signs:**
- Any `instance Num (EconomicQuantity ...)`, `deriving (Num)`, or `newtype ... deriving newtype (Num)` on a semantic type.
- Code that adds two `Gap` or `Effect` values of different `x`/`responder`/`perturband` type parameters and it compiles.
- Reviewer asks "what does `negate` mean here?" and there's no good answer.

**Phase to address:**
Phase covering `EconomicQuantity`/dimensional foundation (first active increment) — decide the arithmetic interface before any later type (Gap, Effect, Conflict) is built on top of it, since all of them compose via arithmetic on quantities.

---

### Pitfall 2: Orientation/sign errors in `Gap` semantics

**What goes wrong:**
`notes/INCOME_DISTRIBUTION.md` explicitly resolves this design question — `Gap` must preserve orientation (`positiveTerm`/`negativeTerm`, since `a − b ≠ b − a`) because household and firm expectation gaps have opposite sign conventions in the wage equation. A naive symmetric `Gap { lhs :: x, rhs :: x }` with an `evalGap` that just does `lhs - rhs` looks correct in isolation but silently produces the wrong sign when composed into `ResponseMultiplier * Gap` for the firm case vs. the household case, because nothing in the type distinguishes "gap oriented as household-minus-realized" from "gap oriented as realized-minus-firm."

**Why it happens:**
Orientation bugs are invisible at the type level if `Gap` is just a pair — both fields have type `x`, so swapping them still typechecks. The bug only shows up as a wrong numeric sign in a downstream test, often several types removed from where the mistake was introduced (in `ExpectationsConflict`, `DistributionalConflict`, or the final wage equation).

**How to avoid:**
- Keep the `positiveTerm`/`negativeTerm` field names from the notes (not `lhs`/`rhs`) so every call site states the orientation explicitly and reviewers can check it against the economics.
- Write the CASO PRUEBA / QuickCheck laws for `Gap` around orientation itself, not just magnitude: `evalGap (Gap a b) == negate (evalGap (Gap b a))`, and a targeted example test asserting `evalGap (householdRealWageExpectationGap ...)` has the sign matching the household case from the notes (positive when expectation exceeds realized) while the firm case has the opposite sign.
- When building smart constructors (`householdRealWageExpectationGap`, future firm equivalent), bake the correct orientation into the constructor name/type rather than leaving orientation to be supplied positionally at each call site.

**Warning signs:**
- A `Gap` constructor called with plain tuples/positional args rather than named smart constructors.
- Tests that check `abs (evalGap g) == expected` instead of `evalGap g == expected` (masking sign bugs by taking absolute value).
- Two different economic scenarios (household vs. firm gap) reusing the exact same constructor call pattern without a type or name distinguishing them.

**Phase to address:**
`Gap` increment (per the roadmap's "one type per increment" plan) — must be the first thing tested, before `Conflict` or `Effect` are built on it, since orientation bugs propagate silently through every refinement layered on `Gap`.

---

### Pitfall 3: Percentage-points vs. basis-points vs. ratio confusion (the CASO PRUEBA cases)

**What goes wrong:**
The three worked examples in `notes/INCOME_DISTRIBUTION.md` are deliberately chosen to stress this: Nivel→Nivel (COP/hour, a level), Nivel→Tasa ("+20 puntos porcentuales" describing a nominal wage that moved 10→12, i.e., +20% relative growth, which happens to equal +20pp only because the base is 100-normalized informally), and Tasa→Tasa ("+20 puntos básicos", a growth rate moving 5%→5.20%, i.e., +0.20pp = +20bp). It is very easy to build a single `GrowthRate` or `Number` type that conflates: (a) a raw ratio (0.05), (b) a percentage (5), (c) a percentage-point delta (0.20 pp), and (d) a basis-point delta (20 bp = 0.0020 in ratio terms). Mixing these — e.g., computing `5.20 - 5 = 0.20` and reporting "20 basis points" without the ×100 conversion, or adding a percentage-point delta to a ratio-typed growth rate — is a real-world catastrophic-magnitude bug class (confusing bp and pp is off by 100x, per financial industry convention).

**Why it happens:**
Colloquial Spanish/English economic prose ("20 puntos porcentuales", "20 puntos básicos") uses natural language that doesn't distinguish the underlying numeric representation; if `Number` is a bare `Double`/`Rational` with no unit tag, the type system provides zero protection, and translating prose into test fixtures is exactly where the ×100 or ÷100 slip happens.

**How to avoid:**
- Introduce a distinct type (or phantom-tagged `Scale`, per the notes' own `Scale`/`Bounds` sketch) for ratio (0–1 range, dimensionless), percentage (ratio×100), percentage-point delta (difference of two percentages, same unit as percentage but semantically a *delta*, not a level), and basis-point delta (percentage-point×100). Do not let `GrowthRate` silently coerce between these — require explicit conversion functions (`toBasisPoints`, `fromPercentagePoints`) with names that make the ×100/÷100 direction unambiguous in the call site.
- Write each CASO PRUEBA as a literal example test asserting the *exact* numeric conversion, not just "compiles" — e.g., `GrowthRate 5.0% → GrowthRate 5.20% ⇒ delta == 20 basis points == 0.20 percentage points == 0.0020 ratio`, and assert all three representations agree.
- Treat "Nivel→Tasa" (level compared across time expressed as a growth rate) as a genuinely different operation from "Tasa→Tasa" (rate compared to rate, i.e., a second-order acceleration) — do not reuse the same `GrowthRate` combinator for both without checking the CASO PRUEBA prose maps to the right one.

**Warning signs:**
- A single unlabeled `Double` flowing through code that is described in comments/docs as "5%", "20 basis points", and "0.20" interchangeably.
- Test fixtures where the expected value was computed by eyeballing the prose rather than an explicit unit-conversion function with a name.
- Any place a growth-rate *delta* (pp/bp) and a growth-rate *level* (%) share the same type with no distinguishing wrapper.

**Phase to address:**
`GrowthRate`/`Scale` foundation increment and the CASO PRUEBA test-writing increment specifically called out in `.planning/PROJECT.md` — this pitfall is the whole reason those three scenarios were chosen as test cases, so the roadmap phase that implements CASO PRUEBA must include example tests (not just properties) that pin the exact cross-representation numbers.

---

### Pitfall 4: Type-level programming over-engineering before value delivery (DataKinds/TypeFamilies explosion)

**What goes wrong:**
The temptation, once `EconomicQuantity <valuation, unit>` exists, is to push dimensional correctness fully into the type level — promoting `CompoundUnit`, `Currency`, `Scale` to kinds via `DataKinds`, writing type families to compute compound unit arithmetic (`Per MoneyUnit LaborUnit` divided by `Per MoneyUnit LaborUnit` should reduce to a dimensionless type, etc.), and chasing full type-level unit algebra (as in Haskell's `units`/`dimensional` packages) before the wage equation — the actual v1 deliverable — is expressed. This produces GHC error messages that are unreadable, long compile times (compounding the existing `kalecky-spec` 2000+ file build burden), and stalls the "one type per increment, test-approved" process because a single "type" (e.g. `EconomicQuantity`) balloons into weeks of type-family plumbing.

**Why it happens:**
Haskell rewards this kind of engineering — it's genuinely satisfying to make the compiler reject `NominalWage / LaborProductivity` mismatches — and the domain (dimensional analysis) has well-known heavyweight prior art (`dimensional`, `units`, `uom-plugin`) that makes "just do it properly with type families" look like the obviously correct move. `Draft.plk`'s own TODO ("this combinatorically scales too much and the function ends up being too responsible" — `kalecky-plank/Draft.plk:96`, noted in `CONCERNS.md`) shows this trap has already been hit once in the DSL layer of this exact project.

**How to avoid:**
- Default to value-level unit tags (ordinary data constructors / newtypes carrying a `Unit` value, checked by smart constructors returning `Maybe`/`Either`) rather than type-level (`DataKinds`+`TypeFamilies`) unit arithmetic, unless a specific increment's test literally cannot be expressed without it.
- Apply the project's own stated discipline — "one type per increment, test co-designed and approved" — as the over-engineering guardrail: if a type family is being written to support a type three increments in the future, stop and cut it to what the current increment's test requires.
- Reserve `DataKinds`/type families for the places genuinely justified by the notes: `EconomicQuantity <valuation, unit>` needs the *phantom* type parameters (`valuation`, `unit`) to prevent mixing nominal/real or mismatched compound units, but the unit *values themselves* (currency, scale, compound structure) can stay at the term level with runtime/smart-constructor checks, especially for v1.

**Warning signs:**
- A single increment's diff touches multiple new type families, closed type families with many equations, or introduces `KnownSymbol`/`KnownNat`-style reflection before any test requires it.
- GHC error messages exceeding a screen for what should be a simple unit mismatch.
- The user's approved test for an increment could be satisfied with a smart constructor + runtime check, but the implementation instead reaches for kind-level machinery "to be safe."

**Phase to address:**
Every increment, but especially the `EconomicQuantity`/dimensional-foundation phase (first) and the `CompoundUnit` (`Per`/`Times`) phase — these are the two places where the type-level-vs-value-level decision must be made deliberately rather than by default.

---

### Pitfall 5: Premature abstraction of the algebra (building the general case before the one instance that's needed)

**What goes wrong:**
The notes already sketch a rich hierarchy — `Gap → Conflict → {ExpectationsConflict, DistributionalConflict, BargainingConflict}`, `Effect → {ResponseMultiplier, Elasticity, DistributionalEffect → NetDistributionalEffect}` — but the v1 end-goal equation only actually *uses* `Gap`, `ExpectationsConflict` (implicitly, via the household gap), `ResponseMultiplier`, `GrowthRate`, `CommonGrowthRate`, and `Indexation`. Building `BargainingConflict`, `Elasticity`, `DistributionalEffect`/`NetDistributionalEffect`, or `Pricing`-kind conflicts now — because "the hierarchy in the notes shows them" — means designing and testing types with no concrete economic scenario to validate them against, which is exactly the failure mode the project's own "Out of Scope" section (ψ distribution matrix, full mechanism taxonomy) is trying to prevent at a coarser grain.

**Why it happens:**
The notes present the full conceptual hierarchy as a unified design dialogue (it was worked out all at once, in one sitting, for intellectual coherence), which makes it look like all branches are equally "next." But design coherence and implementation order are different concerns — the hierarchy documents *where future types will slot in*, not *what to build now*.

**How to avoid:**
- Treat `notes/INCOME_DISTRIBUTION.md`'s type hierarchy diagrams as a target architecture / design record, not a build checklist. Cross-reference every candidate increment against the boxed end-goal equation (lines 992-1039) — if a type doesn't appear in that equation or a CASO PRUEBA scenario, it's not v1.
- When a refinement "obviously" needs a sibling (e.g., building `ExpectationsConflict` naturally raises "should I also build `DistributionalConflict` now, since they share the `Conflict` newtype?") — resist; add the sibling only when a concrete test needs it. `Conflict` as a bare semantic wrapper can stay a documented-but-unimplemented node in the hierarchy.
- Keep the "Active" checklist in `.planning/PROJECT.md` as the authoritative build order and treat additions to it as requiring the same test-approval process as any other work — don't let hierarchy-completeness silently expand scope.

**Warning signs:**
- Writing a type (`Elasticity`, `BargainingConflict`, `NetDistributionalEffect`, etc.) with no corresponding term in the boxed wage equation or a CASO PRUEBA scenario.
- Justifying an increment with "it completes the hierarchy" rather than "the end-goal equation needs it."
- QuickCheck properties written for a type that has no consuming code yet (properties in search of a use, rather than laws the wage equation actually relies on).

**Phase to address:**
Ongoing, but check explicitly at the `Conflict`/`Effect` refinement increments (the point where the hierarchy branches) and again right before the end-goal composition phase — that's when it's most tempting to "finish the diagram" instead of finishing the equation.

---

### Pitfall 6: QuickCheck properties that are vacuous or don't encode the real economic law

**What goes wrong:**
Two related failure modes. First, classic QuickCheck vacuity: a property like `gapOrientation :: Gap RealWage -> Bool; gapOrientation g = expectation g > realized g ==> ...` can pass "100% tests passed" while the precondition (`==>`) is almost never satisfied by the generator, so the property is checking nothing. Second — more specific to this domain — a property can be internally consistent but not actually assert the *economic* law from Blecker-Setterfield: e.g., a property asserting `evalGap (Gap a b) == a - b` for arbitrary `a, b :: RealWage` is a tautology about the `Gap` implementation, not evidence that the household expectation gap has the correct economic sign convention from p.204, or that `ResponseMultiplier * Gap` actually reproduces the textbook wage-adjustment mechanism.

**Why it happens:**
It's much easier to write a property that checks internal type-level consistency (associativity, round-tripping, "the code does what the code does") than one that checks fidelity to an external economic specification, because the latter requires cross-referencing the Blecker-Setterfield source on every property, not just the Haskell types. Default `Arbitrary` instances for numeric types also tend to generate values (including negative wages, negative labor units) that don't correspond to any economically meaningful scenario, silently passing on inputs the theory was never meant to cover.

**How to avoid:**
- For every property test, ask "does this fail if I flip a sign, swap an orientation, or use the wrong CASO PRUEBA number?" — if a deliberately-broken implementation still passes the property, it's vacuous or non-diagnostic.
- Pair every QuickCheck algebraic-law property (associativity, orientation-antisymmetry, dimensional-consistency) with at least one concrete example test tied to the CASO PRUEBA scenarios and the boxed equation — properties establish the general law, examples pin it to the actual economics from Blecker & Setterfield (2019, p.204).
- Write custom `Arbitrary` generators (or `Gen` combinators) that only produce economically plausible values (positive wages, bounded growth rates, valid currency/scale combinations) rather than relying on default `Arbitrary` for `Double`/`Int`-backed newtypes, and use `label`/`classify`/`cover` to confirm the generator actually exercises both branches of any `==>`-guarded property.
- When a property has a precondition (`==>`), always check the generated-case coverage (`Test.QuickCheck.classify` or `cover`) rather than trusting the "+++ OK, passed 100 tests" summary alone.

**Warning signs:**
- Any property using `==>` without a corresponding `cover`/`classify` check on how often the precondition holds.
- Properties phrased purely in terms of the Haskell implementation (`evalGap (Gap a b) = a - b`) with no reference to which economic quantity or CASO PRUEBA scenario they encode.
- 100% of QuickCheck runs pass on the very first attempt for a brand-new nontrivial type — often means the generator or the property (or both) aren't exercising the interesting cases.

**Phase to address:**
Every increment's test-design step (the user-approval gate) — this is a process pitfall as much as a technical one, so it should be checked at the moment each increment's test is co-designed, not caught in review afterward.

---

### Pitfall 7: Floating-point representation for economic quantities instead of Rational/fixed-point

**What goes wrong:**
`Number` (used throughout the notes as the underlying representation for `Effect`, `GrowthRate`, `EconomicQuantity`'s `amount`) gets implemented as `Double`. This reintroduces classic floating-point pitfalls in a domain that specifically cares about exact percentage-point/basis-point deltas: `5.20 - 5.0` in `Double` is not guaranteed to equal exactly `0.20`, accumulated rounding in `CommonGrowthRate`/chained `ResponseMultiplier` compositions can make QuickCheck equality properties flaky (false failures) or, worse, mask real bugs (false passes when two wrong-but-close values compare "close enough").

**Why it happens:**
`Double` is the path of least resistance for any `Number`-like type in Haskell, and it's the type most `Arbitrary`/`Show`/numeric-literal machinery defaults to; the CASO PRUEBA numbers (10, 12, 5, 5.20, 20000) all look like "nice" decimals that seem safe in floating point but are exactly the kind of round decimal literals that don't have exact binary representations.

**How to avoid:**
- Use `Rational` (or a fixed-point/`Data.Decimal`-style type) as the underlying representation for `Number`/monetary amounts, not `Double` — this matches general financial-software practice (floats are avoided for storing cents/currency amounts industry-wide) and makes the exact CASO PRUEBA arithmetic (5.20% − 5.00% = 0.20pp = 20bp) checkable with `==` rather than an epsilon-tolerant comparison.
- If `Double` is used anywhere (e.g., for display or interop), keep it strictly at the boundary (rendering) and never as the canonical stored/compared representation inside `Gap`, `Effect`, `GrowthRate`.
- Decide this once, early, and encode it in the `Number`/`Scale` foundation type — retrofitting `Rational` after several increments have assumed `Double` equality is expensive.

**Warning signs:**
- QuickCheck equality properties on `GrowthRate`/`Gap`/`Effect` that need an epsilon (`~=`) rather than `==` to pass reliably.
- Any `Show`/test-fixture output showing numbers like `0.19999999999998` where the CASO PRUEBA prose says exactly `0.20`.
- `Number` defined as a type alias for `Double` in the foundation increment.

**Phase to address:**
The very first foundation increment (`Scale`/`Number`/`EconomicQuantity`) — this is a load-bearing decision every later type depends on and is disruptive to change later.

---

### Pitfall 8: Building inside a 2000+ file package makes "one type per increment" slower than it needs to be

**What goes wrong:**
`.planning/codebase/CONCERNS.md` documents that `kalecky-spec/` is a full hevm fork with 2000+ `.hs` files under a single Stack/Cabal component. Per the project's explicit constraint, the Kalecky types stay inside this package (to preserve the future hevm/Z3 bridge) rather than moving to a standalone package. Cabal only builds modules of one component at a time and test suites can't start compiling until the whole library component finishes building (documented Cabal behavior, see Sources) — so every incremental `Kalecky.*` module change forces a rebuild proportional to however `Kalecky` is wired into the existing component graph. If `Kalecky.*` is added as ordinary modules inside hevm's existing library stanza (rather than its own internal library/sub-component), every tiny Gap/Effect/Conflict increment pays the full-library rebuild+relink cost, directly undermining the "test-first, one type per increment" workflow's fast feedback loop.

**Why it happens:**
It's the path of least resistance to add new modules to whatever `.cabal` stanza already exists rather than carving out a separate internal library, especially when the existing `.cabal` file is unfamiliar (large, generated/forked, easy to misconfigure).

**How to avoid:**
- Add `Kalecky` as its own internal library (`cabal`'s multi-component / internal-library feature: a separate `library kalecky-core` stanza inside `kalecky-spec.cabal` that depends on nothing from hevm proper) with its own dedicated `test-suite kalecky-test` stanza. This keeps `Kalecky.*` compilation and its QuickCheck/Tasty test run isolated from hevm's own (much larger, EVM-symbolic-execution-heavy) build graph, and is exactly the pattern Cabal recommends for monorepo-style speed (per-component builds/ cross-package parallelism — see Sources).
- Confirm this decision explicitly in the first increment, since `CONCERNS.md` already flags that there's no root-level `stack.yaml`/`cabal.project` and unclear build orchestration between the Lean/Haskell/Plank layers — the Kalecky test suite should be runnable and demonstrably fast (`cabal test kalecky-test`) without triggering a full hevm rebuild, or the "test co-designed and approved, then implemented" loop will be too slow to sustain.
- Watch HLS/ghcid memory and responsiveness inside this monorepo-scale package (documented issue: HLS memory blows up with many cabal packages/modules) — if editor tooling becomes sluggish, that's a signal the internal-library isolation isn't working.

**Warning signs:**
- `cabal test kalecky-test` (or equivalent) takes minutes and visibly recompiles hevm/EVM modules that have nothing to do with `Kalecky.*`.
- New `Kalecky.*` modules added directly under `hs-source-dirs` of the existing hevm library stanza rather than a dedicated internal library.
- HLS becomes unresponsive or restarts frequently when editing `Kalecky.*` files.

**Phase to address:**
Before/at the very first increment (`Scale`/foundation) — this is a one-time build-system setup decision that should happen before any test-driven Kalecky code is written, not retrofitted after several increments.

---

### Pitfall 9: Untracked core work in git — the increment loop has no safety net

**What goes wrong:**
`CONCERNS.md` documents (highest severity) that `kalecky-spec/`, `notes/`, `foundry.toml`, and related files are currently untracked in git. If the "one type per increment, test approved by user, then implemented" workflow proceeds on top of untracked files, there is no commit history to diff against, no way to `git bisect` a broken CASO PRUEBA regression back to the increment that introduced it, and a single `git clean`/tooling mishap could destroy the entire in-progress type hierarchy with zero recovery path — a much higher-stakes version of a normal "forgot to add files" mistake, because the whole deliverable (the type hierarchy itself, per `PROJECT.md`'s "Core Value") lives in these untracked files.

**Why it happens:**
Untracked files accumulate silently in exploratory/research-mode work (this project is explicitly framed as a "research artifact") where committing feels premature until a design is "settled" — but in a type-hierarchy project, the design *is* the settling process, increment by increment, so waiting for settledness before committing means never committing.

**How to avoid:**
- Commit `kalecky-spec/`, `notes/`, `foundry.toml`, `remappings.txt` to git (or add an explicit, justified `.gitignore` entry if some subset is genuinely meant to stay local) before the first test-approved increment is implemented — do this as increment zero, not as cleanup afterward.
- Adopt a commit-per-increment discipline matching the roadmap's own granularity ("one type per increment"): each approved test + its passing implementation is one commit, so a regression in a later CASO PRUEBA scenario can be bisected to the exact type that broke it.
- Given the project's "Rigor over speed" constraint, treat git history itself as part of the research artifact's provenance — a reviewer (or future self) should be able to see the test-first sequence: test committed, approved, implementation committed.

**Warning signs:**
- `git status` showing `kalecky-spec/` or `notes/` as `??` at the start of any new increment.
- No commit corresponding to a given increment's "test approved" milestone before implementation begins.
- Large diffs spanning multiple types in a single commit (signals the one-type-per-increment discipline slipped and committing was deferred).

**Phase to address:**
Increment zero / setup, before any Kalecky type work begins — this blocks the entire test-first process's safety guarantees until resolved.

---

### Pitfall 10: Scope creep toward the full ψ distribution matrix before the wage equation is done

**What goes wrong:**
`notes/INCOME_DISTRIBUTION.md` opens with the full functional-income-distribution matrix (ψ mechanisms across labor/capital/informal sectors, the `Π/Y`, `W/Y` decomposition, the Colombia-specific mechanism taxonomy TODO) — a substantially larger formalization problem than the wage-growth equation that is v1's actual end goal. `PROJECT.md`'s "Out of Scope" section already explicitly defers this ("the ψ object is a later milestone", "other agents' work"), but the ψ matrix is presented first in the notes and is conceptually "upstream" of the wage equation in the economic theory, creating a natural pull to formalize ψ's types (`Mechanism`, the agent/sector taxonomy, the matrix algebra) "since it's needed eventually anyway" or "since the wage equation is technically a special case."

**Why it happens:**
The wage equation *is* economically downstream of / a component within the broader ψ distribution story, so it's easy to rationalize that properly typing ψ first would make the wage equation "fall out" more elegantly — a subtler version of Pitfall 5 (premature abstraction) but at the level of the whole domain model rather than a single type hierarchy.

**How to avoid:**
- Re-read `PROJECT.md`'s Out of Scope list at the start of any increment that touches agent/sector taxonomies, mechanism types, or matrix-shaped data — if a proposed type generalizes beyond what the boxed wage equation needs (e.g., a generic `Mechanism` type covering taxes/subsidies/transfers), it's ψ-scope, not wage-equation-scope.
- Where the wage equation genuinely needs a piece of ψ machinery (e.g., `Agent = Household | Firm | Government | FinancialSector` is already needed for `Expectation agent x`), implement only the minimal slice actually consumed by the equation — resist extending `Agent` with sectors/mechanisms the wage equation doesn't reference.
- Keep the CASO PRUEBA scenarios and the boxed equation as the sole scope oracle (same test as Pitfall 5) — since ψ-related temptation is explicitly called out as future work in the project's own scoping decisions, any deviation should be treated as a scope change requiring the same user-approval process as everything else, not a unilateral "while I'm in here" addition.

**Warning signs:**
- New types named `Mechanism`, `Psi`/`ψ`, `FunctionalShare`, or sector-taxonomy types (`W_{L_I}`, informal sector) appearing in an increment.
- Justifying a type by referencing the matrix on lines 17-26 of `notes/INCOME_DISTRIBUTION.md` rather than the boxed equation on lines 992-1039.
- `Agent` (or similar) growing fields/constructors beyond `Household | Firm | Government | FinancialSector` without a corresponding term in the wage equation requiring it.

**Phase to address:**
Ongoing scope discipline, but check explicitly whenever `Agent`, `Expectation`, or any taxonomy-shaped type is touched — and again at the "end-goal test" phase, where it will be tempting to declare v1 "not really done" until ψ is at least stubbed out.

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|-----------------|-----------------|
| `Number = Double` instead of `Rational`/`Data.Decimal` | Fast to write, familiar numeric literals | Flaky equality tests, silent precision loss on exact CASO PRUEBA numbers (Pitfall 7) | Never for the canonical `Number`/amount type — acceptable only at display/rendering boundary |
| `Gap`/`Effect` given `Num` instances | `+`/`*` "just work," less boilerplate | Collapses dimensional safety, allows nonsensical composition (Pitfall 1) | Never |
| Adding `Kalecky.*` modules to hevm's existing library stanza instead of a new internal library | No `.cabal` editing needed right now | Every increment pays full hevm rebuild cost, kills fast feedback loop (Pitfall 8) | Never — set up the internal library in increment zero |
| Symmetric `Gap { lhs, rhs }` without named orientation fields | Simpler type, faster to write | Orientation bugs typecheck silently, only surface as wrong-sign test failures downstream (Pitfall 2) | Never — the notes already resolved this; use `positiveTerm`/`negativeTerm` |
| Deferring `git add` on `kalecky-spec/`/`notes/` until "the design settles" | Avoids committing "messy" WIP | No bisectable history, no recovery from tooling mishaps on the sole deliverable (Pitfall 9) | Never for a research-artifact project where the types *are* the deliverable |
| Building `DataKinds`/type-family unit algebra ahead of the current increment's test | Feels "more correct," reusable later | Slower increments, unreadable errors, contradicts one-type-per-increment pacing (Pitfall 4) | Acceptable only when a specific approved test cannot be expressed without it |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|-----------------|-------------------|
| Kalecky types ↔ existing `kalecky-spec` hevm build | Adding modules to the existing library stanza, inheriting its dependency/build weight | Dedicated internal library + test-suite stanza in `kalecky-spec.cabal`, isolated from hevm's EVM/symbolic-execution modules |
| Kalecky types ↔ future hevm/Z3 symbolic-execution bridge | Designing `Number`/`EconomicQuantity` around convenience (`Double`, `Num` instance) without considering SMT-encodability | Since the stated rationale for keeping types inside `kalecky-spec` is the eventual Z3 bridge, prefer representations (`Rational`, explicit smart constructors) that are more naturally encodable to SMT theories later, and avoid `Double`/`Num`-instance shortcuts that would need to be undone before that bridge work |
| `kalecky-plank` DSL (out of scope for v1) ↔ Haskell types | Treating `Draft.plk`'s existing (broken, TODO-laden) type dispatch as a spec to mirror in Haskell | `Draft.plk` is explicitly out of scope and known-fragile (`CONCERNS.md`); do not let its hardcoded closed-world dispatch pattern (`if U == MoneyUnit(...) ...`) leak into the Haskell design — the Haskell types should use proper sum types (`data EconomicUnit = ...`) since Haskell already supports what Plank is TODO-blocked on |
| QuickCheck/Tasty test infrastructure (already present in `kalecky-spec`) | Assuming existing test-suite wiring auto-discovers new `Kalecky.*` test modules | Explicitly wire new test modules into the chosen test-suite's `other-modules`/`main-is` in the `.cabal` file per increment; verify `cabal test kalecky-test` actually runs the new tests, don't assume |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|-----------------|
| Kalecky modules compiled as part of hevm's main library component | `cabal build`/`cabal test` for a single new Gap/Effect type takes minutes, recompiles unrelated EVM modules | Dedicated internal library stanza (Pitfall 8) | Immediately at the second or third increment, once the "one type per increment, test-approved" cadence starts feeling slow |
| Type-family-heavy dimensional algebra | GHC type-checking time grows disproportionately per new compound unit combination; error messages become multi-screen | Prefer value-level unit tags + smart constructors over full type-level unit arithmetic (Pitfall 4) | Once `CompoundUnit`/`Per`/`Times` combinations multiply past a handful of unit pairs |
| HLS/ghcid responsiveness in a 2000+ module monorepo package | Editor lag, HLS restarts, slow "jump to definition" while editing `Kalecky.*` | Isolate Kalecky as its own internal library; consider a separate HLS component config if supported | As soon as HLS needs to index the full hevm component to service `Kalecky.*` edits |

## Security Mistakes

Not primarily applicable — this is a pure-Haskell type-modeling research artifact with no network/user input surface in v1. The closest analogues are correctness-as-safety concerns already covered above (Num abuse, orientation errors, precision loss) since in a formal-semantics project, a "wrong but type-checks" economic quantity is the domain-equivalent of a security bug: it silently produces an incorrect, trusted result.

| Mistake | Risk | Prevention |
|---------|------|------------|
| Treating "compiles" as "correct" for economic semantics | A type-checked but economically wrong composition (e.g., mismatched orientation) is trusted as if verified | Every type's test-design step must include at least one example test tied to the Blecker-Setterfield source or CASO PRUEBA prose, not just type-level round-trip properties (Pitfall 6) |
| Silent unit coercion via shared underlying representation | Two economically distinct quantities (e.g., a percentage-point delta and a ratio) accidentally compare/combine as equal because both reduce to the same `Number` | Distinct newtypes per representation (ratio/percentage/pp-delta/bp-delta), no implicit `Num`-based coercion (Pitfall 1, Pitfall 3) |

## UX Pitfalls

Not directly applicable (no end-user interface in v1) — the "user" of this library is future Kaleckian/Kaldorian/Minskyan module authors and the researcher themself. The relevant analogue is API/type-signature ergonomics:

| Pitfall | Impact | Better Approach |
|---------|--------|-------------------|
| Error messages from failed smart constructors (`mkCommonGrowthRate`, etc.) returning bare `Nothing` with no explanation | Future module authors (Kaldor/Minsky) can't tell *why* two growth rates weren't "common" | Prefer `Either Text CommonGrowthRate` (or a small typed error) over `Maybe` once past the very first CASO PRUEBA increment, so failures are self-documenting |
| Type parameter order/naming inconsistency across `Gap x`, `Effect responder perturband`, `Conflict kind x` | Increases cognitive load for reuse across Kaldor/Minsky/fiscal modules — the explicit reusability goal in `PROJECT.md` | Establish and document a consistent naming/ordering convention for type parameters across the whole hierarchy in the first increment, and hold later increments to it |

## "Looks Done But Isn't" Checklist

- [ ] **`Gap x`:** Often missing an explicit orientation-antisymmetry test — verify a property asserts `evalGap (Gap a b) == negate (evalGap (Gap b a))`, not just that some `evalGap` exists.
- [ ] **`EconomicQuantity <valuation, unit>`:** Often missing a check that dimensionally mismatched operations actually fail to compile — verify with a `-- should not compile` example (doctest-style or a documented manual check) that e.g. adding `NominalWage` and `LaborProductivity` is rejected.
- [ ] **CASO PRUEBA scenarios:** Often implemented as "the code produces *a* number" rather than "the code produces the *exact* number from the prose, in all three unit representations (ratio/pp/bp)" — verify each scenario has an explicit example test with the literal expected value from the notes.
- [ ] **`ResponseMultiplier`/`Indexation`:** Often missing the composition test — verify that `ResponseMultiplier * Gap` (or `Indexation * GrowthRate`) actually produces a value of the *responder*'s type, not just that the multiplication typechecks with placeholder values.
- [ ] **Kalecky test suite in `kalecky-spec.cabal`:** Often "wired in" only in the sense that the module compiles, not that `cabal test` actually executes it — verify by intentionally breaking a test and confirming `cabal test` reports failure.
- [ ] **Git tracking:** Often assumed "handled" once a `git add` happens once — verify `git status` is clean (no untracked Kalecky-relevant files) after *every* increment, not just at project start.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|-----------------|-----------------|
| `Num` instance abuse discovered late | MEDIUM | Remove the instance, grep all call sites using `+`/`-`/`*` on the affected type, replace with named operations; likely touches every increment built on top, but the type errors from removing `Num` will mechanically find every affected call site |
| Orientation bug found in `Gap` after `Conflict`/`Effect` are built on it | MEDIUM-HIGH | Fix `Gap`'s constructor/orientation, re-run every downstream CASO PRUEBA example test (not just properties) since sign bugs can cancel out in some scenarios and only surface in others; audit each `Conflict`/`Effect` usage of `Gap` manually |
| `Double`-based `Number` discovered to cause precision issues | HIGH | Requires changing the foundational type and re-deriving/re-checking every increment's arithmetic; cheaper the earlier it's caught — this is why Pitfall 7 should be decided in increment zero |
| Kalecky modules discovered wired into hevm's main library (slow builds) | LOW-MEDIUM | Refactor `.cabal` file to extract an internal library stanza; mostly mechanical (move `hs-source-dirs`, split `other-modules`), low risk since it's a build-config change, not a semantics change |
| Untracked core files (git) | LOW (now) / VERY HIGH (if lost before recovery) | `git add` everything currently untracked immediately, commit; cost only escalates if a destructive operation happens before this is done — treat as urgent, not merely important |
| Scope creep into ψ matrix mid-increment | LOW-MEDIUM | Revert/extract the ψ-scope additions into a separate future-milestone branch or notes entry; since the project already has an explicit Out-of-Scope list, this is a matter of enforcing an existing decision, not making a new one |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|-------------------|----------------|
| Num instance abuse | Foundation (`EconomicQuantity`/`Scale`) phase | Code review checklist item: grep for `instance Num` / `deriving (Num)` on any Kalecky type before merge |
| Orientation/sign errors in `Gap` | `Gap` increment | Orientation-antisymmetry QuickCheck property + household/firm sign example tests both pass |
| pp vs bp vs ratio confusion | `GrowthRate`/`Scale` foundation + CASO PRUEBA increment | All three CASO PRUEBA scenarios have example tests asserting exact cross-representation numbers |
| Type-level over-engineering | Every increment, esp. `EconomicQuantity`/`CompoundUnit` | Increment diff size/review: no type families introduced without a specific test requiring them |
| Premature abstraction of algebra | Every `Conflict`/`Effect` refinement increment | Every new type traces to a term in the boxed wage equation or an approved CASO PRUEBA scenario |
| Vacuous/non-diagnostic QuickCheck properties | Every increment's test-design (user-approval) step | `cover`/`classify` checked on any `==>`-guarded property; at least one example test per type tied to Blecker-Setterfield source |
| Floating-point `Number` | Foundation phase (increment zero for `Number`/`Scale`) | `Number` type defined as `Rational` (or decimal/fixed-point), confirmed before any dependent type is built |
| Slow builds from shared cabal component | Increment zero (build-system setup) | `cabal test kalecky-test` (isolated) demonstrably does not trigger hevm's full library rebuild |
| Untracked core work | Increment zero (before any test-approved implementation) | `git status` clean; commit history shows a commit per approved increment |
| ψ-matrix scope creep | Ongoing, checked at `Agent`/taxonomy-touching increments and the end-goal phase | Every new type/taxonomy field traces to the boxed wage equation, not the ψ matrix in the notes' opening section |

## Sources

- [units: A domain-specific type system for dimensional analysis (Hackage)](https://hackage.haskell.org/package/units) — Num-instance limitation discussion for unit-carrying types
- [Numeric.Units.Dimensional (Hackage)](https://hackage.haskell.org/package/dimensional-1.6.1/docs/Numeric-Units-Dimensional.html) — type-level dimension design precedent
- [Dimensions and Haskell: Introduction (Serokell)](https://serokell.io/blog/dimensions-and-haskell-introduction)
- [dimensional-classic (GitHub)](https://github.com/bjornbm/dimensional-classic)
- [Kinda Technical: Property-Based Testing with QuickCheck](https://kindatechnical.com/haskell/lesson-47-property-based-testing-with-quickcheck.html) — vacuous properties, `==>` vs classify/cover guidance
- [Property-based testing — The Haskell Guide](https://haskell-docs.netlify.app/packages/quickcheck/)
- [Type Families in Haskell: The Definitive Guide (Serokell)](https://serokell.io/blog/type-families-haskell)
- [Basic Type Level Programming in Haskell (Matt Parsons)](https://www.parsonsmatt.org/2017/04/26/basic_type_level_programming_in_haskell.html)
- [Floats Don't Work For Storing Cents: Why Modern Treasury Uses Integers Instead](https://www.moderntreasury.com/journal/floats-dont-work-for-storing-cents)
- [Decimal Safety Right on The Money (fpblock academy)](https://academy.fpblock.com/blog/safe-decimal-right-on-the-money/)
- [Basis Points vs Percentage Points: Definition & Conversion (Gate Glossary)](https://www.gate.com/learn/glossary/basis-points-vs-percentage-points)
- [Basis Points vs Percentage Points: Key Differences + Examples (basispointcalculator.com)](https://www.basispointcalculator.com/guides/basis-points-vs-percentage-points/)
- [Per-component interface for Setup — haskell/cabal#3064](https://github.com/haskell/cabal/issues/3064) — per-component build speed rationale
- [Excessive memory usage in monorepos — haskell-language-server#2151](https://github.com/haskell/haskell-language-server/issues/2151)
- [Monorepo: Cabal internal libraries vs multi-package Cabal (Haskell Discourse)](https://discourse.haskell.org/t/monorepo-cabal-internal-libraries-vs-multi-package-cabal/7424)
- `.planning/PROJECT.md` — project scope, active/out-of-scope requirements, boxed end-goal equation reference
- `.planning/codebase/CONCERNS.md` — untracked-files finding, three-stack mismatch, `Draft.plk` TODO on combinatorial dispatch scaling
- `notes/INCOME_DISTRIBUTION.md` — worked type-design dialogue (Gap orientation resolution, CASO PRUEBA scenarios, boxed wage equation)

---
*Pitfalls research for: Typed economic-semantics Haskell library (Kalecky income-distribution types), built inside an existing hevm fork*
*Researched: 2026-08-15*
