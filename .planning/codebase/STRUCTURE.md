# Codebase Structure

**Analysis Date:** 2025-02-14

## Directory Layout

```
/home/jmsbpp/learning/kalecky-semantics/
├── .planning/                          # Documentation (this agent's output)
├── kalecky-spec/                       # Haskell project: hevm + Kalecky types
│   ├── src/
│   │   ├── EVM/                        # EVM execution engine (inherited)
│   │   │   ├── EVM.hs
│   │   │   ├── Exec.hs
│   │   │   ├── Types.hs
│   │   │   ├── SymExec.hs              # Symbolic execution
│   │   │   ├── SMT/                    # SMT solver integration
│   │   │   ├── Precompiled.hs
│   │   │   ├── Op.hs
│   │   │   ├── UnitTest.hs
│   │   │   └── [20+ other modules]
│   │   └── Kalecky/                    # NEW: Economic domain types
│   │       ├── Operators/              # Economic operators
│   │       │   ├── Gap.hs
│   │       │   ├── Effect.hs
│   │       │   ├── GrowthRate.hs
│   │       │   ├── Conflict.hs
│   │       │   ├── Expectation.hs
│   │       │   └── Indexation.hs
│   │       └── types/                  # Domain type system
│   │           ├── Numerics.hs
│   │           ├── Measure.hs
│   │           ├── Valuation.hs
│   │           ├── Prices/
│   │           │   ├── Price.hs
│   │           │   └── Wage.hs
│   │           └── Units/
│   │               ├── Unit.hs
│   │               ├── CompoundUnit.hs
│   │               ├── MoneyUnit.hs
│   │               └── LaborUnit.hs
│   ├── cli/
│   │   └── cli.hs                      # hevm CLI entry point
│   ├── test/
│   │   ├── test.hs                     # Main Haskell test suite
│   │   ├── BlockchainTests.hs
│   │   ├── ForgeSymbolicTestSuite.hs   # Forge integration tests
│   │   ├── EVM/
│   │   │   ├── SymExec/
│   │   │   ├── ConcreteExecution/
│   │   │   ├── Equivalence/
│   │   │   └── Expr/
│   │   └── clitest.hs                  # CLI tests
│   ├── bench/
│   │   ├── bench.hs
│   │   └── bench-perf.hs
│   ├── kalecky-spec.cabal              # Haskell package definition
│   ├── stack.yaml                      # Stack resolver
│   ├── stack.yaml.lock                 # Stack lock file
│   ├── cabal.project                   # Cabal project config
│   ├── flake.nix                       # Nix development environment
│   ├── hie.yaml                        # Haskell IDE setup
│   ├── .hlint.yaml                     # Linting rules
│   └── doc/                            # hevm book (Markdown docs)
├── kalecky-plank/                      # Plank DSL: economic model implementation
│   ├── Draft.plk                       # Main type/const definitions
│   └── test/
│       └── NominalWageSetter.plk       # Wage-setting logic
├── EvmYul/                             # Lean semantics (inherited, reference)
│   ├── Semantics.lean
│   ├── MachineState.lean
│   ├── Operations.lean
│   ├── SHA256.lean
│   ├── BLAKE2_F.lean
│   ├── EllipticCurves.lean
│   └── [10+ other Lean proofs]
├── Conform/                            # Lean test runner infrastructure (inherited)
│   ├── Main.lean
│   ├── TestRunner.lean
│   ├── TestParser.lean
│   ├── Model.lean
│   └── Exception.lean
├── EthereumTests/                      # (Empty; reserved for Ethereum test vectors)
├── test/                               # Solidity tests for Foundry
│   └── kalecky-plank/
│       └── types/
│           └── NominalWage.t.sol       # Wage type test
├── lib/                                # External dependencies
│   ├── forge-std/                      # Foundry standard library
│   ├── plank-monorepo/                 # Plank compiler + stdlib
│   │   ├── std/                        # Plank standard library
│   │   │   ├── abi.plk
│   │   │   ├── option.plk
│   │   │   ├── storage.plk
│   │   │   ├── math.plk
│   │   │   └── [15+ stdlib modules]
│   │   └── plankc/                     # Plank compiler source
│   └── plank-foundry-deployer/         # PlankDeployer.sol + FFI helper
├── notes/                              # Design documentation
│   └── INCOME_DISTRIBUTION.md          # Economic model spec, type hierarchy
├── .github/                            # GitHub workflows (CI/CD config)
├── cache/                              # Foundry/Plank build cache
├── out/                                # Foundry compilation output (EVM bytecode)
├── .planning/                          # GSD analysis output (ARCHITECTURE.md, STRUCTURE.md)
├── foundry.toml                        # Foundry configuration
├── remappings.txt                      # Solidity import remappings
├── lakefile.lean                       # Lean build config
├── lean-toolchain                      # Lean version
├── lake-manifest.json                  # Lean dependency manifest
├── EvmYul.lean                         # Entry point for Lean proofs
├── SpongeHash.lean                     # Cryptographic utility
├── CLAUDE.md                           # Project instructions
├── README.md                           # Basic Foundry info
└── shell.nix                           # Nix shell configuration
```

## Directory Purposes

**kalecky-spec/**
- Purpose: Haskell implementation of hevm + new Kalecky economic types
- Contains: EVM bytecode execution engine, symbolic execution, economic domain types
- Key files: `kalecky-spec.cabal` (package definition), `src/EVM/` (engine), `src/Kalecky/` (domain)

**kalecky-plank/**
- Purpose: Executable specifications written in Plank DSL
- Contains: Type definitions and implementations targeting EVM bytecode
- Key files: `Draft.plk` (main spec), `test/NominalWageSetter.plk` (wage logic)
- Compiles to: Solidity contracts deployable to Anvil

**EvmYul/**
- Purpose: Lean formal proofs of EVM semantics (reference/academic)
- Contains: Theorem statements and proofs for instruction correctness
- Used by: Documentation, academic papers; referenced by hevm implementation

**Conform/**
- Purpose: Lean test infrastructure for conformance testing
- Contains: Test parser, runner, model definitions
- Used by: EVM conformance tests against Ethereum test vectors

**test/kalecky-plank/**
- Purpose: Foundry test contracts driving Kalecky implementation
- Contains: Solidity test files using PlankDeployer FFI to compile and test Plank code
- Key files: `types/NominalWage.t.sol` (wage type test)
- Executed by: `forge test` command

**lib/**
- Purpose: External reusable code
- Contents:
  - `forge-std/`: Standard Solidity testing library (forge assertions, console)
  - `plank-monorepo/std/`: Plank standard library (Option, ABI, math, storage)
  - `plank-monorepo/plankc/`: Plank compiler source (not directly used; external tool)
  - `plank-foundry-deployer/`: Solidity helper + FFI wrapper for PlankDeployer

**notes/**
- Purpose: Design documentation and specifications
- Key files: `INCOME_DISTRIBUTION.md` (economic model, type hierarchy, use cases)
- Format: Markdown with LaTeX math and pseudocode

**.planning/codebase/**
- Purpose: Analysis artifacts for GSD orchestrator
- Contains: ARCHITECTURE.md (this document), STRUCTURE.md, plus future CONVENTIONS.md, TESTING.md, etc.
- Generated by: `/gsd:map-codebase` CLI

## Key File Locations

**Entry Points:**

- `kalecky-spec/cli/cli.hs`: Haskell CLI executable (hevm tool)
- `kalecky-spec/kalecky-spec.cabal`: Package name and exposed modules
- `foundry.toml`: Foundry project config; entry point for `forge build`, `forge test`
- `kalecky-plank/Draft.plk`: Main Plank source (defines scales, units, types)

**Configuration:**

- `kalecky-spec/cabal.project`: Haskell dependency and build config
- `kalecky-spec/stack.yaml`: Stack resolver and package list
- `kalecky-spec/flake.nix`: Nix development environment
- `foundry.toml`: Foundry project structure (src, test, out, libs)
- `remappings.txt`: Solidity import alias resolution
- `.github/workflows/test.yml`: CI/CD pipeline

**Core Logic:**

- `kalecky-spec/src/EVM/`: EVM bytecode execution semantics
- `kalecky-spec/src/Kalecky/Operators/`: Economic operators (Gap, Effect, etc.)
- `kalecky-spec/src/Kalecky/types/`: Economic type system (Units, Prices, Measures)
- `kalecky-plank/Draft.plk`: Plank definitions for Kalecky domain
- `kalecky-plank/test/NominalWageSetter.plk`: Wage-setting implementation

**Testing:**

- `kalecky-spec/test/test.hs`: Haskell test suite (EVM unit tests)
- `kalecky-spec/test/ForgeSymbolicTestSuite.hs`: Forge → hevm integration tests
- `test/kalecky-plank/types/NominalWage.t.sol`: Solidity wage type test

**Documentation:**

- `notes/INCOME_DISTRIBUTION.md`: Domain specification and type theory
- `kalecky-spec/doc/`: hevm book (user guide, tutorials)
- `EvmYul/*.lean`: Lean proofs documenting EVM semantics
- `CLAUDE.md`: Project-specific instructions ("specs in kalecky-spec/")

## Naming Conventions

**Files:**

- `.hs`: Haskell modules (src/EVM/, src/Kalecky/)
- `.lean`: Lean proofs (EvmYul/, Conform/)
- `.plk`: Plank source code (kalecky-plank/)
- `.sol`: Solidity test contracts (test/kalecky-plank/)
- `.toml`: Configuration files (foundry.toml, cabal.project)
- `.md`: Documentation (notes/, kalecky-spec/doc/)
- `.yaml` / `.yml`: Configuration (stack.yaml, .github/workflows/test.yml)

**Directories:**

- Module hierarchy follows file path: `src/Kalecky/Operators/Gap.hs` → module `Kalecky.Operators.Gap`
- `src/`: Haskell source (library code)
- `cli/`: Haskell CLI entry points
- `test/`: Solidity tests or Haskell test harnesses
- `doc/`: Documentation
- `bench/`: Benchmarks
- `lib/`: External libraries/dependencies

**Kalecky-Specific Naming:**

- Economic operators: `Gap`, `Conflict`, `Effect`, `ResponseMultiplier`, `Indexation`, `Expectation`
- Economic types: `NominalWage`, `RealWage`, `LaborProductivity`, `PriceLevel`
- Plank DSL types: `Unit`, `Scale`, `CompoundUnit`, `Valuation`, `MoneyUnit`, `LaborUnit`
- Test contracts: `{DomainType}Test` (e.g., `NominalWageTest`)

## Where to Add New Code

**New Kalecky Economic Operator:**
- Primary code: `kalecky-spec/src/Kalecky/Operators/{OperatorName}.hs`
  - Define newtype wrapping the semantic distinction
  - Example: `newtype Elasticity responder perturband = Elasticity { effect :: Effect responder perturband }`
- Reference spec: Add mathematical definition to `notes/INCOME_DISTRIBUTION.md`
- Tests: Add to `kalecky-spec/test/test.hs` and/or Haskell test suite

**New Economic Type (Price, Unit, Measure):**
- Primary code: `kalecky-spec/src/Kalecky/types/{Category}/{TypeName}.hs`
  - Examples: `types/Prices/Wage.hs`, `types/Units/LaborUnit.hs`
- Plank equivalent: Define in `kalecky-plank/Draft.plk` with const + compile-time functions
  - Example: `const MoneyUnit = fn (comptime C: type, comptime S: type) type { ... }`
- Tests: `test/kalecky-plank/types/{TypeName}.t.sol` (Solidity test using PlankDeployer)

**New Plank Implementation (e.g., wage-setting logic):**
- Primary code: `kalecky-plank/{DomainModule}/{Implementation}.plk`
  - Example: `kalecky-plank/test/NominalWageSetter.plk`
- Test contract: `test/kalecky-plank/{DomainModule}/{Implementation}.t.sol`
  - Must use PlankDeployer FFI to compile and deploy .plk file
  - Run with: `forge test --match-path "test/kalecky-plank/**/*.t.sol"`

**New Solidity Test:**
- Location: `test/kalecky-plank/{domain}/{test-name}.t.sol`
- Structure: Extend `Test, PlankDeployer`; use PlankDeployer FFI to deploy Plank contracts
- Import: `PlankDeployer` from `lib/plank-foundry-deployer/`
- Dependencies: Must list in `BuildOptions.dependencies` array

**EVM Feature/Fix (rare, inherited codebase):**
- Primary code: `kalecky-spec/src/EVM/{Category}.hs`
- Examples: New opcode in `Op.hs`, new symbolic rule in `SymExec.hs`
- Test: Add to `kalecky-spec/test/test.hs` or `ForgeSymbolicTestSuite.hs`

**Utilities/Helpers:**
- Shared Plank utilities: `lib/plank-monorepo/std/`
- Shared Haskell utils: `kalecky-spec/src/EVM/` (refactor as needed)

## Special Directories

**cache/:**
- Purpose: Foundry compilation cache
- Generated: `forge build` produces intermediate EVM artifacts
- Committed: No (.gitignore'd)
- Clean with: `forge clean`

**out/:**
- Purpose: Foundry compilation output
- Generated: `forge build` produces `out/{ContractName}.sol/` with ABI, bytecode, storage layout
- Committed: No (.gitignore'd)
- Inspect for: `{ContractName}.json` (full ABI), `.bytecode` (EVM bytes)

**.stack-work/ (in kalecky-spec/):**
- Purpose: Stack build artifacts
- Generated: `stack build` produces local dependencies, compiled modules
- Committed: No (.gitignore'd)
- Clean with: `stack clean`

**.planning/:**
- Purpose: GSD analysis output and implementation planning
- Generated by: `/gsd:map-codebase` (produces ARCHITECTURE.md, STRUCTURE.md, etc.)
- Committed: Yes (planning artifacts are version-controlled)
- Subdirectories: `codebase/` (static analysis), `phases/` (implementation plans), `execution/` (completed phases)

---

*Structure analysis: 2025-02-14*
