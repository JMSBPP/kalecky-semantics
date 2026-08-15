# Coding Conventions

**Analysis Date:** 2025-02-12

## Naming Patterns

**Files:**
- Lean files: PascalCase (e.g., `UInt256.lean`, `MachineState.lean`, `StateOps.lean`)
- Solidity test files: snake_case with `.t.sol` suffix (e.g., `NominalWage.t.sol`)
- Plank files: PascalCase (e.g., `Draft.plk`, `NominalWageSetter.plk`)
- Directories: PascalCase or lowercase (e.g., `EvmYul/`, `State/`, `Maps/`)

**Functions/Definitions (Lean):**
- Lean definitions: camelCase (e.g., `ofNat`, `toNat`, `addAccessedAccount`, `lookupAccount`)
- Helper functions: remain in namespace (e.g., `State.addAccessedAccount`)
- Private functions: prefixed with `private` keyword
- Abbreviations for type aliases: `abbrev TypeName := ...`

**Variables:**
- camelCase in Lean (e.g., `gasAvailable`, `activeWords`, `returnData`)
- Type parameters: single letter lowercase or Greek letters (e.g., `τ` for type, `σ` for state)
- Immutable bindings use `let`

**Types:**
- Structures: PascalCase (e.g., `MachineState`, `Account`, `Transaction`)
- Inductive types: PascalCase (e.g., `PostState`, `Exception`)
- Type aliases via `abbrev`: PascalCase (e.g., `TestId`, `Code`, `Pre`, `Post`)

**Constants (Plank):**
- UPPERCASE_WITH_UNDERSCORES (e.g., `SELECTOR_SET_WAGE`, `MONTH_BASE`, `WORKER_BASE`)
- Compile-time functions: camelCase (e.g., `TimeScale`, `LaborScale`, `MoneyUnit`)

**Test Functions (Solidity):**
- Foundry convention: `test_` or `test__unit__` prefix (e.g., `test__unit__setWage`)
- Symbolic tests: `prove_` prefix (e.g., `prove_true`)
- Public visibility: `public` keyword

## Code Style

**Formatting:**
- Linter: `forge fmt` for Solidity (enforced via CI)
- Indentation: 4 spaces (standard for Solidity)
- Line length: Follow Solidity/Lean conventions (no hard limit enforced)

**Linting:**
- Solidity: Foundry's built-in formatter via `forge fmt --check` (CI enforces)
- Lean: No explicit linter, but follows Mathlib4 conventions
- Project: Lean 4 with autoImplicit=false for strict type checking (`lakefile.lean` line 8)

## Import Organization

**Order (Lean):**
1. Standard library imports: `import Init.*`, `import Batteries`
2. Mathlib imports: `import Mathlib.*`
3. Project-specific imports: `import EvmYul.*`, `import Conform.*`
4. Local file imports (same namespace): none (use open instead)

**Path Aliases (Lean):**
- Namespace structure maps to file hierarchy: `EvmYul.UInt256` → `EvmYul/UInt256.lean`
- Sub-namespaces: `EvmYul.State.Account` → `EvmYul/State/Account.lean`
- No explicit import aliases, but `open` statement brings items into scope

**Solidity Imports:**
- Forge-std imports: `import {Test} from "forge-std/Test.sol"`
- Project imports: `import {BuildOptions, PlankDeployer} from "plank-foundry-deployer/PlankDeployer.sol"`
- Remapping via `remappings.txt` for library paths

## Error Handling

**Lean Patterns:**
- Result type: `Except String T` for operations that can fail
- Option type: `Option T` for potentially missing values
- Error construction: `.error "message"` for errors, `.ok value` for success
- Handling methods: `.option default_value`, `.elim on_error on_success`, `.getD default`
- Exception types: inductive `Exception` enum (e.g., `CannotParse`, `InvalidTestStructure` in `Conform/Exception.lean`)
- Pattern matching: explicit case handling with `match` or case expressions

**Solidity Patterns:**
- Assertions: `assertTrue()`, `assertEq()`, `assertApproxEqAbs()` from Foundry Test.sol
- Reverts: `expectRevert()` for testing failure cases
- No custom exceptions, rely on require/revert strings

## Logging

**Framework:** `console2` from forge-std (Solidity tests)

**Patterns:**
- Solidity: `console2.log("message", value)`
- Lean: String formatting with `s!"interpolated {value}"`
- Output: Test execution logs written to `tests_<phase>.txt` (see `Conform/Main.lean` line 17)

## Comments

**When to Comment:**
- Complex algorithm explanations (e.g., section references like "Section 4.1., equation 15")
- Non-obvious design decisions
- Workarounds or temporary solutions (TODO, FIXME comments)
- Specific examples in test setup/execution

**Documentation Comments:**
- Lean: `/--` ... `--/` for documentation blocks (required for public definitions)
- Examples: `UInt256.lean` line 16: `/-- The size of type UInt256, that is, 2^256. --/`
- Solidity: `//` for inline comments, `/** */` for documentation (standard Solidity)

**JSDoc/TSDoc:** Not used in this project (Lean and Solidity lack these conventions)

## Function Design

**Size:** Lean functions generally 5-50 lines; longer functions broken into sections
- Helper functions defined with `where` clause for internal use
- Sections (`section Name ... end Name`) group related functions (see `StateOps.lean` lines 66, 82)

**Parameters:**
- Explicit type signatures mandatory: `def functionName {τ} (param : Type) : ReturnType`
- Type parameters in curly braces for implicit arguments: `{τ}`
- Named parameter groups for related arguments
- Lean pattern: `(self : State τ)` as first parameter for methods

**Return Values:**
- Single value or structured type (tuple, record, Option)
- Lean: state-returning functions return pairs `(State τ × ReturnValue)` for gas/result tracking
- Solidity: multiple return values via tuple syntax
- Error cases: handled via Except/Option types in Lean, via revert in Solidity

## Module Design

**Exports:**
- Lean: namespace determines export (all public defs in namespace exported)
- No explicit `export` keyword; visibility controlled by private keyword
- Pattern: namespace hierarchy matches file structure

**Barrel Files:**
- `EvmYul.lean` (root aggregator) imports all submodules
- `Conform.lean` (implicit in folder structure)
- Pattern: top-level file re-exports everything for convenience

## Specification References

- Comments reference EVM specification sections (e.g., "Section 9.4.1", "equation 15")
- Kaleckian economics formulas documented in `notes/INCOME_DISTRIBUTION.md`
- Test structure follows Ethereum test format (JSON-based)

---

*Convention analysis: 2025-02-12*
