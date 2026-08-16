# Deferred Items — Phase 1

Out-of-scope discoveries logged during plan execution, per the executor's
scope-boundary rule (only auto-fix issues directly caused by the current
task's changes).

## From 01-02 (Task 3 / plan-level verification)

**Item:** `EthereumTests` submodule is declared in `.gitmodules` but not
initialized (`git submodule status` shows a `-` prefix, i.e. the working
tree checkout is empty).

**Evidence:** `.gitmodules` last touched by pre-Phase-1 commit `7879546
force HTTPS on gitmodules for the CI` — predates this project's Phase 1
work entirely; not introduced or modified by 01-01 or 01-02.

**Impact:** `scripts/verify-repo-state.sh` check 3 ("submodules
initialized") fails alongside the expected check 4 (`lib/` untracked)
failure. The 01-02-PLAN.md verification section anticipated only checks
1/2/3 passing with check 4 as the sole failure; check 3 also fails for
this pre-existing, unrelated reason.

**Why deferred:** Locked decision in 01-CONTEXT.md: "Existing
`EthereumTests` submodule stays as-is." Initializing it is unrelated to
INFRA-01's six tracked paths and to the `lib/` submodule conversion
planned for Plans 03-05. Not fixed here.

**Suggested owner:** Revisit alongside the Plans 03-05 submodule work,
or explicitly scope a `git submodule update --init` step if
`EthereumTests`-backed tests are needed before then.

## From 01-03 (Task 2 / plan-level verification)

**Item:** `scripts/verify-repo-state.sh` check 3 ("submodules initialized",
lines 40-47) has a `pipefail` + `grep -q` short-circuit bug that produces
false-negative "ok" results whenever an uninitialized submodule's status
line is matched by `grep -q '^-'` before `git submodule status
--recursive` finishes writing its full output.

**Evidence:** `grep -q` exits immediately once it finds the first
matching line (here, `EthereumTests` is the first of three submodules
listed). `git`, still writing later lines, receives SIGPIPE and exits
141. With `set -o pipefail` active, the pipeline's exit status becomes
git's non-zero 141 rather than grep's successful 0 — so `if pipeline;
then` evaluates false and the script prints `ok:   all submodules
initialized` even though `EthereumTests` is genuinely uninitialized
(confirmed independently: `git submodule status` shows a `-` prefix for
`EthereumTests`, an empty working directory, and no
`.git/modules/EthereumTests`). Reproduced deterministically 5/5 runs;
root-caused by comparing an isolated repro with vs without `set -o
pipefail`.

**Impact:** Check 3 cannot currently detect any uninitialized submodule
as long as at least one is initialized (so `grep -q` finds a match and
exits before the last `git` writer line completes). It happens to
produce output consistent with this plan's expected "exactly one FAIL
block naming lib/plank-monorepo/", but for the wrong reason — it is
silently masking the pre-existing, already-deferred `EthereumTests`
uninitialized state rather than correctly reporting it.

**Why deferred:** `scripts/verify-repo-state.sh` is not in 01-03's
`files_modified` scope, and the underlying `EthereumTests` gap it's
masking is already a locked, deferred decision (see previous entry). Not
fixed here.

**Suggested owner:** Whoever next touches `scripts/verify-repo-state.sh`
— fix by capturing output to a variable first (`out=$(git submodule
status --recursive 2>/dev/null); printf '%s\n' "$out" | grep -q '^-'`) to
avoid the SIGPIPE race, or drop `pipefail` for that one check.

## From 01-05 (Task 1 / plank-monorepo conversion)

**Item:** `.planning/config.json` shows as modified (`M`) in `git status`
throughout this plan's execution — a `"_auto_chain_active": false` key
was added to the `workflow` object (and the file's trailing newline was
dropped) by tooling/a prior session, before this plan's Task 1 began.

**Evidence:** `git status --porcelain` at the very start of 01-05
execution (before any Task 1 command ran) already showed `M
.planning/config.json`. `git diff .planning/config.json` shows only the
`_auto_chain_active` key addition and a `\ No newline at end of file`
marker — nothing touched by this plan.

**Impact:** The plan's overall `<verification>` item 2 (`git status
--porcelain | grep -v '^?? \.github/'` produces no output) does not
literally pass — it reports this one pre-existing modified line. Not
caused by, or in the `files_modified` scope of, 01-05.

**Why deferred:** Out of `files_modified` scope for 01-05 (`.gitmodules`,
`lib/plank-monorepo`, `scripts/verify-repo-state.sh`, this drift report).
Committing or reverting it is a planning-tool config decision, not a
Phase 1 infra-hygiene decision.

**Suggested owner:** Whoever next runs a plan in this phase — either
commit `.planning/config.json` intentionally (with a `chore(planning):`
prefix) or revert it, so `git status --porcelain` returns clean going
forward.

## From 01-05 (Task 1 / plank-monorepo conversion)

**Item:** `find lib/plank-monorepo -name .git -type f | wc -l` reports
`6` (the top-level `lib/plank-monorepo/.git` plus 5 nested submodule
gitfiles), not `0`, even though Task 1's literal automated `<verify>`
line asks for `0`.

**Evidence:** These are the same 5 relative paths the drift report
flagged as "dangling" in the pre-conversion vendored copy, now
re-materialized as genuine (non-dangling) git-submodule gitfiles by
`git submodule add` / `git submodule update --init --recursive` per
option-a. `git submodule status --recursive` shows no line starting with
`-` for any of the 6 paths (all initialized, all resolve), and the
clean-room recursive clone in Task 2 reproduced the entire nested tree
with zero `MISSING IN CLEAN CLONE:` output — proving none of the 6 point
at anything dangling.

**Why deferred / not fixed:** The plan's own drift report (Nested
Submodule Impact section) states option-a "materializes
`plankc/plank-diff-tests/lib/solady` as its own real submodule ...
independent of the self-ignore" — i.e. real `.git` gitfiles for the
nested paths are the *expected, correct* outcome of option-a, not a
defect to fix. Task 1's `<acceptance_criteria>` itself only requires,
for option-a, that `git submodule status --recursive` show no line
starting with `-` — which passes. The literal "`0` gitfiles" clause in
the automated `<verify>` one-liner appears written for option-b
(vendored, no submodules), where dangling `.git` files must be deleted;
it is inapplicable to option-a's submodule mechanics and was not
weakened or edited here — just not satisfiable while staying faithful to
the recorded option-a decision.

**Suggested owner:** Whoever next edits `01-05-PLAN.md`'s Task 1
`<verify>` block — scope the `.git`-file-count assertion to the
option-b branch only (e.g. gate it behind the same `If option-b:` /
`If option-a/c/d:` conditional already used in `<acceptance_criteria>`).
