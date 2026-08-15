# External Integrations

**Analysis Date:** 2025-02-10

## Overview

This project is primarily a formal verification and compiler infrastructure for Kaleckian economics specifications. It has **no external runtime APIs or cloud services** — all integrations are development and toolchain-based.

## Blockchain & EVM Specifications

**Ethereum Execution Specification Tests:**
- Source: GitHub Releases (`ethereum/execution-spec-tests`)
- Version: v5.4.0 (Osaka hardfork)
- Content: Blockchain test fixtures (fixtures_develop.tar.gz)
- Location: Downloaded and extracted to `HEVM_ETHEREUM_TESTS_REPO` (set in `kalecky-spec/flake.nix`)
- Purpose: Provides authoritative Ethereum behavior test vectors for EVM verification

**Ethereum Test Vectors:**
- Source: GitHub submodule (`ethereum/tests`)
- Location: `EthereumTests/` (git submodule)
- Purpose: Historical blockchain tests for validation
- Access: Via `git submodule update --init` (automated in `lakefile.lean`)

## Development Tools & Frameworks

**Foundry (Forge):**
- Purpose: Smart contract testing and deployment framework
- Config: `foundry.toml`
- Features: 
  - FFI enabled (ffi=true) for calling external binaries
  - Source directory: `kalecky-plank/`
  - Test directory: `test/kalecky-plank/`
  - Output: `out/`
- Libraries linked:
  - `forge-std/` (Foundry test library)
  - `plank-foundry-deployer/` (custom deployer for Plank contracts)
  - `solady/` (advanced Solidity utilities)

**Solidity Compiler Integration:**
- Compiler: solc 0.8.31
- Management: Via Nix (solc-pkgs overlay)
- Environment Variable: `DAPP_SOLC` (set to solc binary path)
- Version Selection: solc-select available in `EvmYul/Yul/YulSemanticsTests/shell.nix`

**Hevm (Haskell EVM):**
- Purpose: Embedded EVM interpreter for testing and verification
- Source: `kalecky-spec/`
- Binary Artifacts: 
  - `packages.hevm` - wrapped (dynamic-linked)
  - `packages.redistributable` - static for distribution
- Testing: Integrated with Haskell test suites (QuickCheck + Tasty)

## SMT Solver Integration

**Z3:**
- Provider: Microsoft Research
- Purpose: Constraint solving for symbolic execution
- Status: Included in dev environment
- Usage: Via `kalecky-spec/stack.yaml` test dependencies

**CVC5:**
- Provider: The CVC Project
- Purpose: Alternative SMT solver for verification
- Status: Included in dev environment
- Usage: Via `kalecky-spec/stack.yaml` test dependencies

**Bitwuzla:**
- Provider: Open-source bit-vector solver
- Purpose: Specialized bit-vector and array reasoning
- Status: Included in dev environment
- Usage: Via `kalecky-spec/stack.yaml` test dependencies

**empty-smt-solver:**
- URL: `github:msooseth/empty-smt-solver/74bd120fdb730fde8e44243305e669e5e8a3e02a`
- Purpose: Mock SMT solver for testing SMT integration
- Status: Nix flake dependency (kalecky-spec/flake.nix)

## Cryptographic Libraries & Dependencies

**Secp256k1 (C library):**
- Purpose: ECDSA signature verification and key operations
- Linkage: Static (enabled via Nix)
- Haskell Binding: Via `kalecky-spec/cabal.project`
- Configuration: `--enable-static` flag for static builds

**SHA-2 & Keccak-256 (FFI):**
- C Libraries: Cloned and linked via Lake
  - SHA-2: `github:amosnier/sha-2.git` (cloned to `sha2/`)
  - Keccak-256: `github:brainhub/SHA3IUF.git` (cloned to `keccak256/`)
- Location in Lean: Compiled into `libleanffi` (static library)
- Build Config: `lakefile.lean` (targets: `cloneSha2`, `cloneKeccak256`, `ffi.o`, `libleanffi`)

**Crypton & Memory:**
- Purpose: Cryptographic primitives (replaces deprecated cryptohash)
- Usage: Haskell dependency in `kalecky-spec/kalecky-spec.cabal`
- Linked Libraries: gmp (big integers), libff (pairing-friendly curves)

## Version Control & Collaboration

**GitHub Repository:**
- URL: `https://github.com/JMSBPP/kalecky-semantics.git`
- Purpose: Version control and issue tracking
- CI: GitHub Actions workflow (`.github/workflows/test.yml` - present but untracked)
- Submodule: `EthereumTests` (git submodule)

**Plank Monorepo (Vendored):**
- Source: `lib/plank-monorepo/` (subrepository)
- Components:
  - `plankc/` - Plank compiler (Rust)
  - `plank-doc/` - Documentation
  - `plank-vscode/` - VS Code extension
  - `plank-zed/` - Zed editor extension
  - `plank-tree-sitter/` - Tree-sitter grammar
- Purpose: Provides compiler infrastructure for Plank DSL

## Documentation Hosting

**MDBook:**
- Purpose: Static documentation site generation
- Config: `kalecky-spec/doc/book.toml`
- Build Tools: mdbook, mdbook-mermaid, highlight.js
- Themes: Custom theme via Parcel bundler (`kalecky-spec/doc/theme/`)

**Cloudflare Wrangler:**
- Config: `lib/plank-monorepo/plank-doc/wrangler.toml`
- Purpose: Deploy documentation to Cloudflare Pages (if used)
- Status: Configuration present but not actively integrated in kalecky-semantics

## Lean 4 Ecosystem

**Mathlib4 & Dependencies:**
All via Lake package management (`lake-manifest.json`):
- **mathlib4** (v4.22.0) - Community mathematics library
- **plausible** - Automation tactics
- **LeanSearchClient** - Code search
- **import-graph** - Dependency visualization
- **ProofWidgets4** (v0.0.68) - Interactive proof UI
- **aesop** (v4.22.0) - Automation search
- **Qq** (quote4) - Quasiquoting macros
- **batteries** (v4.22.0) - Standard library extensions
- **lean4-cli** - Command-line utilities

## File Structure & Remappings

**Foundry Path Remappings** (`remappings.txt`):
```
forge-std/=lib/forge-std/src/
plank-foundry-deployer/=lib/plank-foundry-deployer/src/
plank-monorepo/=lib/plank-monorepo/
solady/=lib/plank-monorepo/plankc/plank-diff-tests/lib/solady/src/
test-helpers=kalecky-plank/test/
```

**Library Linking:**
- `lib/forge-std/` - Foundry test framework
- `lib/plank-monorepo/` - Plank compiler infrastructure
- `lib/plank-foundry-deployer/` - Deployment automation
- `lib/solady/` - Advanced Solidity utilities

## Environment Variables (Development)

**Set by Nix Flake (`kalecky-spec/flake.nix`):**
- `HEVM_SOLIDITY_REPO` - Solidity reference implementation
- `HEVM_ETHEREUM_TESTS_REPO` - Ethereum test vectors (blockchain_tests/)
- `HEVM_FORGE_STD_REPO` - Forge standard library
- `DAPP_SOLC` - Path to solc compiler
- `LD_LIBRARY_PATH` / `DYLD_LIBRARY_PATH` - Cryptographic libraries

**Set by Nix Shell (`shell.nix`):**
- `LD_LIBRARY_PATH` - OpenSSL location

## Security & Verification

**No External Services:**
- No cloud APIs
- No authentication providers
- No external databases
- No webhooks or callbacks
- All data remains local

**Verification Chain:**
- Formal proofs in Lean 4 (EvmYul)
- Property-based tests in Haskell (QuickCheck)
- Differential testing against actual EVM
- No trust assumption on external systems (specifications are authoritative)

---

*Integration audit: 2025-02-10*
