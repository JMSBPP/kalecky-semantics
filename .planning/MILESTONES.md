# Milestones

## v1.0 Wage Equation (Shipped: 2026-08-16)

**Phases completed:** 6 phases, 11 plans, 0 tasks

**Delivered:** A typed Haskell kernel for Kaleckian income distribution where ill-formed economics fails to compile, proven by the Blecker-Setterfield wage-setting equation composing exactly from co-designed, test-first types (107 tests + 6 compile-fail boundaries; 36 kalecky RED/GREEN commits; ~1,000 LOC src + ~1,200 LOC tests, shipped 2026-08-15 → 2026-08-16).

**Key accomplishments:**
- Absorbed the hevm fork into a bisectable history and isolated the `kalecky` cabal component (~10s TDD loop, proven never to rebuild hevm)
- Dimensional kernel: per-basis Scales, amount-carrying Units (semigroup), Currency/tradeable-base quantization, structure-preserving Per/Times, type-level Valuation, exact-rational Price arithmetic
- Compile-time boundary proven by 6 should-fail files: COP+USD, money+labor, Worker+LaborHour, Nominal+Real, two-realized Gaps, cross-measure expectations all rejected
- Algebra redefined in dialogue: Gap = expectation-vs-realized only (type-enforced); new Delta operator resolves Tasa→Tasa as Delta-of-rates = exactly 1/500
- Kind-indexed Conflict family orthogonal to Effect; zero-cost ResponseMultiplier/Indexation refinements
- The boxed wage equation (`Equations/WageSetting.hs`): three shipped combinators, no glue — concrete example = exactly 277/900; all three CASO PRUEBA prose scenarios pass as exact tests

---

