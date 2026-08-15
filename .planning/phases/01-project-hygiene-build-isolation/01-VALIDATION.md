---
phase: 1
slug: project-hygiene-build-isolation
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-08-15
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Tasty 1.5.3 + tasty-quickcheck 0.11 (Haskell, via cabal — NOT stack, per 01-RESEARCH.md) |
| **Config file** | none — Wave 0 of this phase creates the `test-suite kalecky-test` stanza |
| **Quick run command** | `cabal test kalecky-test` (run inside `kalecky-spec/`) |
| **Full suite command** | `cabal test kalecky-test` (same — one suite this phase) |
| **Estimated runtime** | ~10 seconds after first build |

---

## Sampling Rate

- **After every task commit:** Run `cabal test kalecky-test` once the stanza exists; before that, git-state assertions (`git status --short`, `git ls-files`)
- **After every plan wave:** Run `cabal build kalecky-test --dry-run` to confirm the plan excludes hevm's main library, then `cabal test kalecky-test`
- **Before `/gsd:verify-work`:** `kalecky-test` green AND dry-run plan lists only sublibrary + test-suite
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| (filled by planner) | | | INFRA-01 | git-state | `git status --short` shows no untracked core dirs; `git ls-files kalecky-spec notes test kalecky-plank \| head` non-empty | ✅ (git) | ⬜ pending |
| (filled by planner) | | | INFRA-02 | build-isolation | `cabal build kalecky-test --dry-run` output contains no `lib:kalecky-spec` main-library component; `cabal test kalecky-test` exits 0 | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `kalecky-spec/kalecky-spec.cabal` — `library kalecky` + `test-suite kalecky-test` stanzas
- [ ] `kalecky-spec/test/kalecky/Main.hs` (or equivalent) — Tasty main with one trivial passing property (smoke test)
- [ ] One trivial placeholder module under the sublibrary (research recommends NOT wiring the stub draft tree yet)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Import commit legibility (one vendor commit, Kalecky work on top) | INFRA-01 | History structure is a human judgment | `git log --oneline` — verify vendor commit precedes Kalecky commits |
| plank-monorepo submodule decision (drift confirmed vs upstream) | INFRA-01 | Requires user decision on pin vs vendor | Review diff summary surfaced by executor before converting |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
