# Plan 05-01 Summary — Domain Vocabulary & CASO PRUEBA (Live Co-Design)

**Completed:** 2026-08-16 | **Tests:** 101/101 green + 6 compile-fail files

## What shipped
1. **Wage** — valuation-parametric `Wage v c l` / `NominalWage` aliases over Price (money per labor, NOT a price index — DOM-01); `wage` constructor delegating quantization to `moneyUnit`; `householdWageGap` (gapER) / `firmWageGap` (gapRE) with the proven opposite-orientation law (DOM-04 as amended).
2. **CASO PRUEBA suite** — all three prose scenarios as exact domain-level tests (PROOF-02..04); passed on arrival (pure validation — no RED phase, flagged at approval). Nivel→Tasa typed at Thousand denomination to respect COP's tradeable base.

## Scope notes (user decisions)
- DOM-02 (RealWage/deflation) DESCOPED to v2; gaps run over the valuation-parametric Wage.
- DOM-03 amended: LaborProductivity not formally defined — enters Phase 6's equation as a phantom `GrowthRate` carrier.

## Verification
- `cabal test kalecky-test` → 101/101; `./scripts/check-compile-fail.sh` → all 6 rejected.
