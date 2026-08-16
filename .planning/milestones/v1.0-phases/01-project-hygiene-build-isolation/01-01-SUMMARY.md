---
phase: 01-project-hygiene-build-isolation
plan: 01
subsystem: infra
tags: [git, gitignore, foundry, cabal, stack, nix, bash, verification]

# Dependency graph
requires: []
provides:
  - "phase/01-hygiene branch, branched from an up-to-date main containing all planning docs"
  - "Extended root .gitignore covering Foundry, Cabal, Stack, and Nix build artifacts"
  - "scripts/verify-repo-state.sh — automated INFRA-01 oracle (currently RED, correctly)"
affects: [01-02, 01-03, 01-04, 01-05, 01-06]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Root .gitignore is extended (never replaced) to preserve pre-existing Lean/python rules"
    - "INFRA-01 verifier reads .gitmodules dynamically rather than hardcoding submodule names"

key-files:
  created: [scripts/verify-repo-state.sh]
  modified: [.gitignore, README.md]

key-decisions:
  - "Advanced main via `git fetch . docs/model-init:main` (ref-only update) instead of `git switch main && git merge`, to avoid transiently deleting .planning/ from the worktree"

patterns-established:
  - "INFRA-01 verifier script format: numbered check sections (tracked paths / gitlinks / submodules / untracked stray paths), each with ok:/FAIL: lines and a final PASS/FAIL summary, exit code mirrors overall pass/fail"

requirements-completed: [INFRA-01]

# Metrics
duration: ~15min
completed: 2026-08-15
---

# Phase 1 Plan 01: Repo Hygiene Scaffolding Summary

**Cut `phase/01-hygiene` off an up-to-date `main`, extended root `.gitignore` for Foundry/Cabal/Stack/Nix artifacts, and shipped a RED `scripts/verify-repo-state.sh` INFRA-01 oracle.**

## Performance

- **Duration:** ~15 min
- **Completed:** 2026-08-15T22:53:12Z
- **Tasks:** 3/3 completed
- **Files modified:** 3 (README.md, .gitignore, scripts/verify-repo-state.sh created)

## Accomplishments
- Fast-forwarded `main` to `docs/model-init` (ref-only, no worktree churn) and branched `phase/01-hygiene` off it — all planning docs now reachable from `main`.
- Extended root `.gitignore` with Foundry (`cache/`, `out/`, `broadcast/`), Cabal (`dist-newstyle/`, `dist/`, `*.hi`, `*.o`), Stack (`.stack-work/`, `**/.stack-work/`), and Nix (`result`, `result-*`) rules, without disturbing pre-existing Lean/python entries.
- Shipped `scripts/verify-repo-state.sh`, an executable INFRA-01 oracle that checks (1) six core paths are tracked, (2) no dangling gitlinks, (3) all submodules initialized, (4) no stray untracked paths beyond the deferred `.github/` — confirmed RED today (`INFRA-01: FAIL`), as intended.

## Task Commits

Each task was committed atomically:

1. **Task 1: Fast-forward main and cut the phase branch** - `a05ec05` (docs, on docs/model-init before fast-forward)
2. **Task 2: Extend root .gitignore with build-artifact rules** - `f3ba37c` (chore)
3. **Task 3: Create the INFRA-01 repo-state verifier script** - `aeba21d` (chore)

_Note: Task 1's commit (`a05ec05`) landed on `docs/model-init` prior to the fast-forward; `main` and `phase/01-hygiene` both now point through it._

## Files Created/Modified
- `README.md` - Updated for kalecky-semantics fork content (Foundry usage docs replacing prior Lean-only description)
- `.gitignore` - Extended with Foundry/Cabal/Stack/Nix artifact-ignore rules, preserving existing Lean/python rules
- `scripts/verify-repo-state.sh` - New executable INFRA-01 verifier (65 lines): tracked-paths check, dangling-gitlink check, submodule-init check, stray-untracked-path check

## Decisions Made
- Used `git fetch . docs/model-init:main` rather than checking out `main` directly, per the plan's explicit guidance — checking out `main` would have transiently removed `.planning/` from the worktree since it only existed on `docs/model-init` prior to the fast-forward.

## Deviations from Plan

None — plan executed exactly as written. One incidental observation: the plan's own inline verify snippet for Task 2 (`git check-ignore -q cache out`) errors under git 2.54 with `fatal: --quiet is only valid with a single pathname` (newer git restricts `-q` to a single path). This is a plan-script portability quirk, not a defect in `.gitignore` or the repo — verified instead via two single-path invocations (`git check-ignore -q cache`, `git check-ignore -q out`), both exit 0, and `git status --porcelain` no longer lists `cache/` or `out/` as untracked, confirming Task 2's actual acceptance criteria are met.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- `phase/01-hygiene` is checked out and ready for Plan 02 (tracking `kalecky-spec/` and friends) to `git add` sources without sweeping in build artifacts.
- `scripts/verify-repo-state.sh` gives Plans 02-05 a shared, automated pass/fail oracle for INFRA-01; it currently reports FAIL as expected and should be re-run after each subsequent plan to track progress toward GREEN.
- Nothing pushed; all work is local to `phase/01-hygiene`.

---
*Phase: 01-project-hygiene-build-isolation*
*Completed: 2026-08-15*

## Self-Check: PASSED

- FOUND: scripts/verify-repo-state.sh
- FOUND: .gitignore
- FOUND: .planning/phases/01-project-hygiene-build-isolation/01-01-SUMMARY.md
- FOUND: a05ec05 (Task 1 commit)
- FOUND: f3ba37c (Task 2 commit)
- FOUND: aeba21d (Task 3 commit)
