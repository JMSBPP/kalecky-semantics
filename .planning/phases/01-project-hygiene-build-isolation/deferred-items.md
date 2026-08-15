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
