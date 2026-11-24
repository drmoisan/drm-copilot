<!-- harness-section: head -->

# TypeScript Code Standards

This rule file summarizes the TypeScript-specific policies for this repository.

<!-- harness-section: toolchain -->
## Toolchain

1. **Formatting — Prettier**: All TypeScript must be formatted with the repository Prettier configuration. Command: `npm run format`
2. **Linting — ESLint**: TypeScript must pass ESLint using the repository configuration. Command: `npm run lint`
3. **Type Checking — TSC**: TypeScript must pass the compiler type-check. Avoid `any`; prefer `unknown` plus narrowing. Command: `npm run typecheck`
4. **Testing — Jest**: All TypeScript unit tests must use Jest. Command: `npm run test:unit`

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: the full test suite runs only at the `Phase 0 baseline` and in the final QA loop, a task check runs its test selection after each task, and each phase gate runs its unit stage over the union of the test selections of the phase's tasks.

<!-- harness-section: coding-standards -->
## Coding Standards

- New user-invocable workflows belong under `.claude/skills/` rather than `.claude/commands/`.
- **Strong typing**: Public functions, methods, and exported APIs must have clear, intentional types. Avoid type assertions (`as X`) unless justified.
- **ES modules**: Use ES module syntax. Do not introduce CommonJS patterns (`require`, `module.exports`).
- **Domain types**: Model domain concepts with interfaces/types that encode invariants. Prefer discriminated unions for state machines.
- **Naming**: `PascalCase` for classes, interfaces, enums, and type aliases. `camelCase` for functions, methods, variables, and object properties. No `I` prefix on interfaces.
- **File naming**: Prefer kebab-case filenames (e.g., `user-session.ts`, `task-runner.ts`).
- **Separation of concerns**: Keep pure logic separate from Office.js, Microsoft Graph SDK, and other host-bound APIs, filesystem/network I/O, and UI wiring.
- **Error handling**: Fail fast with clear errors. Avoid catch-all `catch (e)` without rethrowing or adding context.
- **Dependencies**: Do not add new runtime dependencies unless explicitly approved.

<!-- harness-section: eslint-stack -->
## ESLint Stack

- Require `typescript-eslint` strict-type-checked + stylistic-type-checked rule sets.
- Enable type-aware parsing (`parserOptions.project = true`).
- Required plugins: `eslint-plugin-office-addins`, `eslint-plugin-promise`, `eslint-plugin-security`, `eslint-plugin-import`.
- Error-level rules: `no-floating-promises`, `no-misused-promises`, all `no-unsafe-*`.
- Add a `no-restricted-syntax` rule banning `Date.now`, `setTimeout`, `setInterval`, and `Math.random` outside an explicit infrastructure allowlist.

<!-- harness-section: testing-standards -->
## Testing Standards

- Use **Jest** as the test framework.
- Name test files `*.test.ts`.
- Unit tests must not require the Outlook host runtime.
- Follow Arrange–Act–Assert structure.
- Each test targets one behavior.
- Use `jest.spyOn` or `jest.mock` for targeted mocking; reset mocks with `afterEach(() => { jest.resetAllMocks(); })`.
- No external dependencies (network, filesystem temp files, external processes) in unit tests.
- Avoid snapshot tests unless stable and intentional.
- Coverage thresholds follow the uniform tier rule defined in `.claude/rules/quality-tiers.md`: line coverage >= 85% and branch coverage >= 75% across all tiers (T1–T4).
- Coverage command: `npm run test:unit:coverage` (the root `package.json` script runs `node run-jest.cjs --coverage`).
- Coverage regression on changed lines is a blocking finding.
- Interface/type-only files with no executable behavior — files consisting solely of `interface` or `type` declarations — may be omitted from coverage measurement. Such files legitimately report 0% executable coverage. This is a clarification only; it does not lower any coverage threshold.

<!-- harness-section: architecture-boundaries -->
## Architecture Boundaries

Layer rules and the host-neutral architecture assertions are defined in `.claude/rules/architecture-boundaries.md` under the heading "Host-Neutral Architecture Rules (enforceable assertions)". The TypeScript enforcement tool is `dependency-cruiser` with configuration file `.dependency-cruiser.cjs`.

<!-- harness-section: property-based-and-mutation-testing -->
## Property-Based and Mutation Testing

- `fast-check` provides property-based tests; T1 and T2 modules require >= 1 property test per pure function.
- `StrykerJS` provides mutation testing; T1 modules require mutation score >= 75%.
- Both run in pre-merge or nightly pipelines per `general-code-change.md`.

<!-- harness-section: golden-tests -->
## Golden Tests

- T1 classifier modules require golden-output snapshots tested against a versioned corpus.
- The general guidance to avoid snapshot tests unless stable and intentional remains in force for all other scenarios; classifier-output and schema-evolution snapshots are explicitly permitted when versioned.

<!-- harness-section: runtime-determinism -->
## Runtime Determinism

- `Date`, `Math.random`, and `setTimeout` access must flow through an injected `Clock` / `Random` interface.
- Tests use Jest fake timers (`jest.useFakeTimers()`).
- Prefer `await flushPromises()` over `setTimeout(0)` for awaiting micro-tasks.
<!-- harness-section: head-2 -->

# TypeScript Code Change Policy

This policy **extends** `general-code-change.instructions.md` and applies to all **TypeScript source, test, and script files** (`*.ts`) in this repo.

These instructions assume TypeScript is built with **TypeScript 5.x (or newer)** targeting an **ES2022** JavaScript baseline.

You must:

- Apply **all** rules in the general code change policy.
- Apply **all** TypeScript-specific rules in this file.
- Apply the unit test policies (`general-unit-test.instructions.md` and `typescript-unit-test.instructions.md`) for any work involving TypeScript tests.

If you encounter any conflicting instructions between these documents, **halt and notify the user.**

---

<!-- harness-section: 1-tooling-baseline-for-typescript -->
## 1. Tooling & Baseline for TypeScript

These are the required tools for TypeScript code in this repo:

1. **Formatting — Prettier**

   - All TypeScript must be formatted with the repository’s Prettier configuration.
   - Do not hand-format; if a diff disagrees with Prettier, Prettier wins.
   - Approved command: `npm run format`

2. **Linting — ESLint**

   - TypeScript must pass ESLint using the repository’s configuration.
   - Prefer fixing root causes over suppressions.
   - Approved command: `npm run lint`

3. **Type checking — TypeScript compiler (TSC)**

   - TypeScript must pass the repository’s type-check.
   - Avoid `any` (implicit or explicit). Prefer `unknown` plus narrowing.
   - Approved command: `npm run typecheck`

4. **Testing — Jest**

   - TypeScript unit tests must pass Jest.
   - Approved command: `npm run test:unit`

> **Important:** The general code change policy requires the full toolchain loop: formatting → linting → type checking → testing.

---

<!-- harness-section: 2-typescript-design-typing-principles -->
## 2. TypeScript Design & Typing Principles

These refine the general design principles for TypeScript code.

1. **Strong typing by default**

   - Public functions, methods, and exported APIs must have clear, intentional types.
   - Avoid type assertions (`as X`) unless you can justify why the value is safe; prefer runtime guards.

2. **Prefer explicit domain types**

   - Model domain concepts with interfaces/types that encode invariants.
   - Prefer discriminated unions for state machines and event shapes.

3. **Avoid cleverness**

   - Keep code readable in one pass.
   - Favor small helpers and early returns over deeply nested branching.

4. **Separation of concerns**

   - Keep pure logic separate from:
     - VS Code extension APIs
     - filesystem/network I/O
     - UI/presentation wiring
   - Write core logic so it can be unit tested without VS Code host processes.

---

<!-- harness-section: 3-imports-modules-and-dependencies -->
## 3. Imports, Modules, and Dependencies

1. **Modules**

   - Use ES modules. Do not introduce CommonJS patterns (`require`, `module.exports`).
   - Prefer explicit imports; avoid barrel exports that obscure dependencies unless the repo already uses them for that area.

2. **Dependencies**

   - Do not add new runtime dependencies unless explicitly approved.
   - If a dependency is unavoidable:
     - Prefer widely used, well-maintained packages.
     - Keep dependency surface area small (wrap behind a typed adapter when practical).

---

<!-- harness-section: 4-error-handling-and-logging -->
## 4. Error Handling and Logging

- Fail fast with clear errors when invariants are violated.
- Avoid catch-all `catch (e)` without rethrowing or adding context.
- Use the repo’s established logging/telemetry patterns (where present) instead of ad-hoc `console.log` for permanent behavior.

---

<!-- harness-section: 5-suppressions-and-escape-hatches -->
## 5. Suppressions and Escape Hatches

Suppressions are sometimes necessary, but they must be rare, tightly scoped, and well-justified.

**Authorization requirement:**

- Suppressions are allowed without explicit approval only when they match a **pre-authorized pattern** `typescript-suppressions.instructions.md`.
- Any broader suppression (for example, disabling multiple rules, disabling a whole file, or using `@ts-ignore`) requires **explicit user approval**.

**If you encounter an error that seems to require a suppression not matching a pre-authorized pattern:**

1. First, attempt to resolve it without a suppression (refactor, restructure, adjust types).
2. If that fails, try at least five more distinct approaches.
3. Continue iterating until you solve the problem or demonstrate why each approach fails.
4. Only after multiple documented failed attempts may you request user approval, providing:
    - The specific rule/error and diagnostic code
    - Each approach you tried and why it failed
    - Why a suppression is the only remaining option

All rules for ESLint and TypeScript suppressions are defined in:

- `typescript-suppressions.instructions.md`

---

<!-- harness-section: 6-public-apis-and-compatibility -->
## 6. Public APIs and Compatibility

- Avoid breaking changes to exported APIs unless explicitly required.
- If a breaking change is necessary, update all callers in-repo and add/adjust unit tests that lock in the new contract.

---

<!-- harness-section: 7-project-organization-naming-and-documentation -->
## 7. Project Organization, Naming, and Documentation

1. **Project organization**

   - Follow the repository’s established folder and responsibility layout when adding new code.
   - Keep VS Code extension API wiring and other I/O boundaries thin; push complex logic into pure, testable helpers/services.

2. **File naming**

   - Prefer **kebab-case** filenames for new files (for example, `user-session.ts`, `task-runner.ts`) unless the surrounding area of the repo already uses a different convention.

3. **TypeScript naming conventions**

   - Use **PascalCase** for classes, interfaces, enums, and type aliases; use **camelCase** for functions, methods, variables, and object properties.
   - Do not introduce interface prefixes like `I` (for example, prefer `UserSession` over `IUserSession`).

4. **Documentation expectations**

   - Add JSDoc to exported/public APIs when it improves clarity for callers.
   - When JSDoc is used and intent is non-obvious, prefer including a short rationale (and add `@example` / `@remarks` where it materially improves correct usage).

---

<!-- harness-section: 8-security-configuration-and-external-integrations -->
## 8. Security, Configuration, and External Integrations

1. **Input validation and safety**

   - Treat all external input as untrusted (user input, files, network responses, VS Code configuration).
   - Prefer explicit runtime validation (type guards / schema validation) at trust boundaries.
   - Avoid dynamic code execution and avoid rendering untrusted content as HTML without proper escaping/sanitization.

2. **Secrets and configuration**

   - Never hardcode secrets. Use the repo’s secure storage / configuration patterns.
   - Guard against missing configuration (`undefined`) and surface clear errors when required configuration is absent.
   - If you introduce new configuration keys, document them and add/update unit tests around validation and defaults.

3. **External integrations (network / I/O)**

   - Instantiate expensive clients outside hot paths and inject them for testability.
   - For network or I/O operations, use clear error mapping and add context when rethrowing.
   - Where applicable, apply retries/backoff and cancellation/timeout handling consistent with the repo’s existing patterns.

---

<!-- harness-section: 9-ui-ux-and-lifecycle-hygiene-vs-code-extension-co -->
## 9. UI/UX and Lifecycle Hygiene (VS Code Extension Context)

1. **UI layering**

   - Keep UI layers thin; push business logic into services or pure functions.
   - Prefer events/messaging to decouple UI from domain logic.

2. **Lifecycle and disposal**

   - Dispose resources deterministically and match existing initialization/disposal sequencing.
   - When introducing long-lived services, consider explicit lifecycle hooks (for example, `initialize()` and `dispose()`) and unit tests that lock in lifecycle behavior.

---

<!-- harness-section: 10-performance-and-reliability -->
## 10. Performance and Reliability

- Avoid obvious hot-path allocations and repeated heavy work.
- Prefer lazy-loading heavy dependencies when it materially reduces startup/activation cost.
- Debounce or batch high-frequency events (for example, configuration changes) to avoid thrash.
- Track resource lifetimes to prevent leaks (timers, listeners, file watchers, disposables).
<!-- harness-section: head-3 -->

# TypeScript Unit Test Policy

This policy **extends** `general-unit-test.instructions.md` and applies to all **TypeScript unit tests** in this repo.

You must follow **both**:

- The general unit test policy, and
- The TypeScript-specific rules below.

If there is any conflict between these documents, **halt and notify the user.**

---

<!-- harness-section: 1-framework-and-scope -->
## 1. Framework and Scope

- **Testing framework**
  - All TypeScript unit tests must use **Jest**.

- **Unit test definition**
  - Unit tests validate small, isolated behaviors (functions, helpers, small classes).
  - Unit tests must not require launching the VS Code extension host or depending on a live VS Code environment.

- **Coverage expectation**
  - All new TypeScript logic must be covered by Jest unit tests that follow the general unit test policy.

---

<!-- harness-section: 2-test-layout-and-naming -->
## 2. Test Layout and Naming

### **File naming**

- Name test files with the `.test.ts` suffix.

### **Test location**

- Organize tests in a way that mirrors the code under test where practical (for example, `tests/unit/<module>.test.ts` for `src/<module>.ts`, or a parallel folder structure for deeper subsystems).
- Use shared setup sparingly and keep it narrowly scoped:
  - Prefer `describe()` blocks with local `beforeEach` / `afterEach` for common setup within a small group of tests.
  - Prefer small helper functions / factories (or a local test utility module) when it reduces duplication without hiding intent.
  - Avoid broad, implicit “global” setup that makes tests hard to reason about.

---

<!-- harness-section: 3-test-style-and-structure-typescript -->
## 3. Test Style and Structure (TypeScript)

### **Focused tests**

- Each test should target one behavior.
- Prefer testing observable behavior over internal implementation details.

### **Arrange–Act–Assert**

Organize each test into:
- Arrange — inputs and setup
- Act — call the function/behavior
- Assert — verify results

### **Intent documentation**

- Test names must clearly express the scenario and expected outcome.
- If intent is not obvious, add a brief comment explaining why the case matters.

---

<!-- harness-section: 4-mocking-and-isolation -->
## 4. Mocking and Isolation

### **Avoid external dependencies**

- Unit tests must not depend on external services, network calls, or external processes.

### **Mocking guidance**

- Mock external APIs or platform dependencies to keep tests deterministic.
- Prefer targeted mocks:
  - `jest.spyOn(obj, 'method')` for specific functions
  - `jest.mock('module')` for module-level dependencies

### **Resetting mocks**

- Reset mocks between tests to ensure independence.
- Preferred pattern:
  - `afterEach(() => { jest.resetAllMocks(); });`

### **Time and timers**

- Avoid brittle timing assertions.
- Prefer fake timers (`jest.useFakeTimers()`) or injected clocks when time is part of behavior.

---

<!-- harness-section: 5-assertions-and-diagnostics -->
## 5. Assertions and Diagnostics

- Assertions must produce clear, actionable failures.
- Prefer simple, direct matchers (`toEqual`, `toMatchObject`, `toHaveBeenCalledWith`).
- Avoid snapshots unless they provide strong value and are stable; keep snapshots small and intentional.

---

<!-- harness-section: 6-required-commands -->
## 6. Required Commands

When verifying TypeScript unit tests locally, use the repo-standard scripts:

- Approved command: `npm run test:unit`

> Formatting/lint/type-check commands for the full toolchain loop are defined in the TypeScript code change policy.
<!-- harness-section: coding-standards-2 -->
## Coding Standards

- New user-invocable workflows belong under `.agents/skills/` rather than `.claude/commands/`.
- **Strong typing**: Public functions, methods, and exported APIs must have clear, intentional types. Avoid type assertions (`as X`) unless justified.
- **ES modules**: Use ES module syntax. Do not introduce CommonJS patterns (`require`, `module.exports`).
- **Domain types**: Model domain concepts with interfaces/types that encode invariants. Prefer discriminated unions for state machines.
- **Naming**: `PascalCase` for classes, interfaces, enums, and type aliases. `camelCase` for functions, methods, variables, and object properties. No `I` prefix on interfaces.
- **File naming**: Prefer kebab-case filenames (e.g., `user-session.ts`, `task-runner.ts`).
- **Separation of concerns**: Keep pure logic separate from VS Code extension APIs, filesystem/network I/O, and UI wiring.
- **Error handling**: Fail fast with clear errors. Avoid catch-all `catch (e)` without rethrowing or adding context.
- **Dependencies**: Do not add new runtime dependencies unless explicitly approved.

<!-- harness-section: testing-standards-2 -->
## Testing Standards

- Use **Jest** as the test framework.
- Name test files `*.test.ts`.
- Unit tests must not require the VS Code extension host.
- Follow Arrange–Act–Assert structure.
- Each test targets one behavior.
- Use `jest.spyOn` or `jest.mock` for targeted mocking; reset mocks with `afterEach(() => { jest.resetAllMocks(); })`.
- No external dependencies (network, filesystem temp files, external processes) in unit tests.
- Avoid snapshot tests unless stable and intentional.
- Repository-wide line coverage must remain >= 80%.
- Any new module, class, or method must reach >= 90% coverage.
- Coverage command: `npm run test:unit:coverage`
- Coverage regression on changed lines is a blocking finding.
