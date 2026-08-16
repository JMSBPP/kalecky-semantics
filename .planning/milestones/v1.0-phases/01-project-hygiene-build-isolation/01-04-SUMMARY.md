---
phase: 01-project-hygiene-build-isolation
plan: 04
subsystem: infra
tags: [git-submodules, plank-monorepo, drift-analysis, checkpoint-decision, INFRA-01]

# Dependency graph
requires:
  - phase: 01-project-hygiene-build-isolation (01-03)
    provides: lib/forge-std and lib/plank-foundry-deployer converted to pinned submodules; byte-identity verification pattern established
provides:
  - "Measured drift report for lib/plank-monorepo against upstream (https://github.com/plankevm/plank-monorepo.git)"
  - "Discovery that lib/plank-monorepo is byte-identical to a real historical upstream commit (3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99), not a hand-edited fork"
  - "Quantified nested-submodule hazards: 5 dangling .git gitfile pointers, and a self-ignored plankc/plank-diff-tests/lib/ tree that would silently drop 576 of 1401 files (825 vs 1401) from git add"
  - "User-recorded decision (option-a) selecting the exact conversion Plan 05 must execute"
affects: [01-project-hygiene-build-isolation (Plan 05, lib/plank-monorepo conversion)]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Bisect drift against upstream history via git log --oneline -- <distinguishing-file>, walking newest-to-oldest and stopping at the first zero-diff candidate, rather than assuming HEAD or a single sampled commit is the reference point"

key-files:
  created: []
  modified:
    - .planning/phases/01-project-hygiene-build-isolation/01-plank-monorepo-drift.md

key-decisions:
  - "Task 1 measured drift: local lib/plank-monorepo is byte-identical (0 differing files, both directions, full 1401-file tree) to upstream commit 3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99, four commits behind current upstream HEAD (d1cbd2c). The 52-file drift 01-RESEARCH.md found was a HEAD-relative artifact of upstream having moved on, not evidence of local hand-edits or a fork."
  - "Task 2 (checkpoint:decision): user selected option-a — pin the exact-match commit 3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99 as a plain git submodule. Because the match is byte-identical, option-a collapses to a pure commit pin with no patch-apply step needed (functionally identical to option-d for this specific case, but chosen for the clearer 'explicit updatable pin' framing in commit history)."
  - "No conversion was performed in this plan — per the plan's explicit scope boundary, lib/plank-monorepo remains untouched (still 1401 files, still untracked) and the recorded decision drives Plan 05's execution."

patterns-established:
  - "Pattern: when converting a lib/ dependency that research flagged as drifted, bisect the full commit history of a distinguishing file (not just a handful of hand-picked candidates) before concluding no exact match exists — the research's sampled-commit check can miss the true pin point."

requirements-completed: []

# Metrics
duration: ~5min (Task 2 only; Task 1 measurement was completed in a prior session before this checkpoint resume)
completed: 2026-08-15
---

# Phase 1 Plan 04: Measure plank-monorepo Drift and Record Tracking Decision Summary

**Drift report proves `lib/plank-monorepo` is byte-identical to upstream commit `3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99` (not a hand-edited fork), and the user recorded `option-a` — pin that exact commit as a plain submodule — as the decision Plan 05 will execute.**

## Performance

- **Duration:** ~5 min for the resumed Task 2 (checkpoint decision + recording); Task 1's drift measurement was completed and committed in a prior session (commit `8446042`) before this checkpoint was reached
- **Started:** 2026-08-15T23:18:40Z (Task 1 commit timestamp, prior session)
- **Completed:** 2026-08-15T23:23:10Z (Task 2 decision commit timestamp)
- **Tasks:** 2/2
- **Files modified:** 1 (`.planning/phases/01-project-hygiene-build-isolation/01-plank-monorepo-drift.md`, across two commits)

## Accomplishments
- Recursively cloned upstream `plank-monorepo` and diffed against the local copy at HEAD (52 differing files, matching 01-RESEARCH.md), then bisected the history of `plankc/justfile` to find the true pin point
- Found an exact match at commit `3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99` (2026-08-11) — zero differing files across the full 1401-file tree, both directions — proving the 52-file HEAD-relative drift is upstream progress (4 commits' worth), not local modification
- Quantified two silent-breakage hazards in the nested-submodule structure: 5 dangling `.git` gitfile pointers (targets no longer exist) and a self-ignored `plankc/plank-diff-tests/lib/` tree that would drop the `solady/` remapping target (576 of 1401 files) from a plain `git add`
- Presented the report's Closest Match, Nested Submodule Impact, Assessment, and Recommendation to the user at the `checkpoint:decision` gate; user selected `option-a` (pin `3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99` as a plain submodule, no patch step needed since the match is byte-identical)
- Recorded the decision in the drift report's `## Decision` section, matching the required `**Chosen:** option-[abcd]` pattern Plan 05 Task 1 parses to select its conversion branch

## Task Commits

Each task was committed atomically:

1. **Task 1: Measure the plank-monorepo drift and write the report** - `8446042` (docs)
2. **Task 2: Decide how lib/plank-monorepo is tracked (checkpoint:decision)** - `d251177` (docs)

**Plan metadata:** (this commit, docs: complete plan)

## Files Created/Modified
- `.planning/phases/01-project-hygiene-build-isolation/01-plank-monorepo-drift.md` - Drift report: method, 14-candidate bisection table, closest match (byte-identical), full classification of differing files (all empty — no local-only, no upstream-only, no content differs), representative HEAD-relative diffs, nested submodule impact analysis, assessment, recommendation, and the final recorded `## Decision` (option-a)

## Decisions Made
- **option-a selected by user:** pin `3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99` as a plain submodule. Rationale (user's words): "explicit updatable upstream relationship, nested submodules resolve via recursive init, solady/ remapping keeps working." Since the match is byte-identical, no patch step is needed — this is a pure exact-commit pin, functionally equivalent to option-d for this dependency but framed as an explicit pin rather than a discard.

## Deviations from Plan

None — plan executed exactly as written. Task 1's measurement and Task 2's checkpoint decision both matched the plan's specified procedure and output shape exactly; no auto-fixes, no scope changes, no architectural decisions required.

## Issues Encountered

None. Both automated verification gates (`grep -qE '^\*\*Chosen:\*\* option-[abcd]$'`, `grep -c '^## Decision$'` == 1, `find lib/plank-monorepo ... | wc -l` == 1401) passed on first check. `./scripts/verify-repo-state.sh` still exits 1 with its single FAIL naming `lib/plank-monorepo/`, confirmed unchanged from Plan 03 — exactly as the plan's own verification step expects, since conversion is deferred to Plan 05.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Plan 05 has everything it needs: a recorded `**Chosen:** option-a` line to parse, the exact pin SHA (`3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99`), and documented confirmation that no patch-apply step is needed (byte-identical match)
- Plan 05 must still handle the nested-submodule hazards this report quantified: the 5 dangling `.git` gitfile pointers should resolve naturally via `git submodule update --init --recursive` on the new submodule (not a concern for option-a specifically), and `remappings.txt` line 4 should continue to resolve once the nested `solady` submodule is recursively initialized
- INFRA-01 remains correctly unchecked in REQUIREMENTS.md ("In Progress" — check 4 red on `lib/plank-monorepo`) until Plan 05 completes the actual conversion and `scripts/verify-repo-state.sh` reports a clean PASS

---
*Phase: 01-project-hygiene-build-isolation*
*Completed: 2026-08-15*

## Self-Check: PASSED

- FOUND: `.planning/phases/01-project-hygiene-build-isolation/01-plank-monorepo-drift.md`
- FOUND: `.planning/phases/01-project-hygiene-build-isolation/01-04-SUMMARY.md`
- FOUND: commit `8446042` (Task 1)
- FOUND: commit `d251177` (Task 2 / decision)
