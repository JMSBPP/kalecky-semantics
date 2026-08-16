---
phase: 2
slug: numeric-dimensional-foundation
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-08-15
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Tasty 1.5.3 + tasty-quickcheck 0.11 (+ quickcheck-classes 0.6.5.0 for lawsets where applicable) — via cabal, NOT stack |
| **Config file** | `kalecky-spec/kalecky-spec.cabal` (`library kalecky` + `test-suite kalecky-test`, proven isolated in Phase 1) |
| **Quick run command** | `cd kalecky-spec && cabal test kalecky-test` |
| **Full suite command** | `cd kalecky-spec && cabal test kalecky-test` (one suite; grows per increment) |
| **Estimated runtime** | ~10-20 seconds warm |

Compile-time rejection tests (UNIT-04): excluded-source-file convention — files under a non-built directory that MUST fail `ghc -fno-code` type-checking; do NOT use should-not-typecheck (-Werror conflict verified in 02-RESEARCH.md).

---

## Sampling Rate

- **After every task commit:** `cabal test kalecky-test`
- **After every increment's GREEN commit:** full suite + (when rejection tests exist) the compile-fail check script
- **Before `/gsd:verify-work`:** full suite green; all compile-fail files still rejected
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| (filled by planner — one row per increment) | | | UNIT-01..06, PROOF-01 | property + example + compile-fail | `cd kalecky-spec && cabal test kalecky-test`; compile-fail: `ghc -fno-code <excluded file>` must exit non-zero | ❌ W0 per increment | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

**Checkpoint integration (PROOF-01 pattern):** each increment's test code is drafted RED and shown at a checkpoint for user approval BEFORE implementation. The RED commit is itself a validation artifact.

---

## Wave 0 Requirements

- [ ] Per-increment test modules added under `kalecky-spec/test-kalecky/` and registered in `Main.hs`
- [ ] Compile-fail convention scaffolding: directory (e.g., `kalecky-spec/test-kalecky/should-fail/`) excluded from cabal build + check script
- [ ] Arbitrary instances for Natural amounts / scales as increments land

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Test approval per increment | PROOF-01 | Co-design contract: user approves laws + examples before implementation | Review drafted test code at each increment checkpoint |
| Open-question resolution (HOUR_BASE, LaborUnit denomination, PriceIndex shape, s=h scope, Worker/LaborHour compatibility) | UNIT-01..05 | Spec gaps — user decisions at Stage-1 co-design | Resolve at the relevant increment's discussion before tests are drafted |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
