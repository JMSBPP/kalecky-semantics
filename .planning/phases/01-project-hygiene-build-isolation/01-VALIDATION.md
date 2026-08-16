---
phase: 1
slug: project-hygiene-build-isolation
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-08-15
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Tasty 1.5.3 + tasty-quickcheck 0.11 (Haskell, via cabal — NOT stack, per 01-RESEARCH.md) |
| **Config file** | `kalecky-spec/kalecky-spec.cabal` (library kalecky + test-suite kalecky-test) |
| **Quick run command** | `cabal test kalecky-test` (run inside `kalecky-spec/`) |
| **Full suite command** | `cabal test kalecky-test` (same — one suite this phase) |
| **Estimated runtime** | ~10 seconds after first build |

Do NOT use stack build/stack test for this loop — stack always builds the package's default library (verified in 01-RESEARCH.md Pitfall 2). Use bare cabal.

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
| 01-05 T2 | 01-05 | 5 | INFRA-01 | git-state | `./scripts/verify-repo-state.sh` | ✅ | ✅ green |
| 01-06 T2 | 01-06 | 6 | INFRA-02 | unit | `cd kalecky-spec && cabal test kalecky-test` | ✅ | ✅ green |
| 01-06 T3 | 01-06 | 6 | INFRA-02 | build-isolation | `cd kalecky-spec && cabal build kalecky-test --dry-run \| grep -qvE 'kalecky-spec-[0-9.]+ \(lib\)$'` | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `kalecky-spec/kalecky-spec.cabal` — `library kalecky` + `test-suite kalecky-test` stanzas
- [x] `kalecky-spec/test-kalecky/Main.hs` — Tasty main with two trivial passing properties (smoke test)
- [x] One trivial placeholder module under the sublibrary (`Kalecky.Smoke`; the stub draft tree under `Kalecky.Types.*`/`Kalecky.Operators.*` remains unwired, per research)

---

## Isolation Evidence

Recorded 2026-08-15 during 01-06 Task 3. Three proofs, run inside `kalecky-spec/`.

**Proof 1 — clean-state dry-run build plan (`cabal clean && cabal build kalecky-test --dry-run`):**
```
Resolving dependencies...
Build profile: -w ghc-9.8.4 -O1
In order, the following would be built (use -v for more details):
 - kalecky-spec-0.1.0 (lib:kalecky) (first run)
 - kalecky-spec-0.1.0 (test:kalecky-test) (first run)
```
No bare `kalecky-spec-0.1.0 (lib)` entry, and zero occurrences of `secp256k1`, `aeson-optics`, or `wreq`.

**Proof 2 — touching hevm source does not rebuild the Kalecky suite (`touch src/EVM.hs && cabal build kalecky-test`):**
```
Build profile: -w ghc-9.8.4 -O1
In order, the following will be built (use -v for more details):
 - kalecky-spec-0.1.0 (test:kalecky-test) (additional components to build)
Preprocessing test suite 'kalecky-test' for kalecky-spec-0.1.0...
Building test suite 'kalecky-test' for kalecky-spec-0.1.0...
```
Zero `Compiling` lines and zero `Building library` lines — no module was recompiled (confirmed independently: `Kalecky/Smoke.o`'s mtime was unchanged by this build). Note: this cabal version (3.16.1.0) does not print the literal string `Up to date` for an ephemeral test-suite target re-check, but the substantive claim — no recompilation triggered by touching `EVM.hs` — holds.

**Proof 3 — negative control (`cabal test kalecky-test` warm cache; touching `src/Kalecky/Smoke.hs` with only an mtime change first produced a false "Up to date" because cabal's file-monitor is content-hash based, not mtime based; appending a one-line comment to force a genuine content change and rebuilding gave the expected result, then the file was reverted with `git checkout --` to its committed content):**
```
Build profile: -w ghc-9.8.4 -O1
In order, the following will be built (use -v for more details):
 - kalecky-spec-0.1.0 (lib:kalecky) (file src/Kalecky/Smoke.hs changed)
 - kalecky-spec-0.1.0 (test:kalecky-test) (dependency rebuilt)
Preprocessing library 'kalecky' for kalecky-spec-0.1.0...
Building library 'kalecky' for kalecky-spec-0.1.0...
[1 of 1] Compiling Kalecky.Smoke    ( src/Kalecky/Smoke.hs, ... ) [Source file changed]
```
`Compiling Kalecky.Smoke` appears — the negative control passes, proving Proof 2's silence was genuine isolation and not a stale/broken cache.

Final state re-verified after revert: `cabal test kalecky-test` reports `All 2 tests passed`.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Import commit legibility (one vendor commit, Kalecky work on top) | INFRA-01 | History structure is a human judgment | `git log --oneline` — verify vendor commit precedes Kalecky commits |
| plank-monorepo submodule decision (drift confirmed vs upstream) | INFRA-01 | Requires user decision on pin vs vendor | Review diff summary surfaced by executor before converting |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved 2026-08-15
