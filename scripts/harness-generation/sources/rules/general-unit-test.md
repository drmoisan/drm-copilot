<!-- harness-section: head -->

# General Unit Test Policy

This rule file summarizes the cross-language unit test policy for this repository.

<!-- harness-section: core-principles -->
## Core Principles

Every unit test must satisfy all five of these properties:

1. **Independence** — Tests must be able to run in any order without impacting each other.
2. **Isolation** — Each unit test targets a single function, method, or unit of behavior so failures clearly identify the faulty unit.
3. **Fast execution** — Tests must be fast enough to support frequent runs and rapid feedback loops.
4. **Determinism** — Given the same inputs and environment, tests must produce the same results. Avoid flakiness.
5. **Readability and maintainability** — Test names, structure, and assertions must be clear and easy to understand.

<!-- harness-section: coverage-requirements -->
## Coverage Requirements

- Threshold precedence: when the repository's root `CLAUDE.md` states line or branch coverage thresholds, those thresholds govern. The 85% line and 75% branch figures are defaults that apply only when the root `CLAUDE.md` states none. This precedence applies to every restatement of these figures in other rule files, agents, and skills. Each metric falls back independently: when the root `CLAUDE.md` states only a line threshold or only a branch threshold, the stated threshold governs that metric and the default governs the other.
- **Line coverage must remain >= 85% across all tiers (T1–T4).**
- **Branch coverage must remain >= 75% across all tiers (T1–T4) for languages whose coverage tooling measures branch coverage.** PowerShell (Pester) and bash (kcov) are the exceptions: neither tool measures branch coverage in any output format, so only the line threshold applies to them and there is no branch-coverage gate. This is a threshold exemption only; PowerShell and bash production files remain in the coverage denominator under the Coverage Exclusion Policy below.
- Code changes or refactors must not reduce coverage for the lines that were changed.
- Tier-specific lower coverage thresholds are not used. See `.claude/rules/quality-tiers.md` for the full tier system, which applies only when `quality-tiers.yml` exists at the repository root.
- Coverage is a supporting metric, not the sole quality gate. Untested critical behavior is not acceptable even if the overall percentage looks good.
- Configure coverage tooling to exclude test files (e.g., `tests/`) so metrics reflect application code, not tests.
- Type-only / interface-only modules with no executable behavior may be omitted from coverage measurement. Examples: Python `Protocol`-only modules consumed only under `TYPE_CHECKING`, TypeScript interface/type-only files, and C# interface-only files. Such modules legitimately report 0% executable coverage and may be excluded from measurement. This is a clarification only; it does not lower any coverage threshold.

<!-- harness-section: coverage-exclusion-policy -->
## Coverage Exclusion Policy

No production file may be excluded from coverage measurement. Every production source file is in the denominator of the coverage metric, regardless of whether its lines are reachable in the test environment.

The correct response to a file that contains untestable lines is to refactor it — extract all logic into host-neutral, testable modules and leave only the thinnest possible wiring in the host-bound entry point. The entry point's uncovered lines then represent a real and visible cost in the coverage metric, which creates ongoing pressure to keep those files minimal.

**Permitted `exclude` entries** (non-production paths only):
- Build output directories: `dist/**`, `lib/**`, `lib-amd/**`.
- Test files and test infrastructure: `**/*.test.ts`, `tests/**`, `src/test-support/**`.
- Config files that are not production code: `jest.config.cjs`, `eslint.config.mjs`, `.dependency-cruiser.cjs`, `webpack.config.js`.
- `node_modules/**`.

**Prohibited `exclude` entries:**
- Any path under `src/` that contains production runtime code, regardless of whether it is auto-generated, host-bound, or difficult to test.

**Vendored push-down files** (destination repositories that receive pushed-down files):
- A pushed-down file may be excluded from a destination's coverage measurement only when all three conditions hold: its exact path is a key in `.push-down-manifest.json`; its canonical content hash equals the recorded `sha256`; and the exemption is derived by tooling at measurement time, never written by hand. A directory glob such as `.claude/**` never qualifies.
- Modified files, unlisted files, and files the destination adds (for example a hook added under `.claude/hooks/`) stay in the denominator.
- Pushed-down code is tested upstream. A modified copy is owned and tested by the destination; after a `conflict` re-run it stays non-exempt until it is reverted or deleted and pushed down again.
- A destination may remove its recreated duplicate tests of unmodified pushed-down files.
- The tooling records what it exempted in `vendored-coverage-exemptions.json` beside the coverage output file.
- The repository that is the source of the pushed-down files measures and tests them; the exception does not apply there.

**Enforcement:** Feature-review agents must treat any hand-written `exclude`, `omit`, `coveragePathIgnorePatterns`, or kcov `--exclude-path` entry, or omitted settings-file coverage path, that matches a production source path as a **Blocking** finding. The boolean opt-in `exempt_unchanged_push_down_files` is not an `exclude` entry: a manifest-derived run-time exemption is recognized, and the reviewer verifies it through `vendored-coverage-exemptions.json`. A branch diff that changes `.push-down-manifest.json` hashes without a push-down run (no `payload_version` change and no push-down summary) is a **Blocking** finding.

<!-- harness-section: scenario-completeness -->
## Scenario Completeness

For each unit or behavior, tests must cover:

- Positive flows with valid inputs
- Negative flows for invalid or missing inputs
- Edge cases and boundary conditions
- Error-handling behavior
- Concurrency behavior when relevant
- State transitions for stateful components

<!-- harness-section: test-structure-arrange-act-assert -->
## Test Structure — Arrange–Act–Assert

Organize each test into three sections:

- **Arrange** — set up inputs, environment, and dependencies
- **Act** — execute the behavior under test
- **Assert** — verify outcomes via assertions

Assertions must produce clear, actionable failure messages.

<!-- harness-section: external-dependencies -->
## External Dependencies

- Unit tests must not depend on external services (databases, networks, remote APIs, external processes).
- Use mocks, stubs, or fakes to isolate the unit under test when code interacts with external systems.
- **Creation and use of temporary files in tests is strictly prohibited.**
- Tests must not rely on mutable global state or external configuration that can change between runs.

<!-- harness-section: test-file-location -->
## Test File Location

Test files must live in a `tests/` directory tree that mirrors the production source structure. The test for `src/foo/bar.ts` belongs at `tests/foo/bar.test.ts`; the test for `scripts/powershell/Foo.ps1` belongs at `tests/scripts/powershell/Foo.Tests.ps1`. Language-specific rules may add further naming conventions (framework suffix, file extension) on top of this universal layout requirement.

Colocation — placing test files alongside production source files in `src/` or equivalent — is not permitted. An agent that creates or moves a test file into the production source tree has violated this rule.

<!-- harness-section: documentation -->
## Documentation

- Each test must clearly communicate its purpose via a descriptive name and/or a short docstring or comment summarizing the scenario and expected outcome.
- Group related tests logically within the same file or test class.

<!-- harness-section: test-categories -->
## Test Categories

The following test categories apply across the repository, with tier-dependent obligations per `.claude/rules/quality-tiers.md`; those tier-dependent obligations apply only when `quality-tiers.yml` exists at the repository root:

- **Unit tests** — required for all tiers (T1–T4). Cover single units of behavior in isolation.
- **Property-based tests** — required for T1 and T2 modules: at least one property test per pure function. Use `fast-check` (TypeScript) or `hypothesis` (Python) where applicable.
- **Golden / snapshot tests** — required only for T1 classifier-output modules, tested against a versioned corpus. Snapshot tests are otherwise discouraged unless stable and intentional.
- **Contract / schema tests** — required at every host-service boundary (e.g., Office.js, Microsoft Graph, internal API contracts).
- **Mutation tests** — required for T1 modules: mutation score >= 75%. Run in pre-merge or nightly pipelines.
- **Integration tests** — required where adapters interact with external systems; scoped per tier in the gate matrix.

<!-- harness-section: determinism-infrastructure -->
## Determinism Infrastructure

All test code must be deterministic. The following infrastructure requirements apply uniformly:

- **Controllable clock** — use a `Clock` interface (TypeScript) or `TimeProvider` (.NET) injected into code under test. Do not read wall-clock time directly in production code under test.
- **Seeded RNG** — randomness must be supplied via a seedable interface; on test failure the seed must be printed so the failure is reproducible.
- **Banned APIs in test code** — `setTimeout`, `Thread.Sleep`, `Task.Delay`, real wall-clock waits, and `Date.now()` outside the clock interface are prohibited in tests.
- **Virtual scheduler / fake timers / `FakeTimeProvider`** — async tests must use the framework's fake-timer facility (`jest.useFakeTimers()` for Jest, `FakeTimeProvider` for .NET) to advance simulated time deterministically.
<!-- harness-section: head-2 -->

# General Unit Test Policy

This policy applies to **all unit tests** in this repository, regardless of language or framework.

Every new or modified unit test must adhere to these guidelines.

---

<!-- harness-section: 1-core-principles -->
## 1. Core Principles

- **Independence**  
  Tests must be able to run in any order without impacting each other.

- **Isolation**  
  Each unit test should target a single function, method, or unit of behavior so failures clearly identify the faulty unit.

- **Fast Execution**  
  Tests must be fast enough to support frequent runs and rapid feedback loops.

- **Determinism**  
  Given the same inputs and environment, tests must produce the same results. Avoid flakiness.

- **Readability and Maintainability**  
  Test names, structure, and assertions should be clear and easy to understand.

---

<!-- harness-section: 2-coverage-and-scenarios -->
## 2. Coverage and Scenarios

- **Comprehensive Coverage (within reason)**  
  - These coverage expectations apply across all languages in the repo.
  - Aim to exercise critical paths and important edge conditions.
  - Configure coverage tooling to exclude test files (e.g., `tests/`), so metrics reflect the application code, not the tests themselves.
  - Repository-wide line coverage must remain `>= 80%`.
  - Any new modules, classes, or methods added must target `>= 90%` coverage.
  - Code changes or refactors must not reduce coverage for the lines that were changed.
  - Coverage is a supporting metric, not the sole quality gate; untested critical behavior is not acceptable even if the overall percentage looks good.

- **Scenario Completeness**  
  For each unit or behavior, tests should cover:
  - Positive flows with valid inputs.
  - Negative flows for invalid or missing inputs.
  - Edge cases and boundary conditions.
  - Error-handling behavior.
  - Concurrency behavior when relevant.
  - State transitions for stateful components.

---

<!-- harness-section: 3-test-structure-and-diagnostics -->
## 3. Test Structure and Diagnostics

- **Clear Failure Messages**  
  Assertions should produce clear, actionable failure messages that make it easy to see what went wrong.

- **Arrange–Act–Assert pattern**  
  Organize tests into:
  - *Arrange* — set up inputs, environment, and dependencies.
  - *Act* — execute the behavior under test.
  - *Assert* — verify outcomes via assertions.

- **Document Intent**  
  Each test must clearly communicate its purpose:
  - Use descriptive test names, and/or
  - Include a short docstring or comment summarizing the scenario and expected outcome.

---

<!-- harness-section: 4-external-dependencies-and-environment -->
## 4. External Dependencies and Environment

- **Avoid External Dependencies**  
  Unit tests must not depend on external services such as databases, networks, remote APIs, or external processes.

- **Use Mocks / Stubs as Needed**  
  When code interacts with external systems or heavy resources, use mocks, stubs, or fakes to isolate the unit under test.

- **Environment Stability**  
  Tests must not rely on mutable global state or external configuration that can change between runs. Creation and use of temporary files on the local filesystem is expressly prohibited unless explicitly authorized as an exception. 
  - Currently approved exceptions: none.
  - If an exception is ever approved, list it explicitly here. A possible future example would be a static, read-only sample file committed to the repo and reused without runtime creation; this is not approved today.

---

<!-- harness-section: 5-policy-audit -->
## 5. Policy Audit

Before submitting any change that includes unit tests:

- Review each new or modified test against this policy.
- Confirm that:
  - It is independent, isolated, fast, and deterministic.
  - It is readable and clearly documents its intent.
  - It covers relevant positive, negative, edge, and error scenarios.
  - It does not rely on external dependencies without proper mocking/stubbing.

If any test cannot comply with these rules for a good reason, **call out the exception explicitly** in the change description.







<!-- harness-section: head-3 -->

# Converted rule

Source: legacy Claude rule `general-unit-test`.

# General Unit Test Policy

This rule file summarizes the cross-language unit test policy for this repository.

<!-- harness-section: coverage-requirements-2 -->
## Coverage Requirements

- Threshold precedence: when the repository's root `AGENTS.md` states line or branch coverage thresholds, those thresholds govern; when `AGENTS.md` states none, thresholds stated in the repository's root `CLAUDE.md` govern. The 85% line and 75% branch figures are defaults that apply only when neither root `AGENTS.md` nor root `CLAUDE.md` states thresholds. This precedence applies to every restatement of these figures in other skills, agents, and rule files. Each metric falls back independently: when a root file states only a line threshold or only a branch threshold, that threshold governs its metric and the next source in this order, ending with the default, governs the other.
- **Line coverage must remain >= 85% across all tiers (T1–T4).**
- **Branch coverage must remain >= 75% across all tiers (T1–T4) for languages whose coverage tooling measures branch coverage.** PowerShell (Pester) and bash (kcov) are the exceptions: neither tool measures branch coverage in any output format, so only the line threshold applies to them and there is no branch-coverage gate. This is a threshold exemption only; PowerShell and bash production files remain in the coverage denominator under the Coverage Exclusion Policy below.
- Code changes or refactors must not reduce coverage for the lines that were changed.
- Tier-specific lower coverage thresholds are not used. See `.agents/skills/quality-tiers/SKILL.md` for the full tier system, which applies only when `quality-tiers.yml` exists at the repository root.
- Coverage is a supporting metric, not the sole quality gate. Untested critical behavior is not acceptable even if the overall percentage looks good.
- Configure coverage tooling to exclude test files (e.g., `tests/`) so metrics reflect application code, not tests.
- Type-only / interface-only modules with no executable behavior may be omitted from coverage measurement. Examples: Python `Protocol`-only modules consumed only under `TYPE_CHECKING`, TypeScript interface/type-only files, and C# interface-only files. Such modules legitimately report 0% executable coverage and may be excluded from measurement. This is a clarification only; it does not lower any coverage threshold.

<!-- harness-section: test-categories-2 -->
## Test Categories

The following test categories apply across the repository, with tier-dependent obligations per `.agents/skills/quality-tiers/SKILL.md`; those tier-dependent obligations apply only when `quality-tiers.yml` exists at the repository root:

- **Unit tests** — required for all tiers (T1–T4). Cover single units of behavior in isolation.
- **Property-based tests** — required for T1 and T2 modules: at least one property test per pure function. Use `fast-check` (TypeScript) or `hypothesis` (Python) where applicable.
- **Golden / snapshot tests** — required only for T1 classifier-output modules, tested against a versioned corpus. Snapshot tests are otherwise discouraged unless stable and intentional.
- **Contract / schema tests** — required at every host-service boundary (e.g., Office.js, Microsoft Graph, internal API contracts).
- **Mutation tests** — required for T1 modules: mutation score >= 75%. Run in pre-merge or nightly pipelines.
- **Integration tests** — required where adapters interact with external systems; scoped per tier in the gate matrix.

