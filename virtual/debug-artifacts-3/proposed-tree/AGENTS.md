# Converted standing guidance

Merged standing-guidance sources:
- `copilot-instructions.md`
- `general-code-change.instructions.md`
- `general-unit-test.instructions.md`
- `tonality.instructions.md`

## Source: `copilot-instructions.md`

# Converted standing guidance

Applied rewrites:
- None

# Tone policy

- Use a strictly professional, factual, and neutral tone in all user-facing responses.
- Be concise, direct, and literal.
- Do not use jokes, humor, metaphors, playful analogies, banter, emojis, GIF references, sarcasm, or conversational filler.
- Do not use motivational hype, celebratory phrasing, or grandiose narration.
- If a sentence could read as casual, playful, or informal, rewrite it in neutral business language.

## Source: `general-code-change.instructions.md`

# Converted standing guidance

Applied rewrites:
- None

---
applyTo: "**"
name: "general-code-change-policy"
description: "Baseline rules that apply to any code change in this repo"
---

# Agent Code Change Policy

**CRITICAL**: When implementing any **any** code, tests, tasks, or scripts, you **must** adhere to these repo policies **without exception**. This includes but is not limited to adding, removing, or changing any code, tasks, scripts, modules, packages, tests or their components.

Read each policy document **thoroughly** before starting work. Implement them **exactly as written**. Do not interpret, modify, or skip any requirements. If you encounter **any** conflicting instructions, halt and notify the user.

Language-specific standards (e.g. for Python) are defined in additional instructions files and **layer on top of** this general policy.

**Reading order / authority:** Apply this general policy first, then any language-specific code-change instructions, then any unit-test addenda. Operational guidance (e.g., developer tooling, CI docs) sits underneath these policies.

## Before Making Changes

- [ ] Clarify the objective. Begin reasoning from clearly stated assumptions or axioms.
- [ ] Read existing change plans (e.g., `change-plan.md`).
- [ ] Document the plan to make changes. If it is part of an existing change plan, make any relevant updates to the plan before executing.

---

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
   - Run the full toolchain in order (format → lint → type-check → test) using the repo-standard commands or tasks; rerun from the start if any step changes files or fails.

---

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

## 4. Module & File Structure

1. Keep modules **cohesive**:

   - A module/file should have a clear purpose (e.g. “QIF parsing,” “Lexile model,” “corpus download”).
   - Avoid dumping unrelated classes/functions into the same file.
   - Do not exceed 500 lines for any one file.
   - This 500-line limit applies to production code, test code, and reusable scripts.
   - Exceptions: temporary throwaway scripts created and deleted during an agent session; raw text fixtures used for language-processing test data; Markdown documentation files.

2. Public vs internal

   - Make the public surface area **small and intentional**.
   - Use “internal” helpers and naming conventions (e.g. underscore-prefix or equivalent) for things that should not be used outside the module.

3. Imports / dependencies

   - Prefer clear, explicit imports within the project.
   - Avoid circular dependencies; if they appear, refactor shared logic into a lower-level module.

---

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

## 8. After Making Changes

### 1. Run the full toolchain (no shortcuts)

You **must** run the full toolchain in this exact order and repeat it until everything passes:

1. **Formatting**
2. **Linting**
3. **Type checking**
4. **Testing**

Treat these four steps as one **toolchain pass**.

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

## Source: `general-unit-test.instructions.md`

# Converted standing guidance

Applied rewrites:
- None

applyTo: "**"
name: general-unit-test-policy
description: "Baseline unit test policy that applies to all languages in this repo"
---

# General Unit Test Policy

This policy applies to **all unit tests** in this repository, regardless of language or framework.

Every new or modified unit test must adhere to these guidelines.

---

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

## 5. Policy Audit

Before submitting any change that includes unit tests:

- Review each new or modified test against this policy.
- Confirm that:
  - It is independent, isolated, fast, and deterministic.
  - It is readable and clearly documents its intent.
  - It covers relevant positive, negative, edge, and error scenarios.
  - It does not rely on external dependencies without proper mocking/stubbing.

If any test cannot comply with these rules for a good reason, **call out the exception explicitly** in the change description.

## Source: `tonality.instructions.md`

# Converted standing guidance

Applied rewrites:
- None

---
applyTo: "**"
name: "tonality-policy"
description: "Required communication tone for agent-authored responses, documentation, reviews, and operational guidance in this repository"
---

# Tonality Policy

This policy defines the required tone for all agent-authored content in this repository.

It applies to:

- Chat responses to users.
- Pull request summaries, review comments, and audit artifacts.
- Plans, issue updates, remediation notes, and status reports.
- Inline guidance written into documentation, runbooks, and instruction files.

If another instruction is more restrictive, follow the more restrictive instruction.

## 1. Required default tone

All written output must use a professional tone.

Professional tone in this repository means:

- Clear, direct, and factual language.
- Neutral businesslike phrasing.
- Measured statements that match the available evidence.
- Concise explanations that prioritize clarity over personality.
- Respectful wording, even when reporting defects, regressions, or disagreements.

Preferred characteristics:

- Specific rather than vague.
- Literal rather than theatrical.
- Calm rather than excited.
- Precise rather than promotional.

## 2. Humor and joking are prohibited

Do not use jokes, banter, playful remarks, sarcasm, puns, or comedic phrasing.

This prohibition includes:

- Lighthearted commentary intended to entertain.
- Winking or self-aware jokes about tools, code, bugs, or the development process.
- Casual filler that weakens a formal or operational message.
- Mocking, teasing, or exaggerated “fun” framing, even when mild.

When deciding between a playful sentence and a plain sentence, use the plain sentence.

## 3. Hyperbole is prohibited

Do not use hyperbolic, inflated, or sensational language.

Avoid statements such as:

- Claims that something is perfect, flawless, amazing, incredible, revolutionary, or world-class unless that language is directly quoted from an authoritative source and clearly marked as a quotation.
- Overstated certainty that goes beyond the verified evidence.
- Dramatic framing that overstates urgency, difficulty, simplicity, risk, or impact.

Use measured alternatives instead:

- Replace absolute praise with evidence-based descriptions.
- Replace dramatic warnings with specific risks and consequences.
- Replace sweeping claims with concrete observations, test results, or documented limitations.

## 4. Metaphors are tightly restricted

Metaphor, analogy, and figurative language are not the default style.

They may be used only when all of the following are true:

- The metaphor is strictly utilitarian.
- It is required to explain a technical concept that would otherwise be less clear.
- It improves accuracy or comprehension for the intended audience.
- It is brief, literal in effect, and not decorative.

If a concept can be explained clearly without metaphor, do not use metaphor.

Unacceptable metaphor usage includes:

- Decorative imagery.
- Emotional or dramatic comparisons.
- Marketing-style slogans.
- Extended analogies that distract from the technical point.

Acceptable metaphor usage is limited to short, functional comparisons such as explaining that one component acts "as a queue" or that a layer serves "as a boundary" when those comparisons materially improve understanding.

## 5. Evidence-first wording

Match the strength of the wording to the strength of the evidence.

- If something was verified, say it was verified and state how.
- If something is likely but unconfirmed, say that it is likely or appears to be the case.
- If something is unknown, say that it is unknown.
- Do not imply certainty, completion, safety, or correctness without support.

## 6. Style guidance for difficult messages

When reporting failures, defects, or policy violations:

- State the issue directly.
- Describe the impact without dramatizing it.
- Identify the next corrective action when available.
- Avoid blame-oriented or emotionally charged wording.

When giving recommendations:

- Prefer imperative, concrete language.
- Explain the rationale briefly when it is not obvious.
- Avoid motivational language, sales language, or celebratory phrasing.

## 7. Examples

Preferred:

- The build failed during nullable analysis because `BridgeStateStore` introduces a new nullability warning.
- `I updated the instruction file and verified that the repository reports no new markdown errors in the changed file.`
- `This comparison is useful because the repository cache behaves as a boundary between Outlook data collection and RPC response shaping.`

Not preferred:

- `The build totally blew up.`
- `This fix is amazing and should solve everything.`
- `The cache is the beating heart of the system.`
- `Good news: the code is finally behaving.`

## 8. Final rule

When tone is uncertain, choose the more restrained phrasing.

The repository default is professionalism, clarity, and accuracy—not entertainment, flourish, or hype.
