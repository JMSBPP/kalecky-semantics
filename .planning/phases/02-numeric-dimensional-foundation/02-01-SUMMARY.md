# Plan 02-01 Summary — Dimensional Kernel (Live Co-Design)

**Completed:** 2026-08-15 | **Mode:** live in-session co-design (no executor subagents) | **Tests:** 54/54 green + 4 compile-fail files verified

## What shipped

Six increments, each user-approved (laws + examples) before implementation, each as a `test(kalecky):` RED → `feat(kalecky):` GREEN commit pair on `phase/02-foundation`:

1. **Scale** — `s(b,i) := b^i` checked constructor; hidden newtype over Natural; multiplicative Semigroup
2. **Unit** — basis-typed `Unit u_s(k)`, amount in the unit; semigroup (amounts×, scales×); `HasScale` smart construction; later gained `value`, `align` (s = h within kind, toward finer scale, exact), `add`, `scaleBy`
3. **Base units** — `Currency` (DataKinds tag; `tradeable_base` COP=50, USD deferred), `moneyUnit` divisibility construction, `TimeBasis` Month|Hour (HOUR_BASE=3600, Month=720h), `WorkerBasis`/`LaborHourBasis` as distinct types
4. **CompoundUnit** — structure-preserving `Per` (ρ) / `Times` (τ); `cancel` collapses same-kind ratios exactly or not at all
5. **Valuation** — promoted `Nominal | Real PriceIndex`; opaque `CPI` tag in `Prices/PriceIndex.hs`; singleton bridges
6. **Price** — `Price (v :: Valuation) a b` over `Per`; `addPrice` exact rational addition; UNIT-04 negative boundary as 4 should-fail files + `scripts/check-compile-fail.sh`

## Requirements

UNIT-01..06 and PROOF-01 delivered. Boundary proofs: COP+USD, money+labor, Worker+LaborHour, Nominal+Real all rejected with the intended `Couldn't match type` errors (verified, not just grep-passed).

## Deviations & decisions of note

- **Src tree correction (user):** mid-phase, placement was refactored to honor the user-designed tree — one concept per file; `Numerics` holds only `Scale`; `Denomination` lives with `MoneyUnit`; new `Units/TimeUnit.hs` and `Prices/PriceIndex.hs` placed by user decision. Recorded in agent memory.
- **addPrice is `Maybe`**, not total as first drafted — numerator combination goes through `align`; always `Just` for current scale families; law unchanged. Flagged at approval time.
- `Kalecky.Smoke` placeholder retired by the Scale increment per its own docstring.

## Verification

- `cd kalecky-spec && cabal test kalecky-test` → All 54 tests passed
- `./scripts/check-compile-fail.sh` → all 4 rejected, exit 0
- Every increment has RED and GREEN commits with conventional prefixes
