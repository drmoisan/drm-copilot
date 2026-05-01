# Phase 0 — Policy Read Evidence

**Task:** P0-T1  
**Timestamp:** 2026-04-30T22:00  
**Branch:** feature/20260429090101-port-codex-skill

## Policy Files Read (in required order)

All four policy files were read from `.github/instructions/` and are loaded into execution context via AGENTS.md and instruction attachments.

### 1. `general-code-change.instructions.md`

**Key constraints noted:**
- 500-line limit for all production and test files.
- Bugfix workflow: smallest failing regression test first, then minimal fix.
- Toolchain loop order: format → lint → type-check → test; repeat until clean.
- No adding new dependencies without explicit approval.
- Separation of concerns: pure logic separate from I/O.
- Fail fast and explicitly; no broad catch-alls.
- After making changes: run full toolchain in exact order; may not stop while any step fails.

### 2. `general-unit-test.instructions.md`

**Key constraints noted:**
- Tests must be independent, isolated, fast, and deterministic.
- Repository-wide line coverage must remain ≥80%.
- New modules/classes/methods must target ≥90% coverage.
- No external dependencies (network, DB, filesystem temp files) in unit tests.
- Use of temporary files within tests is strictly prohibited.
- Arrange–Act–Assert pattern required.
- Descriptive test names.

### 3. `python-code-change.instructions.md`

**Key constraints noted:**
- Formatting: Black (default settings). Black wins on all diffs.
- Linting: Ruff with project configuration.
- Typing: Pyright; fully type-annotated, avoid `Any`.
- All public functions/methods/constructors must have full type hints.
- PEP 8 naming: `snake_case` functions/variables, `PascalCase` classes.
- Prefer `@dataclass` for value objects.
- Prefer `typing.Protocol` or `abc.ABC` for multiple implementations.
- Absolute imports within the project.
- No circular dependencies.
- Logging via standard `logging` module; no ad-hoc `print`.
- Suppressions require pre-authorized pattern or explicit user approval.

### 4. `python-unit-test.instructions.md`

**Key constraints noted:**
- Testing framework: Pytest.
- All new Python logic must be covered by Pytest tests.
- Use Pytest fixtures for common setup where it improves clarity.
- Descriptive `test_...` function names.
- Mocking only when needed for isolation/determinism.
- Temporary files prohibited.
- Run tests via `poetry run pytest`.

## Compliance Confirmation

- 500-line file limit: enforced for all files created/modified in this remediation.
- Coverage targets: section_intent.py ≥90%, intermediate_state.py ≥90%.
- No behavioral changes: public APIs of engine.py, models.py, reporting.py remain unchanged.
- No temporary files in tests.
- Full toolchain loop runs after each phase and in final QA.
