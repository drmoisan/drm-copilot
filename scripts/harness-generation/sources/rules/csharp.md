<!-- harness-section: head -->

# C# Code Standards

This rule file summarizes the C#-specific policies for this repository. It targets a host-neutral .NET foundation: MSTest, NSubstitute, FluentAssertions, `dotnet build`, the analyzer stack, `TimeProvider`, and uniform coverage thresholds.

<!-- harness-section: toolchain -->
## Toolchain

1. **Formatting — CSharpier**: All C# source files must be formatted with CSharpier. Do not use `dotnet format`. Command: `dotnet tool restore` followed by `dotnet csharpier check .` (or `dotnet csharpier .` to auto-format).
2. **Linting — .NET Analyzers**: C# code must pass Roslyn/.NET analyzer diagnostics. Analyzer enforcement is centralized in `Directory.Build.props` (`AnalysisLevel=latest-all`, `AnalysisMode=All`, `TreatWarningsAsErrors=true`). Command: `dotnet build` runs analyzers as part of the build.
3. **Type Checking — Nullable Analysis**: Nullable reference types are enabled solution-wide via `Directory.Build.props` (`Nullable=enable`, `TreatWarningsAsErrors=true`). Command: `dotnet build` enforces nullable warnings as errors.
4. **Testing — MSTest + NSubstitute + FluentAssertions**: Run tests with: `dotnet test --collect:"XPlat Code Coverage"`.

Run the toolchain in order: format → lint → type-check → architecture → test. Restart from step 1 if any step fails or changes files. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

<!-- harness-section: coding-standards -->
## Coding Standards

- **Naming**: `PascalCase` for types and public members. `camelCase` for locals and private fields/parameters. Private fields use `_camelCase`. Interfaces use the `I` prefix. Async methods carry the `Async` suffix.
- **Null safety**: Keep nullable reference types enabled. Model optional values with nullable annotations and guard clauses.
- **Composition over inheritance**: Keep classes cohesive and scoped to one responsibility. Favor composition unless polymorphism is a clear requirement.
- **Async/await**: Use `async`/`await` for I/O-bound operations. Prefer `using`/`await using` for disposable resources.
- **Exceptions**: Fail fast with explicit exceptions. Avoid broad `catch (Exception)` unless at a defined boundary with added context.
- **Public surface**: Keep public API surface intentional and minimal. Prefer `internal` for non-public APIs.
- **XML docs**: Public APIs should include XML documentation comments when behavior or contract is non-obvious.
- **File-scoped namespaces**: Required (`csharp_style_namespace_declarations = file_scoped:error` in `.editorconfig`).

<!-- harness-section: testing-standards -->
## Testing Standards

- Use **MSTest** (`Microsoft.VisualStudio.TestTools.UnitTesting`) as the test framework with `[TestClass]` and `[TestMethod]` attributes, on the VSTest runner (the `MSTest` package with `Microsoft.NET.Test.Sdk` and `coverlet.collector`).
- Use **`[TestMethod]` + `[DataRow]`** for parameterized tests.
- Use **`[ClassInitialize]`** to share expensive setup across tests within a class.
- Use **NSubstitute** for test doubles. Example: `var sut = Substitute.For<IService>(); sut.Get().Returns(value);`.
- Prefer **FluentAssertions** for assertions; use MSTest `Assert` only when FluentAssertions is not practical.
- Follow Arrange–Act–Assert structure.
- No external dependencies in unit tests.

### Coverage

- Line coverage line >= 85% and branch coverage branch >= 75% uniform across all tiers (T1–T4). No tier-specific lower floor is used.
- Mutation score mutation >= 75% on T1 modules (via Stryker.NET).
- Coverage regression on changed lines is a blocking finding.
- Interface-only files with no executable behavior — files consisting solely of `interface` declarations or abstract contracts — may be omitted from coverage measurement. Such files legitimately report 0% executable coverage. This is a clarification only; it does not lower any coverage threshold.

### Property-Based and Mutation Testing

- **CsCheck**: at least one property-based test per pure function on T1 and T2 modules.
- **Stryker.NET**: mutation testing required on T1 modules with a mutation score mutation >= 75%. Runs in pre-merge or nightly pipelines.

### Golden Tests

- **Verify.MSTest**: required for T1 classifier-output modules, tested against a versioned corpus.

<!-- harness-section: analyzer-stack -->
## Analyzer Stack

All projects reference the following analyzer packages via `<PackageReference>` with `PrivateAssets="all"` (versions pinned centrally in `Directory.Packages.props`):

- `Meziantou.Analyzer` — `PrivateAssets="all"`
- `SonarAnalyzer.CSharp` — `PrivateAssets="all"`
- `Roslynator.Analyzers` — `PrivateAssets="all"`
- `AsyncFixer` — `PrivateAssets="all"`
- `SecurityCodeScan.VS2019` — `PrivateAssets="all"`
- `Microsoft.CodeAnalysis.BannedApiAnalyzers` — `PrivateAssets="all"`

The shared `<ItemGroup>` lives in `Directory.Build.props` so the stack applies to every project automatically.

<!-- harness-section: banned-apis -->
## Banned APIs

The following APIs are banned outside an explicit allowlist; enforcement is via `Microsoft.CodeAnalysis.BannedApiAnalyzers` against `BannedSymbols.txt` (at solution root, wired through `Directory.Build.props` as an `<AdditionalFiles>` entry):

- `DateTime.Now` (use `TimeProvider.GetLocalNow()` on an injected `TimeProvider`).
- `DateTime.UtcNow` (use `TimeProvider.GetUtcNow()` on an injected `TimeProvider`).
- `Random.Shared` (inject a seeded `Random` or use a deterministic seam).
- `Thread.Sleep` (banned; use cooperative awaits and fake-time advancement).
- `Task.Delay` (banned in production paths; tests must use `FakeTimeProvider`).

Tests inject `TimeProvider` via `Microsoft.Extensions.TimeProvider.Testing`'s `FakeTimeProvider` rather than calling `DateTime.UtcNow` or `Task.Delay` directly.

<!-- harness-section: deterministic-test-rules -->
## Deterministic Test Rules

Unit tests must not depend on network, mutable machine PATH or profile state, implicit working-directory assumptions, or external services. Use seam-based mocking for all external boundaries (processes, HTTP, filesystem, clocks). Tests must produce identical results in the IDE test runner and in CLI runs so local and CI behavior agree.

<!-- harness-section: di-seams -->
## DI Seams

Introduce the smallest seam that enables reliable unit testing. Apply in this order of preference:

1. **Interface seam (preferred)** — extract boundary calls into narrow purpose-specific interfaces (for example, `IProcessRunner`, `IFileSystem`). Keep interfaces minimal.
2. **Injectable delegate seam** — use a narrow `Func<>`/`Action<>` delegate for a single call path when a full interface is excessive. Default behavior must remain safe and deterministic.
3. **Adapter seam for static or third-party APIs** — wrap the static or third-party call behind a small adapter so tests can substitute the adapter with NSubstitute.

### Clock Seam

- **`TimeProvider` is preferred** for new code (since .NET 8). Inject `TimeProvider` and use `GetUtcNow()` / `GetLocalNow()` / `CreateTimer()`.
- Test code injects `FakeTimeProvider` from **`Microsoft.Extensions.TimeProvider.Testing`** to advance simulated time deterministically.
- `IClock` legacy: acceptable only in legacy or pre-.NET 8 contexts that have not yet been migrated. New code must use `TimeProvider`.

<!-- harness-section: prohibited-behaviors -->
## Prohibited Behaviors

- Broad refactors across unrelated projects or files.
- Introducing heavy generic abstraction frameworks without need.
- Creating analyzer debt and deferring cleanup.
- Weakening assertions or relaxing test expectations to make tests pass.
- Adding sleeps, retries, or timing hacks to mask flaky behavior.
- Reporting success without running the required toolchain.
<!-- harness-section: head-2 -->

# C# Code Change Policy

This policy **extends** `general-code-change.instructions.md` and applies to all **C# source, test, and build-configuration files** (`*.cs`, `*.csproj`, `*.props`, `*.targets`) in this repo.

You must:

- Apply **all** rules in the general code change policy.
- Apply **all** C#-specific rules in this file.
- Apply the unit test policies (`general-unit-test.instructions.md` and `csharp-unit-test.instructions.md`) for any work involving tests.

If you encounter any conflicting instructions between these documents, **halt and notify the user.**

---

<!-- harness-section: 1-tooling-baseline-for-c -->
## 1. Tooling & Baseline for C#

These are the required tools for C# code in this repo:

1. **Formatting — `csharpier`**

   - All C# source files (`*.cs`) must be formatted with `csharpier`.
   - Do **not** use `dotnet format` — it loads the solution/project model and can mis-handle legacy VSTO / .NET Framework projects by rewriting `.csproj` files.
   - `csharpier` is file-based and formats only `*.cs` without touching project files.
   - Do not hand-format; if a diff disagrees with `csharpier`, formatter output wins.
   - Approved commands:
     - `dotnet tool run csharpier .`
     - or `csharpier .` (if installed globally)

2. **Linting / Static Analysis — .NET analyzers**

   - C# code must pass Roslyn/.NET analyzer diagnostics configured by `.editorconfig`, `.globalconfig`, and project properties.
   - Enforce analyzer diagnostics in build using `EnableNETAnalyzers` and `EnforceCodeStyleInBuild`.
   - Prefer fixing diagnostics over suppressing them.
   - Approved commands (Windows; choose the variant for your shell):
     - **CMD / Developer Command Prompt:** `msbuild <solution>.sln /t:Build /p:Configuration=Debug /p:Platform="Any CPU" /p:EnableNETAnalyzers=true /p:EnforceCodeStyleInBuild=true`
     - **PowerShell:** `msbuild <solution>.sln /t:Build /p:Configuration=Debug /p:Platform='Any CPU' /p:EnableNETAnalyzers=true /p:EnforceCodeStyleInBuild=true`

3. **Type Checking — C# compiler + nullable analysis**

   - Treat C# compiler diagnostics and nullable-flow warnings as first-class type-safety checks.
   - Enable nullable reference types and fail builds on warnings for touched code paths.
   - Avoid introducing nullable warnings; fix the root null-state issue instead.
   - Approved commands (Windows; choose the variant for your shell):
     - **CMD / Developer Command Prompt:** `msbuild <solution>.sln /t:Build /p:Configuration=Debug /p:Platform="Any CPU" /p:Nullable=enable /p:TreatWarningsAsErrors=true`
     - **PowerShell:** `msbuild <solution>.sln /t:Build /p:Configuration=Debug /p:Platform='Any CPU' /p:Nullable=enable /p:TreatWarningsAsErrors=true`

> **Testing tools and behavior are defined in the unit test policies.** Do not define test behavior here; instead, obey `general-unit-test.instructions.md` and `csharp-unit-test.instructions.md`.

---

<!-- harness-section: 2-c-design-type-safety-principles -->
## 2. C# Design & Type-Safety Principles

These refine the general design principles for C# code.

1. **Strong contracts and explicit APIs**

   - Public methods, constructors, and properties must express clear contracts.
   - Use explicit types at public boundaries; use `var` only when the type is obvious.

2. **Null-safety by default**

   - Keep nullable reference types enabled.
   - Model optional values explicitly with nullable annotations and guard clauses.
   - Use nullability attributes where needed to improve flow analysis.

3. **Prefer composition and focused types**

   - Keep classes cohesive and scoped to one core responsibility.
   - Favor composition over inheritance unless polymorphism is a clear requirement.

4. **Asynchrony and resource safety**

   - Use `async`/`await` for I/O-bound operations.
   - Prefer `using`/`await using` for disposable resources.

---

<!-- harness-section: 3-classes-methods-and-apis-c-specific-guidance -->
## 3. Classes, Methods, and APIs (C#-Specific Guidance)

### 3.1 Classes for domain concepts and workflows

Use classes/records when:

- Modeling domain concepts with state + behavior.
- Protecting invariants across related members.
- Providing multiple implementations behind interfaces.
- Orchestrating multi-step workflows that share context.

When using classes/records:

- Keep methods small and focused.
- Avoid god objects.
- Prefer immutable records/value objects for data-centric models where practical.

### 3.2 Methods and local functions for focused logic

Use methods/local functions when:

- Implementing narrow, deterministic behavior.
- Encapsulating reusable, stateless transformations.

Rules:

- Name methods by behavior.
- Keep branching shallow where possible.
- Extract helper methods instead of deeply nested conditionals.

### 3.3 Interfaces and contracts

- Use interfaces when multiple implementations are expected.
- Keep public APIs stable and avoid unnecessary breaking changes.
- Document non-obvious side effects and failure modes.

---

<!-- harness-section: 4-error-handling-logging-and-contracts-c -->
## 4. Error Handling, Logging, and Contracts (C#)

1. **Exceptions**

   - Fail fast with explicit exceptions when invariants are violated.
   - Avoid catching broad `Exception` unless at a clear boundary and with added context.

2. **Logging**

   - Use the repository/project logging pattern, not ad-hoc console output in production code.
   - Log actionable context at appropriate levels.

3. **Contracts / invariants**

   - Validate constructor and method preconditions.
   - Use `Debug.Assert` only for internal invariants, not user-facing validation.

---

<!-- harness-section: 5-module-file-structure-c -->
## 5. Module & File Structure (C#)

1. **Cohesive files and namespaces**

   - Keep files focused on one responsibility area.
   - Keep file size under the repo limit in `general-code-change.instructions.md`.

2. **Public vs internal**

   - Keep public surface area intentional and minimal.
   - Prefer `internal` for non-public APIs.

3. **Imports and namespace hygiene**

   - Prefer explicit `using` directives at file scope.
   - Avoid circular dependencies.

---

<!-- harness-section: 6-naming-docs-and-comments-c -->
## 6. Naming, Docs, and Comments (C#)

1. **Naming conventions**

   - `PascalCase` for types and public members.
   - `camelCase` for local variables and private fields/parameters.
   - Use descriptive names over abbreviations.

2. **Documentation comments**

   - Public APIs should include XML documentation comments when behavior or contract is non-obvious.

3. **Comments**

   - Comment **why**, not what.
   - Keep comments synchronized with behavior.

---

<!-- harness-section: 7-dependencies-and-analyzer-configuration-c -->
## 7. Dependencies and Analyzer Configuration (C#)

- Prefer built-in .NET SDK analyzers and configuration through `.editorconfig` / `.globalconfig`.
- Use project-level properties (`EnableNETAnalyzers`, `AnalysisLevel`, `AnalysisMode`, `EnforceCodeStyleInBuild`) rather than ad-hoc per-command behavior where possible.
- Avoid adding external dependencies unless unavoidable and approved by the project direction.
- If suppression is unavoidable, keep it as narrow as possible and document the rationale in-code.
<!-- harness-section: head-3 -->

# C# Unit Test Policy

This policy **extends** `general-unit-test.instructions.md` and applies to all C# unit tests in this repo.

You must follow **both**:

- The general unit test policy, and
- The C#-specific rules below.

If there is any conflict between these documents, halt and notify the user.

---

<!-- harness-section: 1-framework-selection -->
## 1. Framework Selection

- **Testing framework**
  - Use **MSTest** (`Microsoft.VisualStudio.TestTools.UnitTesting`) for C# unit tests in this repository.
  - Do not introduce xUnit or NUnit into existing test projects.

---

<!-- harness-section: 2-c-specific-libraries-and-conventions -->
## 2. C#-Specific Libraries and Conventions

- **Mocking library**
  - Use **Moq** for mocks/stubs in C# unit tests.

- **Assertion library**
  - Prefer **FluentAssertions** for new and updated assertions.
  - Use MSTest `Assert` APIs only when FluentAssertions is not practical for a specific assertion shape.

- **MSTest style**
  - Use `[TestClass]`, `[TestMethod]`, and other MSTest attributes from `Microsoft.VisualStudio.TestTools.UnitTesting`.

---

<!-- harness-section: 3-c-toolchain-command-selection -->
## 3. C# Toolchain Command Selection

- For C# work, use these concrete commands for the general policy toolchain loop:
  1. `csharpier .`
  2. `msbuild <solution>.sln /t:Build /p:Configuration=Debug /p:Platform="Any CPU" /p:EnableNETAnalyzers=true /p:EnforceCodeStyleInBuild=true`
  3. `msbuild <solution>.sln /t:Build /p:Configuration=Debug /p:Platform="Any CPU" /p:Nullable=enable /p:TreatWarningsAsErrors=true`
  4. `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage`

- The loop behavior (restart rules, must-pass requirements, and audit expectations) is defined by `general-code-change.instructions.md` and is intentionally not repeated here.

This file is intentionally limited to C#-specific framework/library/tool selection. Cross-language testing principles and policy requirements are defined in `general-unit-test.instructions.md` and `general-code-change.instructions.md`.
<!-- harness-section: head-4 -->

# C# Code Standards

This rule file summarizes the C#-specific policies for this repository.

<!-- harness-section: toolchain-2 -->
## Toolchain

1. **Formatting — CSharpier**: All C# source files must be formatted with CSharpier. Do not use `dotnet format`. Command: `dotnet tool run csharpier .` or `csharpier .`
2. **Linting — .NET Analyzers**: C# code must pass Roslyn/.NET analyzer diagnostics. Command: `msbuild <solution>.sln /t:Build /p:Configuration=Debug /p:Platform="Any CPU" /p:EnableNETAnalyzers=true /p:EnforceCodeStyleInBuild=true`
3. **Type Checking — Nullable Analysis**: Enable nullable reference types and fail on warnings. Command: `msbuild <solution>.sln /t:Build /p:Configuration=Debug /p:Platform="Any CPU" /p:Nullable=enable /p:TreatWarningsAsErrors=true`
4. **Testing — MSTest + Moq + FluentAssertions**: Run tests with: `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage`

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

<!-- harness-section: coding-standards-2 -->
## Coding Standards

- **Naming**: `PascalCase` for types and public members. `camelCase` for locals and private fields/parameters.
- **Null safety**: Keep nullable reference types enabled. Model optional values with nullable annotations and guard clauses.
- **Composition over inheritance**: Keep classes cohesive and scoped to one responsibility. Favor composition unless polymorphism is a clear requirement.
- **Async/await**: Use `async`/`await` for I/O-bound operations. Prefer `using`/`await using` for disposable resources.
- **Exceptions**: Fail fast with explicit exceptions. Avoid broad `catch (Exception)` unless at a defined boundary with added context.
- **Public surface**: Keep public API surface intentional and minimal. Prefer `internal` for non-public APIs.
- **XML docs**: Public APIs should include XML documentation comments when behavior or contract is non-obvious.

<!-- harness-section: testing-standards-2 -->
## Testing Standards

- Use **MSTest** (`Microsoft.VisualStudio.TestTools.UnitTesting`) as the test framework.
- Use **Moq** for mocking.
- Prefer **FluentAssertions** for assertions; use MSTest `Assert` only when FluentAssertions is not practical.
- Use `[TestClass]` and `[TestMethod]` attributes.
- Follow Arrange–Act–Assert structure.
- No external dependencies in unit tests.
- Repository-wide line coverage must remain >= 80%.
- Any new module, class, or method must reach >= 90% coverage.
- Coverage regression on changed lines is a blocking finding.

<!-- harness-section: di-seams-2 -->
## DI Seams

Introduce the smallest seam that enables reliable unit testing. Apply in this order of preference:

1. **Interface seam (preferred)** — extract boundary calls into narrow purpose-specific interfaces (for example, `IProcessRunner`, `IFileSystem`, `IClock`). Keep interfaces minimal.
2. **Injectable delegate seam** — use a narrow `Func<>`/`Action<>` delegate for a single call path when a full interface is excessive. Default behavior must remain safe and deterministic.
3. **Adapter seam for static or third-party APIs** — wrap the static or third-party call behind a small adapter so tests can mock the adapter with Moq.

