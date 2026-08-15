# Codebase Concerns

**Analysis Date:** 2026-08-15

## Critical: Untracked but Essential Work

**Core Project Files Untracked in Git:**
- Files: `kalecky-spec/` (hevm Haskell codebase), `kalecky-plank/` (specification), `test/kalecky-plank/`, `notes/`, `foundry.toml`, `remappings.txt`
- Impact: **Highest** - These are critical to the project but not in version control. Project reproducibility and collaboration are at risk. Any team member cloning the repo cannot build or run the project.
- Status: Discovered via `git status --short` showing all these as untracked (`??`)
- Fix approach: Immediately add to git with `git add` and commit. Update `.gitignore` if these are intentionally excluded. Clarify with team why essential infrastructure is untracked.

## Tech Debt: Architecture Mismatch

**Conflicting Technology Stacks:**
- Issue: Repository has **three incompatible architectural foundations**:
  1. **Lean/Foundry**: `EvmYul/` directory (committed) contains formal EVM semantics in Lean 4 with Foundry integration
  2. **Haskell**: `kalecky-spec/` (untracked) is a full hevm (Ethereum VM implementation in Haskell) with 2000+ .hs files, Stack/Cabal build system
  3. **Custom DSL**: `kalecky-plank/Draft.plk` (untracked) is a specification language for economic units
- Files affected: `./EvmYul/`, `./kalecky-spec/`, `./kalecky-plank/`, `./lakefile.lean`, `./kalecky-spec/stack.yaml`, `./kalecky-spec/kalecky-spec.cabal`
- Context: Project goal stated as "compile to Haskell and be proven via incremental test-driven development"
- Problem: If the goal is Haskell, why is Lean EvmYul committed while hevm (Haskell) is untracked? This suggests either:
  - Lean is a stepping stone (but no migration plan exists)
  - Haskell was added later without removing Lean dependencies
  - Two parallel implementations causing maintenance burden
- Fix approach: 
  1. Clarify architectural decision: Is Lean a formal spec layer? Is Haskell the implementation target?
  2. If Haskell is primary: Move hevm to primary location, make Lean optional/reference
  3. If Lean+Haskell coexist: Document how they interact; add integration tests showing correctness equivalence
  4. If migrating from Lean to Haskell: Create migration roadmap with deprecation timeline

## Fragile: Incomplete Specifications

**Draft Specification with TODOs:**
- File: `kalecky-plank/Draft.plk` (136 lines)
- Issues:
  - Filename literally "Draft" indicating non-finalized status
  - Line 6: `// todo: This takes a enum when available`
  - Line 43: `// todo: This is case match semantics when available`
  - Line 81-82: Incomplete type operations marked as "not doing A / B" and "not doing A*B"
  - Line 96: Critical comment: "This combinatorically scales too much and the function ends up being too responsible"
  - Lines 99-107: Shows desired recursive type structure but current implementation (lines 109-122) is hardcoded dispatch with compile errors
- Impact: Cannot compile/run economic model code without completing these TODOs. Type system is incomplete and fragile to extension.
- Safe modification: Treat entire `kalecky-plank/` as unstable. Do not depend on its output until specification is complete and all TODOs addressed.

## Missing Critical Tooling

**Haskell Build Infrastructure Gap:**
- Expected: Root-level `stack.yaml` or `cabal.project` for Haskell project
- Found: `kalecky-spec/stack.yaml` and `kalecky-spec/kalecky-spec.cabal` exist but are in untracked subdirectory
- Missing:
  - Root-level build configuration (only `lakefile.lean` for Lean exists)
  - Clear dependency management between Lean and Haskell layers
  - Haskell toolchain version specification at project root (only Lean has `lean-toolchain`)
  - No documented build steps for "compile to Haskell" goal
- Files: `./lakefile.lean` (Lean only), no `stack.yaml` or `cabal.project` at root
- Impact: Cannot verify Haskell compilation at project root. Each contributor must know to build `kalecky-spec/` separately.
- Fix approach:
  1. Create root-level `stack.yaml` or `cabal.project` that orchestrates builds
  2. Add `.haskell-version` or similar for consistency
  3. Document build order: Lean→verify→Haskell
  4. Add Makefile or build script targeting both layers

## Scaling Limit: Unmanaged Dependency Chains

**Complex Submodule and External Dependencies:**
- Files: `./lakefile.lean` (lines 12-63), `remappings.txt`, `.gitmodules`
- Issues:
  - `lakefile.lean` clones external repos into `sha2/`, `keccak256/` at build time (lines 17-19)
  - `remappings.txt` points to `kalecky-plank/` and untracked `lib/` subdirectories
  - `lib/` contains 3 major dependencies: `forge-std`, `plank-foundry-deployer`, `plank-monorepo`
  - No documented version pinning for external C libraries (SHA2, Keccak256)
  - No lockfile for Haskell side (`kalecky-spec/` has `stack.yaml` but untracked)
- Problem: FFI dependencies on C libraries fetched at build time with no hash verification. Builds can fail silently or pull compromised code.
- Fix approach:
  1. Pin C library commits in `lakefile.lean` with git revision
  2. Verify SHA256 hashes for fetched artifacts
  3. Consider vendoring critical dependencies instead of clone-at-build
  4. Consolidate `remappings.txt` to only reference committed paths

## Known Issues: Incomplete Features Throughout Codebase

**TODO/FIXME Comments Indicating Incomplete Work:**
- Locations with unfinished implementations:
  - `EvmYul/Wheels.lean:93` - "TODO(rework later to a sane version)"
  - `EvmYul/Wheels.lean:130` - "TODO - Well this is ever so slightly unfortunate"
  - `EvmYul/EVM/Semantics.lean:200` - Unify condition with CREATE, missing unification
  - `EvmYul/EVM/Semantics.lean:782` - "Handle precompiled contracts" not implemented
  - `EvmYul/Maps/ByteMap.lean:17` - "All of this is very ugly"
  - `EvmYul/Maps/StorageMap.lean:17` - "All of this is very ugly"
  - `notes/INCOME_DISTRIBUTION.md:47` - Economic mechanisms not formally identified
  - `kalecky-spec/src/EVM/SMT.hs:590` - "TODO: implement" with show of unimplemented type
  - `kalecky-spec/test/EVM/SymExec/SymExecTests.hs:733` - "FIXME: Ideally, we would be able to explore fully and prove the assertion"
- Count: ~40+ TODO/FIXME comments across codebase
- Impact: Features marked incomplete may silently fail or produce incorrect results. Code quality and correctness cannot be assured.
- Priority: **High** - Before proving correctness via tests, all TODOs in proof-relevant code must be resolved.

## Test Coverage Gaps

**Incomplete Test Infrastructure:**
- Files: `test/`, `kalecky-plank/test/`, `kalecky-spec/test/`
- Issues:
  - `test/kalecky-plank/` is untracked (only `test/kalecky-plank` directory listed in git status)
  - `kalecky-spec/test/` contains 5 test suites but is untracked:
    - `BlockchainTests.hs` - references "TODO" placeholders for Prague fork tests (lines 216-226)
    - `SymExecTests.hs` - Multiple symbolic execution tests marked with "TODO: can't deal with symbolic jump conditions" (line 566)
  - No test coverage for `kalecky-plank/Draft.plk` - specification has no unit tests despite being in draft state
  - Economic model (`notes/INCOME_DISTRIBUTION.md`) has no corresponding executable tests
- Risk: Without tracked tests, cannot verify that economic model implementation matches specification.
- Safe modification: Do not modify specification without adding corresponding test before commit.

## Fragile Areas: Type System Evolution Risk

**Specification Language Type System Too Restrictive:**
- File: `kalecky-plank/Draft.plk` (lines 109-122)
- Pattern: Closed-world dispatch - EconomicUnit accepts only hardcoded types, rejects everything else with `@compile_error`
  ```
  if U == MoneyUnit(COP, Raw) { return U; }
  if U == Unit(LaborScale, Worker) { return U; }
  @compile_error("unsupported economic unit");
  ```
- Problem: Adding new economic units (e.g., virtual labor, derivatives) requires code changes to dispatch, not data. No extensible mechanism.
- Desired (commented lines 99-107): Recursive sum type like Haskell's `data EconomicUnit = Money | Labor | Time | Per | Times`
- Impact: **High** - Blocks adding new features to economic model without language redesign.
- Fix approach: Redesign `EconomicUnit` as open/recursive type once DSL supports it (enums mentioned line 6 TODO, case matching mentioned line 43 TODO).

## Security Considerations

**C FFI in Critical Path:**
- Files: `EvmYul/FFI/ffi.c`, `lakefile.lean` (FFI linking)
- Issue: Direct C FFI calls to SHA256 and Keccak256 in lakefile (lines 26-64)
- Risk: FFI is high-trust code path. No input validation visible before C calls. Potential for crashes on malformed input.
- Current mitigation: Minimal - just linked from verified libs (amosnier/sha-2, brainhub/SHA3IUF)
- Recommendations:
  1. Add bounds checking in `ffi.c` before calling C functions
  2. Document safety invariants (max sizes, allowed patterns)
  3. Add property-based tests generating random inputs to FFI functions
  4. Consider using Haskell bindings instead of direct C if performance allows

## Dependencies at Risk

**Untracked Package Managers and Versions:**
- Lean: `lean-toolchain` pinned to `v4.22.0` (good)
- Haskell: `kalecky-spec/stack.yaml` (untracked) - cannot verify Stack resolver version without reading untracked file
- Solidity: `lib/forge-std`, `lib/plank-monorepo` - no version pins, likely fetching `main` branch
- GHC: Unknown - would need to check untracked `kalecky-spec/stack.yaml`
- Impact: Builds may fail or behave differently on different machines due to version drift.
- Fix approach:
  1. Document all tool versions in `.tool-versions` or similar
  2. Pin all git submodule commits (don't use floating refs)
  3. Add CI check that verifies exact versions used in builds

## Architectural Debt: No Clear Data Flow

**Information Flow Between Layers Undefined:**
- Three independent systems with unclear integration:
  1. Lean EvmYul - Formal EVM specification (committed)
  2. Haskell hevm - EVM implementation for verification (untracked)
  3. Kalecky economic model - Domain logic (untracked, incomplete)
- Missing: How does economic model relate to EVM layer? Does it compile to Solidity/Yul that runs on EvmYul? Does hevm execute it?
- Files: No central documentation; scattered across `EvmYul.lean`, `kalecky-spec/readme.md`, `kalecky-plank/Draft.plk`
- Impact: New contributors cannot understand system without reading all three layers independently.
- Fix approach: Add `ARCHITECTURE.md` at project root showing data flow: Economic Model → DSL Compilation → Yul/Bytecode → EvmYul Verification → hevm Execution.

---

*Concerns audit: 2026-08-15*
