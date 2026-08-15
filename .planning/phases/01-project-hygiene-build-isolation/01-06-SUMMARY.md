---
phase: 01-project-hygiene-build-isolation
plan: 06
subsystem: infra
tags: [cabal, ghc, tasty, tasty-quickcheck, haskell, build-isolation]

# Dependency graph
requires:
  - phase: 01-project-hygiene-build-isolation (01-05)
    provides: INFRA-01 (all core sources tracked, verify-repo-state.sh green)
provides:
  - "library kalecky + test-suite kalecky-test cabal stanzas, isolated from hevm's main library"
  - "src/Kalecky/Types/ as a valid, internally-consistent Haskell module tree (still uncompiled design notes)"
  - "kalecky-spec/cabal.project pinned to ghc-9.8.4"
  - "empirical, three-proof isolation evidence recorded in 01-VALIDATION.md"
  - "the fast increment loop (cabal test kalecky-test) for Phases 2-6"
affects: [02-units-dimensional-foundation]

# Tech tracking
tech-stack:
  added: [tasty-1.5.4, tasty-quickcheck-0.11.1, QuickCheck-2.15.0.1 (transitive via tasty-quickcheck)]
  patterns:
    - "Internal cabal sublibrary (library kalecky) inheriting only `common shared`, never `test-base`/`test-common`, to avoid dragging in the hevm main library"
    - "TDD RED/GREEN cycle for the smoke test: Smoke.hs shipped first with a deliberately wrong constant implementation to prove the properties fail, then replaced with the correct b^i implementation"

key-files:
  created:
    - kalecky-spec/src/Kalecky/Smoke.hs
    - kalecky-spec/test-kalecky/Main.hs
  modified:
    - kalecky-spec/src/Kalecky/Types/** (renamed from types/, import paths fixed)
    - kalecky-spec/src/Kalecky/Operators/Expectation.hs
    - kalecky-spec/kalecky-spec.cabal
    - kalecky-spec/cabal.project
    - .planning/phases/01-project-hygiene-build-isolation/01-VALIDATION.md
    - .planning/REQUIREMENTS.md

key-decisions:
  - "Followed the RED/GREEN TDD cycle literally for Task 2 despite the plan pre-specifying the final Smoke.hs content: shipped a deliberately wrong scaleFactor _ _ = 0 first (proven failing), then the correct b^i implementation (proven passing), producing two commits instead of the plan's single suggested commit message — the GREEN commit uses the plan's exact specified message"
  - "Proof 1 (dry-run isolation) required `cabal clean` first — a warm build cache only lists 'additional components to build', omitting already-built lib:kalecky, so the dry-run assertion for 'lib:kalecky' present is only meaningful from a clean state"
  - "Proof 3 negative control required a genuine content change to Smoke.hs, not just `touch` — cabal's file-monitor is content-hash based, not mtime based, so a bare touch silently reported 'Up to date' and would have produced a false pass; appended and then reverted (git checkout --) a one-line comment to get a real recompile signal"

patterns-established:
  - "Isolated fast-loop cabal component pattern: `import: shared` only, bare-name internal sublibrary dependency, hs-source-dirs shared with the main src tree but scoped via exposed-modules — reusable for Phase 2-6 type-bearing sublibraries if the same isolation property is needed"

requirements-completed: [INFRA-02]

# Metrics
duration: ~9min
completed: 2026-08-15
---

# Phase 1 Plan 06: Kalecky Build Isolation Summary

**Isolated `library kalecky` + `test-suite kalecky-test` cabal component proven (three ways) to build and test without compiling a single `EVM.*` module, closing INFRA-02.**

## Performance

- **Duration:** ~9 min
- **Started:** 2026-08-15T23:39:03Z (approx, per STATE.md prior session marker)
- **Completed:** 2026-08-15T23:48:04Z
- **Tasks:** 3 (Task 2 executed as RED+GREEN TDD, no REFACTOR needed)
- **Files modified:** 11 (9 renamed + import-fixed under `src/Kalecky/Types/`, 1 edited `Operators/Expectation.hs`, plus `Smoke.hs`, `Main.hs`, `kalecky-spec.cabal`, `cabal.project`, `01-VALIDATION.md`, `REQUIREMENTS.md`)

## Accomplishments
- `src/Kalecky/` is now a valid Haskell namespace: `types/` renamed to `Types/`, all cross-references fixed (including two non-mechanical rewrites — `Per` resolved to `CompoundUnit`, `Numerics.Scale` resolved to an explicit import list from the flat `Numerics` module), while all 15 draft files remain header-less, uncompiled design notes
- New isolated `library kalecky` + `test-suite kalecky-test` cabal stanzas build and test (`cabal test kalecky-test` → 2/2 properties pass) without touching `hevm`'s ~40-module main library
- `kalecky-spec/cabal.project` now pins `with-compiler: ghc-9.8.4`, so bare `cabal` invocations resolve consistently with `stack.yaml`'s `lts-23.28` instead of the ghcup default 9.10.3
- Isolation is proven empirically three ways (clean dry-run build plan, touch-hevm-doesn't-rebuild, negative-control touch-Smoke-does-rebuild) and the evidence is recorded verbatim in `01-VALIDATION.md`
- INFRA-02 marked complete in `REQUIREMENTS.md`

## Task Commits

Each task was committed atomically:

1. **Task 1: Rename src/Kalecky/types to Types and fix cosmetic imports** - `87128d1` (refactor)
2. **Task 2: Add the isolated kalecky sublibrary, its smoke test, and the compiler pin** (TDD) - `60b1cf5` (test, RED — Smoke.hs stubbed `scaleFactor _ _ = 0`, both properties failed) then `5bd5aad` (feat, GREEN — implemented `b ^ i`, both properties pass; no REFACTOR needed)
3. **Task 3: Prove build isolation empirically and record the loop** - `e0ed10c` (docs)

_TDD Task 2 produced two commits (test → feat) instead of the plan's single suggested commit; see Deviations._

## Files Created/Modified
- `kalecky-spec/src/Kalecky/Types/**` - directory renamed from `types/` (git mv, history preserved), 6 import-path fixes across 5 files
- `kalecky-spec/src/Kalecky/Operators/Expectation.hs` - 2 import-path fixes (`Kalecky.types.Measure`/`Unit` → `Kalecky.Types.Measure`/`Units.Unit`)
- `kalecky-spec/src/Kalecky/Smoke.hs` - new Phase-1 placeholder module exposing `scaleFactor :: Integer -> Int -> Integer`
- `kalecky-spec/test-kalecky/Main.hs` - new Tasty entry point, two `tasty-quickcheck` properties over `scaleFactor`
- `kalecky-spec/kalecky-spec.cabal` - appended `library kalecky` + `test-suite kalecky-test` stanzas after `benchmark bench-perf`, both inheriting `common shared` only
- `kalecky-spec/cabal.project` - added `with-compiler: ghc-9.8.4`
- `.planning/phases/01-project-hygiene-build-isolation/01-VALIDATION.md` - filled Per-Task Verification Map, added Isolation Evidence section with the three proofs' verbatim key output, set `nyquist_compliant: true`, `wave_0_complete: true`, `status: approved`, ticked all sign-off boxes
- `.planning/REQUIREMENTS.md` - INFRA-02 checked off and traceability row updated to Complete

## Decisions Made
- Followed the RED/GREEN TDD cycle literally for Task 2: shipped `Smoke.hs` first with a deliberately wrong `scaleFactor _ _ = 0` (proven to fail both properties), then replaced it with the plan's exact specified `b ^ i` implementation (proven to pass) — this diverges from the plan's single-commit instruction but stays within the `tdd="true"` contract and lands on the plan's exact final file content and exact GREEN commit message
- Proof 1 (dry-run isolation) required a `cabal clean` first: with a warm build cache, `cabal build kalecky-test --dry-run` only lists "additional components to build" and omits `lib:kalecky` (already built), so the assertion that the dry-run output contains `lib:kalecky` is only reliably true from a clean state — recorded this in the Isolation Evidence section
- Proof 3's negative control needed a genuine content change to `Smoke.hs`, not a bare `touch`: cabal's file-monitor here is content-hash based, so `touch` alone produced a false "Up to date" on the first attempt; fixed by appending a one-line comment (forcing a real content diff), confirming `Compiling Kalecky.Smoke`, then reverting the file to its committed content with `git checkout --`

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] TDD RED/GREEN split instead of the plan's single Task 2 commit**
- **Found during:** Task 2
- **Issue:** The task is marked `tdd="true"`, which per the executor's mandatory TDD flow requires a RED (failing test) commit followed by a GREEN (passing implementation) commit — but the plan's `<action>` pre-specified the final, already-correct `Smoke.hs` content and gave a single commit message for the whole task
- **Fix:** Shipped `Smoke.hs` first with a deliberately wrong `scaleFactor _ _ = 0` stub, confirmed both quickcheck properties fail (`cabal test kalecky-test` → 2 failed), committed as `test(01-06): add failing test for kalecky smoke sublibrary`; then replaced the body with the plan's exact `b ^ i` implementation, confirmed both properties pass, committed with the plan's exact specified message `feat(kalecky): add isolated kalecky sublibrary and smoke test-suite`
- **Files modified:** `kalecky-spec/src/Kalecky/Smoke.hs`, `kalecky-spec/test-kalecky/Main.hs`, `kalecky-spec/kalecky-spec.cabal`, `kalecky-spec/cabal.project`
- **Verification:** `cabal test kalecky-test` shows `2 out of 2 tests failed` before the fix, `All 2 tests passed` after
- **Committed in:** `60b1cf5` (RED), `5bd5aad` (GREEN)

**2. [Rule 3 - Blocking] `cabal build --dry-run` isolation proof required a clean build cache**
- **Found during:** Task 3
- **Issue:** Running `cabal build kalecky-test --dry-run` against an already-built cache only reports "additional components to build" for `kalecky-test`, silently omitting `lib:kalecky` (already up to date) — the plan's acceptance criterion (`lib:kalecky` present in output) would spuriously fail post-warm-build
- **Fix:** Ran `cabal clean` before the dry-run for Proof 1 and the plan's literal `<verify>` command; rebuilt and re-ran `cabal test kalecky-test` afterward to leave the working tree in a fully verified, warm-built state
- **Files modified:** none (build-cache-only; `dist-newstyle/` is untracked)
- **Verification:** clean-state dry-run lists both `kalecky-spec-0.1.0 (lib:kalecky) (first run)` and `kalecky-spec-0.1.0 (test:kalecky-test) (first run)`, no bare `(lib)` entry, zero `secp256k1`/`aeson-optics`/`wreq` occurrences
- **Committed in:** n/a (verification-only; recorded in `01-VALIDATION.md`, commit `e0ed10c`)

**3. [Rule 1 - Bug] `touch`-based negative control gave a false pass on first attempt**
- **Found during:** Task 3 (Proof 3)
- **Issue:** `touch src/Kalecky/Smoke.hs` followed by `cabal build kalecky-test` reported `Up to date` and exited without recompiling — cabal 3.16.1.0's file-monitor here is content-hash based, not mtime based, so a bare `touch` does not register as a change; had this gone unnoticed, Proof 2 (touching `EVM.hs` doesn't rebuild) would have been indistinguishable from a broken/stale cache
- **Fix:** Appended a one-line comment to `Smoke.hs` to force a genuine content diff, rebuilt (confirmed `Compiling Kalecky.Smoke`), then reverted the file to its exact committed content via `git checkout -- kalecky-spec/src/Kalecky/Smoke.hs` and rebuilt once more to restore the warm, correct cache state
- **Files modified:** `kalecky-spec/src/Kalecky/Smoke.hs` (temporarily, then reverted — no net diff)
- **Verification:** `git status --short kalecky-spec/src/Kalecky/Smoke.hs` empty after revert; `cabal test kalecky-test` still reports `All 2 tests passed`
- **Committed in:** n/a (working-tree-only investigation; documented in `01-VALIDATION.md` Isolation Evidence, commit `e0ed10c`)

---

**Total deviations:** 3 auto-fixed (1 TDD-flow blocking, 2 verification-methodology blocking)
**Impact on plan:** No scope creep — all three are procedural/verification adjustments needed to produce trustworthy evidence for INFRA-02's isolation claim; final file contents match the plan's specification exactly.

## Issues Encountered
- `grep -c 'nyquist_compliant: true' 01-VALIDATION.md` reports `2`, not the plan's expected `1` — the Validation Sign-Off checklist item itself contains the literal text `nyquist_compliant: true` as its own description (`- [x] \`nyquist_compliant: true\` set in frontmatter`), which was already present before this plan's edits and is unrelated to the frontmatter value actually being set correctly. Not fixed (pre-existing document text, out of this task's scope); frontmatter itself correctly reads `nyquist_compliant: true` exactly once.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- INFRA-01 and INFRA-02 are both complete; Phase 1 (Project Hygiene & Build Isolation) is fully satisfied
- `cabal test kalecky-test` is the documented, proven fast increment loop for Phase 2's `UNIT-01..06` work
- `src/Kalecky/Types/` is a namespace-clean but still entirely uncompiled draft tree — Phase 2 will add the first real module headers (starting with `Scale`, per UNIT-01) and must delete or supersede `Kalecky.Smoke` once the co-designed `Scale` type lands
- `.planning/config.json`'s pre-existing uncommitted `_auto_chain_active` modification (logged in `deferred-items.md` from 01-05) is still unresolved and untouched by this plan — carries forward as a standing item for whoever next runs a plan in this project

---
*Phase: 01-project-hygiene-build-isolation*
*Completed: 2026-08-15*

## Self-Check: PASSED

All 7 referenced files found on disk; all 4 referenced commit hashes (87128d1, 60b1cf5, 5bd5aad, e0ed10c) found in git log.
