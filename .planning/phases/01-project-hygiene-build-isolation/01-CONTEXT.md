# Phase 1: Project Hygiene & Build Isolation - Context

**Gathered:** 2026-08-15
**Status:** Ready for planning

<domain>
## Phase Boundary

Two non-negotiable prerequisites before any type work: (1) all core project sources tracked in git with a bisectable history, and (2) a `Kalecky.*` cabal component isolated from hevm's main build graph so the test-first increment loop stays fast. No CI, no type implementation — those belong to later phases.

</domain>

<decisions>
## Implementation Decisions

### Nested repo strategy
- **Absorb** `kalecky-spec/.git` into the outer repo: remove the inner `.git` (its single local commit "chore: initialize from hevm" has nothing worth preserving) and commit the contents directly
- **One import commit** for the upstream hevm fork ("vendor hevm fork" style), with Kalecky-specific work in separate commits on top — keeps blame/bisect clean
- Package identity is **kalecky-spec**; the `hevm.cabal` deletion inside it is intentional and gets committed
- **No CI in this phase** — git hygiene + local cabal component only

### Track vs ignore policy
- `lib/` dependencies (forge-std, plank-foundry-deployer, plank-monorepo) become **git submodules pinned to their upstream commits** — user states all three have public upstreams and local copies are unmodified (planner should still verify with a diff before deleting local copies; if a diff shows local modifications, stop and surface it)
- Gitignore all build artifacts: `cache/`, `out/`, `.stack-work/`, `dist-newstyle/`
- Track **all of `notes/`** — the whole directory is project record; specs evolve in place with history
- Existing `EthereumTests` submodule stays as-is

### Cabal component shape
- **Sublibrary + test-suite** inside `kalecky-spec.cabal`: `library kalecky` exposing `Kalecky.*` modules, plus `test-suite kalecky-test` depending only on the sublibrary — mirrors the existing `library test-utils` pattern; running `kalecky-test` must not rebuild hevm's main library
- **Fix module-tree casing now**: rename `src/Kalecky/types/` → `src/Kalecky/Types/` (lowercase segments are invalid Haskell module names) and fix broken imports (e.g., `Wage.hs` imports `Kalecky.types.Units.Per`, which doesn't exist — should reference `CompoundUnit`); `Operators/` modules get consistent paths too
- Test runner: **Tasty + tasty-quickcheck + quickcheck-classes** — consistent with the package's existing test-suites and the stack research
- Phase 1 "done" includes a **trivial smoke test** that runs and passes via `cabal test kalecky-test` (or stack equivalent), proving the loop end-to-end without an hevm rebuild; the real co-designed Scale test still belongs to Phase 2

### Branch & commit flow
- **Branch per phase** off `main` (e.g., `phase/01-hygiene`); merge to main when the phase verifies. `docs/model-init` (current branch, holds planning docs) should be merged so phase branches can start from main
- **Conventional commits**: `feat(kalecky):`, `test(kalecky):`, `chore:`, `docs:` — matches existing history and GSD's own commits
- **Test-then-impl commit pairs** for type increments: `test(kalecky): add approved X laws` → `feat(kalecky): implement X` — the co-designed-test-first process stays visible in history (applies from Phase 2 onward; recorded here as the standing workflow decision)

### Claude's Discretion
- Exact `.gitignore` contents beyond the four listed artifact dirs
- Whether the smoke test is a Scale-shaped placeholder or any minimal property — as long as it's tiny and does not pre-empt Phase 2's co-designed Scale test
- Exact submodule pinning mechanics and `remappings.txt` adjustments if paths change
- Stack vs cabal invocation details for the isolated test loop (`stack.yaml` components exist alongside the cabal file)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project planning
- `.planning/PROJECT.md` — project vision, constraints, key decisions (incl. EconomicQuantity → Price change)
- `.planning/REQUIREMENTS.md` — INFRA-01, INFRA-02 definitions this phase must satisfy
- `.planning/ROADMAP.md` — Phase 1 success criteria

### Codebase state
- `.planning/codebase/CONCERNS.md` — untracked-files audit and cabal-hygiene concerns this phase resolves
- `.planning/codebase/STACK.md` — existing build toolchain (Stack LTS 23.28 / Cabal / Nix) the component must fit
- `.planning/research/PITFALLS.md` — "increment zero" rationale and cabal component hygiene pitfalls
- `.planning/research/STACK.md` — extensions/deps for the sublibrary stanza (GADTs, DerivingStrategies, DerivingVia; Decimal; quickcheck-classes)

### Domain spec (context for module tree, not implemented this phase)
- `notes/INCOME_DISTRIBUTION.md` — source-of-truth spec; the module tree being renamed hosts its types
- `kalecky-spec/src/Kalecky/types/**` — current draft tree with design notes (Unit/Price); renamed to `Kalecky/Types/` this phase, comment content preserved

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `kalecky-spec/kalecky-spec.cabal` existing stanza patterns: `library test-utils` (internal sublibrary) and six `test-suite` stanzas — the `library kalecky` + `test-suite kalecky-test` stanzas follow the same shape
- Existing dependencies already in the package: QuickCheck 2.14.3, tasty, Decimal 0.5.x — no new top-level deps needed except possibly quickcheck-classes (in LTS 23.28)

### Established Patterns
- Conventional commit history in outer repo (`docs:`, `chore:`, merge PRs)
- `EthereumTests` is already a submodule — submodule workflow exists in this repo
- Root `.gitignore` already ignores Lean artifacts (`*.olean`, `.lake/`) — extend, don't replace

### Integration Points
- Outer repo currently sees `kalecky-spec/` as an untracked directory because of the nested `.git` — absorption unblocks tracking
- `remappings.txt` references `lib/` paths — must keep resolving after submodule conversion
- `foundry.toml` (src=kalecky-plank, test=test/kalecky-plank) untouched by this phase apart from being committed

### Verified facts (scout)
- `kalecky-spec/.git` exists: 1 commit, no remote; inside it `kalecky-spec.cabal`, `stack.yaml`, `stack.yaml.lock`, `src/Kalecky/` are untracked and `hevm.cabal` is deleted
- `lib/` subdirectories have **no** nested `.git` — submodule conversion means: verify pristine vs upstream, remove local copy, `git submodule add` at the matching commit
- `cache/` and `out/` are Foundry artifacts present on disk; `.stack-work/` exists inside kalecky-spec

</code_context>

<specifics>
## Specific Ideas

- History legibility is the point: one vendor commit for upstream, then Kalecky commits on top; later phases show red→green test-then-impl pairs
- The isolation criterion is observable: running the Kalecky test-suite must not trigger an hevm main-library rebuild

</specifics>

<deferred>
## Deferred Ideas

- Minimal CI workflow building the kalecky component (the untracked `.github/workflows/test.yml` needs review/ownership) — later phase or milestone
- Root-level build orchestration across Lean/Haskell layers (flagged in CONCERNS.md) — not this milestone

</deferred>

---

*Phase: 01-project-hygiene-build-isolation*
*Context gathered: 2026-08-15*
