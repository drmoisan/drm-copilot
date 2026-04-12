---
paths:
  - "**/*.py"
description: Python-specific toolchain and coding standards derived from .github/instructions/python-code-change.instructions.md and .github/instructions/python-unit-test.instructions.md.
---

# Python Code Standards

This rule file summarizes the Python-specific policies for this repository. The authoritative sources are `.github/instructions/python-code-change.instructions.md` and `.github/instructions/python-unit-test.instructions.md`.

## Toolchain

1. **Formatting — Black**: All Python code must be formatted with Black (default settings). Command: `poetry run black .`
2. **Linting — Ruff**: Python code must pass Ruff using the project configuration. Command: `poetry run ruff check .` Suppressions require pre-authorization per `python-suppressions.instructions.md` or explicit user approval.
3. **Type Checking — Pyright**: All Python code must be fully type-annotated and pass Pyright. Avoid `Any` unless unavoidable and commented. Command: `poetry run pyright`
4. **Testing — Pytest**: All tests use Pytest. New logic must have test coverage >= 90%. Command: `poetry run pytest --cov --cov-report=term-missing`

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files.

## Coding Standards

- **PEP 8 naming**: `snake_case` for functions/methods/variables, `PascalCase` for classes/exceptions, `CONSTANT_CASE` for module constants.
- **Strong typing**: All public functions and methods must have full type hints for parameters and return values.
- **Dataclasses**: Prefer `@dataclass` for value objects. Use `frozen=True` where appropriate.
- **Protocols**: Use `typing.Protocol` or `abc.ABC` when multiple implementations are expected.
- **Imports**: Prefer absolute imports. Avoid circular dependencies.
- **Error handling**: Fail fast with specific exceptions. Avoid broad `except:` or `except Exception:` without context.
- **Logging**: Use the standard `logging` module. No ad-hoc `print` statements for permanent behavior.

## Testing Standards

- Use **Pytest** as the test runner.
- Write focused tests exercising a single function, method, or behavior.
- Follow Arrange–Act–Assert structure.
- Use descriptive `test_...` function names.
- Mock sparingly; prefer real code paths and pure functions.
- No external dependencies (network, filesystem temp files, external processes) in unit tests.
- Organize tests to mirror code structure (e.g., `tests/test_module_name.py` for `module_name.py`).
