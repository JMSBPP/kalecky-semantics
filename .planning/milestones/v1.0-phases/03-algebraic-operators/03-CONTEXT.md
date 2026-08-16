# Phase 3: Algebraic Operators - Context

**Gathered:** 2026-08-16
**Status:** Ready for planning (live co-design mode — this context is the Stage-1 record for the in-session increments)

<domain>
## Phase Boundary

The algebra every later refinement composes from: `Expectation` (measure-indexed), `Gap` (expectation-vs-realized, oriented), `Delta` (realized-to-realized differences — NEW, surfaced this discussion), `Effect` (∂responder/∂perturband), `GrowthRate` + `CommonGrowthRate`. Requirements ALG-01..06 (ALG-01/02 amended below). Semantic refinements (Conflict, ResponseMultiplier, Indexation) are Phase 4; domain instances and CASO PRUEBA tests are Phase 5.

</domain>

<decisions>
## Implementation Decisions

### Gap — REDEFINED (user correction, supersedes earlier "generic difference" wording)
- **Gap takes an expected value and a realized value — never two realized values.** "Gap is a difference from expected values to realized values; it does not take two realized values."
- **Type-enforced**: constructors require an `Expectation` on one side — a Gap of two realized values is unrepresentable. Consequence: Expectation ships BEFORE Gap in the increment order.
- **Both orientations constructible**: `gapER` (expected − realized; household wage gap E^H[W/P] − W/P) and `gapRE` (realized − expected; firm wage gap W/P − E^F[W/P]); a lawful `flip` maps between them with `evalGap (flip g) == negate (evalGap g)`.
- Evaluation returns **signed exact** values (Integer for value-carriers, exact Rational for rate-like carriers); operands stay Natural — signedness exists ONLY at evaluation.
- The subtraction requirement on the carrier `x` is a **small evaluable class** (signed-difference method) instanced by Unit/Price/GrowthRate — Gap itself stores sides for any carrier and stays domain-import-free.

### Delta — NEW operator (realized-to-realized)
- Two realized observations (10→12 money units; 5%→5.20%) are **Delta**, not Gap. Tasa→Tasa's "+20 basis points" types as `Delta (GrowthRate x)` — an absolute level-difference of rates.
- Lives in `kalecky-spec/src/Kalecky/Operators/Delta.hs` (user placement decision), sibling to Gap; oriented (before/after) with the same signed-exact evaluation class.
- This RESOLVES the flagged Tasa→Tasa ambiguity: neither `Gap (GrowthRate x)` nor `GrowthRate (GrowthRate x)` — it's `Delta (GrowthRate x)`. Phase 5's PROOF-04 test asserts this typing.

### Expectation & Measure
- **Measure-indexed**: `Expectation (μ :: Measure) x` (\(\mathbb{E}^{\mu}\)) — the notes' "más fiel matemáticamente" variant, as the stub's imports (`Kalecky.Types.Measure`) already declare.
- `Measure` carries the agent; **Agent (Household | Firm | Government | FinancialSector) is a DataKinds-promoted type-level tag** with a singleton bridge (same pattern as Currency/Valuation) — E^H[x] and E^F[x] are distinct types (ALG-03).

### Effect & GrowthRate
- `Effect responder perturband` = **newtype over exact signed Rational** — estimated coefficients are signed and fractional; no floats anywhere.
- `GrowthRate x` = **independent primitive** storing the exact signed Rational Δx/x (5% = 1/20); NOT defined via Gap or Delta. Convenience constructor from two observations (before/after via the carrier's `value`), `Maybe` on zero base.
- `mkCommonGrowthRate :: GrowthRate a -> GrowthRate b -> Maybe (CommonGrowthRate a b)` — **Just exactly when the two rates are numerically equal** (balanced-growth witness; the notes' `CommonGrowthRate(GrowthRate, GrowthRate) -> GrowthRate`). Exact Rational equality makes it decidable.

### Requirement amendments (apply when writing tests)
- ALG-01/02 reworded: Gap = oriented expectation-vs-realization difference, generic over the carrier; the evaluable class carries the algebraic subtraction requirement; Delta covers realized differences.

### Claude's Discretion
- Exact evaluable-class shape (name, method signatures) and where signed types (Integer/Rational) surface in APIs
- Arbitrary instances and lawset choices per type (quickcheck-classes where applicable)
- Whether Delta and Gap share the evaluation class or Delta reuses Gap's internals privately

</decisions>

<canonical_refs>
## Canonical References

**Read before implementing.**

### Design source of truth
- `notes/INCOME_DISTRIBUTION.md` — §§ Gap/Conflict/Effect/GrowthRate design dialogue; `Gap(ExpectationVar, RealizedVar)` original signature; household/firm gap orientations (§10); CommonGrowthRate smart constructor (§12)
- `kalecky-spec/src/Kalecky/Operators/*.hs` — stub design notes (Effect hierarchy comment, GrowthRate/CommonGrowthRate tree, Expectation's Measure import)
- `kalecky-spec/src/Kalecky/Types/Measure.hs` — μ stub

### Project planning
- `.planning/phases/02-numeric-dimensional-foundation/02-01-SUMMARY.md` — the shipped kernel this phase builds on (Unit/value/align/add/scaleBy, Price, cancel)
- `.planning/phases/02-numeric-dimensional-foundation/02-CONTEXT.md` — standing co-design cadence and API conventions (bare names, Maybe partiality, tree discipline)
- `.planning/REQUIREMENTS.md` — ALG-01..06 (amend ALG-01/02 per decisions above)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Kalecky.Types.Units.Unit`: `value :: Unit b -> Natural` — the carrier magnitude the evaluable class instances build on; `Price`'s `vals` pattern in PriceSpec for rational value-pairs
- Singleton-bridge pattern (`KnownCurrency`, `KnownValuation`) — reuse shape for `Agent`/`Measure`
- Test conventions: spec modules mirror src tree; shared Arbitrary orphans in `NumericsSpec`; `lawsToTree` helper for quickcheck-classes

### Established Patterns
- RED (undefined skeleton, suite compiles) → GREEN commit pairs; compile-fail files under `test-kalecky/should-fail/` + `scripts/check-compile-fail.sh` for negative boundaries (e.g., mixing agents' expectations if a slot demands one agent)
- DataKinds tags with `-Wno-unticked-promoted-constructors` (tick when a name clashes, cf. 'Real)

### Integration Points
- New modules: `Operators/Expectation.hs` (first), `Operators/Gap.hs`, `Operators/Delta.hs` (new file), `Operators/Effect.hs`, `Operators/GrowthRate.hs`; `Types/Measure.hs` becomes real
- Increment order (dependency-forced): Measure/Expectation → Gap → Delta → GrowthRate/CommonGrowthRate → Effect (Effect independent — may land anytime)
- Wire each into `library kalecky` exposed-modules as it becomes real; branch `phase/03-operators` off main after merging `phase/02-foundation`

</code_context>

<specifics>
## Specific Ideas

- "Gap is a difference from expected values to realized values; it does not take two realized values" — the load-bearing correction of this discussion; encode it in types, not docs
- No floats anywhere: Integer/Rational only at evaluation; operands stay Natural
- 5% ≡ 1/20 exactly; +20bp ≡ 1/500 exactly — Phase 5's CASO PRUEBA numbers must fall out of Rational arithmetic untouched

</specifics>

<deferred>
## Deferred Ideas

- `Measure` as a full probability-measure abstraction (beyond agent-tag carrier) — grow when a module needs it
- Second-order growth (`GrowthRate (GrowthRate x)`) — representable in principle; no requirement uses it; revisit if a model needs acceleration

</deferred>

---

*Phase: 03-algebraic-operators*
*Context gathered: 2026-08-16*
