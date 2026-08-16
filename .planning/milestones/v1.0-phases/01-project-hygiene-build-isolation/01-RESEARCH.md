# Phase 1: Project Hygiene & Build Isolation - Research

**Researched:** 2026-08-15
**Domain:** Git repository hygiene (nested-repo absorption, submodule conversion) + Cabal/Stack multi-component build isolation (GHC 9.8.4 / LTS 23.28)
**Confidence:** HIGH — every load-bearing claim in this document was verified by direct reproduction in this repository or a throwaway sandbox package, not by recalled/trained knowledge.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Nested repo strategy**
- Absorb `kalecky-spec/.git` into the outer repo: remove the inner `.git` (its single local commit "chore: initialize from hevm" has nothing worth preserving) and commit the contents directly
- One import commit for the upstream hevm fork ("vendor hevm fork" style), with Kalecky-specific work in separate commits on top — keeps blame/bisect clean
- Package identity is kalecky-spec; the `hevm.cabal` deletion inside it is intentional and gets committed
- No CI in this phase — git hygiene + local cabal component only

**Track vs ignore policy**
- `lib/` dependencies (forge-std, plank-foundry-deployer, plank-monorepo) become git submodules pinned to their upstream commits — user states all three have public upstreams and local copies are unmodified (planner should still verify with a diff before deleting local copies; if a diff shows local modifications, stop and surface it)
- Gitignore all build artifacts: `cache/`, `out/`, `.stack-work/`, `dist-newstyle/`
- Track all of `notes/` — the whole directory is project record; specs evolve in place with history
- Existing `EthereumTests` submodule stays as-is

**Cabal component shape**
- Sublibrary + test-suite inside `kalecky-spec.cabal`: `library kalecky` exposing `Kalecky.*` modules, plus `test-suite kalecky-test` depending only on the sublibrary — mirrors the existing `library test-utils` pattern; running `kalecky-test` must not rebuild hevm's main library
- Fix module-tree casing now: rename `src/Kalecky/types/` → `src/Kalecky/Types/` (lowercase segments are invalid Haskell module names) and fix broken imports (e.g., `Wage.hs` imports `Kalecky.types.Units.Per`, which doesn't exist — should reference `CompoundUnit`); `Operators/` modules get consistent paths too
- Test runner: Tasty + tasty-quickcheck + quickcheck-classes — consistent with the package's existing test-suites and the stack research
- Phase 1 "done" includes a trivial smoke test that runs and passes via `cabal test kalecky-test` (or stack equivalent), proving the loop end-to-end without an hevm rebuild; the real co-designed Scale test still belongs to Phase 2

**Branch & commit flow**
- Branch per phase off `main` (e.g., `phase/01-hygiene`); merge to main when the phase verifies. `docs/model-init` (current branch, holds planning docs) should be merged so phase branches can start from main
- Conventional commits: `feat(kalecky):`, `test(kalecky):`, `chore:`, `docs:` — matches existing history and GSD's own commits
- Test-then-impl commit pairs for type increments (applies from Phase 2 onward; recorded here as the standing workflow decision)

### Claude's Discretion
- Exact `.gitignore` contents beyond the four listed artifact dirs
- Whether the smoke test is a Scale-shaped placeholder or any minimal property — as long as it's tiny and does not pre-empt Phase 2's co-designed Scale test
- Exact submodule pinning mechanics and `remappings.txt` adjustments if paths change
- Stack vs cabal invocation details for the isolated test loop (`stack.yaml` components exist alongside the cabal file)

### Deferred Ideas (OUT OF SCOPE)
- Minimal CI workflow building the kalecky component (the untracked `.github/workflows/test.yml` needs review/ownership) — later phase or milestone
- Root-level build orchestration across Lean/Haskell layers (flagged in CONCERNS.md) — not this milestone
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-------------------|
| INFRA-01 | All core project sources (`kalecky-spec/`, `kalecky-plank/`, `notes/`, `test/`, `foundry.toml`, `remappings.txt`) tracked in git so every increment lands as a reviewable commit | "Git Absorption Procedure" and "Submodule Conversion" sections give the exact verified command order, upstream URLs, and the gitlink pitfall to avoid |
| INFRA-02 | `Kalecky.*` modules build as a dedicated cabal component with its own test-suite, compilable/testable without rebuilding hevm's main library | "Empirically Verified: cabal vs stack isolation" section proves (by direct reproduction, not inference) which tool gives isolation and which doesn't, plus the exact cabal stanza shape to use |
</phase_requirements>

## Summary

This phase has two independent halves — git hygiene and build isolation — and both were verified empirically rather than assumed, because both hide tool-behavior traps that training-data knowledge gets wrong.

For git: `kalecky-spec/` is a nested repo (`.git` present, 1 orphan commit, no remote) that must be absorbed by deleting its `.git` directory *before* `git add`-ing it from the outer repo — adding it while `.git` still exists creates a dangling gitlink (mode `160000`) with no `.gitmodules` entry, which is silently broken and easy to miss. The three `lib/` dependencies have no nested `.git` and must become submodules; this research identified and verified their upstream URLs, and — critically — found that **two of the three are byte-identical to the exact current upstream HEAD** (safe to pin immediately) while **the third, `plank-monorepo`, is NOT byte-identical to any upstream commit sampled**, meaning the user's "unmodified" assumption does not fully hold and a real bisection is needed before that submodule can be pinned honestly.

For build isolation: this research directly reproduced the phase's hardest technical claim in a throwaway sandbox package (main library with a deliberate type error + internal sublibrary + test-suite depending only on the sublibrary). **`cabal build`/`cabal test` on the sublibrary target correctly skips the broken main library and succeeds. `stack build` on the identical target structure always configures and attempts to build the main library too, and fails on its type error.** This is a load-bearing, previously-undocumented-in-CONTEXT finding: the isolated test loop in this phase's success criterion is only achievable through direct `cabal` invocation, not `stack build`/`stack test`, even though `stack.yaml` remains the project's overall toolchain manager. All target packages needed (Decimal, QuickCheck, tasty, tasty-quickcheck, quickcheck-classes) resolve cleanly from the LTS 23.28 snapshot with zero `extra-deps` additions — confirmed by a live `stack build --dry-run` against a package requiring all five.

Separately, this research found that **every existing file under `src/Kalecky/`** (all 15 files, across both `types/` and `Operators/`) **is a comment-only or header-less stub — none currently has a `module … where` declaration**, which is a stricter problem than the casing/import fixes CONTEXT.md called out. Registering any of them in the new cabal stanza's `exposed-modules`/`other-modules` today would fail to compile. The recommended resolution (consistent with CONTEXT's discretion note and the "one type per increment" roadmap) is: rename/fix the tree for consistency, but expose **nothing from the draft tree** in Phase 1's `library kalecky` — build the smoke test against a trivial placeholder module instead, deferring real modules to Phase 2+ as their types are co-designed.

**Primary recommendation:** Use `cabal build kalecky-test` / `cabal test kalecky-test` (bare cabal, not stack) as the Phase-1-and-onward fast increment loop; absorb `kalecky-spec/.git` via `rm -rf` before `git add`; convert `forge-std` and `plank-foundry-deployer` to submodules pinned at their verified exact-match commits immediately, but treat `plank-monorepo`'s pin as an open verification task, not a given.

## Standard Stack

### Core
| Library | Version (LTS 23.28) | Purpose | Why Standard |
|---------|---------|---------|--------------|
| tasty | 1.5.3 | Test-suite runner/tree | Already used by all 6 existing hevm test-suites in this package — consistent driver |
| tasty-quickcheck | 0.11 | Property-based testing under Tasty | Matches existing `test-suite test` dependency; required by PROOF-01 for later phases |
| QuickCheck | 2.14.3 | Property generation/shrinking engine | Already a `library` (main hevm) dependency (bound `>=2.13.2 && <2.16`); tasty-quickcheck depends on it transitively |
| quickcheck-classes | 0.6.5.0 | Law-checking combinators (Eq, Ord, Semigroup, etc.) for QuickCheck | Confirmed present in LTS 23.28 snapshot (no extra-deps needed); assigned to PROOF-01 starting Phase 2, but the dependency can be declared now if the smoke test wants a trivial law check |
| Decimal | 0.5.2 | Exact fixed/arbitrary-precision decimal arithmetic | Already a `library` (main hevm) dependency (bound `>=0.5.1 && <0.6`); UNIT-06 requires exact Decimal arithmetic — same version to be reused, not re-pinned |

### Supporting
None needed for Phase 1's trivial smoke test. `base` only, beyond the Core table.

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `cabal build`/`cabal test` for the isolated loop | `stack build`/`stack test` | Verified (see below) that stack always builds the package's default/main library alongside any requested target — breaks the isolation success criterion. Not viable for the fast loop, though stack remains fine for whole-project/CI builds later. |
| Internal (private) sublibrary `library kalecky` | Separate cabal package (own `.cabal` file, own directory) | A separate package gives stronger isolation guarantees and its own version, but requires a second `cabal.project`/`stack.yaml` entry and breaks the "mirrors `library test-utils`" pattern CONTEXT.md explicitly asked for. Not recommended; internal sublibrary already proven sufficient (see below). |

**Installation:** No new packages need adding to `stack.yaml extra-deps` — all five packages above resolve directly from the `lts-23.28` snapshot. Add to `kalecky-spec.cabal`'s new `library kalecky` / `test-suite kalecky-test` stanzas via `build-depends:` only.

**Version verification:** Verified live via `stack build --dry-run` against a throwaway package declaring `build-depends: base, tasty, tasty-quickcheck, QuickCheck, quickcheck-classes, Decimal` under `resolver: lts-23.28` — resolved entirely from the snapshot database, e.g.:
```
* snaptest-0.1.0: ... after: Decimal-0.5.2, QuickCheck-2.14.3, quickcheck-classes-0.6.5.0, tasty-1.5.3 and tasty-quickcheck-0.11.
```
No "not in snapshot, needs extra-deps" errors were raised for any of the five.

## Architecture Patterns

### Recommended Project Structure (within `kalecky-spec/`)
```
kalecky-spec/
├── kalecky-spec.cabal          # add: library kalecky, test-suite kalecky-test stanzas
├── src/                        # existing hevm main library (untouched)
├── src/Kalecky/                # renamed Types/ tree; NOT wired into cabal yet (Phase 1)
│   ├── Types/                  # was types/ (lowercase — invalid; renamed this phase)
│   │   ├── Numerics.hs
│   │   ├── Valuation.hs
│   │   ├── Measure.hs
│   │   ├── Units/{Unit,LaborUnit,MoneyUnit,CompoundUnit}.hs
│   │   └── Prices/{Price,Wage}.hs
│   └── Operators/               # already correctly-cased; imports get path-fixed only
│       └── {Gap,Effect,Expectation,GrowthRate,Indexation,Conflict}.hs
├── kalecky-test/                # NEW: smoke-test-only source dir (placeholder, decoupled from src/Kalecky/*)
│   └── Main.hs
└── test/                       # existing hevm test-suites (untouched)
```

### Pattern 1: Internal (private) sublibrary mirroring `library test-utils`
**What:** A named `library <name>` stanza in the same `.cabal` file is a *private* sublibrary — visible only to other components in the same package, referenced directly by its bare name in `build-depends:` (no `packagename:` qualifier needed; this is exactly how the existing `test-common` stanza depends on `test-utils` today).
**When to use:** Exactly this case — a build unit that must not pull in the package's main library.
**Example (existing, proven-working pattern in this repo):**
```cabal
-- Source: kalecky-spec/kalecky-spec.cabal (existing, lines ~250-270)
library test-utils
  import: test-base
  exposed-modules:
    EVM.Test.Utils
    EVM.Test.BlockchainTests

common test-common
  import: test-base
  build-depends:
    test-utils,   -- bare name reference to the internal sublibrary
    vector,
```
**New stanzas to add (Phase 1), same shape:**
```cabal
library kalecky
  import: shared
  default-language: GHC2021
  hs-source-dirs: kalecky-test        -- or a dedicated smoke-test dir; do NOT point at src/Kalecky/** yet (see Pitfall below)
  exposed-modules: Kalecky.Smoke      -- new, trivial placeholder module — not the draft design tree
  build-depends: base

test-suite kalecky-test
  import: shared
  type: exitcode-stdio-1.0
  main-is: Main.hs
  hs-source-dirs: kalecky-test
  build-depends:
    base,
    kalecky,          -- bare-name reference; must NOT list kalecky-spec (main lib) or test-utils
    tasty,
    tasty-quickcheck,
    QuickCheck,
```
Note `common shared` (already defined in the file) sets `default-language: GHC2021` and the project's warning flags — reuse it rather than duplicating options, exactly as every existing stanza does.

### Anti-Patterns to Avoid
- **Depending on `kalecky-spec` (bare package name = main library) or `test-utils` from `library kalecky` / `test-suite kalecky-test`:** doing so — even transitively — pulls hevm's ~40-module `EVM.*` library, its C sources (`ethjet/*.c`), and `secp256k1`/`gmp` linking into the build graph, defeating INFRA-02's isolation requirement. `Kalecky.*` must import no `EVM.*` modules (this is also required later by ALG-02: "Gap ... imports no domain modules").
- **Wiring the current `src/Kalecky/Types/**` / `src/Kalecky/Operators/**` draft files into the cabal stanza in Phase 1:** none of them currently have a `module … where` header (see Pitfall below); doing so multiplies this phase's scope into finishing Phase 2's design work under time pressure.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Verifying a `lib/` copy matches its upstream unmodified | A manual line-by-line file comparison script | `diff -rq --exclude=.git <local-dir> <fresh-clone>` against a shallow clone of the candidate commit | Already the exact procedure used and verified in this research; trivial, exact, and gives a clean pass/fail per file |
| Confirming cabal/stack build isolation | Trusting the `.cabal` file shape alone | A build-plan dry run (`cabal build <target> --dry-run`) or a deliberately-broken-main-library sandbox reproduction | Directly observable ground truth — this research's isolation claim was proven this way, not assumed from documentation |
| Locating the exact upstream commit for a modified/drifted vendor copy | Guessing from README version strings | `git log --all -- <path>` / GitHub "list commits for path" API + fetch raw file content per candidate commit to bisect | Version files in these repos (e.g. `plank-monorepo/std/version.plk`) do not encode a pinnable release string — content-diff bisection is the only reliable method found |

**Key insight:** Every one of this phase's three risky operations (nested-repo absorption, submodule pinning, build isolation) has a fast, cheap, *empirical* verification available before committing to it. There is no need to hand-roll trust — check it directly in a sandbox or dry run first.

## Common Pitfalls

### Pitfall 1: Staging the nested repo before removing its `.git`
**What goes wrong:** `git add kalecky-spec/` while `kalecky-spec/.git` still exists creates a gitlink (mode `160000`, a raw commit-SHA reference) in the outer repo's index, with no corresponding `.gitmodules` entry. This looks like a normal add (no error) but produces a broken, un-clonable reference — `git status`/`git diff` will show `kalecky-spec` as unexpectedly empty or "modified" for anyone who clones fresh.
**Why it happens:** Git always treats a directory containing its own `.git` as a candidate submodule pointer, regardless of intent.
**How to avoid:** Verified order: (1) `rm -rf kalecky-spec/.git` first, (2) *then* `git add kalecky-spec/` from the outer repo. Confirmed in this research: `kalecky-spec/.git` currently holds exactly one orphan commit (`a90f7e9 chore: initialize from hevm`, no remote) — nothing is lost by deleting it per the locked decision.
**Warning signs:** `git status` in the outer repo shows `kalecky-spec` as a single-line changed entry (not a file tree) after `git add` — that is the gitlink signature; should never appear if the order above is followed.

### Pitfall 2: Assuming `stack build`/`stack test` gives the same per-component isolation as `cabal`
**What goes wrong:** Running `stack test kalecky-spec:test:kalecky-test` (or `stack build`) will configure **and attempt to build the package's main/default library** even when the requested test-suite's `build-depends` never references it.
**Why it happens:** Directly reproduced in a sandbox package (main library with a deliberate type error, unrelated internal sublibrary, test-suite depending only on the sublibrary): `stack build isotest:test:kalecky-test` printed `isotest> configure (lib + sub-lib + test)` / `build (lib + sub-lib + test)` and invoked the underlying `Setup.hs ... build lib:isotest lib:kalecky test:kalecky-test` — i.e., Stack always includes the main library on the command line for any local-package target. The build failed on the main library's deliberate type error, never reaching the sublibrary/test-suite. The identical package built and ran cleanly (`1 of 1 test suites ... passed`) via `cabal build kalecky-test` / `cabal test kalecky-test`, whose dry-run plan listed only `(lib:kalecky)` and `(test:kalecky-test)` — no reference to the broken main library at all.
**How to avoid:** Use bare `cabal build kalecky-test` / `cabal test kalecky-test` for the fast increment loop (works today with the GHC 9.8.4 toolchain already installed via ghcup, matching `stack.yaml`'s `lts-23.28` resolver — pass `--with-compiler=$(ghcup whereis ghc 9.8.4)` or otherwise ensure cabal picks GHC 9.8.4, not the ghcup-default 9.10.3, whose newer `base` conflicts with the main hevm library's dependency bounds such as `aeson-optics <1.3`). `stack.yaml` can remain as the project's overall toolchain/resolver manager for other purposes; it should not be used for the isolated Kalecky loop.
**Warning signs:** Any increment where `cabal test kalecky-test` finishes in roughly the same time regardless of unrelated hevm source changes is healthy; a build that starts recompiling `EVM.*` modules when only `Kalecky.*` changed indicates the isolation stanza was set up wrong (e.g., accidentally depending on `kalecky-spec` or `test-utils`).

### Pitfall 3: Treating the `src/Kalecky/**` draft tree as "just needs a rename"
**What goes wrong:** CONTEXT.md's fix list (casing rename + the one `Wage.hs` import) undercounts the actual state: **none of the 15 existing files under `src/Kalecky/` declare a `module … where` header at all** — they are design-note/comment stubs (only `types/Numerics.hs` has one real declaration, `newtype Scale = Scale Int`, still headerless). Additionally, `Units/Unit.hs` imports `Kalecky.Types.Numerics.Scale` (a nested module path) when the actual file is a flat `Kalecky/Types/Numerics.hs` — a second broken import CONTEXT.md doesn't mention — and `Units/MoneyUnit.hs` imports `Kalecky.Types.Currency`, a module that does not exist anywhere in the tree (its `Currency` sum type only exists as prose in `notes/INCOME_DISTRIBUTION.md:1108`).
**Why it happens:** These files are working design notes (per canonical ref: "current draft tree with design notes"), not yet-compiling code — casing was the only issue CONTEXT.md's author checked for, but the deeper incompleteness is real and belongs to Phase 2 (UNIT-01..06), not Phase 1.
**How to avoid:** Rename the directory and fix cosmetic import casing for tree consistency (as decided), but **do not** add any `src/Kalecky/Types/**` or `src/Kalecky/Operators/**` module to the new `library kalecky`'s `exposed-modules`/`other-modules` in Phase 1. Build the smoke test against one new, trivial, self-contained module instead (e.g. `Kalecky.Smoke` with a single always-true property) — this is explicitly compatible with CONTEXT's discretion note ("Scale-shaped placeholder or any minimal property ... does not pre-empt Phase 2's co-designed Scale test").
**Warning signs:** If a Phase 1 task tries to add module headers, fix the `Currency` import, or resolve the `Numerics.Scale` path to make the draft tree compile, that is Phase 2 work leaking into Phase 1 — flag it.

### Pitfall 4: Assuming all three `lib/` copies are pristine because the user said so
**What goes wrong:** `plank-monorepo` (unlike `forge-std` and `plank-foundry-deployer`) is **not** byte-identical to its upstream default-branch HEAD, nor to several older commits sampled from that file's history — differences span real source changes (e.g. a `Self` token added to the Rust lexer, `justfile` env-var renames) across `plankc/frontend/**`, `plankc/sir/**`, `plank-tree-sitter/**`, not just metadata/lockfiles.
**Why it happens:** `plank-monorepo` is a fast-moving, actively-developed monorepo (multiple commits/week visible in its history); the local copy was vendored at some earlier point and has since drifted from upstream by normal upstream progress — not necessarily local hand-editing, but this cannot be *assumed* without finding the matching historical commit.
**How to avoid:** Per the locked decision, verify with a diff before deleting the local copy; if a diff shows differences, stop and surface it rather than guessing a pin. This research confirmed `forge-std` and `plank-foundry-deployer` ARE exact matches (safe to pin immediately, see Sources below for exact commits); `plank-monorepo` requires a real bisection (`git log --all -- <distinguishing-file>` + fetch-and-diff per candidate commit, e.g. via `https://raw.githubusercontent.com/plankevm/plank-monorepo/<sha>/<path>`) before it can be pinned — or, if no exact match is found, the planner/user must explicitly accept a "closest known commit, documented drift" fallback rather than silently picking HEAD.
**Warning signs:** A submodule pin chosen without a completed diff-against-that-exact-commit check is not verified — don't accept "upstream default branch" as a pin without confirming file-for-file equality first.

### Pitfall 5: `plank-monorepo` has its own nested submodules
**What goes wrong:** `lib/plank-monorepo/.gitmodules` declares its own submodules (`plankc/plank-diff-tests/lib/{forge-std,plank-foundry-deployer,solady}`, `plankc/sir/sir-solidity-diff-tests/lib/{forge-std,solady}`) — a naive `git submodule add` without `--recurse-submodules` / a follow-up `git submodule update --init --recursive` inside the new submodule will leave those nested directories empty, silently breaking anything that resolves through `plankc/plank-diff-tests/lib/solady` (which `remappings.txt`'s `solady/=lib/plank-monorepo/plankc/plank-diff-tests/lib/solady/src/` entry depends on, if that remapping is exercised).
**Why it happens:** Submodules are not recursive by default.
**How to avoid:** Use `git submodule update --init --recursive` for `plank-monorepo` specifically, or clone-time `--recurse-submodules --shallow-submodules` flags, confirmed working in this research (33M full recursive clone, completed in well under 3 minutes).
**Warning signs:** `remappings.txt`'s `solady/` entry failing to resolve, or `lib/plank-monorepo/plankc/plank-diff-tests/lib/*` appearing as empty directories after conversion.

## Code Examples

### Verified: cabal per-component isolation (reproduced directly)
```
$ cabal build kalecky-test --with-compiler=<ghc-9.8.4>
Resolving dependencies...
Build profile: -w ghc-9.8.4 -O1
In order, the following will be built (use -v for more details):
 - isotest-0.1.0 (lib:kalecky) (first run)
 - isotest-0.1.0 (test:kalecky-test) (first run)
Configuring library 'kalecky' for isotest-0.1.0...
...
Building test suite 'kalecky-test' for isotest-0.1.0...
[2 of 2] Linking .../kalecky-test
```
No mention of `isotest (lib)` — the main library (which had a deliberate type error) is never touched. Same result with `cabal test kalecky-test` (adds `Running 1 test suites... PASS`).

### Verified: stack breaks isolation (reproduced directly)
```
$ stack build isotest:test:kalecky-test
isotest> configure (lib + sub-lib + test)
isotest> build (lib + sub-lib + test) with ghc-9.8.4
Building library for isotest-0.1.0..
[1 of 1] Compiling MainLib
.../MainLib.hs:4:5: error: [GHC-83865]
    • Couldn't match type ‘[Char]’ with ‘Int’
...
Error: [S-7282] Stack failed to execute the build plan.
```
The underlying invocation, visible in stack's error output, is `Setup.hs ... build lib:isotest lib:kalecky test:kalecky-test` — stack always requests the package's default library alongside the named target.

### Verified: existing `test-utils` sublibrary reference syntax (this repo, proof the pattern already works)
```cabal
-- Source: kalecky-spec/kalecky-spec.cabal
library test-utils
  import: test-base
  exposed-modules:
    EVM.Test.Utils
    EVM.Test.BlockchainTests

common test-common
  import: test-base
  build-depends:
    test-utils,   -- bare-name internal library reference
    vector,
```
(Note this existing pattern does *not* itself demonstrate isolation — `test-common`'s parent `test-base` stanza also depends on `kalecky-spec`, the main library, so every existing test-suite already pulls in hevm. `library kalecky` / `kalecky-test` must be built without that `common test-base`/`test-common` inheritance chain — start from `common shared` directly, as shown in Architecture Patterns above.)

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| Cabal packages configured as one monolithic build unit ("old-style"/`v1-build`) | Nix-style local builds (`v2-build`), per-component dependency graph, default since cabal-install 2.x, in effect here via cabal-install 3.16.1.0 | Cabal 1.24+/2.0 (2016-2017); universally default by now | This is *why* `cabal build <target>` gives true isolation — the solver only builds the requested target's transitive closure, not the whole package |
| Stack's internal-library support (previously broken entirely for library-only packages) | Fixed for that specific bug (stack #3787, closed via PR #4111) in Stack 1.7-era | ~2018 | Not directly relevant here — this repo's issue isn't "internal libraries don't work" (they clearly do; `test-utils` proves it), it's that Stack's target-build command line unconditionally includes the package's *default* library regardless of target, which is a different, still-present behavior as of Stack 3.11.1 (verified above) |

**Deprecated/outdated:** None specific to this phase's stack; both cabal-install 3.16.1.0 and Stack 3.11.1 are current.

## Open Questions

1. **What exact upstream commit does the local `lib/plank-monorepo` copy correspond to?**
   - What we know: it is not the current default-branch HEAD (`d1cbd2c3...` as of this research), nor several other recently-sampled commits back to at least 2026-06-15; the differences are genuine upstream commits (new lexer token, justfile env-var renames), not obviously local hand-edits.
   - What's unclear: the exact matching commit (or whether one exists at all — the local copy could interleave changes from more than one historical state if it was hand-assembled).
   - Recommendation: Task the implementer with the bisection procedure documented in Pitfall 4; if no exact match is found within reasonable effort, surface to the user for an explicit "accept closest match with documented drift" or "treat as locally modified, do not blindly submodule" decision — do not silently pin to HEAD.

2. **Should `plank-foundry-deployer`'s and `forge-std`'s pins use their exact verified commits or `git submodule add` defaults?**
   - What we know: both are exact matches to their current upstream default-branch HEAD (forge-std `467ffd422ca01fed5797a4c766a1e4e3a5327902` on `master`; plank-foundry-deployer `24fe42f1021f956838504fcad40a90f45e8ee218` on its default branch) as of this research's timestamp.
   - What's unclear: nothing technical — `git submodule add <url> <path>` followed immediately by commit will naturally pin exactly these commits (since they equal current HEAD); the only risk is time-of-check/time-of-use drift if the implementer runs this materially later than this research.
   - Recommendation: Re-run the `diff -rq --exclude=.git` check against a fresh shallow clone immediately before `git submodule add`, don't rely on this document's commit SHAs if more than a few days have passed.

3. **Does the trivial smoke test need `quickcheck-classes`, or is plain `tasty-quickcheck` enough?**
   - What we know: both are available with zero extra-deps; CONTEXT.md leaves this to discretion ("Scale-shaped placeholder or any minimal property").
   - What's unclear: nothing blocking — this is a real free choice.
   - Recommendation: Use plain `tasty-quickcheck` for Phase 1's placeholder (simpler, fewer moving parts); reserve `quickcheck-classes` for Phase 2 onward when real typeclass instances (Eq, Semigroup, etc. per PROOF-01) exist to check laws against.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Tasty 1.5.3 + tasty-quickcheck 0.11 (via `cabal test`, GHC 9.8.4) |
| Config file | `kalecky-spec/kalecky-spec.cabal` — new `library kalecky` + `test-suite kalecky-test` stanzas (none exist yet) |
| Quick run command | `cd kalecky-spec && cabal test kalecky-test --with-compiler=$(ghcup whereis ghc 9.8.4)` |
| Full suite command | Same command — the Phase 1 suite is a single trivial smoke test; no larger suite exists yet |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|--------------------|--------------|
| INFRA-01 | All listed paths (`kalecky-spec/`, `kalecky-plank/`, `notes/`, `test/`, `foundry.toml`, `remappings.txt`) are git-tracked with no dangling gitlinks | smoke (repo-state assertion) | `git ls-files kalecky-spec kalecky-plank notes test foundry.toml remappings.txt \| wc -l` (nonzero) `&&` `git status --porcelain=v1 \| grep -v '^??' \| wc -l` (expected clean after commit) `&&` `git submodule status` (no `-` prefix = all initialized) | ❌ Wave 0 — no existing verification script; write one as part of this phase |
| INFRA-02 | `cabal test kalecky-test` builds and passes without compiling `EVM.*`/main library modules | unit + isolation smoke | `cd kalecky-spec && cabal build kalecky-test --dry-run --with-compiler=$(ghcup whereis ghc 9.8.4) \| grep -vE '\(lib:kalecky\)\|\(test:kalecky-test\)'` should show no `kalecky-spec-... (lib)` (bare) entry, then `cabal test kalecky-test ...` should print `PASS` | ❌ Wave 0 — `kalecky-test` stanza and its `Main.hs` don't exist yet |

### Sampling Rate
- **Per task commit:** `cabal test kalecky-test --with-compiler=$(ghcup whereis ghc 9.8.4)` (seconds — verified empirically to compile only the tiny sublibrary + test-suite)
- **Per wave merge:** Same command, plus a fresh `cabal build kalecky-test --dry-run` scan to re-confirm no accidental dependency on `kalecky-spec`/`test-utils` was introduced
- **Phase gate:** Full suite green (trivially, the one smoke test) before `/gsd:verify-work`; additionally re-run the git-state checks (`git status`, `git submodule status`, `diff -rq` against upstream for pinned submodules) since this phase's correctness is as much about repo state as about test passing

### Wave 0 Gaps
- [ ] `kalecky-spec/kalecky-spec.cabal` — add `library kalecky` + `test-suite kalecky-test` stanzas (does not exist)
- [ ] `kalecky-spec/kalecky-test/Main.hs` (or similar path) — trivial Tasty + tasty-quickcheck smoke test (does not exist; do not reuse `src/Kalecky/**` per Pitfall 3)
- [ ] A repo-state verification script/checklist for INFRA-01 (git tracking + no dangling gitlinks + submodules initialized) — no existing tooling covers this
- [ ] Framework install: none — Tasty/tasty-quickcheck/QuickCheck already resolve from the `lts-23.28` snapshot with zero `extra-deps` changes (verified)

## Sources

### Primary (HIGH confidence — direct reproduction / this repository)
- This repository, `kalecky-spec/kalecky-spec.cabal` (read in full) — existing `library test-utils`, `common shared`/`test-base`/`test-common` stanzas, all 6 test-suites, dependency bounds
- This repository, `kalecky-spec/.git` (inspected directly) — 1 orphan commit `a90f7e9`, no remote, untracked `kalecky-spec.cabal`/`stack.yaml`/`stack.yaml.lock`/`src/Kalecky/`, deleted `hevm.cabal`
- This repository, `src/Kalecky/**` (all 15 files read in full) — none has a `module … where` header; exact import mismatches documented
- Live sandbox reproduction (`/tmp/.../scratchpad/isotest/`) — `cabal build`/`cabal test` isolate correctly; `stack build` does not (both runs' full output captured above)
- Live sandbox reproduction (`/tmp/.../scratchpad/snaptest/`) — `stack build --dry-run` against `lts-23.28` resolves `Decimal-0.5.2`, `QuickCheck-2.14.3`, `quickcheck-classes-0.6.5.0`, `tasty-1.5.3`, `tasty-quickcheck-0.11` with zero extra-deps
- Live `cabal build kalecky-spec --dry-run` against the real package with ghcup-default GHC 9.10.3 — confirmed base-version bound conflict (`aeson-optics <4.20`), confirming GHC 9.8.4 (also already installed via ghcup) must be used for the main-lib-dependent build path
- `git clone --depth 1 --branch v1.16.2` / `--depth 50` (master) `https://github.com/foundry-rs/forge-std.git`, diffed against local `lib/forge-std` — exact match at master HEAD `467ffd422ca01fed5797a4c766a1e4e3a5327902`, no match at the `v1.16.2` tag
- `git clone --depth 1 https://github.com/plankevm/plank-foundry-deployer.git`, diffed against local `lib/plank-foundry-deployer` — exact match at HEAD `24fe42f1021f956838504fcad40a90f45e8ee218`
- `git clone --depth 1 --recurse-submodules --shallow-submodules https://github.com/plankevm/plank-monorepo.git`, diffed against local `lib/plank-monorepo` — 52 files differ (real source changes, not just metadata); bisection via GitHub commits API (`/repos/plankevm/plank-monorepo/commits?path=plankc/justfile`) and raw-content fetch narrowed but did not pinpoint an exact matching commit within this research's effort budget
- GitHub API (`api.github.com/repos/plankevm/plank-foundry-deployer`, `api.github.com/orgs/plankevm/repos`) — confirmed `plankevm` org ownership and repo existence for `plank-foundry-deployer` and `plank-monorepo`
- `cat kalecky-spec/.gitignore`, root `.gitignore`, `.gitmodules`, `lib/plank-monorepo/.gitmodules` (read directly) — existing ignore/submodule state and plank-monorepo's own nested submodule declarations

### Secondary (MEDIUM confidence)
- [Cabal Package Description docs](https://cabal.readthedocs.io/en/latest/cabal-package-description-file.html) — confirms internal-library declaration syntax and bare-name same-package reference, consistent with what's already observed working in this repo's own `.cabal` file
- [Stack issue #3787](https://github.com/commercialhaskell/stack/issues/3787) — historical "no buildable library" bug, fixed via PR #4111; confirms this is a *different* (and still-reproduced-live) behavior than the one found in this research

### Tertiary (LOW confidence)
- WebFetch of `stackage.org/lts-23.28` package pages for tasty-quickcheck/quickcheck-classes returned generic/possibly-mismatched-snapshot info (showed "LTS Haskell 24.54" in one response) — **superseded** by the direct `stack build --dry-run` reproduction against the actual `lts-23.28` resolver, which is authoritative and is what this document's version table relies on

## Metadata

**Confidence breakdown:**
- Standard stack (package versions): HIGH — verified via live `stack --dry-run` resolution against the actual `lts-23.28` resolver, not a webpage
- Architecture (cabal stanza shape, isolation mechanism): HIGH — reproduced directly in a sandbox package with a deliberate failure oracle (broken main library)
- Git hygiene procedure (gitlink pitfall, submodule commits): HIGH for forge-std/plank-foundry-deployer (exact commit match verified); MEDIUM for plank-monorepo (real drift confirmed, exact pin unresolved — flagged as Open Question, not asserted)
- Pitfalls (module-tree stub state): HIGH — every file read in full, header/import state confirmed directly, not inferred

**Research date:** 2026-08-15
**Valid until:** Package/version findings (LTS 23.28 contents, existing `.cabal` shape): stable, ~30 days. Upstream commit pins for `lib/forge-std` and `lib/plank-foundry-deployer`: volatile, re-verify with a fresh `diff -rq` immediately before executing the submodule-add step if more than a few days pass. `lib/plank-monorepo`'s exact pin remains unresolved regardless of timing — treat as a phase task, not a research-closed fact.
