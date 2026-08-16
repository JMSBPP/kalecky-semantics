---
phase: 01-project-hygiene-build-isolation
plan: 05
subsystem: infra
tags: [git, submodules, foundry, remappings, bash]

# Dependency graph
requires:
  - phase: 01-project-hygiene-build-isolation (Plan 04)
    provides: measured lib/plank-monorepo drift (byte-identical to upstream 3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99) and the user's recorded option-a decision
provides:
  - lib/plank-monorepo tracked as a plain submodule pinned at 3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99
  - scripts/verify-repo-state.sh extended with a check-5 remappings.txt resolution pass (all 5 targets ok)
  - INFRA-01 fully satisfied: ./scripts/verify-repo-state.sh exits 0 and prints INFRA-01: PASS
  - user-approved, bisectable Phase 1 git history (one vendor import commit followed by focused Kalecky commits)
affects: [01-06 (Kalecky.Types isolation plan), Phase 2+ (all future increments rely on INFRA-01 staying green)]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Third lib/ dependency closes out with the same submodule-pin pattern used for lib/forge-std and lib/plank-foundry-deployer in Plan 03, keeping all three lib/ paths uniform (gitlink, mode 160000)"
    - "verify-repo-state.sh check 5 parses remappings.txt as alias=target pairs and asserts every target path exists on disk — a machine-checkable proof that no remapping silently points at a missing or gitignored path"

key-files:
  created: []
  modified:
    - .gitmodules
    - lib/plank-monorepo (submodule gitlink, pinned 3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99)
    - scripts/verify-repo-state.sh (new "== 5. remappings.txt targets resolve ==" section)
    - .planning/phases/01-project-hygiene-build-isolation/01-plank-monorepo-drift.md (deferred-items note appended)

key-decisions:
  - "lib/plank-monorepo pinned as a plain git submodule at the exact byte-identical upstream commit (option-a) rather than vendored or forked — no local delta existed to preserve, so the simpler pin-only path applied"
  - "User approved the Phase 1 history shape as-is: one 'chore: vendor hevm fork as kalecky-spec' commit precedes all Kalecky-specific work, every subject uses a conventional prefix, no rewording requested"

patterns-established:
  - "INFRA-01 gate is now a single command (./scripts/verify-repo-state.sh) covering five independent checks: tracked core sources, no dangling gitlinks, submodules initialized, no stray untracked paths, and remappings.txt resolution — future phases can rely on this oracle staying green"

requirements-completed: [INFRA-01]

# Metrics
duration: 10min
completed: 2026-08-15
---

# Phase 1 Plan 5: Close the plank-monorepo gap and land INFRA-01 Summary

**`lib/plank-monorepo` pinned as a submodule at the verified upstream commit, `verify-repo-state.sh` extended with a remappings-resolution check, and the user signed off on the resulting Phase 1 git history — INFRA-01 is now provably satisfied.**

## Performance

- **Duration:** ~10 min (Tasks 1-2); plus a human-verify checkpoint pause before Task 3 completion
- **Started:** 2026-08-15T23:28:17Z
- **Completed:** 2026-08-15T23:39:03Z
- **Tasks:** 3 (2 auto, 1 checkpoint)
- **Files modified:** 4 (`.gitmodules`, `lib/plank-monorepo`, `scripts/verify-repo-state.sh`, `01-plank-monorepo-drift.md`)

## Accomplishments
- `lib/plank-monorepo` converted from an untracked working-tree copy (with 5 dangling gitdir pointers) into a clean submodule pinned at `3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99`, with the `solady/` remapping target still resolving on disk
- `scripts/verify-repo-state.sh` now runs a fifth check parsing all five `remappings.txt` entries and asserting each target path exists — proven via a clean-room recursive clone, not just the working tree
- `INFRA-01` gate closed: the oracle exits 0 and prints `INFRA-01: PASS`
- User reviewed `git log --oneline --graph -15`, the vendor-import commit's `--stat`, the verifier output, and the plank-monorepo commit, then approved the history shape with no reword requests

## Task Commits

Each task was committed atomically:

1. **Task 1: Execute the recorded plank-monorepo decision (option-a: pin 3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99)** - `0c655db` (chore(lib))
2. **Task 2: Close the INFRA-01 gate (verifier check 5, INFRA-01: PASS, exit 0)** - `3a966be` (chore)
3. **Task 3: Confirm history legibility (checkpoint:human-verify)** - no code changes; user typed "approved" — history shape signed off as-is

**Plan metadata:** (this commit) `docs(01-05): complete execute-plank-monorepo-decision-and-close-infra-01 plan`

_Note: an intermediate `docs(01-05): log plank-monorepo conversion deferred items` commit (`2d1cbae`) also landed between Task 2 and Task 3, recording an out-of-scope discovery to `01-plank-monorepo-drift.md`/`deferred-items.md`._

## Files Created/Modified
- `.gitmodules` - third submodule entry added for `lib/plank-monorepo`
- `lib/plank-monorepo` - gitlink (mode 160000) pinned at `3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99`
- `scripts/verify-repo-state.sh` - new check-5 section: every `remappings.txt` alias=target pair must resolve to an existing path
- `.planning/phases/01-project-hygiene-build-isolation/01-plank-monorepo-drift.md` - deferred-items note appended (see Deviations below)

## Decisions Made
- Pinned `lib/plank-monorepo` as a plain submodule (option-a) at the exact commit measured byte-identical in Plan 04 — no vendored delta patch was needed since the local copy matched upstream exactly
- User approved the Phase 1 history shape without requesting any reword: one vendor-import commit first, Kalecky work in separate single-concern commits on top, all conventional-prefixed

## Deviations from Plan

None affecting the plan's `files_modified` scope, and INFRA-01 closes exactly as specified. Two out-of-scope discoveries surfaced during Task 1 and were logged (not fixed, per the deviation rules' scope boundary) to `deferred-items.md`, committed as `2d1cbae` between Tasks 2 and 3:

### Logged, not fixed (out of scope)

**1. [Scope boundary] Pre-existing `.planning/config.json` drift**
- **Found during:** Task 1 (before any Task 1 command ran)
- **Issue:** `.planning/config.json` already showed `M` in `git status` at the very start of 01-05, with a `"_auto_chain_active": false` key added to `workflow` (and trailing newline dropped) by tooling/a prior session — not caused by this plan
- **Action:** left untouched; deferred to whoever next runs a plan in this phase to intentionally commit or revert
- **Commit (deferred-items note):** `2d1cbae`

**2. [Scope boundary] Task 1's literal "0 gitfiles" verify clause is inapplicable to option-a**
- **Found during:** Task 1 — `find lib/plank-monorepo -name .git -type f | wc -l` reports `6` (the top-level `lib/plank-monorepo/.git` plus 5 nested submodule gitfiles), not `0`
- **Issue:** these are the same 5 paths the Plan 04 drift report flagged as dangling pre-conversion, now correctly re-materialized as genuine, non-dangling git-submodule gitfiles by `git submodule add`/`update --init --recursive` — the expected outcome of option-a per the drift report's own "Nested Submodule Impact" section, not a defect. `git submodule status --recursive` shows no line starting with `-`, and Task 2's clean-room clone reproduced the full nested tree with zero `MISSING IN CLEAN CLONE:` lines
- **Action:** not fixed — the plan's `<acceptance_criteria>` for option-a only requires `git submodule status --recursive` to show no dangling line (which passes); the stricter `<verify>` one-liner appears written for option-b and was left as-is rather than edited mid-execution
- **Commit (deferred-items note):** `2d1cbae`

---

**Total deviations:** 0 auto-fixed; 2 logged-only (both out of `files_modified` scope, no code change)
**Impact on plan:** None — every Task 1-3 acceptance criterion that applies to option-a passed; INFRA-01 (`./scripts/verify-repo-state.sh`) exits 0 and prints `INFRA-01: PASS`.

## Issues Encountered
None. Both automated tasks passed their `<verify>` commands on the first attempt (checkpoint evidence gathered in the prior session before this continuation).

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- INFRA-01 is fully and machine-checkably satisfied; every future increment can rely on `./scripts/verify-repo-state.sh` exiting 0 as a pre-commit sanity check
- Phase 1's remaining plan, 01-06 (`Kalecky.Types` casing/import hygiene, isolated `kalecky` sublibrary + `kalecky-test` smoke suite), is unblocked and can proceed
- No blockers carried forward from this plan; the `EthereumTests` uninitialized-submodule and `verify-repo-state.sh` check-3 pipefail items from earlier plans remain logged in `deferred-items.md` and are still out of INFRA-01's scope

---
*Phase: 01-project-hygiene-build-isolation*
*Completed: 2026-08-15*

## Self-Check: PASSED

- FOUND: `.planning/phases/01-project-hygiene-build-isolation/01-05-SUMMARY.md`
- FOUND: commit `0c655db`
- FOUND: commit `3a966be`
- FOUND: commit `2d1cbae`
