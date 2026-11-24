<!-- harness-section: head -->

# General Code Change Policy

This rule file summarizes the cross-language code change policy for this repository.

<!-- harness-section: design-principles -->
## Design Principles

Apply these priorities in order when designing or changing code:

1. **Simplicity first** — Prefer the simplest design that works and is readable. Avoid cleverness and deep indirection.
2. **Reusability** — Factor out logic that is clearly reusable. Avoid copy-paste; share behavior via composition or helper methods.
3. **Extensibility** — Design public APIs so they can be extended without breaking callers. Prefer keyword-style parameters with defaults. Prefer composition over inheritance. Use interfaces/abstract types/protocols to support multiple implementations.
4. **Separation of concerns** — Keep pure logic (transforms, calculations, parsing) separate from I/O (disk, network, DB), UI/CLI, and framework-specific glue.

<!-- harness-section: classes-functions-and-apis -->
## Classes, Functions, and APIs

- Create a class when: there is a clear domain concept with data + behavior, state and invariants must travel together, multiple implementations behind an interface are expected, or a multi-step workflow shares context.
- Create a standalone function when: the operation is pure, stateless, and simple; it is a small helper that does not naturally belong on a domain class; or it is a simple transformation from inputs to outputs.
- Keep methods small and focused. Avoid god objects.
- Use interfaces/abstract types/protocols when multiple implementations are likely.

<!-- harness-section: module-rigor-tiers -->
## Module Rigor Tiers

Module rigor tiers (T1–T4) and the uniform-versus-tier-dependent gate matrix are defined in `.claude/rules/quality-tiers.md` and apply only when `quality-tiers.yml` exists at the repository root; in that case every project must be classified in it. A repository without `quality-tiers.yml` has not adopted tiers, and the tier requirements do not apply.

<!-- harness-section: mandatory-toolchain-loop -->
## Mandatory Toolchain Loop

Run the full seven-stage toolchain in this exact order and repeat until all stages pass in a single pass:

1. **Formatting** (e.g., Black, Prettier, CSharpier, Invoke-Formatter)
2. **Linting** (e.g., Ruff, ESLint, PSScriptAnalyzer, .NET analyzers)
3. **Type checking** (e.g., Pyright, TSC, nullable analysis; skip for PowerShell)
4. **Architecture-boundary tests** (e.g., dependency-cruiser, NetArchTest.Rules)
5. **Unit tests** (e.g., Pytest, Jest, MSTest, Pester) including property-based tests where applicable per `quality-tiers.md`
6. **Contract / schema compatibility checks** (e.g., oasdiff, schema-snapshot diff)
7. **Integration tests**

**Restart from step 1** if any stage fails or auto-fixes any files. Do not stop the loop until every stage it runs completes without errors in a single pass; at phase gates and in the final QA loop, stage 7 runs in CI.

This loop is the phase-gate and final-QA requirement; integration tests (stage 7) run in CI for phase gates and the final QA loop. At a phase gate, stage 5 runs the union of the test selections of the phase's tasks. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: the full test suite runs only at the `Phase 0 baseline` and in the final QA loop, a task check runs its test selection after each task, and each phase gate runs its unit stage over the union of the test selections of the phase's tasks.

Mutation testing and golden tests run in pre-merge or nightly pipelines, not the per-commit loop.

<!-- harness-section: file-size-limit -->
## File Size Limit

- File size follows three tiers for production code, test code, and reusable script files, counted in logical lines (a trailing line terminator does not add a line):
  - **500 lines (guidance):** look for a logical way to divide the file into multiple files, provided the parts can be separated logically. No gate fails at this tier.
  - **700 lines (advisory):** look for a split more aggressively. Reviewers and `feature-review` report a non-blocking Warning for a file at or above 700 lines. No gate fails at this tier.
  - **Above 800 lines (hard block):** split the file regardless of logical separability. The repository CI check and the PreToolUse hook block a file of 801 lines or more; a file of exactly 800 lines passes. Legacy files above 800 lines are listed in `config/file-size-baseline.json` and may shrink (with the entry tightened) or stay the same size, but may not grow.
- Exceptions: temporary throwaway scripts created and deleted within an agent session; raw text fixtures for language-processing test data; Markdown documentation files.

<!-- harness-section: error-handling-and-logging -->
## Error Handling and Logging

- **Fail fast and explicitly**: raise or return clear, specific errors when invariants are violated.
- Do not silently ignore errors. Do not use broad catch-all handlers unless you immediately re-raise or propagate with added context.
- Use the project's established logging pattern. Log at appropriate levels (`debug`, `info`, `warning`, `error`).
- Enforce invariants at construction/initialization time.
- Use assertions only for internal sanity checks, not user-facing error handling.

<!-- harness-section: naming -->
## Naming

- Names must be descriptive. Abbreviations are acceptable only when they are standard (`id`, `url`, `db`).
- Language-specific conventions: `snake_case` for Python functions/variables, `PascalCase` for Python classes, `camelCase` for TypeScript/C# locals, `PascalCase` for TypeScript/C# types and public members.

<!-- harness-section: public-apis-and-compatibility -->
## Public APIs and Compatibility

- Prefer keyword-style parameters with defaults.
- Prefer composition over inheritance when possible.
- Avoid breaking public APIs. If a breaking change is necessary, update all callers in-repo and call it out clearly in the change description.

<!-- harness-section: dependencies -->
## Dependencies

- Use only libraries already approved in the project unless explicitly told to add more.
- If adding a dependency is unavoidable, choose a well-maintained, widely used package and document why it is required.

<!-- harness-section: i-o-boundaries -->
## I/O Boundaries

- Isolate I/O (disk, network, APIs) into specific classes or modules.
- Core domain logic must be testable without touching the network or filesystem.
- Use of temporary files within tests is strictly prohibited.
<!-- harness-section: head-2 -->

# Agent Code Change Policy

**CRITICAL**: When implementing any **any** code, tests, tasks, or scripts, you **must** adhere to these repo policies **without exception**. This includes but is not limited to adding, removing, or changing any code, tasks, scripts, modules, packages, tests or their components.

Read each policy document **thoroughly** before starting work. Implement them **exactly as written**. Do not interpret, modify, or skip any requirements. If you encounter **any** conflicting instructions, halt and notify the user.

Language-specific standards (e.g. for Python) are defined in additional instructions files and **layer on top of** this general policy.

**Reading order / authority:** Apply this general policy first, then any language-specific code-change instructions, then any unit-test addenda. Operational guidance (e.g., developer tooling, CI docs) sits underneath these policies.

<!-- harness-section: before-making-changes -->
## Before Making Changes

- [ ] Clarify the objective. Begin reasoning from clearly stated assumptions or axioms.
- [ ] Read existing change plans (e.g., `change-plan.md`).
- [ ] Document the plan to make changes. If it is part of an existing change plan, make any relevant updates to the plan before executing.

---

<!-- harness-section: bugfix-workflow-all-languages-defects-only -->
## Bugfix Workflow (all languages, defects only)

Use this workflow only when addressing a bug or defect. Feature work, refactors, and
new capabilities should follow the general planning steps and design principles
rather than this bugfix sequence.

1. **Create a failing regression test first**
   - Add the smallest deterministic test that reproduces the bug using the project’s standard test layout (prefer the module’s existing test file; use `tests/bugs/<YYYY>/<issue>-<desc>.py` only when no clear home exists).
   - Ensure the test fails before the fix and will pass after; avoid external services or temporary files.

2. **Implement the minimal, targeted fix**
   - Change only what is needed to make the failing test pass; keep boundaries intact and avoid opportunistic refactors.
   - If you uncover deeper design problems, open a new issue instead of widening scope; add logging only when it materially aids diagnosis.

3. **Verify locally before review**
   - Re-run the original repro and the new regression test.
   - Run the full toolchain in order (format → lint → type-check → test) using the repo-standard commands or tasks; rerun from the start if any step changes files or fails. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: the full test suite runs only at the `Phase 0 baseline` and in the final QA loop, a task check runs its test selection after each task, and each phase gate runs its unit stage over the union of the test selections of the phase's tasks.

---

<!-- harness-section: 1-design-principles -->
## 1. Design Principles

High-level design priorities (applies to all languages):

1. **Simplicity first**

   - Prefer the simplest design that works and is easy to read.
   - Avoid cleverness and deep indirection. The next maintainer should be able to understand a module in one reading.

2. **Reusability**

   - Factor out logic that is clearly reusable into small methods or pure functions.
   - Avoid copy-paste; share behavior via composition, helper methods, or shared base classes/interfaces.

3. **Extensibility**

   - Design public APIs so they can be extended without breaking callers:
     - Prefer keyword-style parameters with defaults (or equivalent in the language).
     - Prefer composition over inheritance when possible.
     - Use interfaces/abstract types/protocols to support multiple implementations behind an interface.

4. **Separation of concerns**

   - Keep **pure logic** (transforms, calculations, parsing) separate from:
     - I/O (disk, network, DB)
     - UI / CLI
     - Framework-specific glue
   - Orchestration code (e.g., “main” pipeline classes) may depend on many things; pure core logic should depend on very little.

---

<!-- harness-section: 2-classes-functions-and-apis -->
## 2. Classes, Functions, and APIs

**Overall rule:**  
Use **strongly-typed, well-structured classes** to model domain concepts and workflows. Use **functions** (or equivalent) for small, stateless helpers and glue code.

### 2.1 Prefer classes for domain concepts and workflows

Create a class when at least one is true:

- There is a **clear domain concept** with data + behavior  
  - e.g. “transaction”, “corpus”, “contact matcher”, “pipeline”.
- You have **state + invariants** that should travel together  
  - e.g. a model that must keep weights, vocabulary, and metadata in sync.
- You expect **multiple implementations** behind a common interface  
  - e.g. different text sources, storage backends, or pipelines.
- You are modeling a **multi-step workflow** that shares context  
  - e.g. `download()`, `normalize()`, `index()`, `export()` steps on a pipeline object.

When you use classes:

- Keep methods **small and focused**; a method should do one conceptual thing.
- Avoid “god objects” that know about too many unrelated concerns.

### 2.2 Use functions for small, pure helpers

Create a standalone function when:

- The operation is **pure, stateless, and simple**:
  - e.g. “normalize whitespace in this string”
  - e.g. “compute a score from inputs”
- It’s a **small helper** that doesn’t naturally belong on a specific domain class.
- It is a **simple transformation** from inputs to outputs.

Rules for functions:

- Functions should be short, readable, and clearly named by what they do.
- Avoid long, deeply branching functions—factor logic into smaller helpers.

### 2.3 Interfaces and contracts

- Use interfaces / abstract types / protocols when multiple implementations are likely (e.g. different storage backends or text sources).
- Public methods and functions must have clear, documented contracts (inputs, outputs, invariants).

---

<!-- harness-section: 3-error-handling-logging-and-contracts -->
## 3. Error Handling, Logging, and Contracts

1. **Error handling**

   - Fail **fast and explicitly**: raise or return clear, specific errors when invariants are violated.
   - Don’t silently ignore errors or broad-catch (e.g. a “catch all”) unless you immediately re-raise or propagate with added context.

2. **Logging**

   - Use the project’s logging pattern instead of ad-hoc `print`/console output.
   - Log at appropriate levels (`debug`, `info`, `warning`, `error`) and include enough context to debug issues.

3. **Contracts / invariants**

   - Enforce invariants at construction/initialization time.
   - Use assertions only for **internal sanity checks**, not user-facing error handling.

---

<!-- harness-section: 4-module-file-structure -->
## 4. Module & File Structure

1. Keep modules **cohesive**:

   - A module/file should have a clear purpose (e.g. “QIF parsing,” “scoring model,” “corpus download”).
   - Avoid dumping unrelated classes/functions into the same file.
   - File size follows a tiered policy that applies to production code, test code, and reusable scripts:
     - **500 lines (guidance):** look for logical ways to divide the file into multiple files, provided the parts can be separated logically. No gate fails at this tier.
     - **700 lines (advisory):** look for a split more aggressively. Reviewers and `feature-review` report a non-blocking Warning for a file at or above 700 lines. No gate fails at this tier.
     - **Above 800 lines (hard block):** a split is enforced regardless of logical separability. A file of 801 lines or more is blocked by the repository CI check and by the PreToolUse hook; a file of exactly 800 lines passes. Legacy files already above 800 lines are recorded in `config/file-size-baseline.json` and may shrink (with the entry tightened) or stay the same size, but may not grow.
     - Lines are logical lines: the content split on line terminators, where a trailing terminator does not add a line.
   - Exceptions: temporary throwaway scripts created and deleted during an agent session; raw text fixtures used for language-processing test data; Markdown documentation files.

2. Public vs internal

   - Make the public surface area **small and intentional**.
   - Use “internal” helpers and naming conventions (e.g. underscore-prefix or equivalent) for things that should not be used outside the module.

3. Imports / dependencies

   - Prefer clear, explicit imports within the project.
   - Avoid circular dependencies; if they appear, refactor shared logic into a lower-level module.

---

<!-- harness-section: 5-naming-docs-and-comments -->
## 5. Naming, Docs, and Comments

1. Naming

   - Names should be descriptive, not cryptic.
   - Abbreviations are okay only when they are standard and widely understood (e.g. `id`, `url`, `db`).

2. Docs / docstrings

   - Public classes and methods should have a short description covering:
     - What it does.
     - Important arguments/parameters.
     - What it returns or side effects.

3. Comments

   - Comment **why**, not what. The code should generally explain *what*.
   - If you use workarounds or non-obvious patterns, add a short comment explaining the reasoning.

---

<!-- harness-section: 6-performance-i-o-and-dependencies -->
## 6. Performance, I/O, and Dependencies

1. **Performance**

   - Prefer clarity first; optimize only where there is a demonstrated need.
   - Avoid obviously quadratic (O(N²)) or worse algorithms on large inputs unless justified.

2. **I/O boundaries**

   - Isolate I/O (disk, network, APIs) into specific classes or modules.
   - Core domain logic should be testable **without** touching the network or filesystem. 
   - **Use of temporary files within tests is strictly prohibited**.

3. **Dependencies**

   - Use only the libraries already approved in the project unless specifically told to add more.
   - If adding a dependency is unavoidable, choose a well-maintained, widely used package, and document why it’s required.

---

<!-- harness-section: 7-how-to-interact-with-existing-code -->
## 7. How to Interact with Existing Code

1. **Follow existing patterns**

   - Where the repo already has a clear style (e.g. how pipelines or models are structured), **match that style**.
   - If you need to improve an existing pattern, keep it **compatible** with current usages.

2. **API changes**

   - Avoid breaking public APIs. If a breaking change is necessary, call it out clearly in comments or the PR description.

3. **Tests as specification**

   - Treat existing unit tests as **part of the spec**.
   - When adding new behavior, add tests that make the behavior explicit (using the language’s standard test framework).

---

<!-- harness-section: 8-after-making-changes -->
## 8. After Making Changes

### 1. Run the full toolchain (no shortcuts)

You **must** run the full toolchain in this exact order and repeat it until everything passes:

1. **Formatting**
2. **Linting**
3. **Type checking**
4. **Testing**

Treat these four steps as one **toolchain pass**. The toolchain pass is the phase-gate and final-QA requirement; integration tests run in CI for phase gates and the final QA loop. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: the full test suite runs only at the `Phase 0 baseline` and in the final QA loop, a task check runs its test selection after each task, and each phase gate runs its unit stage over the union of the test selections of the phase's tasks.

1. Run the formatter on the relevant files (e.g. Black).

2. Run the linter (e.g. Ruff).
   - If the linter **fails** or **auto-fixes** anything:
     - Fix all reported issues (including applying any auto-fixes).
     - Then **restart the toolchain pass from step 1 (Formatting)**.

3. Run the type checker (e.g. Pyright).
   - If type checking **fails**:
     - Fix all reported issues.
     - Then **restart the toolchain pass from step 1 (Formatting)**.

4. Run the tests (e.g. Pytest).
   - If any test **fails**:
     - Fix all reported issues.
     - Then **restart the toolchain pass from step 1 (Formatting)**.

You **may not stop** this loop while any of the following are true:

- Formatting would change the code.
- Linting reports errors.
- Type checking reports errors.
- Tests fail.

Only when **all four steps complete without errors in a single pass** are you allowed to consider the change complete.

When you report back, explicitly state:
- Which formatting, linting, type-checking, and test commands you ran, and  
- That all four steps passed without errors in the final pass.

---

### 2. Summarize key changes and rationale

- Summarize the key changes made and how they relate to the original objective.
- Explain any important design choices and other options you considered but did not implement.

---

### 3. Update supporting documents

- Update any supporting documents (e.g., README, design docs, runbooks).
- Update any workplan, change plan, or instructions document to show progress and reflect the new behavior.

---

### 4. Provide clear next steps

- Provide clear development next steps (what should happen next, and by whom).
- If development is complete, provide detailed instructions on usage and any operational caveats (limits, known issues, rollout steps).







<!-- harness-section: head-3 -->

# Converted rule

Source: legacy Claude rule `general-code-change`.

# General Code Change Policy

This rule file summarizes the cross-language code change policy for this repository.

<!-- harness-section: module-rigor-tiers-2 -->
## Module Rigor Tiers

Module rigor tiers (T1–T4) and the uniform-versus-tier-dependent gate matrix are defined in `.agents/skills/quality-tiers/SKILL.md` and apply only when `quality-tiers.yml` exists at the repository root; in that case every project must be classified in it. A repository without `quality-tiers.yml` has not adopted tiers, and the tier requirements do not apply.

