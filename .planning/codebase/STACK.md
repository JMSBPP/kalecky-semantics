# Technology Stack

**Analysis Date:** 2025-02-10

## Languages

**Primary:**
- **Haskell** (GHC) - Kaleckian economics model implementation in `kalecky-spec/`
- **Lean 4** (v4.22.0) - Formal verification of EVM semantics in `EvmYul/`
- **Rust** (Edition 2024) - Plank compiler infrastructure (`lib/plank-monorepo/plankc/`)
- **Solidity** (0.8.31) - Smart contract specifications for income distribution testing
- **Yul** - EVM assembly-level semantics and testing

**Secondary:**
- **Python** 3.12 - Cryptographic utilities (coincurve, eth-typing, py-ecc)
- **JavaScript** - Documentation rendering via Node.js (mdbook, mdbook-mermaid)

## Runtime & Build

**Haskell:**
- **Compiler:** GHC (via Nix flake or Cabal)
- **Build Tools:** 
  - Cabal 3.0+ (package manager)
  - Stack (LTS 23.28) via `kalecky-spec/stack.yaml`
  - Nix Flakes (reproducible builds)
- **Lockfile:** `kalecky-spec/stack.yaml.lock`, `kalecky-spec/cabal.project`

**Lean 4:**
- **Toolchain:** `lean-toolchain` (leanprover/lean4:v4.22.0)
- **Build Tool:** Lake (Lean's build system)
- **Manifest:** `lake-manifest.json` (dependency management)

**Rust:**
- **Build System:** Cargo (workspace at `lib/plank-monorepo/plankc/`)
- **Edition:** 2024
- **Profiles:** release-safe, profiling (custom profiles in workspace root)

**Solidity/EVM:**
- **Framework:** Foundry (forge, cast, anvil, chisel)
- **Config:** `foundry.toml` (src: `kalecky-plank/`, test: `test/kalecky-plank/`, out: `out/`)
- **Solidity Compiler:** solc 0.8.31 (managed via Nix)

**Environment Management:**
- **Package Manager:** Nix (declarative dependency management)
- **Shell Environments:** 
  - `shell.nix` (Python + Lean development tools + openssl)
  - `kalecky-spec/flake.nix` (Haskell hevm + testing dependencies)
  - `EvmYul/Yul/YulSemanticsTests/shell.nix` (solc-select for Yul testing)

## Frameworks & Key Dependencies

**Haskell (kalecky-spec):**
- **EVM Execution:** hevm (local EVM implementation)
- **Testing:** 
  - QuickCheck (property-based testing)
  - Tasty (test framework)
  - tasty-quickcheck (QuickCheck integration)
- **Parsing & Language:** 
  - megaparsec (parser combinator library)
  - data structures (containers, vector)
- **Serialization:** aeson, cereal, binary
- **Cryptography:** 
  - crypton (replaces cryptohash)
  - secp256k1 (static-linked elliptic curve library)
  - base16 (hex encoding)
- **Optics:** optics-core, optics-extra, optics-th, aeson-optics
- **Utilities:** optparse-generic, async, stm, spawn, witch

**Lean 4 (EvmYul):**
- **Standard Library:** Mathlib4 (v4.22.0)
- **Utilities:** Batteries, Plausible
- **Verification Tools:** ProofWidgets4, aesop, import-graph, LeanSearchClient
- **FFI:** C bindings to SHA-256 and Keccak-256 (see `lakefile.lean`)

**Rust (Plank Compiler):**
- Modular monorepo:
  - `plank-core`: Index vectors, string interning, big integers
  - `plank-parser`: Lexer (logos), error-resilient CST/AST
  - `plank-hir`: High-level IR
  - `plank-mir`: Mid-level IR
  - `plank-evm`: EVM codegen
  - `sir/*`: Sensei IR (EVM-specific intermediate representation)

**Node.js (Documentation):**
- mdbook (static site generation)
- mdbook-mermaid (diagrams)
- highlight.js, highlightjs-solidity (syntax highlighting)
- prettier (formatting, NPM version 4.0.0-alpha.8)

## External Tools & Solvers

**Development Environment:**
- **Version Control:** Git (submodules used for EthereumTests)
- **Editor Support:** 
  - Haskell Language Server (HLS)
  - Lean Language Server
  - VSCode extensions (plank-vscode, plank-zed in lib/plank-monorepo)
- **Formatters & Linters:**
  - HLint (Haskell linting)
  - Prettier (JavaScript/Markdown formatting)
  - rustfmt (Rust formatting)

**Testing & Verification:**
- **SMT Solvers** (from `kalecky-spec/flake.nix`):
  - Z3 (Microsoft's SMT solver)
  - cvc5 (Cooperating Validity Checker)
  - Bitwuzla (bit-vector solver)
  - empty-smt-solver (test framework integration)
- **Blockchain Fixtures:**
  - execution-spec-tests v5.4.0 (Ethereum Osaka fixtures)
  - Ethereum test vectors via submodule (EthereumTests)

**Deployment & Interaction:**
- **Forge-std:** Library of Solidity test utilities
- **Plank Foundry Deployer:** Custom deployer for Plank-compiled contracts
- **Solady:** Advanced Solidity library (via lib/plank-monorepo)

## Configuration Files

**Package Management:**
- `kalecky-spec/cabal.project` - Haskell project config
- `kalecky-spec/stack.yaml` - Haskell Stack snapshot
- `lib/plank-monorepo/plankc/Cargo.toml` - Rust workspace
- `foundry.toml` - Foundry profile (FFI enabled, src=kalecky-plank, test=test/kalecky-plank)

**Build & Environment:**
- `kalecky-spec/flake.nix` - Nix flake for reproducible builds
- `shell.nix` - Nix shell for development
- `lean-toolchain` - Lean version pinning
- `lake-manifest.json` - Lean Lake dependencies

**Development:**
- `kalecky-spec/.hlint.yaml` - HLint configuration
- `kalecky-spec/hie.yaml` - HLS configuration
- `remappings.txt` - Foundry remappings:
  - `forge-std/` → forge-std library
  - `plank-foundry-deployer/` → custom deployer
  - `plank-monorepo/` → plank libraries
  - `solady/` → advanced Solidity utilities
  - `test-helpers` → local test utilities

## Compilation Flags

**Haskell (kalecky-spec):**
- `ci`: Enforce -Werror in CI
- `static-secp256k1`: Static linkage for secp256k1
- `devel`: Development mode with parallel compilation
- `debug`: Debug symbols, eventlog, info-table-map

**Lean 4:**
- `autoImplicit=false` - Explicit implicit parameter requirement

## Platform Requirements

**Development:**
- Linux/macOS/Windows (tested on nixos-24.11)
- Git with submodule support
- Nix package manager (optional but recommended)
- GHC with Haskell 2021 standard
- Lean 4.22.0 toolchain (via elan)

**Testing:**
- SMT solvers (z3, cvc5, bitwuzla)
- solc compiler (0.8.31)
- go-ethereum (geth)
- OpenSSL development libraries
- secp256k1 C library

**Production:**
- Linux (primary target for redistributable builds)
- Static binary builds possible via Nix (libcxx, libsystem, libiconv on macOS)

---

*Stack analysis: 2025-02-10*
