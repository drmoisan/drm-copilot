<!-- harness-section: head -->

# Python Code Standards

This rule file summarizes the Python-specific policies for this repository.

<!-- harness-section: toolchain -->
## Toolchain

1. **Formatting — Black**: All Python code must be formatted with Black (default settings). Command: `poetry run black .`
2. **Linting — Ruff**: Python code must pass Ruff using the project configuration. Command: `poetry run ruff check .` Suppressions require pre-authorization per `python-suppressions.instructions.md` or explicit user approval.
3. **Type Checking — Pyright**: All Python code must be fully type-annotated and pass Pyright. Avoid `Any` unless unavoidable and commented. Command: `poetry run pyright`
4. **Testing — Pytest**: All tests use Pytest. Coverage thresholds are uniform across tiers per `.claude/rules/quality-tiers.md` (>= 85% line, >= 75% branch). Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files. Do not stop the loop until all four steps complete without errors in a single pass. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

If the environment prevents running tools, stop implementation and provide a plan and proposed diffs only, clearly marked **unverified**.

<!-- harness-section: coding-standards -->
## Coding Standards

- **PEP 8 naming**: `snake_case` for functions/methods/variables, `PascalCase` for classes/exceptions, `CONSTANT_CASE` for module constants.
- **Strong typing**: All public functions and methods must have full type hints for parameters and return values.
- **Dataclasses**: Prefer `@dataclass` for value objects. Use `frozen=True` where appropriate. Enforce invariants in `__post_init__` (dataclasses) or `__init__`.
- **Protocols**: Use `typing.Protocol` or `abc.ABC` when multiple implementations are expected.
- **Imports**: Prefer absolute imports. Avoid circular dependencies.
- **Error handling**: Fail fast with specific exceptions. Avoid broad `except:` or `except Exception:` without context. Reserve broad handlers for well-defined boundaries (CLI/entrypoints) with context logging.
- **Assertions**: Use `assert` only for internal sanity checks, not for user-facing validation.
- **Logging**: Use the standard `logging` module. No ad-hoc `print` statements for permanent behavior.

<!-- harness-section: python-design-rules -->
## Python Design Rules

### Small, cohesive modules

- Each class or module has one clear purpose. Avoid grab-bag utilities.
- Prefer explicit names and straightforward control flow.
- Keep the public surface area small. Internal helpers are `_prefixed` or live in `_internal` modules.

### Classes vs functions

Create a class when at least one of the following is true:

- A clear domain concept with data and behavior.
- State and invariants must travel together.
- Multiple implementations behind a common interface are expected.
- A multi-step workflow shares context across steps.

Create a standalone function when:

- The operation is pure, stateless, and simple.
- It is a small helper that does not naturally belong on a specific domain class.
- It is a simple transformation from inputs to outputs.

Keep methods small and focused. Avoid god objects that know about too many unrelated concerns. Avoid long, deeply branching functions; factor logic into smaller helpers.

### Strong typing by default (Pyright-clean)

- All public functions, methods, and constructors must have complete type hints.
- Avoid `Any`. If unavoidable, isolate it by wrapping untyped libraries behind small typed adapters.
- Use line-specific `# type: ignore[...]` only when justified with a brief comment.
- Prefer `typing.Protocol` (or `abc.ABC`) only when multiple implementations are expected.

### Dependency seams (testability without frameworks)

Introduce the smallest seam that enables reliable testing:

- Inject collaborators via constructor parameters (preferred).
- Accept optional callables with sensible defaults for time/randomness (for example, `clock: Callable[[], datetime] = datetime.now`).
- Extract boundary interactions into a tiny helper function and patch that helper in tests.

Do not introduce generic service-locator patterns or heavy dependency-injection frameworks.

<!-- harness-section: pytest-rules -->
## Pytest Rules

- Use **Pytest** as the test runner.
- One behavior per test. Follow Arrange–Act–Assert structure.
- Use descriptive `test_...` function names.
- Prefer behavioral assertions over implementation detail.
- Use `pytest.mark.parametrize` for boundary matrices.
- Fixtures should be narrow by default (function scope unless justified).
- Mock sparingly; prefer real pure code paths. Use `monkeypatch` for environment variables and module attributes.
- Patch at the **import location used by the unit under test**, not where a symbol originated.
- No sleeps, retries, or timing hacks.
- Organize tests to mirror code structure (for example, `tests/test_module_name.py` for `module_name.py`).
- No external dependencies (network, databases, external processes, runtime filesystem temp files) in unit tests.
- Line coverage must remain >= 85% across all tiers (T1–T4) per `.claude/rules/quality-tiers.md`.
- Branch coverage must remain >= 75% across all tiers (T1–T4).
- Coverage regression on changed lines is a blocking finding.
- Type-only modules with no executable behavior — for example `Protocol`-only modules consumed only under `TYPE_CHECKING` — may be omitted from coverage measurement. Such modules legitimately report 0% executable coverage. This is a clarification only; it does not lower any coverage threshold.

<!-- harness-section: prohibited-behaviors -->
## Prohibited Behaviors

- Broad refactors across multiple modules outside the approved scope.
- Adding new dependencies without explicit user instruction.
- Reducing typing strictness to make Pyright pass.
- Weakening tests to make them pass (removing assertions, overbroad exception checks).
- Using runtime temp files or external services in unit tests.
- Claiming success without running the toolchain.
<!-- harness-section: head-2 -->

# Python Code Change Policy

This policy **extends** `general-code-change.instructions.md` and applies to all **Python source, test, and script files** (`*.py`) in this repo.   

You must:

- Apply **all** rules in the general code change policy.
- Apply **all** Python-specific rules in this file.
- Apply the unit test policies (`general-unit-test.instructions.md` and `python-unit-test.instructions.md`) for any work involving tests.

If you encounter any conflicting instructions between these documents, **halt and notify the user.**

---

<!-- harness-section: 1-tooling-baseline-for-python -->
## 1. Tooling & Baseline for Python

These are the required tools for Python code in this repo:

1. **Formatting — Black**

   - All Python code must be formatted with **Black** (default settings).
   - Do not hand-format; if a diff disagrees with Black, Black wins.
   - Approved command: `poetry run black .`

2. **Linting — Ruff**

   - Python code must pass **Ruff** using the project’s configuration.
   - **Suppression Authorization** (see `python-suppressions.instructions.md`):
     - All `# noqa` suppressions must either:
       1. **Match a pre-authorized pattern** in `python-suppressions.instructions.md`, OR
       2. **Have explicit user approval** for that specific suppression
     - If you encounter a Ruff error that seems to require a suppression:
       1. First, attempt to resolve it without a suppression (refactor, restructure, use approved patterns)
       2. If that fails, try at least five more distinct approaches
       3. Continue iterating until you solve the problem or demonstrate why each approach fails
       4. Only after multiple documented failed attempts may you request user approval, providing:
          - The specific Ruff rule and error message
          - Each approach you tried and why it failed
          - Why a suppression is the only remaining option
   - Use **targeted, single-line** suppressions with required comment format from `python-suppressions.instructions.md`.
   - Approved command: `poetry run ruff check`

3. **Typing — Pyright**

   - Python code must be **fully type-annotated** and pass **Pyright**.
   - Avoid `Any` unless absolutely unavoidable. If `Any` is used, include a short comment explaining why.
   - **Suppression Authorization** (see `python-suppressions.instructions.md`):
     - All `# type: ignore` suppressions must either:
       1. **Match a pre-authorized pattern** in `python-suppressions.instructions.md`, OR
       2. **Have explicit user approval** for that specific suppression
     - If you encounter a Pyright error that seems to require a suppression:
       1. First, attempt to resolve it without a suppression (add proper types, use typed wrappers, refactor)
       2. If that fails, try at least five more distinct approaches
       3. Continue iterating until you solve the problem or demonstrate why each approach fails
       4. Only after multiple documented failed attempts may you request user approval, providing:
          - The specific Pyright error and diagnostic code
          - Each approach you tried and why it failed
          - Why a suppression is the only remaining option
   - **All custom Python code** (src, tests, scripts) must be type-checked.
   - Only exclude third-party packages without proper stubs (e.g., `tkinter`, `pandas`).
   - When using untyped third-party libraries:
     - Wrap usage in custom functions or classes with proper type hints.
     - Use **line-specific** `# type: ignore[...]` comments instead of excluding whole files or directories.
   - Approved command: `poetry run pyright`

> **Testing tools and behavior are defined in the unit test policies.** Do not define test behavior here; instead, obey `general-unit-test.instructions.md` and `python-unit-test.instructions.md`.

---

<!-- harness-section: 2-python-design-typing-principles -->
## 2. Python Design & Typing Principles

These refine the general design principles for Python code.

1. **Strong typing by default**

   - All public functions, methods, and class constructors must have full type hints for parameters and return values.
   - Internal helpers should also be annotated unless they are extremely trivial and short-lived.

2. **dataclasses and value objects**

   - Prefer `@dataclass` for value objects and simple data carriers.
   - Use `frozen=True` where appropriate to enforce immutability.
   - Keep dataclasses focused on representing data + invariants, not on performing orchestration.

3. **Protocols and abstract base classes**

   - Use `typing.Protocol` or `abc.ABC` when multiple implementations are expected (e.g., different corpus sources, stores, or pipelines).
   - Code should depend on these interfaces rather than concrete implementations where flexibility is important.

4. **Utility code**

   - Avoid static-method-only “utility” classes.
   - In Python, prefer modules with top-level functions for helpers and simple transforms.
   - If you need multiple interchangeable implementations, use protocols/ABCs + classes, not utility classes.

---

<!-- harness-section: 3-classes-functions-and-apis-python-specific-guida -->
## 3. Classes, Functions, and APIs (Python-Specific Guidance)

This section refines the general “classes vs functions” rules for Python. :contentReference[oaicite:4]{index=4}  

### 3.1 Classes for domain concepts and workflows

Use classes for:

- **Domain concepts** with data + behavior  
  - e.g. `QifTransaction`, `TextCorpus`, `ContactMatcher`, `CorpusPipeline`.
- **State + invariants** that must stay consistent  
  - e.g. a `ScoringModel` that must keep weights, vocabulary, and metadata in sync.
- **Multiple implementations behind a shared contract**  
  - e.g. `ITextSource` / `TextSourceProtocol` with `EpubTextSource`, `HttpTextSource`, etc.
- **Multi-step workflows** that share context  
  - e.g. a pipeline with `.download()`, `.normalize()`, `.index()`, `.export()`.

When using classes in Python:

- Prefer `@dataclass` for value objects.
- Keep methods small and focused; one conceptual responsibility per method.
- Avoid “God objects” that accumulate too many unrelated concerns.

### 3.2 Functions for small, pure helpers

Use standalone functions when:

- The operation is **pure, stateless, and simple**, for example:
  - `normalize_whitespace(text: str) -> str`
  - `slugify(title: str) -> str`
- It is a **small helper** that does not naturally belong on a specific domain class.
- It is a **simple transformation** from inputs to outputs.

Rules for Python helper functions:

- Fully annotate parameters and return types.
- Name functions by what they do (`parse_qif_file`, `compute_readability_score`).
- Keep functions short, readable, and low in branching; factor complex logic into smaller helpers.

---

<!-- harness-section: 4-error-handling-logging-and-contracts-python -->
## 4. Error Handling, Logging, and Contracts (Python)

These refine the general error-handling rules with Python-specific details.   

1. **Exceptions**

   - Fail **fast and explicitly** by raising clear, specific exceptions when invariants are violated.
   - Avoid broad `except:` clauses.
   - Avoid `except Exception:` unless you:
     - Immediately re-raise with added context, or
     - Are at a well-defined boundary (e.g., CLI entry point) and log the full context.

2. **Logging**

   - Use the project’s logging pattern, typically the standard `logging` module.
   - Do not add ad-hoc `print` statements for permanent behavior.
   - Log at appropriate levels (`debug`, `info`, `warning`, `error`) and include enough context to debug issues.

3. **Contracts / invariants**

   - Enforce invariants at construction time (`__init__` or `__post_init__` for dataclasses).
   - Use `assert` only for internal sanity checks, not for user-facing validation or recoverable errors.

---

<!-- harness-section: 5-module-file-structure-python -->
## 5. Module & File Structure (Python)

The general policy covers cohesion and file size; this section adds Python-specific structure rules.   

1. **Cohesive modules**

   - A module should have a clear purpose (e.g. “QIF parsing”, “scoring model”, “corpus download”).
   - Avoid “grab-bag” modules like `utils.py` that mix many unrelated concerns.

2. **Public vs internal**

   - Keep the public surface area **small and intentional**.
   - Use `_`-prefixed module members or `_internal` modules for code that should not be used outside the module/package.
   - Do not expose internal helpers via `__all__` unless strictly necessary.

3. **Imports**

   - Prefer **absolute imports** within the project (e.g. `from project.module import Thing`) instead of deep relative imports.
   - Avoid circular dependencies; if they appear, refactor shared logic into a lower-level module.

---

<!-- harness-section: 6-naming-docs-and-comments-python -->
## 6. Naming, Docs, and Comments (Python)

This section specializes the general naming/documentation rules for Python using PEP 8.   

1. **PEP 8 naming**

   - Use `snake_case` for functions, methods, and variables.
   - Use `PascalCase` for classes and exceptions.
   - Use `CONSTANT_CASE` for module-level constants.
   - Avoid cryptic abbreviations unless they are standard (`id`, `url`, `db`).

2. **Docstrings**

   - Public classes and methods should have a short docstring describing:
     - What it does.
     - Important arguments.
     - What it returns or any side effects.
   - Follow the prevailing docstring style in this repo (e.g., Google-style, NumPy-style, or simple one-paragraph docstrings).

3. **Comments**

   - Comment **why**, not what; the code should make the “what” clear.
   - For non-obvious patterns, workarounds, or `# type: ignore[...]` and `# noqa` uses, add a short comment explaining the reasoning.

---

<!-- harness-section: 7-dependencies-and-third-party-libraries-python -->
## 7. Dependencies and Third-Party Libraries (Python)

The general policy defines overall dependency rules; this section notes Python-specific expectations.   

- Prefer libraries with good type stubs (built-in or via `types-...` packages).
- Do not add new runtime dependencies casually; only add them when:
  - There is no reasonable standard-library or existing-dependency alternative, and
  - The library is well-maintained and widely used.
- When wrapping third-party libraries, hide them behind small, typed adapter functions or classes so the rest of the codebase depends on your interfaces, not the raw third-party APIs.






<!-- harness-section: head-3 -->
# Python Unit Test Policy

This policy **extends** `general-unit-test.instructions.md` and applies to all Python unit tests in this repo.

You must follow **both**:

- The general unit test policy, and
- The Python-specific rules below.

If there is any conflict between these documents, halt and notify the user.

---

<!-- harness-section: 1-framework-and-scope -->
## 1. Framework and Scope

- **Testing framework**
  - All Python unit tests must use **Pytest** as the test runner and framework.
- **Coverage expectation**
  - All new Python logic must be covered by Pytest tests that follow the general unit test policy.

---

<!-- harness-section: 2-test-style-and-structure-python -->
## 2. Test Style and Structure (Python)

- **Focused unit tests**

  - Write focused tests that exercise a single function, method, or behavior.
  - Prefer testing behavior directly over testing implementation details.
- **Mocking**

  - Use mocking sparingly. Prefer real code paths and pure functions where possible.
  - Only introduce mocks/stubs when needed to satisfy isolation and “avoid external dependencies” requirements (e.g., external services, heavy resources).
- **Organization**

  - Organize tests into modules and classes in a way that mirrors the code under test where practical (e.g., `tests/test_module_name.py` for `module_name.py`).
  - Use Pytest fixtures for common setup where it improves clarity and reduces duplication, while keeping fixture scope as narrow as possible.

---

<!-- harness-section: 3-naming-and-readability-python -->
## 3. Naming and Readability (Python)

- **Naming conventions**

  - Use descriptive `test_...` function names that clearly express the scenario and expected outcome.
  - Group related tests logically within the same file or test class.
- **Docstrings and comments**

  - Where the intent is not obvious from the name alone, include a short docstring or comment summarizing:
    - The scenario being tested.
    - The expected outcome.

---

<!-- harness-section: 4-respecting-the-toolchain-loop -->
## 4. Respecting the Toolchain Loop

- When running the “After Making Changes” toolchain loop from the general code change policy on Python work, your **testing step** must be performed with **Pytest**.
- Approved command: `poetry run pytest --cov=scripts/dev_tools --cov-report=term-missing`
- Do **not** substitute other test runners or frameworks for Python code unless explicitly instructed to do so.

This file defines **how** Python tests are written and structured; the general code change policy defines **when** the toolchain (including tests) must be run and how strictly that loop must be followed.






<!-- harness-section: toolchain-2 -->
## Toolchain

1. **Formatting — Black**: All Python code must be formatted with Black (default settings). Command: `poetry run black .`
2. **Linting — Ruff**: Python code must pass Ruff using the project configuration. Command: `poetry run ruff check .` Suppressions require pre-authorization per `python-suppressions.instructions.md` or explicit user approval.
3. **Type Checking — Pyright**: All Python code must be fully type-annotated and pass Pyright. Avoid `Any` unless unavoidable and commented. Command: `poetry run pyright`
4. **Testing — Pytest**: All tests use Pytest. New logic must have test coverage >= 90%. Command: `poetry run pytest --cov --cov-report=term-missing`

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files. Do not stop the loop until all four steps complete without errors in a single pass. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

If the environment prevents running tools, stop implementation and provide a plan and proposed diffs only, clearly marked **unverified**.

<!-- harness-section: pytest-rules-2 -->
## Pytest Rules

- Use **Pytest** as the test runner.
- One behavior per test. Follow Arrange–Act–Assert structure.
- Use descriptive `test_...` function names.
- Prefer behavioral assertions over implementation detail.
- Use `pytest.mark.parametrize` for boundary matrices.
- Fixtures should be narrow by default (function scope unless justified).
- Mock sparingly; prefer real pure code paths. Use `monkeypatch` for environment variables and module attributes.
- Patch at the **import location used by the unit under test**, not where a symbol originated.
- No sleeps, retries, or timing hacks.
- Organize tests to mirror code structure (for example, `tests/test_module_name.py` for `module_name.py`).
- No external dependencies (network, databases, external processes, runtime filesystem temp files) in unit tests.
- Repository-wide line coverage must remain >= 80%.
- Any new module, class, or method must reach >= 90% coverage.
- Coverage regression on changed lines is a blocking finding.

