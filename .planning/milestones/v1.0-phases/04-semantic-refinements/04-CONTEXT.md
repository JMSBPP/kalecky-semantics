# Phase 4: Semantic Refinements - Context

**Gathered:** 2026-08-16
**Status:** Ready for planning (live co-design mode)

<domain>
## Phase Boundary

The economics-aware refinements the wage equation consumes: `Conflict` (kind-indexed family, Expectations specialization), `ResponseMultiplier`, `Indexation` — zero-cost layers over Phase 3's algebra. SEM-01..03.

</domain>

<decisions>
## Implementation Decisions

### Conflict (amends SEM-01's "newtype over Gap" wording)
- **Kind-indexed family now**: promoted `ConflictKind = Expectations | Distributional | Bargaining`; `Conflict (k :: ConflictKind) (a :: Measure) (b :: Measure) x` with hidden constructor.
- **Expectations is a specialization of Conflict** — "orthogonal to Effect but same structure" (user): a parallel operator family to Effect (parent + refinements pattern), difference-shaped rather than derivative-shaped.
- Only the Expectations kind is constructible in v1 (`expectationsConflict :: Expectation a x -> Expectation b x -> Conflict Expectations a b x`); Distributional/Bargaining kinds exist at the type level, constructors deferred (SEM-06, v2).
- NOT a Gap wrapper: Gap requires a realized side (Phase 3 correction); a conflict compares two expectations. `evalConflict` = a's view − b's view via SignedDiff. No NetConflict wrapper (user choice) — evaluation returns the bare signed value.

### ResponseMultiplier & Indexation
- `ResponseMultiplier responder perturband` = newtype over `Effect` (no redundant scalar, SEM-02) in **new `Operators/ResponseMultiplier.hs`** (user placement).
- `Indexation target reference` = newtype over `Effect (GrowthRate target) (GrowthRate reference)` (SEM-03) in existing `Operators/Indexation.hs` stub.
- Both expose apply-through (delegating to `applyEffect`) so Phase 6's equation terms compose without unwrapping.

### Claude's Discretion
- Exact GADT/constructor encoding of the kind restriction; lawset selection; example numbers

</decisions>

<canonical_refs>
## Canonical References

- `notes/INCOME_DISTRIBUTION.md` — §§2 (Conflict kinds), 3-6 (Effect refinements, Indexation redundancy resolution), 11 (ExpectationsConflict from two Expectations)
- `kalecky-spec/src/Kalecky/Operators/Conflict.hs`, `Indexation.hs` — stub design comments
- `.planning/phases/03-algebraic-operators/03-01-SUMMARY.md` — the shipped algebra (SignedDiff, Expectation, Effect/applyEffect)
- `.planning/REQUIREMENTS.md` — SEM-01 amended per above

</canonical_refs>

<code_context>
## Existing Code Insights

- `SignedDiff`/`Diff` (Operators/Gap.hs) — evalConflict's evaluation machinery
- `Expectation (μ :: Measure) x` + measure singletons — conflict operands
- `Effect`/`applyEffect` — the wrapped core of both refinements
- Boundary suite pattern for any new negative cases (e.g., same-variable enforcement is by type already)

</code_context>

<specifics>
## Specific Ideas

- "Expectations is a specialization of Conflict, which is orthogonal to Effect but has the same structure" — parent-family + specialization pattern on both sides of the operator taxonomy

</specifics>

<deferred>
## Deferred Ideas

- Distributional/Bargaining constructors + DistributionalEffect/NetDistributionalEffect/Elasticity (v2, SEM-04..06)
- NetConflict evaluated-value wrapper — revisit if equation composition wants it

</deferred>

---

*Phase: 04-semantic-refinements*
*Context gathered: 2026-08-16*
