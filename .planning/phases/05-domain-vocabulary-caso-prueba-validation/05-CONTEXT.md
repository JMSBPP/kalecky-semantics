# Phase 5: Domain Vocabulary & CASO PRUEBA - Context

**Gathered:** 2026-08-16
**Status:** Ready (live co-design mode)

<domain>
## Phase Boundary

Concrete wage vocabulary over the proven algebra, plus the three CASO PRUEBA scenarios asserted at the domain level. NARROWED by user decision: NO RealWage/deflation (DOM-02 descoped to v2); LaborProductivity NOT formally defined — enters only as a phantom `GrowthRate` carrier (DOM-03 amended). Requirements: DOM-01, DOM-03 (amended), DOM-04 (amended), PROOF-02..04.

</domain>

<decisions>
## Implementation Decisions

- **Wage** (`Types/Prices/Wage.hs` stub): a `Price` with `Per` connector, money per labor — valuation-parametric type alias so Real variants cost nothing later; `NominalWage` = Nominal-valued Wage (DOM-01). Smart constructor via `moneyUnit` (Maybe).
- **No RealWage**: wage-expectation gaps (DOM-04) run over the Wage price directly, valuation-parametric; deflation is a later milestone.
- **LaborProductivity**: a phantom tag only (no Ratio Output/LaborService type); `GrowthRate LaborProductivity` is how it appears in the equation. Declared where the equation needs it (Phase 6) — no dedicated module this phase.
- **Gap constructors**: `householdWageGap` (gapER shape: E^H[w] − w) and `firmWageGap` (gapRE shape: w − E^F[w]) — thin domain aliases in Wage.hs.
- **CASO PRUEBA at domain level** (PROOF-02..04): Nivel→Nivel (20000 COP/hour wage constructs; 20025 rejected), Nivel→Tasa (wage 10→12 via growthFrom = +1/5 exactly, using HasMagnitude (Price …)), Tasa→Tasa (`Delta (GrowthRate Wage)` = +1/500).

### Claude's Discretion
- Exact alias/constructor signatures; labor-basis parameter defaulting (LaborHour for the hourly cases)

</decisions>

<canonical_refs>
- `notes/INCOME_DISTRIBUTION.md` — § CASO PRUEBA; §7 (NominalWage is money/labor, not a price index)
- `kalecky-spec/src/Kalecky/Types/Prices/Wage.hs` — stub ("price is a CompoundUnit with per as the connector")
- `.planning/REQUIREMENTS.md` — DOM-01/03/04 as amended; DOM-02 descoped
</canonical_refs>

<code_context>
- Everything needed exists: `Price`/`per`/`moneyUnit`, `Gap` (gapER/gapRE), `Expectation`, `GrowthRate`/`growthFrom`/`HasMagnitude (Price v a b)`, `Delta`
- This phase is mostly aliases + constructors + domain-level tests
</code_context>

<deferred>
- RealWage + deflation by PriceLevel (with numeric PriceIndex content) — v2
- Formal LaborProductivity quantity (Ratio Output LaborService) — v2
</deferred>

---
*Phase: 05-domain-vocabulary-caso-prueba-validation — gathered 2026-08-16*
