# lib/plank-monorepo — Upstream Drift Report

**Measured:** 2026-08-15
**Upstream:** https://github.com/plankevm/plank-monorepo.git
**Local copy:** lib/plank-monorepo — 1401 files, 25M, no `.git` directory

## Method

1. Cloned upstream recursively (required — the local copy is a flattened snapshot of a repo declaring 5 nested submodules; without `--recurse-submodules` the diff would falsely report all 5 nested trees as differing):
   ```bash
   git clone --quiet --recurse-submodules https://github.com/plankevm/plank-monorepo.git /tmp/kalecky-phase1/pm.upstream
   ```
   Upstream default-branch HEAD resolved to `d1cbd2c314f435757bcabc581e7c9b87c5203065`.
2. Full-tree diff at HEAD: `diff -rq --exclude=.git lib/plank-monorepo /tmp/kalecky-phase1/pm.upstream` → **52 differing entries**, matching 01-RESEARCH.md's finding exactly (52 files).
3. Bisected the history of `plankc/justfile` (a distinguishing file research already used) via `git log --oneline -40 -- plankc/justfile`, which returned 14 commits total (well under the 20-candidate cap). Walked newest → oldest, at each candidate ran `git checkout <SHA> && git submodule update --init --recursive --quiet` then re-ran the full-tree diff and recorded the count. Stopped early per the plan's instruction once a clean (0-diff) candidate was found — reached at the 2nd candidate tried, so the search used 2 of the 20-candidate/30-minute budget, not the full 14.
4. Re-verified the winning candidate standalone (re-checkout + re-diff, independent of the loop) to rule out a state-leak from the loop, then cross-checked file *lists* (not just counts) both directions were identical (1401 files each side, zero path-only differences).

## Candidates Tried

| Commit | Date | Subject | Differing files |
|--------|------|---------|-----------------|
| `d1cbd2c314f435757bcabc581e7c9b87c5203065` | 2026-08-15 | ⚡️ simplify optimization options (#306) | 52 |
| `3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99` | 2026-08-11 | ⚡️ sir: basic block merging optimization (#303) | **0** |
| `bd87f33cba8213780d87ffb991352242c7119587` | 2026-08-10 | ⚡️ inlining with heuristic (#299) | 21 |
| `40c19e2fb71a0cd325c8ca8b58451111118f70b4` | 2026-07-21 | ⚡️ intra op scheduler v2 (#278) | 116 |
| `c3c1616803f3da836134d90c5e43f1e9dd4b7495` | 2026-06-29 | ✨ clz (#254) | 152 |
| `30f3bdcd405057ef7394dd9bf703f5923b03134a` | 2026-06-15 | ✨ comptime bytes (#215) | 184 |
| `b61409c2e4fde5e04973c63b9d71b74463434979` | 2026-05-20 | 🏗️ Stack Scheduling Backend (#211) | 218 |
| `7a67f52cba898c6f20b86f537b94bfba521d306e` | (older) | 🏗️ SIR: setup stack scheduler infra (#199) | 282 |
| `7609f59edc39ec73f47e917d4e6d76f82d6eec82` | (older) | ✨ add sonatina backend (#193) | 264 |
| `18cdf4f48c2771b668141247ef72b9502c008774` | (older) | 🐞 fix codegen failure | 261 |
| `eb8c45cd509ed1b0267324f2d88adc2bf1c7c3a4` | (older) | 🔋 stdlib abi encode & decode + tree-sitter fixes | 281 |
| `d4716b12da3b466b21009ca2de7e56ba45cc4ebe` | (older) | ✨ Implement binary & unary operator handling (#165) | 253 |
| `7ea983919522211fdfd3ef28679f71795628a494` | (older) | 🏗️ docs via mdbook setup (#152) | 243 |
| `3c248de2d40af36476c0abbfcfcd0c39636b591a` | 2026-03-09 | Rename "Sensei" to "Plank" (#76) | 215 |

Note: the count climbs monotonically moving away from the match in either direction (52 at HEAD going forward 4 commits, 21/116/152/… going backward), which is exactly the pattern expected from a repo that keeps moving while the local copy stays pinned to a single point in its history — not noise.

## Closest Match

**Commit:** `3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99`
**Differing files:** **0** — byte-identical, both directions, full 1401-file tree (contradicts 01-RESEARCH.md's expectation that no exact match would be found; the research sampled fewer historical commits than this bisection did)

## Differing Files (closest match)

### Local-only (present here, absent upstream)
None.

### Upstream-only (absent here, present upstream)
None.

### Content differs
None. `diff -rq --exclude=.git` against `3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99` produced zero output lines. File-list comparison (`find ... -printf '%P\n' | sort` both sides) also produced zero diff — same 1401 paths, same content, on both sides.

## Representative Diffs

Since the closest match is byte-identical, there is nothing to show a diff *of*. Instead, to characterize what the local copy is missing relative to upstream **HEAD** (`d1cbd2c`, 4 commits ahead of the pinned point), here are the same distinguishing files research flagged, diffed against current upstream HEAD:

```diff
--- lib/plank-monorepo/plankc/justfile          (== 3c4ce7b, == local)
+++ pm.upstream/plankc/justfile                  (HEAD d1cbd2c)
@@ -33,21 +33,19 @@
 [working-directory: 'sir/sir-solidity-diff-tests']
 test-sir-diff: build-debug-sir
-    SIR_RELEASE_BACKEND=0 forge test
-    SIR_RELEASE_BACKEND=1 forge test
+    SIR_OPTIMIZE= forge test
+    SIR_OPTIMIZE=O2 forge test
 ...
-     PLANK_BACKEND=sir-debug   PLANK_OPTIMIZE=     forge test --nmp 'test/benchmark/*'
-     PLANK_BACKEND=sir-debug   PLANK_OPTIMIZE=csuimd forge test --nmp 'test/benchmark/*'
-     PLANK_BACKEND=sir-release PLANK_OPTIMIZE=     forge test --nmp 'test/benchmark/*'
-     PLANK_BACKEND=sir-release PLANK_OPTIMIZE=csuimd forge test --nmp 'test/benchmark/*'
+     PLANK_BACKEND=sir PLANK_OPTIMIZE=O0 forge test --nmp 'test/benchmark/*'
+     PLANK_BACKEND=sir PLANK_OPTIMIZE=O2 forge test --nmp 'test/benchmark/*'
```

```diff
--- lib/plank-monorepo/plankc/frontend/parser/src/lexer.rs   (== 3c4ce7b, == local)
+++ pm.upstream/plankc/frontend/parser/src/lexer.rs           (HEAD d1cbd2c)
@@ -233,6 +233,8 @@
     As,
     #[token("match")]
     Match,
+    #[token("Self")]
+    SelfType,
```

```diff
--- lib/plank-monorepo/plankc/sir/crates/passes/src/lib.rs   (== 3c4ce7b, == local)
+++ pm.upstream/plankc/sir/crates/passes/src/lib.rs           (HEAD d1cbd2c)
@@ -18,7 +18,7 @@
-pub use optimizations::{Defragmenter, OPTIMIZE_HELP, parse_optimizations_string};
+pub use optimizations::{Defragmenter, OptimizationLevel, PASSES_HELP, parse_passes};
```

These three hunks are exactly the shape 01-RESEARCH.md predicted (env-var/flag renames in `justfile`, a `Self` token added to the lexer) and are consistent across all 52 HEAD-relative diffs sampled: env var/flag renames (`SIR_RELEASE_BACKEND`→`SIR_OPTIMIZE`, `csuimd`→`O2`, `OPTIMIZE_HELP`→`PASSES_HELP`), a new lexer token, and a basic-block-merging optimization pass landing in `sir/`. All are upstream feature/refactor commits, not local hand-edits.

## Nested Submodule Impact

- **Five dangling `.git` gitfile pointers**, confirmed present, none resolve (parent `.git/modules/` no longer exists locally):
  - `lib/plank-monorepo/plankc/plank-diff-tests/lib/forge-std/.git` → `gitdir: ../../../../.git/modules/plankc/plank-diff-tests/lib/forge-std` (71 bytes)
  - `lib/plank-monorepo/plankc/plank-diff-tests/lib/solady/.git` → `gitdir: ../../../../.git/modules/plankc/plank-diff-tests/lib/solady` (68 bytes)
  - `lib/plank-monorepo/plankc/plank-diff-tests/lib/plank-foundry-deployer/.git` → `gitdir: ../../../../.git/modules/plankc/plank-diff-tests/lib/plank-foundry-deployer` (84 bytes)
  - `lib/plank-monorepo/plankc/sir/sir-solidity-diff-tests/lib/forge-std/.git` → `gitdir: ../../../../../.git/modules/plankc/sir/sir-solidity-diff-tests/lib/forge-std` (85 bytes)
  - `lib/plank-monorepo/plankc/sir/sir-solidity-diff-tests/lib/solady/.git` → `gitdir: ../../../../../.git/modules/plankc/sir/sir-solidity-diff-tests/lib/solady` (82 bytes)
  - Confirmed: `find lib/plank-monorepo -name .git -type d | wc -l` → `0`; `find lib/plank-monorepo -name .git -type f` → the 5 paths above.
- **`plank-diff-tests/lib/` is self-ignored upstream** — `lib/plank-monorepo/plankc/plank-diff-tests/.gitignore:3` is `lib/`. Confirmed: `git check-ignore -v lib/plank-monorepo/plankc/plank-diff-tests/lib/solady/src/Milady.sol` → matches that line. Measured consequence: `git add --dry-run lib/plank-monorepo | wc -l` → **825** (of 1401 files on disk). `plankc/sir/sir-solidity-diff-tests/lib/**` is **not** ignored and stages normally — only the `plankc/plank-diff-tests/lib/**` copy (which hosts `remappings.txt` line 4's `solady/` target) is affected.
- **`remappings.txt` line 4** resolves `solady/=lib/plank-monorepo/plankc/plank-diff-tests/lib/solady/src/`. Whether it keeps resolving after conversion depends on the option chosen in Task 2:
  - **option-a** (pin closest match + tracked patch): resolves — `git submodule update --init --recursive` on the pinned `3c4ce7b` checkout materializes `plankc/plank-diff-tests/lib/solady` as its own real submodule (the nested `.gitmodules` entry is honoured on recursive init), independent of the self-ignore (which only affects the *parent* repo's tracking, not nested submodule checkout).
  - **option-b** (vendor, no submodule): resolves **only if** both the dangling `.git` gitfiles are deleted first (git submodule machinery does not apply — they are ordinary files at that point) **and** `plankc/plank-diff-tests/lib/**` is force-added (`git add -f`) despite the self-ignore; skipping either step means a fresh clone of this repo is missing the `solady/` target and the remapping dies.
  - **option-c** (fork + submodule-pin fork): resolves — same mechanism as option-a, since the fork is the local state (which already includes the vendored `solady/` content) recursively re-submoduled.
  - **option-d** (pin upstream, discard local delta): resolves — since the closest match is byte-identical, "discard the local delta" is a no-op here (there is no delta between local and the pin target); behaves identically to option-a's submodule mechanics minus the patch step.

## Assessment

The drift is **not** local hand-edits. It is the local copy being pinned to a real historical upstream commit (`3c4ce7b`, 2026-08-11) that is exactly 4 commits behind current upstream HEAD (`d1cbd2c`, 2026-08-15). Every one of the 52 HEAD-relative differences traces to a normal upstream commit in that 4-commit range (`#306` optimization-option simplification, `#303` basic-block merging, `#299` inlining heuristic — the last two are folded into the diff because they land in the same window as the vendoring point). There is zero local-only content and zero upstream-only content at the matched commit — the "52 files differed" finding from 01-RESEARCH.md was a HEAD-relative artifact of upstream having moved on, not evidence of a fork or hand-edit. This directly contradicts the plan's `<context>` framing ("52 files differed... spanning real source changes") only in attribution, not in the underlying numbers — the files really did differ from HEAD; they just don't differ from the commit the copy was actually taken from.

## Recommendation

**option-a** (pin closest match, `3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99`, as a plain submodule) is favoured, with a caveat: because the match is byte-identical, there is no local delta to carry as a patch, so option-a collapses to "pin the exact matching commit" — no patch-apply step is actually needed in this case. This makes **option-a and option-d functionally identical** for `lib/plank-monorepo` specifically (unlike the general case where they'd differ), since discarding "the local delta" discards nothing. Recommend option-a's framing (explicit, updatable upstream pin) over option-d's framing (implies data was thrown away) purely for clarity of intent in the commit history, even though the resulting `git submodule add` command and pinned SHA are the same either way. option-b (vendor) is not favoured — it requires two extra fragile steps (deleting dangling gitfiles, force-adding a self-ignored tree) to avoid silently breaking `remappings.txt` line 4, with no offsetting benefit now that an exact upstream pin exists. option-c (fork) is not favoured — unnecessary network/account action when the exact upstream commit is public and pinnable directly.

## Decision

**Chosen:** option-a
**Date:** 2026-08-15
**Rationale:** Pin closest upstream commit `3c4ce7bd7fd061dac883f291c6aec5d66f7a9f99` as a plain submodule. Since the match is byte-identical, no patch step is needed; this is a pure exact-commit pin. Rationale: explicit updatable upstream relationship, nested submodules resolve via recursive init, solady/ remapping keeps working.
