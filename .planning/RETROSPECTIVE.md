# Retrospective — Kalecky Semantics

## Milestone: v1.0 — Wage Equation

**Shipped:** 2026-08-16 | **Phases:** 6 | **Plans:** 11

### What Was Built
Typed income-distribution kernel in Haskell (inside the hevm fork's isolated `kalecky` sublibrary): dimensional units → algebraic operators → semantic refinements → wage vocabulary → the boxed Blecker-Setterfield wage-setting equation, all exact-Rational, all test-first.

### What Worked
- **Live co-design beat orchestration for spec-driven work**: after Phase 1, dropping executor subagents for in-session increments (discuss laws → approve tests → RED → GREEN) cut per-increment time to ~10 minutes with zero fidelity loss.
- Full GSD machinery earned its cost exactly once — Phase 1's infra unknowns (nested repo, submodule drift, cabal isolation), where research caught real traps (stack-vs-cabal, plank-monorepo drift, gitlink ordering).
- The compile-fail boundary suite (excluded-source files + check script) made "ill-formed economics must not type-check" an executable claim.
- User corrections mid-flight (src-tree discipline; Gap = expectation-vs-realized) were absorbed as amendments + memory notes rather than rework.

### What Was Inefficient
- The Phase 2 planner was about to emit 11 plans before the user questioned the fit — the process pivot should have been considered at roadmap time.
- Two placement mistakes (types consolidated into Numerics.hs) cost a refactor commit; the one-concept-per-file rule is now in agent memory.

### Patterns Established
- RED (undefined-skeleton, always-compiling) → GREEN commit pairs; ledger plans ticked per increment; boundary files for every new compile-time rejection; DataKinds tag + singleton bridge for every identity-like distinction (Currency, Valuation, Measure, ConflictKind).

### Key Lessons
- Match process weight to where the unknowns are: discovery-heavy → agents; dialogue-heavy → live co-design with the user.
- Encode user corrections in types, not docs (two-realized Gaps are unrepresentable, not discouraged).

### Cost Observations
- Post-pivot phases ran entirely in the main session (opus-class); subagents (sonnet/haiku) only in Phase 1 + planning artifacts.

## Cross-Milestone Trends

| Milestone | Phases | Plans | Duration | Mode |
|-----------|--------|-------|----------|------|
| v1.0 | 6 | 11 | 2 days | GSD-full (P1) → live co-design (P2-6) |
