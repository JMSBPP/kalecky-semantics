# Testing Patterns

**Analysis Date:** 2025-02-12

## Test Framework

**Runner:**
- Foundry (Forge) - for Solidity/Plank contract testing
- Lake (Lean package manager) - for Lean executable tests
- Custom Conform runner - for EVM conformance testing (JSON-based)

**Assertion Library:**
- Solidity: `forge-std/Test.sol` from Foundry (assertTrue, assertEq, assertApproxEqAbs, etc.)
- Lean: Custom validation logic in `Conform/TestRunner.lean`, standard Lean tactics (rfl, simp, omega)

**Run Commands:**
```bash
forge build                          # Build Solidity contracts
forge build --sizes                  # Build with size analysis
forge fmt --check                    # Check Solidity formatting
forge test -vvv                      # Run Solidity tests with verbose output
lake build                           # Build Lean project
lean --run path/to/executable.lean   # Run Lean test executable
```

## Test File Organization

**Location:**
- Solidity tests: `test/kalecky-plank/types/`
- Lean conformance tests: `Conform/` (test data in `BlockchainTests/`)
- Yul semantics tests: `EvmYul/Yul/YulSemanticsTests/`
- Kalecky-spec tests: `kalecky-spec/test/contracts/pass/` and `fail/`

**Naming:**
- Solidity test files: `*.t.sol` suffix (e.g., `NominalWage.t.sol`)
- Test contracts: `XyzTest is Test` (e.g., `NominalWageTest`)
- Test methods: `test_` or `test__unit__` prefix (e.g., `test__unit__setWage`)
- Symbolic test methods: `prove_` prefix (e.g., `prove_true`)

**Structure:**
```
test/
└── kalecky-plank/
    └── types/
        └── NominalWage.t.sol    # Test file for NominalWage type
```

## Test Structure

**Suite Organization (Solidity):**
```solidity
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {BuildOptions, Dependency, PlankDeployer} from "plank-foundry-deployer/PlankDeployer.sol";
import {console2} from "forge-std/console2.sol";

// Define test contracts/interfaces
struct TestData {
    uint256 val;
}
interface ITestContract {
    function method(TestData memory) external returns(TestData memory);
}

// Test contract
contract TestNameTest is Test, PlankDeployer {
    ITestContract contract;

    function setUp() public {
        // Initialize test dependencies
        BuildOptions memory opts;
        opts.backend = "sona";
        
        Dependency[] memory deps = new Dependency[](2);
        deps[0] = Dependency("std", "lib/plank-monorepo/std/");
        deps[1] = Dependency("types", "kalecky-plank/");
        opts.dependencies = deps;
        
        contract = ITestContract(plankDeployFFI("kalecky-plank/test/Contract.plk", opts));
    }

    function test__unit__methodName() public {
        console2.log("Test description");
        TestData memory result = contract.method(TestData(value));
        assertEq(result.val, expected);
    }
}
```

**Patterns:**
- setUp runs before each test function (Foundry convention)
- PlankDeployer FFI for cross-language (Plank→Solidity) testing
- BuildOptions configure compilation backend and dependencies
- State initialized in setUp, not at contract level

## Mocking

**Framework:** FFI (Foreign Function Interface) via PlankDeployer

**Patterns:**
```solidity
// Deploy via FFI
contract = ITestContract(plankDeployFFI(
    "path/to/contract.plk",
    opts
));

// Call deployed contract
result = contract.method(input);
```

**What to Mock:**
- External smart contracts via interface definitions
- Plank-compiled code via FFI deployment

**What NOT to Mock:**
- Core EVM operations (handled by Foundry)
- Standard library contracts (use real implementations)
- Blockchain state (Foundry provides anvil for state simulation)

## Fixtures and Factories

**Test Data:**
- Solidity: struct instances initialized in test functions
- Plank: const definitions in `.plk` files (e.g., `SELECTOR_SET_WAGE = 0xcbd33c60`)

**Location:**
- Solidity fixtures: defined at top of test file or in setUp
- Plank fixtures: `kalecky-plank/test/*.plk` files
- Lean fixtures: JSON test files in `BlockchainTests/` subdirectories

**Example:**
```solidity
struct NominalWage {
    uint256 val;
}

function test__unit__setWage() public {
    NominalWage memory fixture = NominalWage(1_800_000);
    // use fixture
}
```

## Coverage

**Requirements:** Not explicitly enforced in codebase
- No coverage targets set in foundry.toml
- Manual testing via forge test

**View Coverage:**
```bash
forge coverage                       # Generate coverage report
forge coverage --report lcov        # LCOV format
```

## Test Types

**Unit Tests:**
- Scope: Individual function or contract method
- Approach: Direct function call with known inputs, assert expected output
- Example: `test__unit__setWage()` - tests NominalWage setter in isolation
- Pattern: Test contracts extend `Test` from forge-std

**Integration Tests:**
- Scope: Multiple components interacting (Plank compiled to Solidity via FFI)
- Approach: Deploy via PlankDeployer, call methods, verify state changes
- Pattern: Uses BuildOptions for dependency management and FFI for cross-compilation

**E2E Tests:**
- Framework: Foundry test framework (simulated blockchain via Anvil)
- Scope: Full contract workflows from deployment to state finality
- Pattern: setUp() initializes contracts, test functions verify complete flows
- Example: `test/kalecky-plank/types/NominalWage.t.sol` - E2E test for income distribution types

**Conformance Tests (Lean):**
- Framework: Custom Conform runner in `Conform/TestRunner.lean`
- Format: JSON test files from Ethereum Test Suite
- Scope: EVM semantics compliance
- Pattern: `Conform.Main` loads JSON tests, compares pre/post state, reports deltas
- Parallel execution: Supports multi-threaded test scheduling (see `Conform/Main.lean` lines 64-73)
- Blacklist/Whitelist: Filter tests by name patterns

## Common Patterns

**Async Testing:**
- Solidity: No async/await (EVM transactions are pseudo-async)
- Lean: IO monad for side effects, Task for parallelism
- Pattern in Conform: `IO.asTask` for parallel test execution (line 73 of Main.lean)

**Error Testing (Solidity):**
```solidity
function test_reverts() public {
    vm.expectRevert("error message");
    contract.failingMethod();
}

function test_requires() public {
    vm.expectRevert(bytes4(keccak256("CustomError()")));
    contract.methodWithCustomError();
}
```

**State Verification (Lean Conformance):**
```lean
def compareWithEVMdefaults (s₁ s₂ : EvmYul.Storage) : Bool :=
  withDefault s₁ == withDefault s₂
  where
    withDefault (s : EvmYul.Storage) : EvmYul.Storage := 
      if s.contains ⟨0⟩ then s else s.insert ⟨0⟩ ⟨0⟩

def storageΔ (m₁ m₂ : PersistentAccountMap .EVM) : 
    PersistentAccountMap .EVM × PersistentAccountMap .EVM :=
  (storageComplement m₁ m₂, storageComplement m₂ m₁)
```

## CI/CD Integration

**CI Pipeline:** GitHub Actions (`.github/workflows/test.yml`)

**Steps:**
1. Checkout with submodules: `actions/checkout@v5` with `submodules: recursive`
2. Install Foundry: `foundry-rs/foundry-toolchain@v1`
3. Format check: `forge fmt --check`
4. Build: `forge build --sizes`
5. Test: `forge test -vvv`

**Environment:**
- `FOUNDRY_PROFILE: ci` (configuration profile)
- Ubuntu latest runner
- Permissions: read-only for contents

**Configuration (foundry.toml):**
```toml
[profile.default]
src = "kalecky-plank"
test = "test/kalecky-plank"
out = "out"
libs = ["lib"]
ffi = true  # Enable FFI for Plank interop
```

---

*Testing analysis: 2025-02-12*
