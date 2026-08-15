# Architecture

**Analysis Date:** 2025-02-14

## Pattern Overview

**Overall:** Layered architecture combining formal verification (Lean), economic domain modeling (Haskell), and smart contract execution (Plank/EVM).

**Key Characteristics:**
- Vertical separation between domain specifications (Kalecky types/operators) and EVM infrastructure (hevm)
- Plank DSL compiles to EVM bytecode for execution and testing
- Haskell types model economic domains; EVM executes logic on blockchain
- Test-driven development: Solidity tests drive Plank implementation
- Academic-style specifications in notes/ inform type system design

## Layers

**Domain Layer (Economic Semantics):**
- Purpose: Define types and operators for Kaleckian economics
- Location: `kalecky-spec/src/Kalecky/`
- Contains: Type definitions (Units, Prices, Measures, Numerics), Operators (Gap, Effect, GrowthRate, Conflict, Indexation, Expectation)
- Depends on: Haskell standard library, custom numeric types
- Used by: EVM execution layer (when Plank code runs on-chain)

**Specification Layer (Domain Design):**
- Purpose: Document economic model structure and requirements
- Location: `notes/INCOME_DISTRIBUTION.md`
- Contains: Mathematical specifications, type hierarchies, semantic distinctions (e.g., Gap vs. Conflict)
- Depends on: Economic literature, mathematical notation
- Used by: Developers implementing Kalecky modules

**Implementation Layer (Plank DSL):**
- Purpose: Write executable economic model logic targeting EVM
- Location: `kalecky-plank/`
- Contains: Type definitions (Draft.plk), function implementations (NominalWageSetter.plk)
- Depends on: Plank standard library (`lib/plank-monorepo/std/`)
- Used by: Foundry test runner, hevm for symbolic execution

**EVM Infrastructure Layer (Inherited):**
- Purpose: Execute arbitrary EVM bytecode, symbolic execution, test harness
- Location: `kalecky-spec/src/EVM/`
- Contains: EVM semantics (`Op.hs`, `Exec.hs`, `Types.hs`), symbolic execution (`SymExec.hs`), testing (`UnitTest.hs`)
- Depends on: Z3 SMT solver, cryptographic libraries, Haskell runtime
- Used by: Plank compiler backend, Forge test runner, CLI tool (hevm)

**Verification Layer (Lean Proofs):**
- Purpose: Formal verification of EVM operations and semantic properties
- Location: `EvmYul/`
- Contains: Lean proofs for EVM instructions, cryptographic operations (BLAKE2_F, SHA256, etc.), state management
- Depends on: Lean theorem prover
- Used by: Academic publication, reference semantics for hevm

**Test Infrastructure Layer:**
- Purpose: Run unit tests and integration tests for Kalecky specifications
- Location: `test/kalecky-plank/`, `kalecky-spec/test/`
- Contains: Solidity tests (Forge format), Haskell test suites (EVM execution tests)
- Depends on: Forge/Foundry, hevm CLI, PlankDeployer FFI
- Used by: CI/CD, developer validation

## Data Flow

**Specification to Implementation:**

1. **Notes** (`INCOME_DISTRIBUTION.md`) document economic models with mathematical notation
   - Defines type hierarchies: Gap → Conflict → ExpectationsConflict
   - Specifies operators: Effect, ResponseMultiplier, Elasticity
   - Shows use cases: NominalWage as EconomicQuantity<Nominal, CompoundUnit<MoneyUnit, LaborUnit>>

2. **Haskell Types** (`kalecky-spec/src/Kalecky/`) implement specification abstractions
   - `Gap.hs`: Algebraic structure for differences
   - `Conflict.hs`: Semantic wrapper distinguishing economic conflict types
   - `Unit.hs`, `Valuation.hs`: Dimensional analysis support
   - Compile to bytecode-compatible types

3. **Plank Implementation** (`kalecky-plank/Draft.plk`) encodes domain types in DSL
   - Defines scales (MONTH_BASE, WORKER_BASE) as compile-time constants
   - Declares compound units via type-level functions (Per, Times)
   - Implements domain logic (NominalWageSetter.plk)

4. **Plank Compilation** → Solidity → EVM bytecode
   - PlankDeployer FFI invokes `plankc` compiler
   - Generates Solidity interfaces matching test contracts
   - Produces deployable bytecode for Anvil/Forge

5. **Test Execution** (`test/kalecky-plank/types/NominalWage.t.sol`)
   - Solidity tests import PlankDeployer and compile-time dependencies
   - Deploy Plank-compiled contracts via FFI
   - Validate economic logic: e.g., "set wage to 1,800,000 COP/month"

6. **Symbolic Execution** (optional hevm execution)
   - `hevm test` runs same Forge tests symbolically
   - Z3 SMT solver explores execution paths
   - Discovers edge cases and invariants

**State Management:**

- **Compile-time:** Plank type checking, FFI dispatch to `plankc`
- **Load-time:** EVM bytecode deployment to Anvil local chain
- **Runtime:** On-chain state via storage operations (SSTORE, SLOAD)
- **Post-execution:** Test assertions validate expected economic outcomes

## Key Abstractions

**Gap(X):**
- Purpose: Algebraic structure encoding a difference between two values of type X
- Files: `kalecky-spec/src/Kalecky/Operators/Gap.hs`
- Pattern: Gap lhs rhs ≡ lhs - rhs (requires subtraction in X)
- Example: Gap(E^H[W/P], W/P) = household expectation - realized real wage

**Conflict (semantic refinement of Gap):**
- Purpose: Distinguish gaps that represent economic conflicts from generic differences
- Files: `kalecky-spec/src/Kalecky/Operators/Conflict.hs`
- Pattern: newtype ExpectationsConflict x = ExpectationsConflict (Gap x)
- Example: ExpectationsConflict(E^H[W/P], E^F[W/P]) = wage expectation gap between household and firm agents

**Effect(responder, perturband):**
- Purpose: Model partial derivative ∂(responder)/∂(perturband)
- Files: `kalecky-spec/src/Kalecky/Operators/Effect.hs`
- Pattern: newtype Effect = Effect Number
- Example: Effect NominalWageGrowth HouseholdRealWageExpectationGap

**ResponseMultiplier (refinement of Effect):**
- Purpose: Quantify how much responder changes when perturband changes
- Files: `kalecky-spec/src/Kalecky/Operators/Effect.hs` (implicitly)
- Pattern: newtype ResponseMultiplier responder perturband = ResponseMultiplier (Effect responder perturband)

**EconomicQuantity<valuation, unit>:**
- Purpose: Encode dimensional analysis for economic variables
- Files: `kalecky-spec/src/Kalecky/types/Numerics.hs` (skeletal)
- Pattern: EconomicQuantity { amount :: Number, valuation :: Valuation, unit :: Unit }
- Example: NominalWage = EconomicQuantity<Nominal, CompoundUnit<MoneyUnit COP, LaborUnit Worker>>

**CompoundUnit(op, A, B):**
- Purpose: Type-safe ratio construction for derived units
- Files: `kalecky-plank/Draft.plk` (Per/Times operators), `kalecky-spec/src/Kalecky/types/Units/CompoundUnit.hs`
- Pattern: Per(MoneyUnit, LaborUnit) ≈ CompoundUnit<MoneyUnit, LaborUnit> represents money per labor service
- Example: Wage = MoneyUnit COP / LaborUnit Worker

## Entry Points

**Haskell CLI (hevm):**
- Location: `kalecky-spec/cli/cli.hs`, executable `hevm`
- Triggers: `hevm test --root myproject`
- Responsibilities: Parse Solidity contracts, compile to EVM, execute symbolically or concretely, report test results
- Depends on: `EVM.UnitTest`, `EVM.SymExec`, Z3 solver

**Forge/Foundry Test Runner:**
- Location: System-wide `forge` binary
- Triggers: `forge test` from project root (reads `foundry.toml`)
- Responsibilities: Compile Plank sources via PlankDeployer FFI, deploy to Anvil, run Solidity tests
- Reads config: `foundry.toml` (src=kalecky-plank, test=test/kalecky-plank)

**Plank Compiler (Backend):**
- Location: External tool `plankc` (in `lib/plank-monorepo/`)
- Triggers: FFI call from `PlankDeployer.sol` via Solidity `ffi` call
- Responsibilities: Parse .plk files, type-check with compile-time unit validation, generate Solidity code
- Dependencies: `kalecky-plank/`, `lib/plank-monorepo/std/`

## Error Handling

**Strategy:** Layered validation with fail-fast semantics

**Patterns:**

- **Compile-time type errors (Plank):**
  - CompileError emitted for unsupported Currency, Unit basis, Denomination
  - Example: `@compile_error("unsupported currency")` in `kalecky-plank/Draft.plk:47`
  - Resolution: Fix .plk source and recompile

- **EVM Runtime Errors (hevm):**
  - Reverts on arithmetic overflow, invalid opcodes, out-of-gas
  - SymExec.hs catches assertion failures in contract code
  - Resolution: Trace execution via `hevm` debug output or add assertions in test

- **Test Assertion Failures:**
  - Solidity require() statements in test contracts
  - Forge reports which assertion failed and gas usage
  - Example: `test__unit__setWage()` expects console output matching economic semantics

- **Missing Dependencies:**
  - Plank import errors if std/ or types/ not in dependency list
  - BuildOptions.dependencies must include "std" and "types"
  - Resolution: Add to deps array in test setUp() or fix remappings.txt

## Cross-Cutting Concerns

**Logging:** 
- Plank: `console.log()` from std library
- Haskell: `putStrLn` for CLI output, structured via `EVM.Format`
- Tests: Forge's `console2.log()` for test output

**Validation:** 
- Compile-time: Plank type checker enforces dimensional correctness (Scale, Currency, Unit)
- Runtime: EVM instruction validation in `Op.hs`, solver constraints in `SymExec.hs`
- Domain-level: Assertions in test contracts and Haskell test suites

**Authentication:** 
- EVM caller identity via `msg.sender`
- Forge fuzz testing in `ForgeSymbolicTestSuite.hs`
- Access control patterns in Plank stdlib (`sol.sol` precompiles)

**Build Consistency:**
- Cabal lockfile: `kalecky-spec/cabal.project.freeze`
- Stack lockfile: `kalecky-spec/stack.yaml.lock`
- Nix flake: `kalecky-spec/flake.nix` for reproducible dev environment
- Foundry remappings: `remappings.txt` for library resolution

---

*Architecture analysis: 2025-02-14*
