---
phase: 01-project-hygiene-build-isolation
verified: 2026-08-15T23:59:00Z
status: passed
score: 4/4 must-haves verified
---

# Phase 1: Project Hygiene & Build Isolation Verification Report

**Phase Goal:** Two non-negotiable prerequisites are resolved before any type work begins — a bisectable git history for the sole deliverable, and a `Kalecky.*` cabal component isolated from hevm's main build graph so the test-first increment loop stays fast.
**Verified:** 2026-08-15T23:59:00Z
**Status:** passed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | `git status` shows `kalecky-spec/`, `kalecky-plank/`, `notes/`, `test/`, `foundry.toml`, `remappings.txt` as tracked, not untracked | ✓ VERIFIED | `./scripts/verify-repo-state.sh` check 1: all six paths report `ok:` with nonzero tracked-file counts (kalecky-spec 190, kalecky-plank 2, notes 1, test 1, foundry.toml 1, remappings.txt 1). `git status --porcelain` shows only pre-existing, deliberately-out-of-scope noise (`.planning/config.json` M, `.github/workflows/test.yml` untracked). |
| 2 | `kalecky-spec.cabal` defines a dedicated `Kalecky.*` library and test-suite stanza, buildable and testable independently of hevm's main library | ✓ VERIFIED | `library kalecky` (line 424) and `test-suite kalecky-test` (line 434) both `import: shared` only (never `test-base`/`test-common`, which pull in the hevm main library). `cd kalecky-spec && cabal test kalecky-test` → `All 2 tests passed`. Clean-state `cabal build kalecky-test --dry-run` lists only `kalecky-spec-0.1.0 (lib:kalecky)` and `(test:kalecky-test)` — no bare `(lib)` (hevm main library) entry. |
| 3 | Running the `Kalecky` test-suite does not trigger a full hevm rebuild | ✓ VERIFIED | Empirically re-ran: warmed the cache, `touch src/EVM.hs`, `cabal build kalecky-test` → `Up to date`, zero `Compiling` lines. Negative control: `Kalecky/Smoke.hs` content edit → `cabal build kalecky-test` correctly shows `Compiling Kalecky.Smoke`, proving the touch-test wasn't a false pass from a stale/broken cache. File reverted afterward (`git status` clean on that file). |
| 4 | Every subsequent increment lands as a reviewable git commit | ✓ VERIFIED | `git log --oneline main..HEAD` shows ~20 commits, every subject conventional-prefixed (`chore`, `feat`, `docs`, `test`, `refactor`). The vendor-import commit (`chore: vendor hevm fork as kalecky-spec`) touches zero `src/Kalecky/` or `kalecky-spec.cabal` files (`git show --stat` on that commit: 0 matches), confirming the blame/bisect boundary the plan specified. |

**Score:** 4/4 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `scripts/verify-repo-state.sh` | INFRA-01 automated oracle | ✓ VERIFIED (with a noted defect) | Executable, exits 0, prints `INFRA-01: PASS`. Five checks all green including the remappings-resolution check added in Plan 05. **Defect (non-blocking):** check 3 ("submodules initialized") has a documented `pipefail`+`grep -q` SIGPIPE race (logged in `deferred-items.md`) that produces a false `ok:` even though the pre-existing `EthereumTests` submodule is genuinely uninitialized (`git submodule status` shows `-EthereumTests...`). This is a real bug in the oracle script, but `EthereumTests` init is explicitly out of INFRA-01's scope (locked decision: "stays as-is") and does not affect any of the four required truths above — none of INFRA-01's six required tracked paths, nor any of the three newly-added `lib/` submodules (all genuinely initialized, confirmed independently), is affected. |
| `kalecky-spec/kalecky-spec.cabal` | `library kalecky` + `test-suite kalecky-test` stanzas | ✓ VERIFIED | Both stanzas present, correctly isolated (`import: shared` only), `kalecky-test` depends on bare-name internal sublibrary `kalecky`, never on `kalecky-spec` (main hevm lib). |
| `kalecky-spec/src/Kalecky/Smoke.hs` | Phase 1 placeholder module, `scaleFactor` | ✓ VERIFIED | Module exists, exports `scaleFactor :: Integer -> Int -> Integer` implementing `b^i`, clearly commented as a placeholder to be superseded by Phase 2's `Scale` type. |
| `kalecky-spec/test-kalecky/Main.hs` | Tasty entry point | ✓ VERIFIED | `defaultMain`, two `tasty-quickcheck` properties over `scaleFactor`, both pass. |
| `kalecky-spec/cabal.project` | Compiler pin | ✓ VERIFIED | `with-compiler: ghc-9.8.4` present, matches `stack.yaml`'s `lts-23.28`. |
| `src/Kalecky/Types/` (renamed from `types/`) | Valid Haskell namespace, consistent imports | ✓ VERIFIED | `git mv` preserved history; zero remaining `Kalecky.types.` (lowercase) references anywhere in `src/Kalecky/`. All 15 draft stub files remain header-less, uncompiled, and unwired from any cabal stanza (Phase 2 scope correctly untouched). |
| `.gitmodules` | Three new submodule declarations | ✓ VERIFIED | `lib/forge-std`, `lib/plank-foundry-deployer`, `lib/plank-monorepo` all declared and initialized (space-prefix in `git submodule status`), alongside the pre-existing (still uninitialized, out-of-scope) `EthereumTests`. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|----|--------|---------|
| `scripts/verify-repo-state.sh` | git index / `.gitmodules` | shell assertions over six INFRA-01 paths | ✓ WIRED | All six paths pass check 1; script executable and correctly exits 0/1 based on repo state (modulo the noted check-3 defect on an out-of-scope submodule). |
| `remappings.txt` | `lib/*/src/` targets | Foundry import remapping over submodule/vendored working trees | ✓ WIRED | Check 5 confirms all five remapping targets resolve to existing paths, including the nested `solady/` target inside `lib/plank-monorepo/plankc/plank-diff-tests/lib/solady/src/`. |
| `test-kalecky/Main.hs` | `src/Kalecky/Smoke.hs` | `import Kalecky.Smoke`, resolved via internal sublibrary `kalecky` | ✓ WIRED | `cabal test kalecky-test` builds and runs the import successfully; 2/2 properties pass. |
| `test-suite kalecky-test` build-depends | `library kalecky` | bare-name internal sublibrary reference | ✓ WIRED | Confirmed in cabal file and via successful build; `library kalecky` compiles independently of the main hevm library (dry-run proof). |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|----------|
| INFRA-01 | 01-01, 01-02, 01-03, 01-04, 01-05 | All core project sources tracked in git so every increment lands as a reviewable commit | ✓ SATISFIED | `./scripts/verify-repo-state.sh` exits 0, prints `INFRA-01: PASS`. REQUIREMENTS.md marks it Complete with matching evidence. |
| INFRA-02 | 01-06 | `Kalecky.*` modules build as a dedicated cabal component with its own test-suite, compilable/testable without rebuilding hevm's main library | ✓ SATISFIED | `cabal test kalecky-test` passes 2/2; dry-run + touch-test + negative-control all confirm isolation. REQUIREMENTS.md marks it Complete with matching evidence. |

No orphaned requirements found — REQUIREMENTS.md's Phase 1 rows (INFRA-01, INFRA-02) both appear in plan frontmatter `requirements:` fields (01-01 through 01-05 declare INFRA-01; 01-06 declares INFRA-02).

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `scripts/verify-repo-state.sh` | 41 | `pipefail` + `grep -q` SIGPIPE race causes check 3 to false-positive "ok" when an uninitialized submodule's status line is matched before `git` finishes writing | ⚠️ Warning | Does not affect any of the four phase-goal truths (all newly-created submodules are genuinely initialized, verified independently); masks a pre-existing, explicitly out-of-scope `EthereumTests` gap. Documented in `deferred-items.md` with a suggested fix. Recommend fixing before Phase 2 relies on this oracle for a scenario where it matters more. |
| `kalecky-spec/src/Kalecky/Types/Units/MoneyUnit.hs` | 1 (comment above) | `TODO(Phase 2, UNIT-01): Kalecky.Types.Currency does not exist yet` | ℹ️ Info | Intentional, plan-specified marker for deferred Phase 2 work; file is an uncompiled stub not wired into any cabal stanza. Not a defect. |
| `.planning/config.json` | — | Uncommitted drift (`_auto_chain_active` key) | ℹ️ Info | Pre-existing, unrelated to this phase's `files_modified` scope; logged in `deferred-items.md`. Does not affect INFRA-01/INFRA-02. |

No blocker anti-patterns found.

### Human Verification Required

None. All four observable truths and both requirements were verified via re-run automated commands (`./scripts/verify-repo-state.sh`, `cabal test kalecky-test`, dry-run build plan, touch/negative-control rebuild tests, git log/show inspection).

### Gaps Summary

No gaps block phase-goal achievement. One non-blocking defect was found and documented: `scripts/verify-repo-state.sh` check 3 has a pipefail/SIGPIPE race that can mask uninitialized submodules under certain orderings. It currently masks only the pre-existing, explicitly out-of-scope `EthereumTests` submodule (locked decision: "stays as-is"), and does not affect verification of any of this phase's required truths — all three submodules created in this phase (`lib/forge-std`, `lib/plank-foundry-deployer`, `lib/plank-monorepo`) were independently confirmed initialized via `git submodule status --recursive` (space-prefixed, no `-`). This is already logged in `deferred-items.md` with a concrete suggested fix for whoever next touches the script.

---

_Verified: 2026-08-15T23:59:00Z_
_Verifier: Claude (gsd-verifier)_
